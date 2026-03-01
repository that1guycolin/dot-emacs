# dot-emacs (.emacs.d)

<!--toc:start-->

- [dot-emacs (.emacs.d)](#dot-emacs-emacsd)
  - [Installation](#installation)
  - [Requirements](#requirements)
  - [Supported Languages](#supported-languages)
    - [Full Support (LSP, linting, formatting)](#full-support-lsp-linting-formatting)
  - [Configuration Structure](#configuration-structure)
    - [Core / Package Management](#core-package-management)
    - [UI / Completion](#ui-completion)
    - [Project / File Management](#project-file-management)
    - [General Language & Coding Support](#general-language-coding-support)
    - [Specific Language Support](#specific-language-support)
    - [Reference / Utilities](#reference-utilities)
  - [Custom Themes](#custom-themes)
  - [Todo](#todo)
  - [License](#license)
  - [Version](#version)
  <!--toc:end-->

Personal Emacs configuration for that1guycolin. Please modify as much as you'd
like for your own use, and definitely share any modifications you make
(I'm sure this configuration could be much better)!

## Installation

Some users may only need to run 'git clone...' but running the two lines
beforehand backs up any existing Emacs configuration you might have in place.

```bash
[ ! -d "${HOME}/.emacs.d" ] || mv "${HOME}/.emacs.d" "${HOME}/.emacs.d.bak"
[ ! -f "${HOME}/.emacs" ] || mv ${HOME}/.emacs "${HOME}/.emacs.bak"
git clone https://github.com/that1guycolin/dot-emacs.git "${HOME}/.emacs.d"
```

FYI, your first startup may take 2-3 minutes or longer, since you will be
downloading and building all of these packages. Once that's out of the way,
your typical startup time should be under 10 seconds; mine averages ~3-5 seconds.

## Requirements

- Emacs 30.2 or later
- [elpaca](https://github.com/progfolio/elpaca)
  (auto-installed on first startup)

## Supported Languages

### Full Support (LSP, linting, formatting)

Please note that some languages require extra tools. These can be downloaded
from your package manager, npm, pip, uv, or cargo.
(The installation method/options depend heavily on your distro/setup).

- **bash** - shellcheck, shfmt
- **cmake** - neocmakelsp
- **common-lisp** - ros (Roswell)
- **emacs-lisp** - All support built-in
- **fish** - fish-lsp, fish_indent (included with fish)
- **json** - prettier
- **markdown** - marksman, prettier
- **python** - ty, ruff, debugpy
- **toml** - tombi
- **xml** - xmlstarlet
- **yaml** - yamllint

## Configuration Structure

I use a modular config, with **init.el** as the entry point.

- **early-init.el** - Early startup settings (UI, backup/load path)
- **init.el** - Main entry point, loads modules from ~init.el.d/~
- **init.el.d/**
  - **load-first.el** - Elpaca bootstrap, use-package, auto-compile
  - **project-support-configs.el** - Magit, Projectile, Treemacs, Forge
  - **language-specific-configs.el** - LSP, flycheck, apheleia, language modes
  - **user-interface-config.el** - Dashboard, Corfu, Vertico, themes, Dired extensions
  - **external-connections.el** - Org-mode, EMMS media player
  - **user-functions.el** - Theme cycling, font switching functions
- **themes/** - Themes (weyland-yutani is default)
- **Eask** - Eask package manager configuration

This configuration uses the following packages:

### Core / Package Management

- [elpaca](https://github.com/progfolio/elpaca) -
  Functional package manager
- [use-package](https://github.com/jwiegley/use-package) -
  Configuration macro for packages

### UI / Completion

- [corfu](https://github.com/minad/corfu) - Inline completion UI
- [vertico](https://github.com/minad/vertico) - Minimalist vertical completion
  UI
- [orderless](https://github.com/oantolin/orderless) -
  Completion style that supports filtering patterns
- [marginalia](https://github.com/minad/marginalia) - Rich annotations in
  minibuffer
- [savehist](https://www.gnu.org/software/emacs/manual/html_node/emacs/Savehist.html)
  \- Save minibuffer history
- [nerd-icons](https://github.com/rainstormstudio/nerd-icons.el) - Icons from
  Nerd Fonts
- [treemacs](https://github.com/Alexander-Miller/treemacs) - File tree viewer
- [treemacs-projectile](https://github.com/Alexander-Miller/treemacs-projectile)
  \- Treemacs + Projectile integration
- [treemacs-nerd-icons](https://github.com/Alexander-Miller/treemacs) -
  Treemacs Nerd Icons support
- [which-key](https://github.com/justbur/emacs-which-key) - Display available
  keybindings
- [rainbow-delimiters](https://github.com/Fanael/rainbow-delimiters) - Colorize
  delimiters
- [auto-complete](https://github.com/auto-complete/auto-complete) -
  Auto-completion framework
- [dashboard](https://github.com/emacs-dashboard/emacs-dashboard) -
  Startup screen

### Project / File Management

- [projectile](https://github.com/bbatsov/projectile) - Project interaction
  library
- [magit](https://github.com/magit/magit) - Git interface for Emacs
- [forge](https://github.com/magit/forge) - Git forges integration (GitHub)
- [magit-git-toolbelt](https://github.com/thisisrc/magit-git-toolbelt) -
  Additional magit commands
- [magit-pre-commit](https://github.com/sigma/magit-pre-commit) - Pre-commit
  hook support
- [deadgrep](https://github.com/Wilfred/deadgrep) - Search tool using ripgrep
- [envrc](https://github.com/purcell/envrc) - direnv integration
- [license-templates](https://github.com/iqbalansari/license-templates.el) -
  Insert license headers
- [transient](https://github.com/magit/transient) - Transient menus

### General Language & Coding Support

- [lsp-mode](https://github.com/emacs-lsp/lsp-mode) - Language Server Protocol
- [lsp-ui](https://github.com/emacs-lsp/lsp-ui) - UI improvements for lsp-mode
- [lsp-treemacs](https://github.com/emacs-lsp/lsp-treemacs) - Treemacs
  integration for LSP
- [dap-mode](https://github.com/emacs-lsp/dap-mode) - Debug Adapter Protocol
  support
- [dap-python](https://github.com/emacs-lsp/dap-python) - Python DAP support
- [flycheck](https://www.flycheck.org/) - On-the-fly syntax checking
- [flycheck-inline](https://github.com/flycheck/flycheck-inline) -
  Inline error display
- [flycheck-color-mode-line](https://github.com/flycheck/flycheck-color-mode-line)
  \- Flycheck in mode line
- [flycheck-eask](https://github.com/emacs-eask/flycheck-eask) - Eask support
  for flycheck
- [apheleia](https://github.com/radian-software/apheleia) - Code formatter
  interface

### Specific Language Support

- [fish-mode](https://github.com/wwwjfy/emacs-fish-mode) - Fish shell
- [sly](https://github.com/joaotavora/sly) - Superior Lisp Interaction
- [json5-ts-mode](https://github.com/AndreasRihsmanel/json5-mode) - JSON/JSON5
- [markdown-ts-mode](https://github.com/AlphaYuan/Emacs-Markdown-Mode) -
  Markdown
- [python-x](https://github.com/pythonic-emacs/python-x) - Extended Python
  support
- [uv-mode](https://github.comz80dev/uv-mode) - Astral-uv integration
- [live-py-mode](https://github.com/andyjeffries/live-py-mode) - Live Python
  coding
- [eask-mode](https://github.com/emacs-eask/eask-mode) - Eask package manager
- [elisp-def](https://github.com/Wilfred/elisp-def) - Definition lookup for
  Elisp
- [suggest](https://github.com/Wilfred/suggest) - Elisp code
  suggestion
- [test-simple](https://github.com/rocky/emacs-test-simple) - Simple test
  framework

### Reference / Utilities

- [yasnippet](https://github.com/joaotavora/yasnippet) - Snippet system
- [yasnippet-snippets](https://github.com/AndreaCrotti/yasnippet-snippets) -
  Collection of snippets
- [editorconfig](https://github.com/editorconfig/editorconfig-emacs) -
  EditorConfig support
- [mistty](https://github.com/mistty/mistty) - Terminal emulator
- [buffer-terminator](https://github.com/cleesmith/buffer-terminator) -
  Auto-close idle buffers
- [adjust-parens](https://github.com/Fanael/adjust-parens) - Adjust parenthesis
- [emms](https://www.gnu.org/software/emms/) - Emacs Multimedia System

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
- Explore AI-assisted coding integrations

## License

GPL-3.0

## Version

0.1.0
