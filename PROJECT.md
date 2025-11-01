# dotfiles – Zorin OS Dev Environment

This project is meant to automate the setup of a **fresh Zorin OS** machine so I don’t have to repeat the same manual steps after installing the system.

The goal is: **one command → full dev environment**.

---

## 1. Context

- I will format my computer and keep **only Linux (Zorin OS)**.
- I want to test the scripts first in a **VM / container** before running them on the real machine.
- I want this repo to be **AI-friendly**, so an AI agent (ChatGPT, Claude, etc.) can read this file and help me generate new scripts, improve them, or fix problems.

---

## 2. Objectives

1. **Bootstrapable**: a single script (e.g. `bootstrap.sh`) that I can curl/wget and run on a fresh Zorin OS.
2. **Idempotent**: running the script twice must NOT break the system (check before installing).
3. **Zorin-first**: Zorin is Ubuntu-based, so we will start with `apt` and standard Ubuntu repos.
4. **Developer-ready**: install the tools I use most often (git, node, docker, editor, zsh, etc.).
5. **Personalized**: apply my dotfiles (shell, aliases, git config).
6. **Documented**: keep small markdown docs in `docs/` so the AI can read context.

---

## 3. High-level flow

1. Fresh Zorin OS
2. Open terminal
3. Run:
   ```bash
   curl -s https://raw.githubusercontent.com/<USER>/dotfiles/main/bootstrap.sh | bash
   ```
