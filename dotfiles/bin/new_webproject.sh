#!/bin/bash
# Creates a basic HTML/CSS/JS project structure inside ~/projects.
# Includes Git init, boilerplate files, first commit, and opens Neovim.

# --- Configuration ---
PROJECTS_BASE_DIR="$HOME/projects"

# --- Input Validation ---
if [ -z "$1" ]; then
    echo "Usage: $0 <ProjectName>"
    echo "       <ProjectName> should not contain spaces or special characters."
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_DIR="$PROJECTS_BASE_DIR/$PROJECT_NAME"

# --- Cleanup Function ---
# Function to remove the project directory if script fails
cleanup() {
    echo "[Cleanup] Script interrupted or failed. Removing partial project $PROJECT_DIR..." >&2
    # Make sure PROJECT_DIR is set before removing!
    if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
        # Attempt to go back to original directory before removing
        if [ -n "$original_dir" ] && [ "$(pwd)" != "$original_dir" ]; then
            cd "$original_dir" || echo "[Cleanup Warning] Could not cd back from $PROJECT_DIR" >&2
        fi
        rm -rf "$PROJECT_DIR"
        if [ $? -eq 0 ]; then echo "[Cleanup] Removed $PROJECT_DIR." >&2; else echo "[Cleanup Warning] Failed to remove $PROJECT_DIR." >&2; fi
    else
        echo "[Cleanup] PROJECT_DIR variable not set or directory does not exist. No cleanup needed." >&2
    fi
}

# Set the trap to call cleanup function on ERR signal (error) or EXIT signal (includes Ctrl+C)
trap cleanup ERR EXIT

# --- Pre-checks ---
# Ensure base directory exists
if [ ! -d "$PROJECTS_BASE_DIR" ]; then
    echo "Info: Base project directory '$PROJECTS_BASE_DIR' not found. Creating it..."
    mkdir -p "$PROJECTS_BASE_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create base project directory '$PROJECTS_BASE_DIR'." >&2
        exit 1
    fi
fi

# Check if project directory already exists
if [ -d "$PROJECT_DIR" ]; then
    echo "Error: Project directory '$PROJECT_DIR' already exists." >&2
    exit 1
fi

echo "--- Creating web project: $PROJECT_NAME in $PROJECTS_BASE_DIR ---"

# 1. Create directories
echo "[1/7] Creating directory structure ($PROJECT_DIR, css, js, images)..."
mkdir -p "$PROJECT_DIR/css" || {
    echo "Error creating css dir." >&2
    exit 1
}
mkdir -p "$PROJECT_DIR/js" || {
    echo "Error creating js dir." >&2
    exit 1
} # Trap handles cleanup now
mkdir -p "$PROJECT_DIR/images" || {
    echo "Error creating images dir." >&2
    exit 1
} # Trap handles cleanup now

# 2. Create index.html with boilerplate
echo "[2/7] Creating index.html..."
cat <<EOF >"$PROJECT_DIR/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${PROJECT_NAME}</title>
    <link rel="stylesheet" href="css/styles.css">
    </head>
<body>

    <h1>Welcome to ${PROJECT_NAME}!</h1>
    <p>Your content starts here.</p>

    <script src="js/script.js"></script>
</body>
</html>
EOF
if [ $? -ne 0 ]; then
    echo "Error creating index.html." >&2
    exit 1
fi

# 3. Create css/styles.css with boilerplate
echo "[3/7] Creating css/styles.css..."
cat <<EOF >"$PROJECT_DIR/css/styles.css"
/* Basic Reset & Box Sizing */
*,
*::before,
*::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

/* Basic Body Styling */
body {
  font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
  line-height: 1.6;
  padding: 20px;
  color: #333;
  background-color: #f4f4f4;
}

h1 {
   margin-bottom: 1rem;
   color: #111;
}

/* Add your project-specific styles below */

EOF
if [ $? -ne 0 ]; then
    echo "Error creating css/styles.css." >&2
    exit 1
fi

# 4. Create js/script.js with boilerplate
echo "[4/7] Creating js/script.js..."
cat <<EOF >"$PROJECT_DIR/js/script.js"
console.log('Hello from ${PROJECT_NAME} script!');

// Wait for the HTML document to be fully loaded before running JS code
document.addEventListener('DOMContentLoaded', () => {
    console.log('${PROJECT_NAME} DOM fully loaded and parsed');

    // Add event listeners or other startup code here
});
EOF
if [ $? -ne 0 ]; then
    echo "Error creating js/script.js." >&2
    exit 1
fi

# 5. Create README.md with boilerplate
echo "[5/7] Creating README.md..."
cat <<EOF >"$PROJECT_DIR/README.md"
# ${PROJECT_NAME}

A brief description of what this project does.

## How to Run

1.  Open the \`index.html\` file in your web browser.
2.  (Add other steps if needed)

## Notes

* Add any relevant notes about the project here.
EOF
if [ $? -ne 0 ]; then
    echo "Error creating README.md." >&2
    exit 1
fi

# 6. Initialize Git, create .gitignore, make first commit
echo "[6/7] Initializing Git repository and making first commit..."
if command -v git &>/dev/null; then
    # Change into project dir to run git commands relative to it
    original_dir=$(pwd) # Remember where we started
    cd "$PROJECT_DIR" || {
        echo "Error changing to project directory for Git init." >&2
        exit 1
    }

    git init -b main >/dev/null
    if [ $? -ne 0 ]; then
        echo "Error initializing Git repository." >&2
        cd "$original_dir"
        exit 1
    fi

    # Create .gitignore
    cat <<EOG >".gitignore"
# Node modules (if you use npm later)
node_modules/
npm-debug.log
yarn-error.log

# Build outputs
dist/
build/
out/

# Editor/OS files
.idea/
.vscode/
*.swp
*~
.DS_Store

# Environment variables
.env
.env.*
!.env.example
EOG
    if [ $? -ne 0 ]; then
        echo "Error creating .gitignore." >&2
        cd "$original_dir"
        exit 1
    fi

    # Add and commit
    echo "Making initial Git commit..."
    git add . >/dev/null
    if [ $? -ne 0 ]; then
        echo "Error adding files to Git index." >&2
        cd "$original_dir"
        exit 1
    fi

    # Check if user name/email is configured for Git
    if ! git config --get user.name >/dev/null || ! git config --get user.email >/dev/null; then
        echo "[Warning] Git user name/email not configured locally or globally." >&2
        echo "           Commit might fail or use default system values." >&2
        echo "           Configure globally using: git config --global user.name 'Your Name'" >&2
        echo "                                      git config --global user.email 'you@example.com'" >&2
    fi
    git commit -m "Initial project structure from script" >/dev/null
    if [ $? -ne 0 ]; then
        echo "[Error] Initial Git commit failed. Please check Git configuration (user name/email) and repo status." >&2
        # We don't necessarily exit here, let nvim open anyway, but trap will still clean up if forced exit
    fi

    # Go back to original directory before opening nvim
    cd "$original_dir" || exit 1 # Exit if we can't cd back
else
    echo "Info: git command not found. Skipping Git initialization and commit."
fi

# 7. Open in Neovim
echo "[7/7] Opening project in Neovim..."
if command -v nvim &>/dev/null; then
    # Open Neovim focused on the new project directory
    # We detach trap here, because opening nvim means success, even if user exits nvim causing script exit
    trap - ERR EXIT
    nvim "$PROJECT_DIR"
else
    echo "Info: nvim command not found. Cannot open editor automatically."
fi

echo ""
echo "--- Web project '$PROJECT_NAME' created successfully in $PROJECT_DIR ---"
echo "Neovim should be opening the project. If not, manually 'cd $PROJECT_DIR' and run 'nvim .'"
echo "-------------------------------------------------"

# Remove trap on successful completion (also done before nvim launch, but good to be explicit)
trap - ERR EXIT

exit 0
