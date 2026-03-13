# progrun - Search for and run GUI Programs on Hyprland
# Copyright (C) 2026 Fuzzycc <fuzzycc@tutamail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org>.
function progrun
    set -l script_version "1.0.9"
    set -l log_file "/tmp/progrun_debug.log"

    set -l license_txt "progrun $script_version
Copyright (C) 2026 Fuzzycc
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Fuzzycc (fuzzycc@tutamail.com) (Github/Fuzzycc)."
    set -l license_txt_short "$(string split \n $license_txt)[1..2]"

    argparse 'w/workspace=' 'l/level=' 'd/directory=' h/help v/version i/ignore-workspace c/copyright 'm/menu=' -- $argv
    or return

    set -l dmenu "wofi -I -m -b -q -G -W 25% --prompt='Launch GUI Program' --show=dmenu"
    if set -q PROGRUN_MENU
        set dmenu $PROGRUN_MENU
    end
    if set -q _flag_menu
        set dmenu $_flag_menu
    end
    set -l dmenu_cmd (string split ' ' -- $dmenu)[1]

    set -l depsies hyprctl find setsid $dmenu_cmd
    set -l missing_depsies
    for depsy in $depsies
        if not command -v $depsy >/dev/null
            set -a missing_depsies $depsy
        end
    end

    if test -n "$missing_depsies"
        echo "Error: Required dependencies missing: $missing_depsies" >&2
        return 1
    end

    if set -q _flag_help
        echo "A helpful program to search for and run GUI Programs"
        echo ""
        echo "Usage: progrun [OPTIONS]"
        echo "Options:"
        echo "  -w, --workspaces=N         Target workspace (0-10, default 9, 0=10)"
        echo "  -l, --level=DEPTH          Search depth for binaries (default 2)"
        echo "  -d, --directory=PATH       Base directory to search (default ~/Game)"
        echo "  -i, --ignore-workspace     Launch in active workspace, ignoring --workspace"
        echo ""
        echo "  -m, --menu=\"CMD\"           Launcher command"
        echo "                             (default: wofi -I -m -b -q -G -W 25% --prompt='Launch GUI Program' --show=dmenu)"
        echo ""
        echo "  -c, --copyright            Print copyright license and quit"
        echo "  -v, --version              Print progrun version and quit"
        echo "  -h, --help                 Print this help message and quit"
        echo ""
        echo "Env:"
        echo "   PROGRUN_MENU: set command for launcher with args as a string"
        echo "                             (default: same as --menu default)"
        if test "$dmenu" = "$PROGRUN_MENU"
            echo " *Env Variable found: PROGRUN_MENU = \"$dmenu\")"
            echo ""
        end
        echo $license_txt_short "(-c for contact)"
        return 0
    end

    if set -q _flag_copyright
        echo $license_txt
        return 0
    end

    if set -q _flag_version
        echo "progrun $script_version"
        return 0
    end

    echo "===LOG_$(date +%s) [$(date +%c)]===" >>$log_file

    echo "checking for menu..." >>$log_file
    echo "Env Variable PROGRUN_MENU: \"$PROGRUN_MENU\"" >>$log_file
    echo "Flag --menu: \"$dmenu\"" >>$log_file
    echo "menu set to \"$dmenu_cmd\" with args \"$(echo (string split ' ' -- $dmenu)[2..])\"" >>$log_file

    set -l ignore_wksp 1
    if set -q _flag_ignore_workspace
        set ignore_wksp 0
        echo "flag set: --ignore-workspace $ignore_wksp" >>$log_file
    end

    set -l wksp 9
    if set -q _flag_workspace
        if string match -qr '^[0-9]$|^10$' -- $_flag_workspace
            set wksp $_flag_workspace
            if test "$wksp" = 0
                set wksp 10
            end
            echo "flag set: --workspace $wksp" >>$log_file
        end
    end

    set -l depth 2
    if set -q _flag_level
        if string match -qr '^[0-9]+$' -- $_flag_level
            set depth $_flag_level
            echo "flag set: --depth $depth" >>$log_file
        end
    end

    set -l target_dir "$HOME/Games"
    if set -q _flag_directory
        set target_dir (string replace -r '^~' "$HOME" $_flag_directory | path normalize)
        echo "flag set: --directory $target_dir" >>$log_file
    end

    set -l selection (find $target_dir -maxdepth $depth -type f -executable ! -name "*.*" ! -name ".*" -printf "%P\n" | eval $dmenu)

    if test -n "$selection"
        echo "set selection: $selection" >>$log_file
        set -l full_path (path normalize "$target_dir/$selection")
        echo "set full_path: $full_path" >>$log_file
        set -l parent_dir (dirname "$full_path")
        echo "set parent_dir: $parent_dir" >>$log_file
        set -l target_executable (basename "$full_path")
        echo "set target_executable: $target_executable" >>$log_file

        if test $ignore_wksp -eq 1
            hyprctl dispatch workspace $wksp >>$log_file
        end

        cd "$parent_dir"
        echo "==PROGRAM_LOG[stdout,stderr]==" >>$log_file
        setsid ./$target_executable >>$log_file 2>>&1 &

        disown
        cd - >/dev/null
    end
end
