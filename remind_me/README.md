# Reminder System

A bash script that uses systemd user timers and the Brevo email API to send future reminders to your desktop and email. Also includes a test script for the email configuration.

## Dependencies

- `curl`
- `systemd` (standard on most modern Linux systems)

## Setup

1.  This script requires a configuration file with your API credentials. First, create the directory:
    ```bash
    mkdir -p ~/.config/remind_me
    ```
2.  Next, copy the example template to that directory:
    ```bash
    cp config.example ~/.config/remind_me/config
    ```
3.  **Edit the new configuration file** (`nano ~/.config/remind_me/config`) and replace the placeholder values with your actual Brevo API key and verified sender email.
4.  **Secure your configuration file**:
    ```bash
    chmod 600 ~/.config/remind_me/config
    ```

## Usage

- To set a reminder: `remind_me`
- To test your email setup: `email_test recipient@example.com`
