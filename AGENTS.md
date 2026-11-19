# Repository instructions

## Running tests

- Always run tests through `make`, never invoke `elm-test`, Playwright, or other test runners directly.
- For a focused check, use the matching Make target, such as `make elm_test`, `make e2e_test`, or `make test_openspec`.
- To run the full test suite, use `make all_test` (or its alias `make test_all`).

## Changelog

- The project maintains a `CHANGELOG.md` file at the repository root.
- After completing every task (feature, fix, refactor, etc.), append a short entry to `CHANGELOG.md` describing what was done.
- Use the following format:

```
## [YYYY-MM-DD] <Short title>

- <One-line description of the change>
```

- If `CHANGELOG.md` does not exist yet, create it with a `# Changelog` heading first.
- Keep entries concise — one to three bullet points per task is enough.
- Do not modify previous entries.
