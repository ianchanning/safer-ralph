# Advanced

This document covers power-user configurations and features for Safer Ralph.

## Global Installation
Make `sandbox.sh` available for other projects by linking it to your local bin:

```bash
# Link to your local bin
mkdir -p ~/.local/bin
ln -s "$(pwd)/sandbox.sh" ~/.local/bin/sandbox.sh

# Ensure ~/.local/bin is in your PATH
export PATH="$HOME/.local/bin:$PATH"
```

## Templates

Snapshot a sandbox to reuse its state later.

### Save a Template
```bash
./sandbox.sh save ID [MY-TEMPLATE]
```
If `MY-TEMPLATE` is omitted, it auto-detects the repository name from the workspace.

### Use a Template
```bash
./sandbox.sh create [MY-TEMPLATE] [NEW-ID]
./sandbox.sh up NEW-ID [MY-TEMPLATE]
```
If `MY-TEMPLATE` is omitted, the script defaults to the base image or auto-detects a matching repository template.

### Auto-Selection
Commands like `./sandbox.sh go <repo_url>` and `./sandbox.sh up <id>` will automatically check for a Docker image matching the repository name and use it if found.

Useful for freezing environments after heavy dependency installs or manual configuration.
