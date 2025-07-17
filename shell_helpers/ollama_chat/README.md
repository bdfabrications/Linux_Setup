# Ollama Chat Helper

A wrapper script for the `ollama` command-line tool that provides a convenient interactive chat session.

## Features

- Checks if the Ollama server is running and attempts to start it in the background if it's not detected.
- Starts an interactive chat session with a specified model.
- Defaults to a user-configurable model if no model is specified as an argument.

## Dependencies

- `ollama`: Must be installed and accessible in the system's PATH.
- `curl`: Used to check if the Ollama server is running.

## Setup (Optional)

To change the default chat model from `llama3:8b`, you can create a custom configuration file.

1.  Create the configuration directory:
    ```bash
    mkdir -p ~/.config/ollama_chat
    ```
2.  Copy the example template to that directory:
    ```bash
    cp config.example ~/.config/ollama_chat/config
    ```
3.  Edit `~/.config/ollama_chat/config` and set your preferred default model.

## Usage

```bash
# Start a chat with the default model
ollama_chat

# Start a chat with a specific model
ollama_chat phi3

# Start a chat with a specific variant
ollama_chat mistral:7b-instruct-q4_K_M
To exit the chat, type /bye or press Ctrl+D
```

