# Secrets Management

This directory contains resources related to managing secrets (API keys, passwords, tokens) securely within your development environment. Storing secrets in plaintext configuration files is risky. A more secure and modern approach is to use a command-line interface (CLI) for a dedicated secrets manager.

## Why Use a CLI Secrets Manager?

- **Enhanced Security**: Secrets are never stored on disk in plaintext. They are fetched on-demand from your encrypted vault.
- **Centralized Management**: All your secrets are in one place, making them easier to rotate and manage.
- **Portability**: Your scripts can run on any machine where you've authenticated with your secrets manager, without needing to copy config files.

## Recommended Tools

- **1Password CLI**: If you use 1Password, its CLI (`op`) is excellent. The `install_routines/80_1password_cli.sh` script handles its installation.
- **Bitwarden CLI**: A great open-source alternative.

### Example Usage (1Password CLI)

Instead of sourcing a key from a file:
`source ~/.config/remind_me/config`

You would fetch the key directly in your script:
`API_KEY=$(op read "op://your-vault/your-item/api-key")`

This approach significantly improves the security and maintainability of your automated workflows.
