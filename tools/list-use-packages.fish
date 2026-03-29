function list-use-packages -d "List all packages invoked via use-package in an .el file."
    argparse h/help -- $argv

    if test (count $argv) -ne 1
        echo "ERROR: Function requires a .el file as argument."
        set _flag_h true
        return
    end

    if not string match -q "*.el" "$argv"
        echo "ERROR: Argument must be a file with extension .el."
        set _flag_h true
        return
    end

    if set -ql _flag_h
        echo "USAGE: list-use-packages FILE.el"
        echo ""
        echo "List all packages invoked via use-package in a .el file"
        echo "in your Emacs config folder."
        echo ""
        echo "FLAGS:"
        echo "  -h,--help"
        echo "     Print this message and exit."
        echo ""
        return
    end

    set -l temp (mktemp)
    emacs --script \
        $HOME/.emacs.d/tools/list-use-packages.el $argv \
        | sort >$temp
    set -l package_names (cat $temp)

    echo "Packages included:" >$temp
    for package in $package_names
        echo "$package," >>$temp
    end
    set -l packages (cat $temp)
    echo "$packages"
end
