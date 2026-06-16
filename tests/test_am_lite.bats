#!/usr/bin/env bats

setup() {
	TEST_TEMP_DIR="$(mktemp -d)"
	export TEST_TEMP_DIR
	export HOME="$TEST_TEMP_DIR"
	export XDG_CONFIG_HOME="$TEST_TEMP_DIR/.config"
	export XDG_STATE_HOME="$TEST_TEMP_DIR/.local/state"

	# Create mock binary path and prepend to PATH
	MOCK_BIN_DIR="$TEST_TEMP_DIR/mock_bin"
	mkdir -p "$MOCK_BIN_DIR"
	
	# Create mock curl that intercepts repo calls
	cat > "$MOCK_BIN_DIR/curl" << 'EOF'
#!/usr/bin/env bash
ARGS=("$@")
OUTPUT=""
IS_APPS=false
IS_PROGRAMS=false
TARGET_URL=""

while [[ $# -gt 0 ]]; do
	case "$1" in
		-o|--output)
			OUTPUT="$2"
			shift 2
			;;
		--output=*)
			OUTPUT="${1#--output=}"
			shift
			;;
		http*|ftp*)
			TARGET_URL="$1"
			shift
			;;
		*)
			shift
			;;
	esac
done

if [[ "$TARGET_URL" == *"-apps" ]]; then
	IS_APPS=true
elif [[ "$TARGET_URL" == *"programs/"* ]]; then
	IS_PROGRAMS=true
fi

write_output() {
	if [ -n "$OUTPUT" ]; then
		cat > "$OUTPUT"
	else
		cat
	fi
}

if [ "$IS_APPS" = true ]; then
	echo "◆ mockapp1" | write_output
	echo "◆ mockapp2" | write_output
	exit 0
elif [ "$IS_PROGRAMS" = true ]; then
	cat << 'INNER_EOF' | write_output
#!/bin/sh
# Call curl in fallback mode (no -o or -O) to test that wrapper recursion is prevented
curl -s --help >/dev/null
APP=mockapp1
mkdir -p "/opt/$APP/bin"
touch "/opt/$APP/bin/mockapp1-bin"
ln -s "/opt/$APP/bin/mockapp1-bin" "/usr/local/bin/mockapp1"
mkdir -p "/usr/share/applications"
echo "[Desktop Entry]" > "/usr/share/applications/mockapp1.desktop"
cat >> "/opt/$APP/AM-updater" << 'UPDATER_EOF'
#!/bin/sh
echo "Updating mockapp1..."
UPDATER_EOF
chmod +x "/opt/$APP/AM-updater"

# Create remover script
cat >> "/opt/$APP/remove" << 'REMOVER_EOF'
#!/bin/sh
rm -f "/usr/local/bin/mockapp1"
rm -rf "/opt/mockapp1"
REMOVER_EOF
chmod +x "/opt/$APP/remove"
INNER_EOF
	exit 0
else
	# Fallback to standard curl
	exec /usr/bin/curl "${ARGS[@]}"
fi
EOF
	chmod +x "$MOCK_BIN_DIR/curl"
	export PATH="$MOCK_BIN_DIR:$PATH"
}

teardown() {
	rm -rf "$TEST_TEMP_DIR"
}

@test "Help flag prints usage guidelines" {
	run ./am-lite --help
	[ "$status" -eq 1 ]
	[[ "$output" =~ "Usage:" ]]
}

@test "Version flag prints application version" {
	run ./am-lite --version
	[ "$status" -eq 0 ]
	[[ "$output" =~ "version 2.0.0" ]]
}

@test "Search lists matches from mock database" {
	run ./am-lite search "mock"
	[ "$status" -eq 0 ]
	[[ "$output" =~ "mockapp1" ]]
	[[ "$output" =~ "mockapp2" ]]
}

@test "User-space installer maps system paths to user directories" {
	# Run installation non-interactively using -y flag
	run ./am-lite -y install mockapp1
	[ "$status" -eq 0 ]

	# Verify installation directory layouts
	[ -d "$TEST_TEMP_DIR/.local/share/am-lite/opt/mockapp1/bin" ]
	[ -f "$TEST_TEMP_DIR/.local/share/am-lite/opt/mockapp1/bin/mockapp1-bin" ]
	
	# Verify binary link
	[ -L "$TEST_TEMP_DIR/.local/bin/mockapp1" ]
	
	# Verify desktop application registration
	[ -f "$TEST_TEMP_DIR/.local/share/applications/mockapp1.desktop" ]
}

@test "List command shows installed mockapp" {
	run ./am-lite -y install mockapp1
	[ "$status" -eq 0 ]

	run ./am-lite list
	[ "$status" -eq 0 ]
	[[ "$output" =~ "mockapp1" ]]
}

@test "User-space remover cleans up installed files" {
	run ./am-lite -y install mockapp1
	[ "$status" -eq 0 ]

	run ./am-lite remove mockapp1
	[ "$status" -eq 0 ]

	# Verify directories and binary links were deleted
	[ ! -d "$TEST_TEMP_DIR/.local/share/am-lite/opt/mockapp1" ]
	[ ! -f "$TEST_TEMP_DIR/.local/bin/mockapp1" ]
}

@test "Logging is captured in state log file" {
	run ./am-lite -y install mockapp1
	[ "$status" -eq 0 ]

	# Verify logging file exists and contains installation entries
	local log_file="$TEST_TEMP_DIR/.local/state/am-lite/am-lite.log"
	[ -f "$log_file" ]
	grep -q "Installing mockapp1" "$log_file"
	grep -q "mockapp1 installed successfully" "$log_file"
}
