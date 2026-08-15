#!/usr/bin/env bats

# Mocking system files and commands
setup() {
    # Create a temporary directory for mocks
    MOCK_DIR="$(mktemp -d)"
    export MOCK_DIR
    PATH="$MOCK_DIR:$PATH"
    
    # Mock /etc/os-release
    mkdir -p "$MOCK_DIR/etc"
    echo 'ID=ubuntu' > "$MOCK_DIR/etc/os-release"
    echo 'VERSION_ID="24.04"' >> "$MOCK_DIR/etc/os-release"
    echo 'PRETTY_NAME="Ubuntu 24.04 LTS"' >> "$MOCK_DIR/etc/os-release"
    
    # Mock systemctl, balooctl, and plasmashell
    echo 'echo "enabled"' > "$MOCK_DIR/systemctl"
    echo 'echo "is running"' > "$MOCK_DIR/balooctl"
    echo 'echo "plasmashell 5.27.0"' > "$MOCK_DIR/plasmashell"
    chmod +x "$MOCK_DIR/systemctl" "$MOCK_DIR/balooctl" "$MOCK_DIR/plasmashell"
}

teardown() {
    rm -rf "$MOCK_DIR"
}

@test "detect_system identifies environment" {
    run bash -c "
        source ./optimize_and_aero.sh
        export XDG_CURRENT_DESKTOP='KDE'
        detect_system
        echo \"\$DE_TYPE\"
    "
    [ "$status" -eq 0 ]
    [[ "$output" =~ "kde" ]]
}

@test "log_message creates log file" {
    LOG_FILE="/tmp/test_aero.log"
    rm -f "$LOG_FILE"
    run bash -c "source ./optimize_and_aero.sh && LOG_FILE=$LOG_FILE && log_message 'INFO' 'Test Message'"
    [ "$status" -eq 0 ]
    [ -f "$LOG_FILE" ]
    grep -q "Test Message" "$LOG_FILE"
}

@test "init_state creates state file" {
    STATE_FILE="/tmp/test_state.sh"
    rm -f "$STATE_FILE"
    
    run bash -c "
        source ./optimize_and_aero.sh
        STATE_FILE=$STATE_FILE
        DE_TYPE='kde'
        init_state
    "
    [ "$status" -eq 0 ]
    [ -f "$STATE_FILE" ]
    grep -q "SVC_cups" "$STATE_FILE"
    grep -q "BALOO_STATE" "$STATE_FILE"
}

@test "show_help displays help information" {
    run ./optimize_and_aero.sh --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Opciones:" ]]
    [[ "$output" =~ "--auto" ]]
    [[ "$output" =~ "--verify" ]]
}

@test "show_version displays version information" {
    run ./optimize_and_aero.sh --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "v5.2-modular" ]]
}

@test "apply_konsole_glass generates profile and colorscheme" {
    TEST_HOME="$(mktemp -d)"
    run bash -c "
        source ./optimize_and_aero.sh
        HOME=\"$TEST_HOME\"
        apply_konsole_glass
    "
    [ "$status" -eq 0 ]
    [ -f "$TEST_HOME/.local/share/konsole/AeroGlass.profile" ]
    [ -f "$TEST_HOME/.local/share/konsole/AeroBlue.colorscheme" ]
    grep -q "ColorScheme=AeroBlue" "$TEST_HOME/.local/share/konsole/AeroGlass.profile"
    grep -q "Blur=true" "$TEST_HOME/.local/share/konsole/AeroBlue.colorscheme"
    rm -rf "$TEST_HOME"
}

@test "apply_vlc_skin sets skins2 interface" {
    TEST_HOME="$(mktemp -d)"
    mkdir -p "$TEST_HOME/.config/vlc"
    echo "intf=qt" > "$TEST_HOME/.config/vlc/vlcrc"
    
    run bash -c "
        source ./optimize_and_aero.sh
        HOME=\"$TEST_HOME\"
        apply_vlc_skin
    "
    [ "$status" -eq 0 ]
    [ -f "$TEST_HOME/.config/vlc/vlcrc" ]
    grep -q "intf=skins2" "$TEST_HOME/.config/vlc/vlcrc"
    grep -q "skins2-last=" "$TEST_HOME/.config/vlc/vlcrc"
    rm -rf "$TEST_HOME"
}

@test "apply_aurora_wallpapers executes without errors" {
    run bash -c "
        source ./optimize_and_aero.sh
        export DE_TYPE='kde'
        apply_aurora_wallpapers
    "
    [ "$status" -eq 0 ]
}
