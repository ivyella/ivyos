#!/bin/sh
# apply-theme.sh — ivyshell theming engine
# usage: apply-theme.sh <pack>/<variant>
#   e.g: apply-theme.sh kanagawa/wave

SLUG="$1"

if [ -z "$SLUG" ]; then
    echo "ivyshell: no theme slug provided" >&2
    exit 1
fi

PACK=$(echo "$SLUG" | cut -d/ -f1)
VARIANT=$(echo "$SLUG" | cut -d/ -f2)

THEMES_DIR="$HOME/ivyos/ivyshell/themes/colors"
SCRIPTS_DIR="$HOME/ivyos/ivyshell/scripts"
TEMPLATES_DIR="$SCRIPTS_DIR/templates"
TARGETS_FILE="$SCRIPTS_DIR/targets.json"

# --- find theme file case-insensitively ---

THEME_JSON=$(find "$THEMES_DIR" -iname "$PACK.json" | head -1)

if [ -z "$THEME_JSON" ] || [ ! -f "$THEME_JSON" ]; then
    echo "ivyshell: error: theme file not found for '$PACK'" >&2
    exit 1
fi

if [ ! -f "$TARGETS_FILE" ]; then
    echo "ivyshell: error: targets.json not found at $TARGETS_FILE" >&2
    exit 1
fi

if ! jq -e ".variants[\"$VARIANT\"]" "$THEME_JSON" > /dev/null 2>&1; then
    echo "ivyshell: error: variant '$VARIANT' not found in $PACK" >&2
    exit 1
fi

# --- extract colors and fonts as key=value pairs ---

COLORS=$(jq -r ".variants[\"$VARIANT\"].color | to_entries[] | \"\(.key)=\(.value)\"" "$THEME_JSON")
FONTS=$(jq -r ".variants[\"$VARIANT\"].font | to_entries[] | \"font_\(.key)=\(.value)\"" "$THEME_JSON")

# --- template engine ---

ERRORS=0

fill_template() {
    local src="$1"
    local dest="$2"

    if [ ! -f "$src" ]; then
        echo "ivyshell: error: template not found: $src" >&2
        ERRORS=$((ERRORS + 1))
        return 1
    fi

    mkdir -p "$(dirname "$dest")"

    local content
    content=$(cat "$src")

    while IFS='=' read -r key val; do
        [ -z "$key" ] && continue
        content=$(echo "$content" | sed "s|{{$key}}|$val|g")
    done <<EOF
$COLORS
EOF

    while IFS='=' read -r key val; do
        [ -z "$key" ] && continue
        content=$(echo "$content" | sed "s|{{$key}}|$val|g")
    done <<EOF
$FONTS
EOF

    echo "$content" > "$dest"
}

# --- iterate targets ---

TARGET_COUNT=$(jq '.targets | length' "$TARGETS_FILE")
i=0

while [ "$i" -lt "$TARGET_COUNT" ]; do
    template=$(jq -r ".targets[$i].template" "$TARGETS_FILE")
    output=$(jq -r ".targets[$i].output" "$TARGETS_FILE")
    output=$(echo "$output" | sed "s|^~|$HOME|")

    fill_template "$TEMPLATES_DIR/$template" "$output"

    reload=$(jq -r ".targets[$i].reload // empty" "$TARGETS_FILE")
    if [ -n "$reload" ]; then
        eval "$reload" 2>/dev/null
    fi

    i=$((i + 1))
done

if [ "$ERRORS" -gt 0 ]; then
    echo "ivyshell: applied $SLUG ($TARGET_COUNT targets, $ERRORS errors)"
else
    echo "ivyshell: applied $SLUG ($TARGET_COUNT targets)"
fi
