# progrun-fish
progrun - Search for and run GUI Programs on Hyprland - fish script version (original)

# Help
A helpful program to search for and run GUI Programs

Usage: progrun [OPTIONS]
Options:
  -w, --workspaces=N         Target workspace (0-10, default 9, 0=10)
  -l, --level=DEPTH          Search depth for binaries (default 2)
  -d, --directory=PATH       Base directory to search (default ~/Game)
  -i, --ignore-workspace     Launch in active workspace, ignoring --workspace

  -m, --menu="CMD"           Launcher command
                             (default: wofi -I -m -b -q -G -W 25% --prompt='Launch GUI Program' --show=dmenu)

  -c, --copyright            Print copyright license and quit
  -v, --version              Print progrun version and quit
  -h, --help                 Print this help message and quit

Env:
   PROGRUN_MENU: set command for launcher with args as a string
                             (default: same as --menu default)
progrun 1.0.9
Copyright (C) 2026 Fuzzycc (-c for contact)

# Why
Originally, I had a bunch of games on my machine that I wanted to easily launch.
Yet, at the same time, I did not wish to clutter my launcher with them.
These games' binaries were not a relevant enough part of my daily driver setup to include them there.
Hence this script. With it, I could easily point to the root directory where my games are, and easily run them.
The script is minimal but helpful.

# Future
- Searching multiple base directories (for now, you can achieve that-ish using --level)
- Make filtering executables with extensions a toggle (filtered atm)

