#!/bin/bash
#
# rgf - A Ripgrep Find Helper
# Description: A robust wrapper for ripgrep (rg) that uses default options
# from a config file while also allowing for command-line overrides.

set -euo pipefail

# --- Configuration & Helper Functions ---
CONFIG_FILE="$HOME/.config/rgf_helper/config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Set default options for ripgrep if not defined by the user.
# These defaults prioritize readability with color, headings, and line numbers.
RG_DEFAULT_OPTS="${RG_DEFAULT_OPTS:---heading --line-number --ignore-case --color=always}"

# --- Usage and Help ---
usage() {
    cat <<EOF
Usage: rgf [rg_options] <pattern> [path]
A wrapper for ripgrep (rg) to provide a consistent search experience.

Arguments:
  [rg_options]    Optional flags to pass directly to ripgrep (e.g., -l, --stats).
  <pattern>       The text pattern to search for.
  [path]          The directory or file to search in. Defaults to the current directory.

Examples:
  rgf "my_function"
  rgf "my_variable" ./src
  rgf -l "my_api_key"         # List only files containing the pattern
EOF
    exit 1
}

# --- Main Logic ---
main() {
    # Check for the 'rg' command dependency first.
    if ! command -v rg &>/dev/null; then
        echo -e "\033[1;31m[ERROR]\033[0m ripgrep (rg) is not installed. Please install it to use this script." >&2
        exit 1
    fi

    # --- Argument Parsing ---
    # Separate user-provided options from the main pattern and path arguments.
    local user_opts=()
    local positional_args=()
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            # Treat --help as a special case to show our custom usage.
            --help)
                usage
                ;;
            # All other arguments starting with a hyphen are stored as options.
            -*)
                user_opts+=("$1")
                shift
                ;;
            # Anything else is a positional argument (pattern or path).
            *)
                positional_args+=("$1")
                shift
                ;;
        esac
    done

    # The first positional argument must be the pattern.
    if [ "${#positional_args[@]}" -eq 0 ]; then
        echo -e "\033[1;31m[ERROR]\033[0m No search pattern provided." >&2
        usage
    fi

    local pattern="${positional_args[0]}"
    local search_path="${positional_args[1]:-.}" # Default to current directory.

    if [ ! -e "$search_path" ]; then
        echo -e "\033[1;31m[ERROR]\033[0m Search path not found: $search_path" >&2
        exit 1
    fi

    # Safely convert the RG_DEFAULT_OPTS string into an array.
    # This prevents issues with options that contain spaces.
    local default_opts_array=()
    read -r -a default_opts_array <<< "$RG_DEFAULT_OPTS"

    echo -e "\033[1;34m[INFO]\033[0m Searching for '${pattern}' in '${search_path}'..." >&2

    # Execute the command, expanding the arrays safely.
    # The '--' tells ripgrep to stop parsing options, so a pattern like '-foo' is not
    # misinterpreted as a flag.
    rg "${default_opts_array[@]}" "${user_opts[@]}" -- "$pattern" "$search_path"
}

# Pass all script arguments to the main function.
main "$@"
