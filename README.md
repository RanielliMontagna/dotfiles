# dotfiles (Zorin OS)

Automated setup for a fresh **Zorin OS** machine. The idea is to run **one command** after installing the OS and get your full development environment ready (CLI tools, shell config, Node.js, Docker, editors, etc.).

> Zorin-first: since Zorin is Ubuntu-based, everything here starts with `apt`.

---

## Features

- 🐧 Zorin/Ubuntu friendly
- 🔁 Idempotent (safe to run more than once)
- 🧰 Installs basic CLI tools (git, curl, build tools)
- 🐚 Shell setup (zsh + dotfiles)
- 🟦 Node.js via nvm
- 🐳 Docker (optional script)
- 📦 Structured by scripts (`scripts/NN-name.sh`)
- 🤖 AI-friendly docs (`project.md`)

---

## Quick start (recommended way)

```bash
git clone https://github.com/<USER>/dotfiles.git
cd dotfiles
bash bootstrap.sh
```
