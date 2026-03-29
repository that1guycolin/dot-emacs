function list-all-packages --description "Prints a list of all pacakges called with 'use-package' in '~/.emacs.d/init.el.d'."
    function usage
        echo "USAGE: list-all-packages [OPTIONS]"
        echo ""
        echo "List all packages invoked via use-package in '~/.emacs.d/init.el.d'."
        echo ""
        echo "FLAGS:"
        echo "  -a, --aditional-package [PACKAGE]"
        echo "    Include PACKAGE in list. Useful if you call any packages with a different macro."
        echo ""
        echo "  -e, --elpaca"
        echo "    Add 'elpaca' and 'elpaca-use-package' to package list."
        echo "    This flag is the same as running '-a elpaca -a elpaca-use-package'."
        echo ""
        echo "  -h,--help"
        echo "    Print this message and exit."
        echo ""
    end

    argparse 'a/additional-package=+&' e/elpaca h/help -- $argv
    or return

    if set -ql _flag_h
        usage
        return
    end

    if test (count $argv) -gt 0
        echo "ERROR: Argument(s) $argv not recognized."
        return
    end

    if set -ql _flag_a
        set addtnl_pkgs $_flag_a
    else
        set addtnl_pkgs ""
    end

    if set -ql _flag_e
        set addtnl_pkgs elpaca elpaca-use-package $addtnl_pkgs
    end

    set -l temp (mktemp)
    for pkg in $addtnl_pkgs
        echo $pkg >>$temp
    end
    for elfile in $HOME/.emacs.d/init.el.d/*.el
        ~/projects/dot-emacs/list-use-packages.el $elfile >>$temp
    end
    set -l temp2 (mktemp)
    sort $temp | uniq >$temp2
    set -l package_names (cat $temp2)
    echo "" >$temp

    for package in $package_names
        echo "$package," >>$temp
    end
    set -l packages (cat $temp)
    echo "$packages"
end
