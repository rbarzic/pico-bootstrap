#!/usr/bin/env bash
# Create a new Pico/Pico2 project from the pico-bootstrap templates.
#
# Usage: scaffold.sh <project-name> [target-dir]
#   project-name  Name used for the CMake target, binary, and directory
#   target-dir    Where to create the project (default: ../<project-name>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"  # pico-bootstrap root

if [ "${1:-}" = "" ]; then
    echo "Usage: scaffold.sh <project-name> [target-dir]" >&2
    exit 1
fi

PROJECT_NAME="$1"
TARGET_DIR="${2:+$2}"
TARGET_DIR="${TARGET_DIR:-$(dirname "$SCRIPT_DIR")/$PROJECT_NAME}"

if [ -e "$TARGET_DIR" ]; then
    echo "ERROR: '$TARGET_DIR' already exists." >&2
    exit 1
fi

echo ">>> Creating project '$PROJECT_NAME' in $TARGET_DIR"
mkdir -p "$TARGET_DIR/src"

# Substitute @PROJECT_NAME@ placeholder in templates
substitute() {
    sed "s/@PROJECT_NAME@/$PROJECT_NAME/g" "$1"
}

substitute "$SCRIPT_DIR/templates/Makefile"       > "$TARGET_DIR/Makefile"
substitute "$SCRIPT_DIR/templates/CMakeLists.txt" > "$TARGET_DIR/CMakeLists.txt"
substitute "$SCRIPT_DIR/templates/src/main.cpp"   > "$TARGET_DIR/src/main.cpp"

# Add pico-bootstrap as a submodule
git -C "$TARGET_DIR" init -q
git -C "$TARGET_DIR" submodule add \
    "$(git -C "$SCRIPT_DIR" remote get-url origin 2>/dev/null || echo https://github.com/rbarzic/pico-bootstrap.git)" \
    pico-bootstrap

# .gitignore
cat > "$TARGET_DIR/.gitignore" <<'EOF'
build/
*.elf
*.bin
*.hex
*.uf2
*.map
EOF

echo ""
echo ">>> Done. Next steps:"
echo ""
echo "    cd $TARGET_DIR"
echo "    make download"
echo "    make install"
echo "    make build"
echo "    make flash   PROBE_SERIAL=<serial>"
echo "    make monitor PROBE_SERIAL=<serial>"
