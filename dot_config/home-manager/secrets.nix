# 層1: 個人グローバル secret（sops-nix で管理）。
# 値は secrets/global.json（age 暗号文, commit 済み）にのみ存在し、ここは「参照宣言」だけ。
# private.nix の env 方式（nix store に平文を焼く）を置き換える。
{ ... }:
{
  sops = {
    # SSH ed25519 を ssh-to-age 経由で age 復号鍵として直接使う（age 専用鍵は作らない）。
    age.sshKeyPaths = [ "/Users/mz/.ssh/id_ed25519" ];

    defaultSopsFile = ./secrets/global.json;
    defaultSopsFormat = "json";

    # 各 secret は activation 時に復号され、nix store 外の 0400 ファイルに配置される。
    # zsh init から $(<path) で読んで export する（common.nix 側）。
    secrets = {
      MNEMO_ACCESS_CLIENT_ID = { };
      MNEMO_ACCESS_CLIENT_SECRET = { };
      MNEMO_API_TOKEN = { };
    };
  };
}
