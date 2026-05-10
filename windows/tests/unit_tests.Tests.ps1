Describe "Frutiger Aero Optimizer Windows Port" {
    BeforeAll {
        # Initialize variables by explicitly calling detection
        . "$PSScriptRoot/../optimize_and_aero.ps1"
        # Skip Admin check if it's already defined
        # We manually call Get-SystemInfo for testing
        Get-SystemInfo
    }

    Context "System Detection" {
        It "Successfully detects Windows version" {
            $Global:OS_NAME.Should-NotBeNullOrEmpty()
        }
    }

    Context "Asset Path Verification" {
        It "Finds the authentic sound assets" {
            $SoundDir = Join-Path $PSScriptRoot "../assets/sounds"
            Test-Path (Join-Path $SoundDir "Logon.wav") | Should -Be $true
        }

        It "Finds the authentic icon assets" {
            $IconDir = Join-Path $PSScriptRoot "../assets/icons"
            Test-Path (Join-Path $IconDir "computer.ico") | Should -Be $true
        }
    }
}
