#!/bin/bash
#
# A script to set a future reminder using systemd timers and email.

set -euo pipefail

# --- Configuration & Helper Functions ---
CONFIG_FILE="$HOME/.config/remind_me/config"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file not found at $CONFIG_FILE" >&2
    echo "Please copy the example and fill in your details." >&2
    exit 1
fi
source "$CONFIG_FILE"

# Validate that required config variables are set
: "${API_KEY:?API_KEY not set in $CONFIG_FILE}"
: "${SENDER_EMAIL:?SENDER_EMAIL not set in $CONFIG_FILE}"
: "${SENDER_NAME:?SENDER_NAME not set in $CONFIG_FILE}"

log_info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m $1" >&2; exit 1; }

# --- Main Logic ---
# Get reminder details from the user
read -p "Enter reminder message: " message
read -p "Enter when (e.g., '10 minutes', 'tomorrow 10am', 'next monday'): " remind_time

# Convert the human-readable time to a systemd-compatible format
# and a user-friendly format for confirmation.
# The 'trap' command ensures we clean up the temp file on exit.
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

if ! date -d "$remind_time" +"%Y-%m-%d %H:%M:%S" > "$temp_file"; then
    log_error "Invalid date format. Could not parse '$remind_time'."
fi

calendar_time=$(cat "$temp_file")
log_info "Reminder will be set for: $calendar_time"

# Generate a unique name for the systemd units
service_id="reminder-$(date +%s%N)"
service_file="$HOME/.config/systemd/user/${service_id}.service"
timer_file="$HOME/.config/systemd/user/${service_id}.timer"

# Create the systemd user directory if it doesn't exist.
mkdir -p "$HOME/.config/systemd/user"

# Create the systemd service file using a heredoc
log_info "Creating systemd service file: $service_file"
cat > "$service_file" << EOF
[Unit]
Description=Send a reminder: "${message}"

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c 'echo "Sending reminder..." >> /tmp/remind_me.log; /usr/bin/curl --silent --request POST --url https://api.brevo.com/v3/smtp/email --header "accept: application/json" --header "api-key: ${API_KEY}" --header "content-type: application/json" --data "{\\"sender\\":{\\"name\\":\\"${SENDER_NAME}\\",\\"email\\":\\"${SENDER_EMAIL}\\"},\\"to\\":[{\\"email\\":\\"${SENDER_EMAIL}\\",\\"name\\":\\"Me\\"}],\\"subject\\":\\"Reminder: ${message}\\",\\"htmlContent\\":\\"This is a reminder for: <strong>${message}</strong>\\"}"'
EOF

# Create the systemd timer file
log_info "Creating systemd timer file: $timer_file"
cat > "$timer_file" << EOF
[Unit]
Description=Timer for the reminder: "${message}"

[Timer]
OnCalendar=${calendar_time}
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Reload systemd, enable and start the new timer
log_info "Reloading systemd user daemon and starting timer..."
systemctl --user daemon-reload
systemctl --user enable "$timer_file"
systemctl --user start "$timer_file"

log_success "Reminder set successfully!"
echo "You can check the status with: systemctl --user list-timers"
