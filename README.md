# dot-emacs (.emacs.d)

<!-- markdown-toc start - Don't edit this section.
Run M-x markdown-toc-refresh-toc -->

"Table of Contents"

- [dot-emacs (.emacs.d)](#dot-emacs-emacsd)
  - [Packages Included:](#packages-included)
    - [Core / Package Management](#core--package-management)
    - [Completion](#completion)
    - [UI](#ui)
    - [Directory Navigation](#directory-navigation)
    - [Project / File Management](#project--file-management)
    - [General Language & Coding Support](#general-language--coding-support)
    - [Specific Language Support](#specific-language-support)
    - [Reference / Utilities](#reference--utilities)
  - [Custom Themes](#custom-themes)
  - [Todo](#todo)
  - [License](#license)
  - [Version](#version)

<!-- markdown-toc end -->

Personal Emacs configuration for that1guycolin. Please modify as much as you'd
like for your own use, and definitely share any modifications you make
(I'm sure this configuration could be much better)!

## Packages Included

### Core / Package Management

- [elpaca](https://github.com/progfolio/elpaca)
- [use-package](https://github.com/jwiegley/use-package)
- [auto-compile](https://github.com/emacs-auto/auto-compile)

### Completion

- [corfu](https://github.com/minad/corfu)
- [cape](https://github.com/minad/cape)
- [yasnippet-capf](https://github.com/elken/yasnippet-capf)
- [vertico](https://github.com/minad/vertico)
- [orderless](https://github.com/oantolin/orderless)
- [marginalia](https://github.com/minad/marginalia)
- [savehist](https://www.gnu.org/software/emacs/manual/html_node/emacs/Savehist.html)

### UI

- [nerd-icons](https://github.com/rainstormstudio/nerd-icons.el)
- [nerd-icons-corfu](https://github.com/LuigiPiucco/nerd-icons-corfu)
- [nerd-icons-dired](https://github.com/rainstormstudio/nerd-icons-dired.el)
- [tab-line-nerd-icons](https://github.com/lucius-martius/tab-line-nerd-icons)
- [treemacs](https://github.com/Alexander-Miller/treemacs)
- [treemacs-projectile](https://github.com/Alexander-Miller/treemacs/blob/master/src/extra/treemacs-projectile.el)
- [treemacs-nerd-icons](https://github.com/Alexander-Miller/treemacs)
- [dashboard](https://github.com/emacs-dashboard/emacs-dashboard)

### Directory Navigation

- [ranger](https://github.com/ralesi/ranger)
- [diredfl](https://github.com/purcell/diredfl)
- [dired-efap](https://github.com/cpitclaudel/dired-efap)
- [dired-rsync](https://github.com/hrs/dired-rsync)
- [dired-rsync-transient](https://github.com/hrs/dired-rsync)
- [dired-video-thumbnail](https://github.com/captainflasmr/dired-video-thumbnail)
- [dired-narrow](https://github.com/vapniks/dired-narrow)
- [dired-quick-sort](https://github.com/mpasternak/dired-quick-sort)

### Project / File Management

- [projectile](https://github.com/bbatsov/projectile)
- [disproject](https://github.com/pkkm/disproject)
- [magit](https://github.com/magit/magit)
- [forge](https://github.com/magit/forge)
- [magit-git-toolbelt](https://github.com/thisisrc/magit-git-toolbelt)
- [magit-pre-commit](https://github.com/sigma/magit-pre-commit)
- [treemacs-magit](https://github.com/Alexander-Miller/treemacs)
- [envrc](https://github.com/purcell/envrc)
- [license-templates](https://github.com/iqbalansari/license-templates.el)
- [transient](https://github.com/magit/transient)
- [transient-dwim](https://github.com/conao3/transient-dwim)

### General Language & Coding Support

- [treesit-auto](https://github.com/ethan-leba/treesit-auto)
- [mason](https://github.com/yyoncho/emacs-mason)
- [lsp-mode](https://github.com/emacs-lsp/lsp-mode)
- [lsp-ui](https://github.com/emacs-lsp/lsp-ui)
- [lsp-treemacs](https://github.com/emacs-lsp/lsp-treemacs)
- [dap-mode](https://github.com/emacs-lsp/dap-mode)
- [flycheck](https://www.flycheck.org/)
- [flyover](https://github.com/pashinin/flyover)
- [flycheck-inline](https://github.com/flycheck/flycheck-inline)
- [flycheck-color-mode-line](https://github.com/flycheck/flycheck-color-mode-line)
- [apheleia](https://github.com/radian-software/apheleia)
- [yasnippet](https://github.com/joaotavora/yasnippet)
- [yasnippet-snippets](https://github.com/AndreaCrotti/yasnippet-snippets)
- [editorconfig](https://github.com/editorconfig/editorconfig-emacs)

### Specific Language Support

- [fish-mode](https://github.com/wwwjfy/emacs-fish-mode)
- [modern-sh](https://github.com/wyuenho/modern-sh)
- [cmake-mode](https://github.com/Kitware/CMake/blob/master/Auxiliary/cmake-mode.el)
- [slime](https://github.com/slime/slime)
- [flycheck-eask](https://github.com/emacs-eask/flycheck-eask)
- [lisp-semantic-hl](https://github.com/Lindydancer/lisp-semantic-highlight)
- [markdown-mode](https://github.com/jrblevin/markdown-mode)
- [python-x](https://github.com/pythonic-emacs/python-x)
- [uv-mode](https://github.com/z80dev/uv-mode)
- [auto-virtualenv](https://github.com/that1guycolin/auto-virtualenv)
- [live-py-mode](https://github.com/andyjeffries/live-py-mode)
- [eask-mode](https://github.com/emacs-eask/eask-mode)
- [auto-rename-tag](https://github.com/minad/auto-rename-tag)
- [elisp-def](https://github.com/Wilfred/elisp-def)
- [suggest](https://github.com/Wilfred/suggest)
- [test-simple](https://github.com/rocky/emacs-test-simple)

### Reference / Utilities

- [gcmh](https://github.com/emacscollective/gcmh)
- [which-key](https://github.com/justbur/emacs-which-key)
- [rainbow-delimiters](https://github.com/Fanael/rainbow-delimiters)
- [exec-path-from-shell](https://github.com/purcell/exec-path-from-shell)
- [mistty](https://github.com/mistty/mistty)
- [buffer-terminator](https://github.com/cleesmith/buffer-terminator)
- [adjust-parens](https://github.com/Fanael/adjust-parens)
- [deadgrep](https://github.com/Wilfred/deadgrep)
- [emms](https://www.gnu.org/software/emms/)

## Custom Themes

The following custom themes are included in the `themes/` directory:

- [Wayland-Yutani](https://github.com/jstaursky/weyland-yutani-theme/tree/e89a63a62e071180c9cdd9067679fadc3f7bf796)
  (default)
- [Material](https://github.com/cpaulik/emacs-material-theme/tree/6823009bc92f82aa3a90e27e1009f7da8e87b648)
- [Monokai](https://github.com/oneKelvinSmith/monokai-emacs/tree/dacd9d8a8867afea3ed76b15a6c997053ff88093)
- [Morrowind](https://github.com/SamuelBanya/morrowind-theme/tree/f197ef02e96fa3b8a38eca25ba750df7b843e564)
- [Night-Owl](https://github.com/aaronjensen/night-owl-emacs/tree/13d9966ffda746231eef0dc905b50303309f115e)
- [Nord](https://github.com/nordtheme/emacs/tree/551b2b8a0751c0a22e5c5daa6958152f208e668f)
- [Nordic-Night](https://codeberg.org/ashton314/nordic-night)
- [Oblivion](https://codeberg.org/ideasman42/emacs-theme-oblivion)
- [Obsidian](https://github.com/mswift42/obsidian-theme/tree/f45efb2ebe9942466c1db6abbe2d0e6847b785ea)
- [Overcast](https://github.com/myTerminal/overcast-theme/tree/e02b835a08919ead079d7221d513348ac02ba92e)
- [VS-Dark](https://github.com/emacs-vs/vs-dark-theme/tree/ebc176a83808772746c55c91420a95b28b84c869)

## Todo

- Finish lite build
- Explore AI integrations

## License

GPL-3.0

## Version

0.1.0
