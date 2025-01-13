# Bypass MDM Script

## Description
This script is designed to bypass MDM (Mobile Device Management) configuration on macOS devices. It handles the removal of MDM restrictions by creating a temporary user, blocking MDM-related domains, and modifying configuration profiles.

This script is intended for educational and authorized use only. Unauthorized use may violate applicable laws or agreements.

## Features
- Renames system volumes if necessary.
- Creates a temporary admin user.
- Blocks MDM-related domains.
- Removes MDM configuration profiles.
- Ensures execution with root permissions.

## Requirements
- macOS operating system.
- Administrative/root permissions.
- `diskutil` and `dscl` commands available.

## Usage
1. Clone the repository:
   ```bash
   git clone https://github.com/hetoraparici0/bypass-mdm-mac.git
   cd bypass-mdm-mac
   
