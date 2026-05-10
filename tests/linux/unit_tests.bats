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
    
    # Mock systemctl and balooctl
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
