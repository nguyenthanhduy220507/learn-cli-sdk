#!/bin/bash
# <IKIGAI AI CLI> Installer for macOS / Linux
# GitHub Repo: https://github.com/nguyenthanhduy220507/learn-cli-sdk

INSTALL_DIR="$HOME/.ikigai"
IMAGE_NAME="ghcr.io/nguyenthanhduy220507/learn-cli-sdk:latest"
BINARY_PATH="$INSTALL_DIR/ikigai"

echo "--------------------------------------------------"
echo "   IKIGAI AI CLI SDK - macOS/Linux Installer"
echo "--------------------------------------------------"

# 1. Create installation directory
mkdir -p "$INSTALL_DIR"

# 2. Create the wrapper script
cat <<EOF > "$BINARY_PATH"
#!/bin/bash
# IKIGAI AI CLI Wrapper
# Automatically pull the latest image
docker pull $IMAGE_NAME > /dev/null 2>&1

# Run the container
docker run --rm -it \\
  -v "\$(pwd):/data" \\
  -w "/data" \\
  -e GEMINI_API_KEY=\$GEMINI_API_KEY \\
  $IMAGE_NAME "\$@"
EOF

# Make it executable
chmod +x "$BINARY_PATH"
echo "[*] Created wrapper script at: $BINARY_PATH"

# 3. Add to PATH automatically
detect_shell_rc() {
    if [[ "$SHELL" == */zsh ]]; then
        echo "$HOME/.zshrc"
    elif [[ "$SHELL" == */bash ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "$HOME/.bash_profile"
        else
            echo "$HOME/.bashrc"
        fi
    else
        echo "$HOME/.profile"
    fi
}

RC_FILE=$(detect_shell_rc)

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "" >> "$RC_FILE"
    echo "# IKIGAI AI CLI PATH" >> "$RC_FILE"
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$RC_FILE"
    echo "[+] Added $INSTALL_DIR to $RC_FILE"
else
    echo "[i] $INSTALL_DIR is already in your PATH."
fi

# 4. Initial Pull
echo "[*] Pulling the latest CLI image from registry..."
docker pull $IMAGE_NAME

echo "--------------------------------------------------"
echo "✅ INSTALLATION COMPLETED!"
echo "--------------------------------------------------"
echo "NOTES:"
echo "1. Please RESTART your terminal or run: source $RC_FILE"
echo "2. Ensure Docker Desktop is running."
echo "3. To set your API Key permanently, run:"
echo "   echo 'export GEMINI_API_KEY=\"YOUR_KEY\"' >> $RC_FILE && source $RC_FILE"
echo "--------------------------------------------------"
