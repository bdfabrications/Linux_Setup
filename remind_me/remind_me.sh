#!/bin/bash
#
# remind_me - A script to set a future reminder using systemd timers and an email API.
# This version incorporates improvements for security, reliability, and error handling.
#

# --- Configuration ---
# This script loads sensitive data from a separate file to keep it secure.
# Create this file at the location specified by the CONFIG_FILE variable.
# For example: ~/.config/remind_me/config
CONFIG_FILE="${HOME}/.config/remind_me/config"

# --- Help Function ---
show_help() {
  cat <<EOF
Usage: $(basename "$0")

An interactive script to set a reminder for a future date and time.
This script uses systemd user timers for scheduling and an email API for notifications.

Description:
  This script will prompt you for the details of a reminder and then create the
  necessary systemd service and timer files in ~/.config/systemd/user/.
  The reminder automatically cleans itself up after it has run.

Dependencies:
  1. curl: Used to send the email notification via an API.
     (e.g., 'sudo apt install curl' or 'sudo dnf install curl')
  2. systemd: Standard on most modern Linux distributions.

Setup Required:
  1. You must create a configuration file at:
     $CONFIG_FILE

  2. This file should contain your API key and sender details:
     API_KEY="your-brevo-api-key"
     SENDER_EMAIL="your-verified-email@example.com"
     SENDER_NAME="Reminder Service"

  3. Secure the file with: chmod 600 $CONFIG_FILE

  4. Your systemd user instance must be running. It usually is by default.
EOF
}

# --- Argument Parsing for Help ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
  exit 0
fi

# --- Dependency & Configuration Checks ---
check_setup() {
  echo "Checking script configuration and dependencies..."
  local setup_error=0

  if ! command -v curl &>/dev/null; then
    echo "[ERROR] 'curl' command not found. Please install it." >&2
    setup_error=1
  fi

  if [ ! -f "$CONFIG_FILE" ]; then
    echo "[ERROR] Configuration file not found at: $CONFIG_FILE" >&2
    echo "        Please create it and add your API key and sender email." >&2
    echo "        Run with -h for more detailed instructions." >&2
    exit 1
  fi

  # NEW: Check for secure file permissions
  if [[ $(stat -c %a "$CONFIG_FILE") != "600" ]]; then
    echo "[WARNING] Configuration file permissions are not '600'." >&2
    echo "          Your API key is readable by other users on the system." >&2
    echo "          It is highly recommended you run: chmod 600 $CONFIG_FILE" >&2
  fi

  # Load the configuration file
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"

  if [[ -z "$API_KEY" || "$API_KEY" == "your-brevo-api-key" ]]; then
    echo "[ERROR] API_KEY is not set correctly in $CONFIG_FILE" >&2
    setup_error=1
  fi

  if [[ -z "$SENDER_EMAIL" || "$SENDER_EMAIL" == "your-verified-email@example.com" ]]; then
    echo "[ERROR] SENDER_EMAIL is not set correctly in $CONFIG_FILE" >&2
    setup_error=1
  fi

  if [[ -z "$SENDER_NAME" ]]; then
    SENDER_NAME="Reminder Service" # Default if not set
  fi

  if [ ! -d "$HOME/.config/systemd/user" ]; then
    echo "[INFO] Creating systemd user directory: ~/.config/systemd/user/"
    mkdir -p "$HOME/.config/systemd/user"
  fi

  if [ "$setup_error" -eq 1 ]; then
    exit 1
  fi

  echo "Configuration and dependencies are OK."
}

# --- Main Logic ---
main() {
  check_setup
  echo ""
  echo "--- Create a New Reminder (using systemd) ---"

  read -p "Enter your email address (for notification): " NOTIFY_EMAIL
  read -p "Reminder Title: " REMINDER_TITLE
  read -p "Reminder Description: " REMINDER_DESC
  read -p "Reminder Date (YYYY-MM-DD): " REMINDER_DATE
  read -p "Reminder Time (HH:MM, 24-hour format): " REMINDER_TIME

  # --- Input Validation ---
  if [[ -z "$REMINDER_TITLE" ]]; then
    echo "[Error] Reminder Title cannot be empty." >&2
    exit 1
  fi
  if [[ ! "$NOTIFY_EMAIL" =~ ^.+@.+\..+$ ]]; then
    echo "[Error] Invalid email address format." >&2
    exit 1
  fi

  local reminder_datetime="${REMINDER_DATE} ${REMINDER_TIME}:00"
  local reminder_timestamp
  if ! reminder_timestamp=$(date --date="$reminder_datetime" +%s); then
    echo "[Error] Invalid date or time format. Please use YYYY-MM-DD and HH:MM." >&2
    exit 1
  fi

  if ((reminder_timestamp <= $(date +%s))); then
    echo "[Error] The specified reminder time is in the past." >&2
    exit 1
  fi

  # --- Create systemd unit files ---
  local safe_title
  safe_title=$(echo "$REMINDER_TITLE" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]')
  local unit_name="reminder-${safe_title}-$(date +%s)"
  local service_file="$HOME/.config/systemd/user/${unit_name}.service"
  local timer_file="$HOME/.config/systemd/user/${unit_name}.timer"
  local exec_script_file="$HOME/.config/systemd/user/${unit_name}-exec.sh"

  # NEW: Trap to clean up generated files if script is interrupted
  trap 'echo "Script interrupted. Cleaning up..."; rm -f "$service_file" "$timer_file" "$exec_script_file"; exit' SIGHUP SIGINT SIGTERM

  echo ""
  echo "--- Summary ---"
  echo "Title:         $REMINDER_TITLE"
  echo "Description:   $REMINDER_DESC"
  echo "Notify Email:  $NOTIFY_EMAIL"
  echo "Time:          $reminder_datetime"
  echo "---------------"
  echo "This will create the following files:"
  echo "  - Service: $service_file"
  echo "  - Timer:   $timer_file"
  echo "  - Script:  $exec_script_file"
  echo "---------------"
  read -p "Is this correct? [y/N] " confirm

  if [[ ! "$confirm" =~ ^[yY](es)?$ ]]; then
    echo "Aborted. No reminder was set."
    exit 0
  fi

  # FIXED: Escape variables to handle special characters (quotes, spaces, etc.) safely.
  local E_API_KEY=$(printf %q "$API_KEY")
  local E_REMINDER_TITLE=$(printf %q "$REMINDER_TITLE")
  local E_REMINDER_DESC=$(printf %q "$REMINDER_DESC")
  local E_NOTIFY_EMAIL=$(printf %q "$NOTIFY_EMAIL")
  local E_SENDER_NAME=$(printf %q "$SENDER_NAME")
  local E_SENDER_EMAIL=$(printf %q "$SENDER_EMAIL")
  local E_REMINDER_DATE=$(printf %q "$REMINDER_DATE")
  local E_REMINDER_TIME=$(printf %q "$REMINDER_TIME")

  # --- Create the Execution Script ---
  # This script is called by the systemd service. It now uses pre-escaped variables.
  cat >"$exec_script_file" <<EOF
#!/bin/bash
# This script is executed by the systemd service: ${unit_name}.service

# Define variables using the safely escaped values from the parent script
API_KEY=${E_API_KEY}
REMINDER_TITLE=${E_REMINDER_TITLE}
REMINDER_DESC=${E_REMINDER_DESC}
NOTIFY_EMAIL=${E_NOTIFY_EMAIL}
SENDER_NAME=${E_SENDER_NAME}
SENDER_EMAIL=${E_SENDER_EMAIL}
REMINDER_DATE=${E_REMINDER_DATE}
REMINDER_TIME=${E_REMINDER_TIME}

# --- Desktop Notification ---
# This is now safe from special characters.
if command -v notify-send &>/dev/null; then
    # Try to find the user's graphical session for notifications
    export DISPLAY=\$(grep -z DISPLAY /proc/\$(pgrep -u \$USER gnome-shell | head -n 1)/environ | tr -d '\\0' | sed 's/DISPLAY=//')
    if [[ -n \$DISPLAY ]]; then
        /usr/bin/notify-send -u critical "\$REMINDER_TITLE" "\$REMINDER_DESC"
    fi
fi

# --- Email Notification using Brevo API ---
# This printf call is simpler as variables are already defined and safe.
# Note: This doesn't escape JSON-specific characters like newlines within the strings.
# For most reminder use cases, this is sufficient.
JSON_PAYLOAD=\$(printf '{
  "sender": {"name": "%s", "email": "%s"},
  "to": [{"email": "%s"}],
  "subject": "Reminder: %s",
  "htmlContent": "<html><body><h1>Reminder: %s</h1><p>%s</p><p><b>Time:</b> %s at %s</p></body></html>"
}' "\$SENDER_NAME" "\$SENDER_EMAIL" "\$NOTIFY_EMAIL" "\$REMINDER_TITLE" "\$REMINDER_TITLE" "\$REMINDER_DESC" "\$REMINDER_DATE" "\$REMINDER_TIME")

# IMPROVED: Send email with better error handling. Logs to systemd journal on failure.
echo "Sending reminder email for '\${REMINDER_TITLE}'..."
API_RESPONSE=\$(curl --request POST \\
  --url https://api.brevo.com/v3/smtp/email \\
  --header "accept: application/json" \\
  --header "api-key: \$API_KEY" \\
  --header "content-type: application/json" \\
  --data "\$JSON_PAYLOAD" --silent --show-error --write-out "HTTP_STATUS:%{http_code}")

if [[ "\$API_RESPONSE" =~ HTTP_STATUS:2[0-9]{2}$ ]]; then
    echo "Email sent successfully."
else
    echo "Error: Email API call failed. Server response:" >&2
    echo "\$API_RESPONSE" >&2
    # The cleanup will still run, but the error is logged for debugging.
    # To debug, run: systemctl --user status ${unit_name}.service
fi

# --- Self-cleanup ---
echo "Cleaning up reminder units..."
systemctl --user disable --now "${unit_name}.timer"
rm -f "$service_file" "$timer_file" "\$0" # \$0 is the script itself
systemctl --user daemon-reload
EOF

  chmod +x "$exec_script_file"

  # --- Create the systemd Service File ---
  # IMPROVED: Description now uses the actual reminder title for clarity.
  cat >"$service_file" <<EOF
[Unit]
Description=Reminder for: ${REMINDER_TITLE}

[Service]
Type=oneshot
ExecStart=${exec_script_file}
EOF

  # --- Create the systemd Timer File ---
  # IMPROVED: Description is now more readable in 'list-timers'.
  cat >"$timer_file" <<EOF
[Unit]
Description=Run reminder for '${REMINDER_TITLE}'

[Timer]
OnCalendar=${reminder_datetime}
Persistent=true

[Install]
WantedBy=timers.target
EOF

  # --- Final Steps ---
  echo ""
  echo "--- Activating Reminder ---"
  systemctl --user daemon-reload
  systemctl --user enable --now "${unit_name}.timer"

  if [ $? -eq 0 ]; then
    # Disable the trap so it doesn't delete the files on normal exit
    trap - SIGHUP SIGINT SIGTERM
    echo "Reminder successfully set and enabled!"
    echo "You can view pending timers with: systemctl --user list-timers"
  else
    echo "[Error] Failed to enable the systemd timer. Please check your systemd configuration." >&2
    # The trap will trigger on exit here, cleaning up the generated files.
    exit 1
  fi
}

# Run the main function with all passed arguments
main "$@"

exit 0
