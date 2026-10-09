
# Global notes

## Python

- Always use the version produced by `/usr/bin/python3 --version` as the project version.
- Always use uv to manage dependencies.
- Always use the latest version of PyTorch (`curl -s https://pypi.org/pypi/torch/json | jq -r '.info.version'`) with the highest available CUDA version.

## Images

- You can display images to the user with `xdg-open <path>`.
- When the user says "show me", "display", or similar about an image, open it with `xdg-open`.

## Sudo Access

- If something requires admin/sudo access, do not ask the user to paste their password into chat. Instead use `pw=$(zenity --password --title="<brief reason>")` — it pops up a password dialog on the user's desktop.
- If a later sudo need is materially different from the original task, ask again with a fresh zenity invocation rather than reusing the old password.
- A non-zero exit means the user cancelled: stop immediately.

## Dotfiles

- The user's dotfiles are located in `~/.local/src/dotfiles/`.
