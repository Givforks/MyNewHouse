# VS Code Settings Sync — How to save & restore your environment

1. Turn on Settings Sync in VS Code:
   - Open Command Palette → `Settings Sync: Turn On`
   - Sign in with GitHub or Microsoft and allow sync access
   - Choose to sync `Settings`, `Keybindings`, `Snippets`, `Extensions`, and `UI State`.

2. Keep a copy of workspace templates in this folder:
   - `.eslintrc.json`, `.prettierrc.json`, `.lintstagedrc.json`, `.vscode/` etc.
   - Commit this folder to a private Git repo (recommended) or a GitHub Gist for backup.

3. To restore on another machine or after reinstall:
   - Sign in and enable Settings Sync in VS Code
   - Clone this repo/folder and run `./init_project.sh /path/to/new/project` to copy templates
   - Run `npm install` in your new project and `npm run prepare` to enable Husky hooks

4. Security notes:
   - Do NOT commit secrets or `.env` files. Add `.env` to `.gitignore`.

5. Optional: Use a dotfiles repo or GitHub Gist for global templates and import them into VS Code Settings.

Current Settings Sync Gist:
- https://gist.github.com/Givforks/c145ab5820514017458ffbb25ed81269

Repository protection status:
- Branch protection is enabled on `main` for `Givforks/MyNewHouse`.

That's it — once Settings Sync is on and this folder is in a remote repo, you can sign into VS Code and recover your environment quickly.
