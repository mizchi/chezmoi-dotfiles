# TypeScript Best Practices

## Principles

- Prefer standard library over external dependencies
- Avoid classes; use pure functions and separate state
- Keep functions idempotent

## Package Manager

Use pnpm unless package-lock.json exists:

```bash
pnpm install
pnpm add <package>
```

## Bundler

- Frontend: vite
- Library: tsdown

## Lint

Use oxlint (fast, Rust-based):

```bash
pnpm add -D oxlint
pnpm oxlint
```

See `assets/oxlint.json` for config example.

## Execution

Node.js 24+ runs TypeScript directly without flags:

```bash
node foo.ts
```

## Testing

Use vitest:

```bash
pnpm add -D vitest
```

```typescript
// foo.test.ts
import { expect, test } from 'vitest';
import { add } from './foo.ts';

test('add', () => {
  expect(add(1, 2)).toBe(3);
});
```

```bash
pnpm vitest
```

## Code Style

```typescript
// Good: pure function + separate state
type State = { count: number };

const increment = (state: State): State => ({
  ...state,
  count: state.count + 1,
});

// Avoid: class with mutable state
class Counter {
  count = 0;
  increment() { this.count++; }
}
```

## Prefer Standard APIs

```typescript
// Good: native fetch
const res = await fetch(url);
const data = await res.json();

// Good: native crypto
const id = crypto.randomUUID();

// Good: native URL
const url = new URL('/path', base);
```
