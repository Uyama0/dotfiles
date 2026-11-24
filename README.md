# Uyama dotfiles

## Before handing over the old Mac

Run `make doctor` for read-only checks. Warnings return a nonzero exit status.

1. Save and push changes in this repo. **`work/` is ignored here**: save it
   separately in a private repository, or transfer the whole directory privately.
   An uncommitted work repository without a remote cannot be restored by cloning.
2. Copy `~/.secrets.zsh` privately. `make secrets` only creates an empty template;
   work variables are documented in `work/secrets/secrets.example.zsh`.
3. Transfer the local state below through an encrypted backup or private transfer.
   Keep the old laptop/backup until the new one can access GitLab, Jira and clusters.

| Local state outside this repo | What to restore |
|---|---|
| `~/.ssh/` | SSH config, keys if present; keys may also live in Keychain/hardware |
| `~/.kube/`, `~/.config/rclone/` | Cluster contexts and storage remotes; reauthenticate where required |
| `~/raiffeisen-ca.pem`, `~/Documents/raif_cert.cer` | Both paths are referenced by work configs; restore both |
| `~/.gitlab-token`, `~/.continue/` | GitLab token and Continue configuration |
| `~/.codex/`, `~/.agents/` | Local settings, skills, rules and history; close the app before backing up SQLite state |
| `~/.claude.json`, `~/.claude/` | MCP registrations, plugins, skills and local state beyond the tracked files |
| `~/.config/opencode/`, `~/.config/kilo/`, `~/.kimi/` | Other AI tools' local configuration, if used |
| Projects, `~/Documents/`, Obsidian vaults | Local changes, untracked files, notebooks and other working data |
| Docker volumes and local databases | Export needed data separately; `daemon.json` only transfers settings |

These directories can contain credentials: do not add them to the public repo.
Browser profiles/bookmarks and password manager/Keychain access also need sync or
migration. Corporate VPN, MDM and certificates may require enrollment on the new Mac.

## New Mac setup

```sh
xcode-select --install                       # wait for installation to finish (git + make)
mkdir -p ~/Desktop/projects
git clone https://github.com/Uyama0/dotfiles ~/Desktop/projects/dotfiles
cd ~/Desktop/projects/dotfiles

make brew      # Homebrew + everything from Brewfile (log into App Store first for mas apps)
make secrets   # creates ~/.secrets.zsh from template — fill in the values
make links     # symlink configs into $HOME (existing files are moved to *.backup)
make node      # node via nvm + global npm packages (claude-code, claude-code-router, ...)
make vscode    # VS Code extensions
make macos     # Dock / Finder / trackpad settings
# Restore work/ and the private files listed above BEFORE make work.
# Restore ~/.secrets.zsh instead of relying on the empty template.
make work      # work layer (see below)
make doctor    # final local readiness checks
```

`make all` does everything above except `work`, `make help` lists commands,
`make dump` shows what is installed on this Mac but missing in the repo.
Installation needs internet and may prompt for administrator access. Sign into
the App Store first for Pages/Windows App. Run `make work` after `make node`;
the work setup loads nvm itself so it also works before reopening Terminal.

Before applying links, compare the old `~/.zprofile` with `zsh/zprofile` and the
work layer: a regular local profile is not automatically included in Git.
Existing configs are saved as `.backup`, `.backup.1`, etc. Restore private state
before applying links so tracked configs are applied last.

After setup, open a new terminal and verify `node -v`, `java -version`,
`claude --version`, `codex --version`, `kubectl config get-contexts`, plus GitLab
and Jira access over the corporate network. Test a normal project build.

## What's inside

| Folder | Goes to |
|---|---|
| `zsh/` | `~/.zshrc`, `~/.zprofile` (+ `aliases.zsh`) |
| `git/` | `~/.gitconfig`, `~/.config/git/ignore` |
| `ghostty/` | `~/.config/ghostty/config` |
| `vscode/` | `settings.json`, `extensions.txt` |
| `claude/` | `~/.claude/` settings, CLAUDE.md, RTK.md |
| `k9s/`, `docker/` | k9s aliases/config, docker `daemon.json` |
| `node/` | node version + global packages |
| `macos/` | `defaults write` settings |
| `secrets/` | `secrets.example.zsh` — template for `~/.secrets.zsh` |

## Work layer

Work-specific config lives in `work/` — a separate private repo, ignored here.
Personal configs pick it up if present:

- `~/.zshrc` / `~/.zprofile` source `~/.zshrc.work` / `~/.zprofile.work`
- `~/.gitconfig` includes `~/.gitconfig.work` (user identity)

`make work` installs `work/Brewfile`, links `work/**/*.link`, registers MCP servers.

## Secrets

All tokens/passwords live in `~/.secrets.zsh` (chmod 600, outside the repo),
sourced from `~/.zprofile`. Configs reference them as `$VAR` / `${VAR}`.
Move this file to the new Mac manually (password manager, AirDrop) — never commit it.

## Manual steps on a new Mac

- SSH keys (`~/.ssh/id_*`) — copy or generate new ones
- keyboard layouts

## Adding a new config

Put the config into its own folder and add a `*.link` file next to it:

```
$DOTFILES/<folder>/<file>=$HOME/<target path>
```

Then run `make links` (or `make work` for files under `work/`).
