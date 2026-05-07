# Recommended Branch Protection Settings

To keep `main` stable and enforce CI checks, set these branch protection rules in the GitHub repository settings (Settings → Branches → Add rule):

- Branch name pattern: `main`
- Require pull request reviews before merging: **ON**
  - Require approving reviews: 1 (or more for larger teams)
  - Require review from Code Owners: **ON** (enabled by `CODEOWNERS`)
- Require status checks to pass before merging: **ON**
  - Select the CI checks you want to require (the `CI` workflow in `.github/workflows/ci.yml`)
- Require branches to be up to date before merging: **ON**
- Include administrators: optional (recommended to be ON if you want consistent enforcement)

Notes:
- After adding the rule, GitHub will enforce the checks and require PRs to pass CI and reviews before merging.
- If you enable required status checks, make sure the names match the job names in the workflow (Lint, Unit tests, Integration tests, etc.).
