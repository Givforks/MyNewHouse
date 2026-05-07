# Contributing & CI

This repository contains templates and recommended CI/testing stages for your projects. Use the GitHub Actions workflow in `.github/workflows/ci.yml` as a starting point for new projects.

Recommended branch flow:
- `main` — production-ready, protected
- `develop` — integration branch
- feature branches named `feat/<name>`

Please open pull requests for changes; CI will run lint and tests automatically.
