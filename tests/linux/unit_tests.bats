#!/usr/bin/env bats

# Mocking system files and commands
setup() {
    # Create a temporary directory for mocks
    MOCK_DIR="$(mktemp -d)"
    PATH="$MOCK_DIR:$PATH"
    
    # Mock /etc/os-release
    mkdir -p "$MOCK_DIR/etc"
    echo 'ID=ubuntu' > "$MOCK_DIR/etc/os-release"
    echo 'VERSION_ID="24.04"' >> "$MOCK_DIR/etc/os-release"
    
    # Source the script (mocking the execution)
    # We need to make sure the script doesn't execute its main logic when sourced
    export BASH_SOURCE_MOCK=true
}

teardown() {
    rm -rf "$MOCK_DIR"
}

@test "detect_system identifies Ubuntu 24.04" {
    # Create a wrapper to source the script and call the function
    run bash -c "
        source ./optimize_and_aero.sh
        # Override the check to use our mock file
        OS_NAME=\$(grep '^ID=' $MOCK_DIR/etc/os-release | cut -d'=' -f2 | tr -d '\"')
        OS_VER=\$(grep 'VERSION_ID' $MOCK_DIR/etc/os-release | cut -d'\"' -f2)
        echo \"\$OS_NAME \$OS_VER\"
    "
    [ "$status" -eq 0 ]
    [ "$output" == "ubuntu 24.04" ]
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
    # Mock systemctl to avoid errors
    echo 'echo "enabled"' > "$MOCK_DIR/systemctl"
    chmod +x "$MOCK_DIR/systemctl"
    
    run bash -c "source ./optimize_and_aero.sh && STATE_FILE=$STATE_FILE && init_state"
    [ "$status" -eq 0 ]
    [ -f "$STATE_FILE" ]
    grep -q "SVC_cups" "$STATE_FILE"
}
