# Testing Stages

This project template supports three testing stages; copy these into new projects and implement tests accordingly.

1) Unit tests
  - Fast, isolated tests for functions and modules.
  - Located under `tests/unit/`.
  - Run with `npm run test:unit`.

2) Integration tests
  - Tests that involve external services (DBs, message queues).
  - Located under `tests/integration/`.
  - Run with `npm run test:integration`.
  - CI runs a Mongo service by default; adapt to your stack.

3) End-to-end (E2E)
  - Full-system tests against a running environment.
  - Located under `tests/e2e/`.
  - Run with `npm run test:e2e`.

CI will run these stages sequentially: lint -> unit -> integration -> e2e.

Tips:
- Keep unit tests fast and deterministic.
- Tag slow integration tests and run them in nightly pipelines if needed.
- Use test containers or services in GitHub Actions for DB dependencies.
