# Ripgrep Find Helper (rgf)

A simple wrapper script for the excellent `ripgrep` (`rg`) tool to provide a consistent, powerful search experience.

## Features

- Recursively searches for a text pattern in a specified path (or the current directory by default).
- Uses a default set of `ripgrep` options for readable output (line numbers, headings, case-insensitivity).
- Allows for the default options to be easily customized via a configuration file.

## Dependencies

- `ripgrep` (`rg`): Must be installed. On Debian/Ubuntu, use `sudo apt install ripgrep`.

## Setup (Optional)

The default search options are `--heading --line-number --ignore-case --color=always`. To change these defaults, you can create a custom configuration file.

1.  Create the configuration directory:
    ```bash
    mkdir -p ~/.config/rgf_helper
    ```
2.  Copy the example template to that directory:
    ```bash
    cp config.example ~/.config/rgf_helper/config
    ```
3.  Edit `~/.config/rgf_helper/config` and set your preferred `ripgrep` options.

## Usage

```bash
# Search for "my_variable" in the current directory and subdirectories
rgf "my_variable"

# Search for "my_function" inside the ~/my_linux_setup/remind_me directory
rgf "my_function" ~/my_linux_setup/remind_me
```
