# Linux Shell

Add and configure 3 different shells :

- bash
- zsh
- fish

These 3 shells then have equivalent prompts. These prompts have the following characteristics :

- Time display
- Display of the active shell (bash, zsh or fish)
- Display of the active user
- Display of the machine name
- Display of the current location
- Display of the branch [Git](https://git-scm.com/) of the current folder (if it exists)

## Installation

- If you are in root mode, the shells and their configuration will be installed for all users of the system. You can pass as argument which shell (bash, zsh or fish) will be the default shell. Note, the default shell of the root user will always be bash (for security reasons).

- If you have a simple user account, the shell configuration will be installed on your account. However, if the shells are not already installed on the system, the script will not be able to install them for you.

## Other features

- The command vi will use vim
