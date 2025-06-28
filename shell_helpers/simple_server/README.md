# Simple HTTP Server (serve_here)

A convenient wrapper script to start a simple Python HTTP server in the current directory.

## Overview

This script makes it incredibly easy to share files on your local network or to quickly preview a static website without needing a complex web server like Apache or Nginx. It uses Python's built-in `http.server` module.

## Dependencies

- `python3`: Required to run the web server.

## Setup (Optional)

The default port for the server is `8000`. To change this default, you can create a custom configuration file.

1.  Create the configuration directory:
    ```bash
    mkdir -p ~/.config/simple_server
    ```
2.  Copy the example template to that directory:
    ```bash
    cp config.example ~/.config/simple_server/config
    ```
3.  Edit `~/.config/simple_server/config` and set your preferred default port.

## Usage

Navigate to any directory you want to share and run the command.

```bash
# Serve the current directory on the default port (8000)
serve_here

# Serve the current directory on a specific port
serve_here 9999
The script will print the URLs you can use to access the server from your local machine (localhost) and from other devices on your network. Press Ctrl+C to stop the server.
```
