# Project Scaffolding Scripts

This project contains a collection of scripts designed to automate the setup of new development projects.

By default, all new projects are created within the `~/projects` directory. This can be customized via a configuration file (see Setup).

## Setup (Optional)

To change the default base directory where projects are created, you can create a configuration file.

1.  Create the configuration directory:
    ```bash
    mkdir -p ~/.config/project_scaffolding
    ```
2.  Copy the example template to that directory:
    ```bash
    cp config.example ~/.config/project_scaffolding/config
    ```
3.  Edit `~/.config/project_scaffolding/config` and set your preferred base directory path.

---

## `new_pyproject` Command

### Overview

Creates a standard boilerplate project for a Python application.

### Usage

`new_pyproject <ProjectName>`

### Features

- Creates a main project directory.
- Initializes a Git repository.
- Creates a Python 3 virtual environment named `.venv`.
- Generates a comprehensive `.gitignore` file tailored for Python projects.

### Dependencies

- `python3` (and the `python3-venv` package)
- `git`

---

## `new_webproject` Command

### Overview

Creates a complete boilerplate project for a simple HTML/CSS/JS web application.

### Usage

`new_webproject <ProjectName>`

### Features

- Creates a main project directory with `css`, `js`, and `images` subdirectories.
- Generates boilerplate `index.html`, `css/styles.css`, and `js/script.js` files.
- Initializes a Git repository, creates a `.gitignore` file, and makes the first commit.
- Optionally opens the entire project in Neovim if it's installed.
