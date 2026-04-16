---
name: gleam-practice
description: Best practices for building and reviewing Gleam projects on the Erlang target, especially Wisp plus Mist web services, OTP processes, justfile workflows, testing, formatting, CI, and performance measurement.
---

# Gleam Practice

Gleam を新規作成するとき、既存プロジェクトを改善するとき、`wisp + mist + gleam_otp + just` 構成で実装するときに使う。

## Default Workflow

- まず `gleam new` と `gleam add` を使う。依存は手書きより solver に決めさせる。
- TDD で進める。`探索 -> Red -> Green -> Refactor`。
- 純粋ロジックと状態管理を分ける。domain module と actor/server module を分離する。
- 公開 API は小さく保つ。外部からコンストラクタへの直接アクセスを防ぎたいときは `pub opaque type` を使う。ただし積極的に使われるケースは多くなく、test との兼ね合いで判断する。
- `@external` は最後の手段。使う場合は薄い adapter module に閉じ込める。
- web 層は薄くする。`wisp` handler は decode, call service, encode response に寄せる。
- タスク実行は `justfile` に集約し、CI も `just ci` を叩く。

## Project Setup

Erlang target の新規 project はこれを起点にする。

```sh
gleam new my_app --template erlang
cd my_app
gleam add wisp mist gleam_otp gleam_erlang
gleam add gleam_json envoy
gleam add --dev gleeunit
```

必要に応じて追加する。

- HTTP client: `gleam add gleam_http gleam_httpc`
- file I/O: `gleam add simplifile filepath`
- snapshot test: `gleam add --dev birdie`
- property test: `gleam add --dev qcheck qcheck_gleeunit_utils`
- interactive test loop: `gleam remove gleeunit && gleam add --dev glacier`
- unused export check: `gleam add --dev cleam`
- benchmark: `gleam add --dev glychee`
- logging config: `gleam add logging`
- live reload DX: `gleam add --dev olive`

外部 CLI:

- HTTP load test: `k6`

`wisp` と `mist` は互換性のある組み合わせを使う。version を個別に固定するより、`gleam add wisp mist` を同じタイミングで解決させる方が安全。

雛形:

- `assets/README.md`
- `assets/justfile`
- `assets/github-actions/ci.yml`
- `assets/bench/http.js`
- `assets/test/snapshot_test.gleam`
- `assets/test/property_test.gleam`
- `assets/test/qcheck_parallel_test.gleam`
- `assets/test/timeout_test.gleam`

## gleam.toml Defaults

最低限これを埋める。

```toml
name = "my_app"
version = "0.1.0"
target = "erlang"
description = "Short package summary"
licences = ["Apache-2.0"]
repository = { type = "github", user = "owner", repo = "repo" }

# Package 内だけで使う module は隠す
internal_modules = [
  "my_app/internal",
  "my_app/http/internal",
]
```

原則:

- metadata を空のまま放置しない
- package 内専用 module は `internal_modules` で隠す
- broad な semver range は許容されるが、CI で必ず固定 lockfile を通す

## Recommended Layout

最初はこの分け方から始める。

```text
src/
  my_app.gleam                # entrypoint
  my_app/app.gleam            # DI と supervision 起動
  my_app/web.gleam            # router / request handling
  my_app/domain.gleam         # pure domain logic
  my_app/domain_server.gleam  # actor wrapper
  my_app/http_json.gleam      # encoder / decoder
test/
  my_app_test.gleam
docs/
  reference-ja.md
  reference-en.md
bench/
  main.gleam
justfile
```

分離の基準:

- `domain.gleam`: pure function のみ
- `*_server.gleam`: actor / supervision / timeout / mailbox
- `web.gleam`: routing と HTTP mapping
- `http_json.gleam`: JSON schema と codec（エンコーダー/デコーダーは LSP の Code Action で生成できる）
- `app.gleam`: wiring のみ

1 file に router, JSON codec, business logic, actor state を混ぜない。

大きくなったらこう分ける。

- `web_*.gleam`: feature ごとの handler
- `web_json_*.gleam`: domain ごとの encoder / decoder
- `agent_*.gleam`: protocol, runner, tool, transport
- `workspace_*.gleam`: overlay, patch, git, session, runtime
- `*_test_support.gleam`: test helper を責務ごとに分離

## Wisp + Mist Skeleton

`src/my_app.gleam`

```gleam
import envoy
import gleam/erlang/process
import gleam/int
import gleam/result
import mist
import my_app/app
import my_app/web
import wisp/wisp_mist

const default_port = 4000
const default_secret_key_base =
  "local-dev-secret-key-base-local-dev-secret-key-base-1234567890"

pub fn main() -> Nil {
  let port =
    envoy.get("PORT")
    |> result.map(int.parse)
    |> result.flatten
    |> result.unwrap(default_port)

  let secret_key_base =
    envoy.get("SECRET_KEY_BASE")
    |> result.unwrap(default_secret_key_base)

  let assert Ok(app_state) = app.start()
  let assert Ok(_) =
    web.app(app_state)
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(port)
    |> mist.start

  process.sleep_forever()
}
```

`src/my_app/web.gleam`

```gleam
import gleam/http
import my_app/app.{type App}
import wisp

pub fn app(app: App) -> fn(wisp.Request) -> wisp.Response {
  fn(request) {
    case request.method, wisp.path_segments(request) {
      http.Get, ["healthz"] -> wisp.text_response(200, "ok\n")
      _, _ -> wisp.not_found()
    }
  }
}
```

web 層の原則:

- `wisp.require_json` で payload を読む
- decoder 失敗は `400`
- domain error は `4xx/5xx` へ明示的に map する
- handler は大きくなったら feature ごとに分割する

## OTP Pattern

**重要**: `gleam_otp` の Actor は Erlang の `gen_server` に静的型付けを加えたものだが、インターフェースは互換性がない。Supervisor も `static`, `factory`, `dynamic` と細分化されている。詳細は公式ドキュメントを参照: https://hexdocs.pm/gleam_otp/

基本は `pure state` と `server` の 2 層。

```gleam
// pure state
pub opaque type State

pub fn new() -> State
pub fn apply(state: State, command: Command) -> Result(State, Error)
```

```gleam
// actor wrapper
pub opaque type Server
pub opaque type ServerName

pub fn start() -> Result(Server, actor.StartError)
pub fn start_named(name: ServerName) -> Result(Server, actor.StartError)
pub fn from_name(name: ServerName) -> Server
pub fn supervised(name: ServerName) -> supervision.ChildSpecification(Server)
```

指針:

- `Server` は opaque にする（外部から Subject を直接操作させない）
- HTTP から state を直接触らない
- supervision tree は `app.gleam` に集める
- Supervisor の種類を使い分ける: `static`（固定子プロセス）、`factory`（引数付き生成）、`dynamic`（動的追加）
- restart strategy はまず `OneForOne`
- test しやすくするため named actor を使う

## justfile Template

再利用するなら、まず `assets/justfile` を project root にコピーしてから微調整する。

```just
set shell := ["bash", "-cu"]

default:
  @just --list

deps:
  gleam deps download

format:
  gleam format

format-check:
  gleam format --check .

typecheck:
  gleam check

build:
  gleam build --warnings-as-errors

test:
  gleam test

run:
  gleam run

docs:
  gleam docs build

check:
  gleam format --check .
  gleam check
  gleam build --warnings-as-errors
  gleam test

ci: deps check

clean:
  gleam clean

bench *args:
  gleam run -m bench/main -- {{args}}
```

方針:

- shell は `bash`
- CI の入口は `just ci`
- `lint` 専用コマンドは作らず、`format-check + build --warnings-as-errors` で閉じる

必要ならこれも足す。

- `exports: gleam run -m cleam`
- `snapshot-review: gleam run -m birdie`
- `test-watch: gleam test -- --glacier`
- `bench-http: k6 run bench/http.js`
- `serve-dev: gleam run -m olive`

## CI Workflow Template

GitHub Actions を使うなら、まず `assets/github-actions/ci.yml` を `.github/workflows/ci.yml` にコピーしてから project 固有の step だけ足す。

原則:

- CI も local も `just ci` を唯一の入口にする
- Erlang / Gleam version は workflow 側で固定する
- `@external`, NIF, Wasm, Elixir 依存がある場合だけ追加 toolchain を足す
- workflow で shell script を増やしすぎず、処理は `justfile` 側へ寄せる

## Testing

まず pure function を固定し、そのあと actor、最後に HTTP を固定する。

`test/my_app_test.gleam`

```gleam
import gleam/http
import gleeunit
import my_app/app
import my_app/web
import wisp/simulate

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn healthz_test() {
  let assert Ok(app_state) = app.start()
  let response = web.app(app_state)(simulate.request(http.Get, "/healthz"))

  assert response.status == 200
  assert simulate.read_body(response) == "ok\n"
}
```

テスト方針:

- pure module は state transition を直接 test
- actor module は public API だけ test
- HTTP test は `wisp/simulate` を優先
- 外部 API は fake service を注入する
- flaky な sleep ではなく poll/retry helper を使う
- snapshot が効く出力には `birdie`
- property-based test が効く pure logic には `qcheck`
- ローカルの反復速度が欲しいときは `glacier`

`birdie` の基本 workflow:

1. `gleam test`
2. failing / new snapshot を確認
3. `gleam run -m birdie`
4. snapshot を review して commit

`qcheck` の基本 workflow:

1. pure function の性質を 1 つ決める
2. `qcheck.given(...)` で generator を流す
3. 反例が出たら shrink 結果をもとに unit test へ落とし込む
4. 長い test や並列実行が必要なら `qcheck_gleeunit_utils` を使う

`qcheck_gleeunit_utils` の注意:

- Erlang target 専用
- 全 test をまとめて並列化したいなら `run.run_gleeunit`
- 長い test を 1 本だけ包みたいなら `test_spec.make`
- custom timeout を付けたいなら `test_spec.make_with_timeout`
- test group を明示したいなら `test_spec.run_in_parallel` / `run_in_order`

## Test Structure

feature が増えたら test file を責務で割る。

- `domain_test.gleam`: pure domain logic
- `runtime_test.gleam` / `app_test.gleam`: supervision と actor integration
- `web_app_test.gleam`: HTTP contract
- `agent_test.gleam`: external API orchestration
- `workspace_session_server_test.gleam`: server / state helper
- `workspace_session_http_test.gleam`: session API の contract
- `workspace_bit_runtime_test.gleam`: FFI / git / wasm integration

support module も分ける。

- `*_app_test_support.gleam`: app 起動、handler 作成、runtime helper
- `*_workspace_test_support.gleam`: fixture directory、workspace helper

1つの巨大な test file に全部詰め込まない。refactor が進んだら test も一緒に分割する。

## Lint and Quality

Gleam には first-party の独立 lint tool より、formatter と compiler warning を厳格に使う方が合う。

最低限:

- `gleam format --check .`
- `gleam check`
- `gleam build --warnings-as-errors`
- `gleam test`

補助:

- deprecated API の追従: `gleam fix`
- docs の確認: `gleam docs build`
- unused export の検出: `gleam run -m cleam`

## Performance Measurement

計測は 3 段でやる。

1. pure function の micro benchmark
2. actor / workspace の integration benchmark
3. HTTP endpoint の load test

原則:

- benchmark 対象は pure function と I/O を分ける
- warmup と measurement を分ける
- debug log を切る
- benchmark 前に `gleam clean` と依存 download を済ませる
- micro benchmark の結果と HTTP 負荷試験の結果を同列に比較しない
- FFI / Wasm / Port は cold start と hot path を分けて測る

手段:

- micro benchmark: `bench/` module を作って `gleam run -m bench/main`
- library を入れるなら `glychee` を使う
- HTTP load test: `k6` か `wrk`
- BEAM hotspot: `erl` / `gleam shell` から `:eprof`, `:fprof`, `:erlang.statistics(:reductions)` を使う

HTTP の最小測定例:

```sh
just run
k6 run bench/http.js
```

最初は `assets/bench/http.js` を `bench/http.js` にコピーして使う。

## FFI and Native Integration

`@external` を使うときは次を守る。

- adapter module を 1 枚作る
- `pub opaque type Handle` だけ公開する
- Erlang/Elixir の型や pid を外に漏らしすぎない
- path, ETS, NIF, Port, Wasm runtime の詳細は internal module に閉じ込める
- live test と failure test を両方書く

`@external` 実装は compiler が検証しないので、Gleam 側の surface area を最小にする。

## Additional Tools

よく使う外部ツールの位置づけはこう考える。

- `gleeunit`: 基本の unit test runner。まずこれ。
- `birdie`: snapshot test。HTTP response や generated text の固定に向く。
- `qcheck` + `qcheck_gleeunit_utils`: property-based test。pure domain logic に向く。
- `glacier`: interactive / incremental test loop。`gleeunit` の drop-in replacement として使う。
- `cleam`: 未使用 export の検出。公開 API の掃除に向く。
- `glychee`: micro benchmark。pure function や small integration の比較に向く。
- `k6`: HTTP / websocket 負荷試験。Gleam package ではなく外部 CLI。
- `logging`: Erlang logger 設定。運用寄り project なら入れてよい。
- `olive`: live reload 付き dev proxy。Wisp/Mist 開発体験を上げたいときだけ使う。

使い分け:

- default は `gleam format/check/build/test`
- 追加で入れる第一候補は `birdie`, `qcheck`, `cleam`, `glychee`
- `glacier` と `olive` は local DX を上げたいとき
- `logging` は long-running service や production app 向け

## Documentation

README には少なくともこれを書く。

- 何が実装済みで、何がまだ非対象か
- 主要 module prefix と責務
- 起動方法、`just ci`、主要 endpoint
- test file の見方

中規模以上の project では `docs/` を置き、読む順番を案内する。

- `docs/reference-ja.md`: 日本語向けの実装ガイド
- `docs/reference-en.md`: 英語向けの実装ガイド

この project が「入門用」なのか「実践的な参照実装」なのかを README 冒頭で明示する。

## Reference Project Positioning

Gleam project を参照実装として見せるなら、位置づけを曖昧にしない。

- beginner sample: 小さい API と最小の OTP だけ
- medium reference: `wisp + mist + gleam_otp + just + CI + docs`
- advanced integration: FFI, Wasm, external LLM, workspace/session orchestration

高度な題材を入れる場合は、「これは一般的な Gleam の書き方」なのか「この project 固有の複雑さ」なのかを分けて説明する。

## Closure Checklist

一旦仕上げる区切りはこのあたり。

- public / internal の境界が整理されている
- `just ci` が green
- test file が feature 単位に分かれている
- support module が責務ごとに分かれている
- README に実装状況と test 構成が書かれている
- 必要なら `docs/` に参照ガイドがある

## Review Checklist

- 公開 constructor は本当に必要か
- 公開 API でコンストラクタ直接アクセスを防ぎたい型に `pub opaque type` を使っているか（ただし過剰に使わない）
- `internal_modules` に隠すべき module はないか
- web 層が decode/call/encode 以上のことをしていないか
- pure logic と actor state が混ざっていないか
- `just ci` が local と CI の共通入口になっているか
- `gleam build --warnings-as-errors` を通しているか
- absolute path や machine-local config を埋めていないか
- external/FFI 境界が広すぎないか

## Gleam Tips (2025 時点)

- **名前空間のマージ**: パッケージの `src/` は単一の名前空間にマージされる。同名 module が衝突する場合は `import hoge/piyo/module as piyo_module` で回避する。
- **`gleam dev` コマンド** (Gleam 1.11+): `dev/` ディレクトリの `main()` を実行する。開発スクリプトがパッケージに含まれない。
- **プロジェクト命名規則**: `gleam_` prefix は公式パッケージ用。小文字・数字・underscore のみ。先頭に `_` や数字は不可。
- **Config パターン**: record update syntax でフルエントな設定 API を作れる。label shorthand も活用する (`Config(..config, foo:)`)。
- **`fold` vs `reduce`**: `fold` は初期値を受け取り空リストにも対応。`reduce` は空で失敗する。`fold` を優先する。
- **guard clause**: case の guard では関数呼び出しができない。事前に評価して `case thing, func(val) { ... }` の形にする。
- **エンコーダー/デコーダー**: LSP の Code Action で自動生成できる。手書きする前に試す。

## References

- Gleam docs: https://gleam.run/
- Gleam `gleam.toml`: https://gleam.run/writing-gleam/gleam-toml/
- Gleam externals: https://gleam.run/documentation/externals/
- Gleam CLI: https://gleam.run/reference/cli/
- Wisp docs: https://hexdocs.pm/wisp/
- Mist docs: https://hexdocs.pm/mist/
- gleam_otp docs: https://hexdocs.pm/gleam_otp/
- just manual: https://just.systems/man/en/
- Gleam tips (2025): https://zenn.dev/comamoca/scraps/07e2855c032a85
