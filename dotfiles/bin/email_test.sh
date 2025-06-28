#!/bin/bash
#
# email_test.sh - A small script to test the email configuration for remind_me.
# It loads the configuration and sends a test email to the specified address.
#

# --- Configuration ---
CONFIG_FILE="${HOME}/.config/remind_me/config"

# --- Help Function ---
show_help() {
  cat <<EOF
Usage: $(basename "$0") [options] <recipient@example.com>

A utility to test the email configuration used by the 'remind_me' script.
It reads the configuration, connects to the Brevo API, and sends a single
test email to the specified recipient address.

Required Argument:
  recipient@example.com   The email address to send the test message to.

Options:
  -h, --help              Display this help message and exit.

Dependencies:
  This script requires a valid configuration file located at:
  $CONFIG_FILE
EOF
}

# --- Argument Parsing ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
  exit 0
fi

if [ -z "$1" ]; then
  echo "Error: No recipient email address provided." >&2
  echo "Usage: $(basename "$0") <recipient@example.com>" >&2
  echo "Run '$(basename "$0") --help' for more details." >&2
  exit 1
fi
RECIPIENT_EMAIL="$1"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "[ERROR] Configuration file not found at: $CONFIG_FILE" >&2
  exit 1
fi

source "$CONFIG_FILE"

if [[ -z "$API_KEY" || "$API_KEY" == "your-brevo-api-key" ]]; then
  echo "[ERROR] API_KEY variable is empty or using the placeholder value." >&2
  exit 1
fi
if [[ -z "$SENDER_EMAIL" || "$SENDER_EMAIL" == "your-verified-email@example.com" ]]; then
  echo "[ERROR] SENDER_EMAIL is not set correctly in $CONFIG_FILE" >&2
  exit 1
fi

SENDER_NAME=${SENDER_NAME:-"API Test"}

echo "--- Email Configuration Test ---"
echo "Sender:   $SENDER_NAME <$SENDER_EMAIL>"
echo "Recipient: $RECIPIENT_EMAIL"
echo "--------------------------------"

# --- NEW DEBUG LINE ---
# This will show us exactly what key the curl command is about to use.
echo "DEBUG: Using API Key: '$API_KEY'"
echo "--------------------------------"
echo "Sending test email via Brevo API..."
echo ""

curl -s --request POST \
  --url https://api.brevo.com/v3/smtp/email \
  --header 'accept: application/json' \
  --header "api-key: ${API_KEY}" \
  --header 'content-type: application/json' \
  --data "{
    \"sender\": {\"name\": \"${SENDER_NAME}\", \"email\": \"${SENDER_EMAIL}\"},
    \"to\": [{\"email\": \"${RECIPIENT_EMAIL}\"}],
    \"subject\": \"Brevo API Test Message\",
    \"htmlContent\": \"<html><body><p>This is a test email to confirm your API configuration is working correctly.</p></body></html>\"
  }"

echo ""
echo "--------------------------------"
echo "Test complete."
