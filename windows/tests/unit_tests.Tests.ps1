Describe "Frutiger Aero Optimizer Windows Port" {
    BeforeAll {
        # Initialize variables by explicitly calling detection
        . "$PSScriptRoot/../optimize_and_aero.ps1"
        # Manually call Get-SystemInfo for testing
        Get-SystemInfo
    }

    Context "System Detection" {
        It "Successfully detects Windows version" {
            $Global:OS_NAME | Should -Not -BeNullOrEmpty
        }
    }

    Context "Asset Path Verification" {
        It "Finds the authentic sound assets" {
            $SoundDir = Join-Path $PSScriptRoot "../assets/sounds"
            $LogonPath = Join-Path $SoundDir "Logon.wav"
            Test-Path $LogonPath | Should -Be $true
        }

        It "Finds the authentic icon assets" {
            $IconDir = Join-Path $PSScriptRoot "../assets/icons"
            $PCPath = Join-Path $IconDir "computer.ico"
            Test-Path $PCPath | Should -Be $true
        }
    }
}
