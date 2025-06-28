# Shell Theming

This directory contains theme files for command-line tools.

## `poshthemes/`

This folder holds the JSON theme files for **Oh My Posh**, the tool used to render the custom shell prompt.

The `install_links.sh` script creates a symbolic link from `~/.poshthemes` to this directory, allowing Oh My Posh to find all the themes. The specific theme used is configured in the main `~/.bashrc` file.
