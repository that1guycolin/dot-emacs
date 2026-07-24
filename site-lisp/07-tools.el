;;; 07-tools.el --- Integrate or Emulate External Tools -*- lexical-binding: t -*-

;;; Packages included:
;; casual, casual-avy, dirvish, dwim-shell-command, eat, elisp-dev-mcp, ellama,
;; emacs-everywhere, emms, emms-info-mediainfo, free-keys, ghostel, gptel,
;; htmlize, llm, llm-ollama, mcp-server-lib, mistty, native-complete, org-mcp,
;; ready-player, recentf, telega, vterm, with-editor

;;; Commentary:
;; This file contains use-package objects for packages that help integrate Emacs
;; with external applications (e.g., "docker") or packages that extend Emacs'
;; functionality to the extent it mirrors an external tool (e.g., "dirvish").

;;; Code:
;;; Terminals:
;; Emulate A Terminal
(use-package eat
  :defer t
  :bind ("C-c t e"   . eat)
  :hook (eshell-mode . eat-eshell-visual-command-mode))

;; Excellent terminal shell buffer
;; (based on libghostty)
(use-package ghostel
  :ensure (ghostel
           :source nil :package "ghostel" :id ghostel :fetcher github
           :repo "dakra/ghostel"
           :files (:defaults
                   "README.md" "etc" "src" "vendor" "build.zig" "build.zig.zon"
                   "symbols.map" ("build" "Makefile"))
           :type git :protocol https :inherit t :depth treeless)
  :defer t
  :bind ("C-c t g" . ghostel)
  :custom (ghostel-module-auto-install 'compile)
  :config (with-eval-after-load 'disproject
            (transient-append-suffix 'disproject-dispatch
              "s" '("o" "Ghostel" ghostel-project))))

;; Commit shell layer
(use-package mistty
  :defer t
  :bind (("C-c t m" . mistty)
         (:map mistty-prompt-map
               ("M-<up>"    . mistty-send-key)
               ("M-<down>"  . mistty-send-key)
               ("M-<left>"  . mistty-send-key)
               ("M-<right>" . mistty-send-key))))

;; The old workhorse
(use-package vterm
  :defer t
  :bind (("C-c t v" . vterm)
         ("C-c t V" . vterm-other-window))
  :init (setq vterm-always-compile-module t))

;; Set EDITOR to current Emacs session
(use-package with-editor
  :defer t
  :hook ((eshell-mode shell-mode vterm-mode) . with-editor-export-editor))

;; Shell completion in shell buffers
(use-package native-complete
  :defer t
  :hook (shell-mode . (lambda ()
                        (add-to-list
                         'completion-at-point-functions
                         #'native-complete-at-point)))
  :commands native-complete-at-point)


;;; File explorer:
(use-package recentf
  :ensure nil
  :demand t
  :preface
  (defvar no-littering-var-directory)
  (defvar no-littering-etc-directory)
  :bind ("C-x C-r" . recentf-open)
  :config
  (add-to-list 'recentf-exclude no-littering-var-directory)
  (add-to-list 'recentf-exclude no-littering-etc-directory)
  (recentf-mode 1))

;; `Dired' with "batteries included"
(use-package dirvish
  :defer t
  :preface
  (declare-function transient-define-prefix "transient")
  
  (defvar user/dirvish-clipboard-files nil
    "Files currently staged by `user/dirvish-copy' or `user/dirvish-cut'.")

  (defvar user/dirvish-clipboard-action nil
    "Current Dirvish clipboard action.
Expected values are `copy' or `cut'.")

  (defvar-local user/dirvish-preview-buffer nil
    "Non-nil when this buffer was made read-only as a Dirvish preview.")

  (defun user/dirvish--file-at-point ()
    "Return the file at point, or signal a user error."
    (or (dired-get-filename nil t)
        (user-error "No file at point")))

  (defun user/dirvish--marked-files-or-current ()
    "Return marked files, or the file at point if nothing is marked."
    (let ((files (dired-get-marked-files nil nil)))
      (unless files
        (user-error "No files selected"))
      files))

  (defun user/dirvish-rename-file ()
    "Rename the file at point by editing only its basename."
    (interactive)
    (let* ((old-file (directory-file-name (user/dirvish--file-at-point)))
           (old-dir  (file-name-directory old-file))
           (old-name (file-name-nondirectory old-file))
           (new-name (read-string "Rename to: " old-name)))
      (when (string-empty-p (string-trim new-name))
        (user-error "Filename cannot be empty"))
      (when (file-name-directory new-name)
        (user-error "Rename only changes the filename, not the directory"))
      (when (member new-name '("." ".."))
        (user-error "Invalid filename: %s" new-name))
      (let ((new-file (expand-file-name new-name old-dir)))
        (if (string= old-file (directory-file-name new-file))
            (message "Rename canceled")
          (rename-file old-file new-file nil)
          (revert-buffer)
          (dired-goto-file new-file)
          (message "Renamed %s -> %s" old-name new-name)))))

  (defun user/dirvish-copy ()
    "Stage marked files, or current file, for copying."
    (interactive)
    (setq user/dirvish-clipboard-files (user/dirvish--marked-files-or-current)
          user/dirvish-clipboard-action 'copy)
    (message "Copied %d item(s)" (length user/dirvish-clipboard-files)))

  (defun user/dirvish-cut ()
    "Stage marked files, or current file, for moving."
    (interactive)
    (setq user/dirvish-clipboard-files (user/dirvish--marked-files-or-current)
          user/dirvish-clipboard-action 'cut)
    (message "Cut %d item(s)" (length user/dirvish-clipboard-files)))

  (defun user/dirvish--paste-target-directory ()
    "Return the directory where staged files should be pasted.
If point is on a directory, paste into that directory.
Otherwise paste into the current Dired/Dirvish directory."
    (let ((file (dired-get-filename nil t)))
      (file-name-as-directory
       (if (and file (file-directory-p file))
           file
         (dired-current-directory)))))

  (defun user/dirvish--copy-one-file (src dest)
    "Copy SRC to DEST without overwriting."
    (if (file-directory-p src)
        (copy-directory src dest t nil nil)
      (copy-file src dest nil t)))

  (defun user/dirvish-paste ()
    "Paste staged files into the directory at point or current directory."
    (interactive)
    (unless user/dirvish-clipboard-files
      (user-error "Nothing has been copied or cut"))
    (unless (memq user/dirvish-clipboard-action '(copy cut))
      (user-error "Unknown clipboard action: %s" user/dirvish-clipboard-action))
    (let* ((dest-dir (user/dirvish--paste-target-directory))
           (files user/dirvish-clipboard-files)
           (action user/dirvish-clipboard-action)
           first-dest)
      (dolist (src files)
        (let* ((base (file-name-nondirectory (directory-file-name src)))
               (dest (expand-file-name base dest-dir)))
          (when (file-exists-p dest)
            (user-error "Target already exists: %s" dest))
          (unless first-dest
            (setq first-dest dest))
          (pcase action
            ('copy (user/dirvish--copy-one-file src dest))
            ('cut  (rename-file src dest nil)))))
      (when (eq action 'cut)
        (setq user/dirvish-clipboard-files nil
              user/dirvish-clipboard-action nil))
      (revert-buffer)
      (when (and first-dest (file-exists-p first-dest))
        (ignore-errors (dired-goto-file first-dest)))
      (message "%s %d item(s) to %s"
               (pcase action
                 ('copy "Copied")
                 ('cut  "Moved"))
               (length files)
               dest-dir)))

  (defun user/dirvish-down-directory ()
    "Open the directory at point in the current Dirvish window."
    (interactive)
    (let ((file (user/dirvish--file-at-point)))
      (unless (file-directory-p file)
        (user-error "Not a directory: %s" file))
      (dired-find-file)))

  (defun user/dirvish-make-opened-file-editable ()
    "Undo preview read-only state after opening a file normally."
    (when (and buffer-file-name
               (bound-and-true-p user/dirvish-preview-buffer))
      (setq-local user/dirvish-preview-buffer nil)
      (when (bound-and-true-p view-mode)
        (view-mode -1))
      (when (file-writable-p buffer-file-name)
        (read-only-mode -1))))

  (defun user/dirvish-return-dwim ()
    "On directories, descend.  On files, open the file normally."
    (interactive)
    (let ((file (user/dirvish--file-at-point)))
      (if (file-directory-p file)
          (user/dirvish-down-directory)
        (dired-find-file)
        (user/dirvish-make-opened-file-editable))))

  (defun user/dirvish-tab-dwim ()
    "Change behaviour based on current marker positions.
On directories, toggle subtree.  On files, use Dirvish file outline viewer."
    (interactive)
    (unless (fboundp 'dirvish-subtree-toggle)
      (user-error "`dirvish-subtree-toggle' is not available"))
    (dirvish-subtree-toggle))

  (defun user/dirvish-preview-read-only ()
    "Make Dirvish preview buffers read-only."
    (setq-local user/dirvish-preview-buffer t)
    (read-only-mode 1))

  :bind ("C-x d" . dirvish)
  :commands (dirvish-dwim)
  :functions (dired-create-directory
              dired-create-empty-file dired-current-directory dired-do-rename
              dired-find-file dired-get-filename dired-get-marked-files
              dired-goto-file dired-next-line dired-previous-line
              dired-up-directory dirvish-override-dired-mode
              dirvish-subtree-toggle user/dirvish-dispatch)
  :defines (dirvish-mode-map)
  :init (dirvish-override-dired-mode 1)
  :custom
  (dirvish-hide-cursor nil)
  (dirvish-attributes '(subtree-state file-size file-time nerd-icons))
  (dirvish-hide-details t)
  (dirvish-reuse-session nil)
  :config
  (dolist (plugin '(dirvish-extras dirvish-subtree dirvish-yank))
    (require plugin))
  (dolist (optional-plugin '(dirvish-vc dirvish-emerge))
    (require optional-plugin nil t))
  
  (add-hook 'dirvish-preview-setup-hook #'user/dirvish-preview-read-only)

  (defvar user/dirvish-dispatch)
  (transient-define-prefix user/dirvish-dispatch ()
    "Custom Dirvish command menu."
    [
     ["Navigation"
      ("C-p"   "Previous line"       dired-previous-line :transient t)
      ("C-n"   "Next line"           dired-next-line :transient t)
      ("^"     "Up directory"        dired-up-directory :transient t)
      ("C-M-p" "Up directory"        dired-up-directory :transient t)
      ("C-M-n" "Down directory"      user/dirvish-down-directory :transient t)
      ("TAB"   "Subtree / outline"   user/dirvish-tab-dwim :transient t)
      ("RET"   "Open / down"         user/dirvish-return-dwim)]

     ["File operations"
      ("R"   "Rename filename only" user/dirvish-rename-file)
      ("m"   "Move..."              dired-do-rename)
      ("C-w" "Cut"                  user/dirvish-cut)
      ("M-w" "Copy"                 user/dirvish-copy)
      ("C-y" "Paste here"           user/dirvish-paste)
      ("c f" "Create file"          dired-create-empty-file)
      ("c d" "Create directory"     dired-create-directory)]

     ["Dirvish native menus"
      ("a"   "Setup UI"             dirvish-setup-menu)
      ("f"   "File info"            dirvish-file-info-menu)
      ("o"   "Quick access"         dirvish-quick-access)
      ("s"   "Sort"                 dirvish-quicksort)
      ("l"   "ls switches"          dirvish-ls-switches-menu)
      ("*"   "Mark menu"            dirvish-mark-menu)
      ("y"   "Yank menu"            dirvish-yank-menu)]
     [""
      ("v"   "VC menu"              dirvish-vc-menu)
      ("N"   "Narrow"               dirvish-narrow)
      ("M-b" "History back"         dirvish-history-go-backward :transient t)
      ("M-f" "History forward"      dirvish-history-go-forward :transient t)
      ("M-e" "Emerge menu"          dirvish-emerge-menu)
      ("g"   "Revert"               revert-buffer :transient t)
      ("q"   "Quit Dirvish"         dirvish-quit)]])
  
  (let ((map dirvish-mode-map)
        (create-map (make-sparse-keymap)))
    (keymap-set map "C-p"        #'dired-previous-line)
    (keymap-set map "C-n"        #'dired-next-line)
    (keymap-set map "R"          #'user/dirvish-rename-file)
    (keymap-set map "m"          #'dired-do-rename)
    (keymap-set map "c"            create-map)
    (keymap-set map "C-w"        #'user/dirvish-cut)
    (keymap-set map "M-w"        #'user/dirvish-copy)
    (keymap-set map "C-y"        #'user/dirvish-paste)
    (keymap-set map "^"          #'dired-up-directory)
    (keymap-set map "C-M-p"      #'dired-up-directory)
    (keymap-set map "C-M-n"      #'user/dirvish-down-directory)
    (keymap-set map "TAB"        #'user/dirvish-tab-dwim)
    (keymap-set map "RET"        #'user/dirvish-return-dwim)
    (keymap-set map "?"          #'user/dirvish-dispatch)
    (keymap-set create-map "f"   #'dired-create-empty-file)
    (keymap-set create-map "d"   #'dired-create-directory)))

;; execute shell commands on marked files
(use-package dwim-shell-command
  :defer t
  :preface
  (keymap-global-unset "M-!")

  (defun user/convert-ts-to-mp4 ()
    "Convert .ts files to .mp4 using FFmpeg."
    (interactive)
    (dwim-shell-command-on-marked-files
     "Convert to mp4"
     "ffmpeg -hide_banner -v quiet -stats -y -i '<<f>>' -map 0:v -map 0:a \
-c copy -movflags +faststart '<<fne>>.mp4'"
     :utils "ffmpeg"))

  (defun user/extract-video-only ()
    "Extract only video streams from file using FFmpeg."
    (interactive)
    (dwim-shell-command-on-marked-files
     "Extract video streams."
     "ffmpeg -hide_banner -v quiet -stats -y -i '<<f>>' -map 0:v -c copy \
-movflags +faststart '<<fne>>-video.mp4'"
     :utils "ffmpeg"))

  (defun user/extract-audio-only ()
    "Extract only audio streams from file using FFmpeg."
    (interactive)
    (dwim-shell-command-on-marked-files
     "Extract audio streams."
     "ffmpeg -hide_banner -v quiet -stats -y -i '<<f>>' -map 0:a -c copy \
-movflags +faststart '<<fne>>-audio.m4a'"
     :utils "ffmpeg"))
  
  :bind (("M-!" . dwim-shell-command)
         :map dirvish-mode-map
         ("F" . user/ffmpeg-actions-map))
  :commands (dwim-shell-command-on-marked-files)
  :config
  (defvar-keymap user/ffmpeg-actions-map
    :doc "Keymap with FFmpeg actions to run on marked files in dired/dirvish."
    "4" #'user/convert-ts-to-mp4
    "v" #'user/extract-video-only
    "a" #'user/extract-audio-only)
  (transient-append-suffix 'user/dirvish-dispatch "c d"
    '("F" "FFmpeg Actions" user/ffmpeg-actions-map)))

;; Launch media directly from `dirvish'
(use-package ready-player
  :defer t
  :hook (dired-mode . ready-player-mode))


;;; LLM:
(unless (eq system-type 'android)
  (use-package llm
    :demand t)

  (use-package llm-ollama
    :ensure nil
    :after (llm)
    :demand t
    :preface
    (defvar user/ollama-alist
      `((codegemma:2b              . ,(* 1  4096))
        (codegemma:7b              . ,(* 2  4096))
        (codellama:7b-instruct     . ,(* 2  4096))
        (cogito:3b                 . ,(* 1  4096))
        (cogito:8b                 . ,(* 2  4096))
        (gemma4:e2b                . ,(* 1  4096))
        (gemma4:e4b                . ,(* 2  4096))
        (gpt-oss:120b-cloud        . ,(* 16 4096))
        (granite4.1:3b             . ,(* 1  4096))
        (granite4.1:8b             . ,(* 2  4096))
        (granite-code:3b           . ,(* 1  4096))
        (granite-code:8b           . ,(* 2  4096))
        (lfm2.5-thinking:1.2b      . ,(* 2  4096))
        (llama3.1:8b               . ,(* 2  4096))
        (llama3.2:1b               . ,(* 1  4096))
        (llama3.2:3b               . ,(* 2  4096))
        (nomic-embed-text:latest   . ,(* 2  4096))
        (opencoder:1.5b            . ,(* 1  4096))
        (opencoder:8b              . ,(* 2  4096))
        (qwen3:0.6b                . ,(* 1  4096))
        (qwen3:1.7b                . ,(* 1  4096))
        (qwen3:4b                  . ,(* 2  4096))
        (qwen3.5:cloud             . ,(* 16 4096))
        (qwen3:8b                  . ,(* 2  4096))
        (qwen3-coder:480b-cloud    . ,(* 16 4096))
        (qwen3-coder-next:cloud    . ,(* 16 4096))
        (stable-code:3b            . ,(* 1  4096)))
      "Alist containing Ollama models and their context length.
Models on this list are either cloud-based or have already been downloaded
to the user's device.")

    (defvar user/ollama-models (mapcar #'car user/ollama-alist)
      "List of ollama-models (without their context lengths).")

    (defvar user/openrouter-list
      '(google/gemma-3-27b-it:free
        meta-llama/llama-3.3-70b-instruct:free openai/gpt-oss-120b:free
        openrouter/free qwen/qwen3-4b:free qwen/qwen3-coder:free)
      "A list of user-selected LLMs available through OpenRouter.")

    (defun user/ensure-ollama-system-service ()
      "Check if the system-wide Ollama service is active and start it if not."
      (interactive)
      (let ((status (shell-command-to-string "systemctl is-active ollama")))
        (if (string-prefix-p "active" (string-trim status))
            (message "Ollama system service is already running.")
          (progn
            (message "Ollama is down. Requesting system start...")
            (shell-command "systemctl start ollama &")
            (message "Ollama service start command sent.")
            (kill-buffer "*Async Shell Command*")))))
    
    (defun user/llm-ollama-model-setup (model)
      "Setup Ollama MODEL for use with llm, ellama, etc..."
      (interactive
       (list
        (completing-read "Model: " (mapcar #'car user/ollama-alist) nil t)))
      (unless (member model (mapcar #'car user/ollama-alist))
        (error "Model not in `user/ollama-alist'"))
      (make-llm-ollama
       :chat-model (symbol-name model)
       :embedding-model "nomic-embed-text"
       :default-chat-max-tokens (cdr (assoc model user/ollama-alist))))
    
    :functions (make-llm-ollama))

  ;; MCP:
  (use-package mcp-server-lib
    :defer t
    :commands (mcp-server-lib-start mcp-server-lib-stop))

  (use-package org-mcp
    :defer t
    :commands (org-mcp-enable)
    :custom (org-mcp-allowed-files
             (directory-files-recursively org-directory "\\.org\\'")))

  (use-package elisp-dev-mcp
    :defer t
    :commands (elisp-dev-mcp-enable))

  ;; GPTel
  (use-package gptel
    :defer t
    :preface
    (declare-function auth-source-pick-first-password "auth-source")

    (defvar user/gptel--backend-map
      `(("Ollama"     . (name "Ollama"  models ,(mapcar #'car user/ollama-alist)))
        ("OpenRouter" . (name "OpenRouter"  models user/openrouter-list)))
      "Alist mapping display names to backend metadata plists.")

    (defun user/gptel-switch-backend ()
      "Interactively select a gptel backend, then select a model for it.
The user is allowed to select their already-active backend, so this function
doubles as a model-switcher."
      (interactive)
      (let* ((backend-name
              (completing-read
               (format "Backend (current: %s): "
                       (gptel-backend-name gptel-backend))
               user/gptel--backend-map nil t))
             (meta  (cdr (assoc backend-name user/gptel--backend-map)))
             (gptel-name (plist-get meta 'name))
             (models (plist-get meta 'models))
             (model
              (completing-read
               (format "Model [%s]: " backend-name) models nil t)))
        (setq gptel-backend (gptel-get-backend gptel-name)
              gptel-model   (if (consp (car models))
                                (cdr (assoc model models))
                              (intern model)))
        (message "[gptel] Backend → %s | Model → %s"
                 backend-name gptel-model)))
    
    :commands (gptel gptel-send)
    :functions (gptel-get-backend gptel-make-ollama gptel-make-openai)
    :defines (gptel-backend)
    :config
    (user/ensure-ollama-system-service)
    (setq
     gptel-backend
     (gptel-make-ollama "Ollama"
       :host "localhost:11434"
       :stream t
       :models (mapcar #'car user/ollama-alist))
     gptel-model 'llama3.2:3b)

    (gptel-make-openai "OpenRouter"
      :host "openrouter.ai"
      :endpoint "/api/v1/chat/completions"
      :stream t
      :key (lambda ()
             (auth-source-pick-first-password
              :host "openrouter.ai"
              :user "apikey"))
      :models user/openrouter-list))

  (use-package gptel-forge-prs
    :defer t
    :hook (forge-pullreq-mode . gptel-forge-prs-install))

  ;; Ellama:
  (use-package ellama
    :defer t
    :commands (ellama-transient-main-menu)
    :functions (ellama-disable-scroll ellama-enable-scroll)
    :init (setopt ellama-language "English")
    :config
    ;; -- Model Types --
    ;; Fast:
    (defvar user/ellama-model-fast-chat
      (user/llm-ollama-model-setup 'lfm2.5-thinking:1.2b))

    (defvar user/ellama-model-fast-code
      (user/llm-ollama-model-setup 'cogito:3b))

    ;; Balanced:
    (defvar user/ellama-model-balanced-chat
      (user/llm-ollama-model-setup 'llama3.2:3b))

    (defvar user/ellama-model-balanced-summary
      (user/llm-ollama-model-setup 'qwen3:4b))

    (defvar user/ellama-model-balanced-code
      (user/llm-ollama-model-setup 'codellama:7b-instruct))

    ;; Heavy
    (defvar user/ellama-model-heavy-chat
      (user/llm-ollama-model-setup 'granite4.1:8b))

    (defvar user/ellama-model-heavy-code
      (user/llm-ollama-model-setup 'cogito:8b))

    ;; Cloud-Based
    (defvar user/ellama-model-cloud-chat
      (user/llm-ollama-model-setup 'gpt-oss:120b-cloud))

    (defvar user/ellama-model-cloud-summary
      (user/llm-ollama-model-setup 'qwen3.5:cloud))

    (defvar user/ellama-model-cloud-code
      (user/llm-ollama-model-setup 'qwen3-coder-next:cloud))

    ;; -- Functions --
    (defun user/ellama-set-tier (tier)
      "Activate default models for TIER."
      (interactive
       (list
        (completing-read "Tier: " '(fast heavy cloud balanced))))
      (pcase tier
        ('fast
         (setopt
          ellama-provider user/ellama-model-fast-chat
          ellama-coding-provider user/ellama-model-fast-code
          ellama-summarization-provider user/ellama-model-fast-chat)
         (message "Ellama tier → FAST"))

        ('balanced
         (setopt
          ellama-provider user/ellama-model-balanced-chat
          ellama-coding-provider user/ellama-model-balanced-code
          ellama-summarization-provider user/ellama-model-balanced-summary)
         (message "Ellama tier → BALANCED"))

        ('heavy
         (setopt
          ellama-provider user/ellama-model-heavy-chat
          ellama-coding-provider user/ellama-model-heavy-code
          ellama-summarization-provider user/ellama-model-balanced-summary)
         (message "Ellama tier → HEAVY"))

        ('cloud
         (setopt
          ellama-provider user/ellama-model-cloud-chat
          ellama-coding-provider user/ellama-model-cloud-code
          ellama-summarization-provider user/ellama-model-cloud-summary)
         (message "Ellama tier → CLOUD"))))
    
    ;; -- Defaults --
    (setopt
     ellama-provider user/ellama-model-fast-chat
     ellama-coding-provider user/ellama-model-fast-code
     ellama-summarization-provider user/ellama-model-balanced-summary
     ;; Display
     ellama-chat-display-action-function #'display-buffer-full-frame
     ellama-instant-display-action-function #'display-buffer-at-bottom)

    (advice-add 'pixel-scroll-precision :before #'ellama-disable-scroll)
    (advice-add 'end-of-buffer :after #'ellama-enable-scroll))

  ;; Transient:
  (with-eval-after-load 'transient
    (declare-function transient-define-prefix "transient")
    (defvar user/llm-dispatch nil)
    (transient-define-prefix user/llm-dispatch ()
      "Commands to interact with LLMs in Emacs."
      ["LLM Integrations"
       ["Gptel"
        ("g ." "Activate @ cursor" gptel-send)
        ("g b" "Chat buffer"       gptel)
        ("g s" "Switch backend"    user/gptel-switch-backend :transient t)]
       ["Ellama / MCP"
        ("e"   "Ellama Menu"       ellama-transient-main-menu)
        ("m s" "Server Start"      mcp-server-lib-start)
        ("m e" "Server Stop"       mcp-server-lib-stop)]])
    (keymap-global-set "C-c a" 'user/llm-dispatch)))


;;; Media player (mpv):
(unless (eq system-type 'android)
  (use-package emms
    :defer t
    :preface
    (defun user/emms-seek-backward-med ()
      "Seek backwards 30 seconds in EMMS."
      (interactive)
      (emms-seek -30))

    (defun user/emms-seek-forward-med ()
      "Seek forward 30 seconds in EMMS."
      (interactive)
      (emms-seek 30))

    (defun user/emms-seek-backward-long ()
      "Seek backwards 2 minutes in EMMS."
      (interactive)
      (emms-seek (* -2 60)))

    (defun user/emms-seek-forward-long ()
      "Seek forward 2 minutes in EMMS."
      (interactive)
      (emms-seek (* 2 60)))

    (defvar user/emms-is-paused t
      "Non-nil if EMMS player is paused.")

    (defun user/emms-play ()
      "Set user/emms-is-paused to nil."
      (setq user/emms-is-paused nil))

    (defun user/emms-toggle-play-pause ()
      "If EMMS player is playing, pause it.  If it is paused, start playing."
      (interactive)
      (if user/emms-is-paused
          (progn
            (emms-player-mpv-resume)
            (setq user/emms-is-paused nil))
        (progn
          (emms-player-mpv-pause)
          (setq user/emms-is-paused t))))

    (defvar-keymap user/emms-view-options-map
      :doc "Different options for viewing & interacting with EMMS."
      "b" #'emms-browser
      "s" #'emms-smart-browse
      "g" #'emms-playlist-mode-go
      "p" #'emms-playlist-mode-go-popup)
    (with-eval-after-load 'which-key
      (which-key-add-keymap-based-replacements user/emms-view-options-map
        "b" "EMMS Browser"
        "s" "Smart Browse"
        "g" "Playlist Mode Go"
        "p" "Playlist Mode Popup"))
    :bind (("<f6>" . emms-browser)
           ("<f7>" . emms-smart-browse)
           ("<f8>" . emms-playlist-mode-go)
           ("<f9>" . emms-playlist-mode-go-popup)
           (:map emms-playlist-mode-map
                 ("SPC"     . user/emms-toggle-play-pause)
                 ("m"       . emms-next)
                 ("n"       . emms-previous)
                 ("s"       . emms-playlist-shuffle)
                 ("j"       . emms-seek-backward)
                 ("k"       . emms-seek-forward)
                 ("J"       . user/emms-seek-backward-med)
                 ("K"       . user/emms-seek-forward-med)
                 ("M-j"     . user/emms-seek-backward-long)
                 ("M-k"     . user/emms-seek-forward-long)
                 ("p"       . emms-play-playlist)
                 ("f"       . emms-play-file)
                 ("d"       . emms-play-find)
                 ("C-x C-s" . emms-playlist-save)
                 ("C-x n"   . emms-playlist-new)
                 ("C-x u"   . emms-playlist-mode-undo)
                 ("i"       . emms-show)
                 ("l"       . emms-sort)
                 ("C-y"     . emms-playlist-mode-yank)))
    :bind-keymap ("C-c m" . user/emms-view-options-map)
    :functions (emms-all
                emms-seek emms-player-mpv-pause emms-player-mpv-resume
                emms-playlist-mode-go emms-playlist-mode-go-popup emms-pause
                emms-next emms-previous emms-playlist-shuffle emms-seek-backward
                emms-seek-forward emms-play-playlist emms-play-file
                emms-play-find emms-playlist-save emms-playlist-new emms-show
                emms-sort emms-playlist-mode-undo emms-playlist-mode-yank)
    :defines (emms-info-functions
              emms-playlist-mode-map emms-player-mpv-command-name
              emms-player-mpv-parameters emms-browser-default-browse-type
              emms-browser-info-title-format)
    :config
    (require 'emms-setup)
    (emms-all)
    (setq
     emms-info-functions '(emms-info-native emms-info-exiftool)
     emms-player-list '(emms-player-mpv)
     emms-player-mpv-command-name "mpv"
     emms-player-mpv-parameters '("--force-window=yes"))
    (advice-add 'emms-playlist-mode-play-smart :after #'user/emms-play))

  (use-package emms-info-mediainfo
    :ensure (emms-info-mediainfo
             :host github :repo "that1guycolin/emms-info-mediainfo"
             :files (:defaults) :method https)
    :after (emms)
    :demand t
    :custom (emms-info-functions
             (append '(emms-info-mediainfo) emms-info-functions))))


;;; Miscellaneous:
;; Typing is better in Emacs
(unless (eq system-type 'android)
  (use-package emacs-everywhere
    :demand t
    :config
    ;; Customizing the frame appearance for a "popup" feel
    (setq emacs-everywhere-frame-parameters
          '((name . "emacs-everywhere") (width . 80) (height . 20)
            (menu-bar-lines . 0) (tool-bar-lines . 0)
            (vertical-scroll-bars . nil)))))

;; Podman/container integration
(use-package docker
  :defer t
  :bind ("C-c d" . docker)
  :custom (docker-command "podman"))

;; Show available keybinds
(use-package free-keys
  :defer t
  :bind ("C-c C-=" . free-keys))

;; GUIX
(use-package guix
  :defer t
  :bind ("C-c x" . guix))

;; Convert to html
(use-package htmlize
  :defer t
  :commands (htmlize-buffer
             htmlize-region htmlize-file htmlize-many-files
             htmlize-many-files-dired))

;; Global rg integration
(use-package deadgrep
  :defer t
  :bind (("<f5>"    . deadgrep)
         ("C-c C-d" . deadgrep)))

;; Project rg integration & more
(use-package rg
  :defer t
  :bind (("C-c C-r" . rg-menu)
         (:map isearch-mode-map
               ("M-s r" . rg-isearch-menu)))
  :config (require 'rg-isearch))

;; Telegram in Emacs
(unless (eq system-type 'android)
  (use-package telega
    :defer t
    :bind ("C-M-g" . telega)
    :functions (telega-mode-line-mode
                telega-appindicator-mode telega-auto-download-mode
                telega-autoplay-mode telega-chat-auto-fill-mode
                telega-highlight-text-mode telega-notifications-mode
                telega-root-auto-fill-mode telega-transient-keymaps-mode)
    :init (setq
           telega-use-docker "podman"
           telega-use-images t)
    :config
    (if (daemonp)
        (add-hook 'after-make-frame-functions
                  (lambda (frame)
                    (with-selected-frame frame
                      (unless telega-mode-line-mode
                        (telega-mode-line-mode 1)))))
      (telega-mode-line-mode 1))
    (telega-appindicator-mode 1)
    (telega-auto-download-mode 1)
    (telega-autoplay-mode 1)
    (telega-chat-auto-fill-mode 1)
    (telega-highlight-text-mode 1)
    (telega-notifications-mode 1)
    (telega-root-auto-fill-mode 1)
    (telega-transient-keymaps-mode 1)
    
    (message "Telega loaded successfully.")))


;; Casual:
(use-package casual
  :defer t
  :preface
  (declare-function org-agenda-clock-goto "org")

  (declare-function compilation-display-error "compilation-mode")
  (declare-function compilation-next-error "compilation-mode")
  (declare-function compilation-next-file "compilation-mode")
  (declare-function compilation-previous-error "compilation-mode")
  (declare-function compilation-previous-file "compilation-mode")
  
  (declare-function eww-back-url "eww")
  (declare-function eww-bookmark-browse "eww")
  (declare-function eww-browse-with-external-browser "eww")
  (declare-function eww-forward-url "eww")
  (declare-function eww-next-url "eww")
  (declare-function eww-previous-url "eww")
  (declare-function shr-next-link "eww")
  (declare-function shr-previous-link "eww")
  
  (declare-function ibuffer-backward-filter-group "ibuffer")
  (declare-function ibuffer-backwards-next-marked "ibuffer")
  (declare-function ibuffer-forward-filter-group "ibuffer")
  (declare-function ibuffer-forward-next-marked "ibuffer")
  (declare-function ibuffer-toggle-filter-group "ibuffer")
  (declare-function ibuffer-visit-buffer "ibuffer")
  (declare-function ibuffer-visit-buffer-other-window "ibuffer")
  
  (declare-function Info-history-back "Info")
  (declare-function Info-history-forward "Info")
  (declare-function Info-next "Info")
  (declare-function Info-next-reference "Info")
  (declare-function Info-prev "Info")
  (declare-function Info-prev-reference "Info")
  (declare-function Info-search "Info")
  
  (defvar calc-alg-ent-map)
  (defvar calc-mode-map)
  (defvar calendar-mode-map)
  (defvar compilation-mode-map)
  (defvar css-mode-map)
  (defvar csv-mode-map)
  (defvar emacs-lisp-mode-map)
  (defvar eshell-mode-map)
  (defvar eww-bookmark-mode-map)
  (defvar eww-mode-map)
  (defvar grep-mode-map)
  (defvar ibuffer-mode-map)
  (defvar image-mode-map)
  (defvar Info-mode-map)
  (defvar isearch-mode-map)
  (defvar makefile-mode-map)
  (defvar org-agenda-mode-map)
  (defvar org-mode-map)
  (defvar org-table-fedit-map)
  (defvar reb-lisp-mode-map)
  (defvar reb-mode-map)

  :bind (("C-o" . casual-editkit-main-tmenu)
         :map org-agenda-mode-map      ("C-o"  . casual-agenda-tmenu)
         :map calc-mode-map            ("C-o"  . casual-calc-tmenu)
         :map calc-alg-ent-map         ("C-o"  . casual-calc-tmenu)
         :map calendar-mode-map        ("C-o"  . casual-calendar)
         :map compilation-mode-map     ("C-o"  . casual-compile-tmenu)
         :map grep-mode-map            ("C-o"  . casual-compile-tmenu)
         :map css-mode-map             ("M-m"  . casual-css-tmenu)
         :map csv-mode-map             ("M-m"  . casual-csv-tmenu)
         :map emacs-lisp-mode-map      ("M-m"  . casual-elisp-tmenu)
         :map eshell-mode-map          ("C-o"  . casual-eshell-tmenu)
         :map eww-mode-map             ("C-o"  . casual-eww-tmenu)
         :map eww-bookmark-mode-map    ("C-o"  . casual-eww-bookmarks-tmenu)
         :map ibuffer-mode-map         ("C-o"  . casual-ibuffer-tmenu)
         :map ibuffer-mode-map         ("F"    . casual-ibuffer-filter-tmenu)
         :map ibuffer-mode-map         ("s"    . casual-ibuffer-sortby-tmenu)
         :map image-mode-map           ("C-o"  . casual-image-tmenu)
         :map Info-mode-map            ("C-o"  . casual-info-tmenu)
         :map isearch-mode-map         ("C-o"  . casual-isearch-tmenu)
         :map makefile-mode-map        ("M-m"  . casual-make-tmenu)
         :map org-mode-map             ("M-m"  . casual-org-tmenu)
         :map org-table-fedit-map      ("M-m"  . casual-org-table-fedit-tmenu)
         :map reb-mode-map             ("C-o"  . casual-re-builder-tmenu)
         :map reb-lisp-mode-map        ("C-o"  . casual-re-builder-tmenu))
  :functions (casual-ediff-install
              casual-ediff-tmenu casual-editkit-windows-tmenu
              casual-editkit-rectangle-tmenu casual-editkit-registers-tmenu
              casual-editkit-project-tmenu casual-lib-browse-forward-paragraph
              casual-lib-browse-backward-paragraph
              casual-eww-backward-paragraph-link
              casual-eww-forward-paragraph-link
              casual-info-browse-backward-paragraph
              casual-info-browse-forward-paragraph)
  :defines (ediff-mode-map)
  :config
  (casual-ediff-install)
  (add-hook 'ediff-keymap-setup-hook
            (lambda () (keymap-set ediff-mode-map "C-o" #'casual-ediff-tmenu)))
  (bind-keys
   ("C-c w"                      . casual-editkit-windows-tmenu)
   ("M-r"                        . casual-editkit-rectangle-tmenu)
   ("C-c g"                      . casual-editkit-registers-tmenu)
   ("C-c p"                      . casual-editkit-project-tmenu)
   :map org-agenda-mode-map
   ("M-j"                        . org-agenda-clock-goto)
   ("J"                          . bookmark-jump)
   :map compilation-mode-map
   ("k"                          . compilation-previous-error)
   ("j"                          . compilation-next-error)
   ("o"                          . compilation-display-error)
   ("["                          . compilation-previous-file)
   ("]"                          . compilation-next-file)
   :map grep-mode-map
   ("k"                          . compilation-previous-error)
   ("j"                          . compilation-next-error)
   ("o"                          . compilation-display-error)
   ("["                          . compilation-previous-file)
   ("]"                          . compilation-next-file)
   :map eww-mode-map
   ("C-c C-o"                    . eww-browse-with-external-browser)
   ("j"                          . shr-next-link)
   ("k"                          . shr-previous-link)
   ("["                          . eww-previous-url)
   ("]"                          . eww-next-url)
   ("M-]"                        . eww-forward-url)
   ("M-["                        . eww-back-url)
   ("n"                          . casual-lib-browse-forward-paragraph)
   ("p"                          . casual-lib-browse-backward-paragraph)
   ("P"                          . casual-eww-backward-paragraph-link)
   ("N"                          . casual-eww-forward-paragraph-link)
   ("M-l"                        . eww)
   :map eww-bookmark-mode-map
   ("p"                          . previous-line)
   ("n"                          . next-line)
   ("<double-mouse-1>"           . eww-bookmark-browse)
   :map ibuffer-mode-map
   ("{"                          . ibuffer-backwards-next-marked)
   ("}"                          . ibuffer-forward-next-marked)
   ("["                          . ibuffer-backward-filter-group)
   ("]"                          . ibuffer-forward-filter-group)
   ("$"                          . ibuffer-toggle-filter-group)
   ("<double-mouse-1>"           . ibuffer-visit-buffer)
   ("M-<double-mouse-1>"         . ibuffer-visit-buffer-other-window)
   :map Info-mode-map
   ("M-["                        . Info-history-back)
   ("M-]"                        . Info-history-forward)
   ("p"                          . casual-info-browse-backward-paragraph)
   ("n"                          . casual-info-browse-forward-paragraph)
   ("h"                          . Info-prev)
   ("j"                          . Info-next-reference)
   ("k"                          . Info-prev-reference)
   ("l"                          . Info-next)
   ("/"                          . Info-search)
   ("B"                          . bookmark-set)))

(use-package casual-avy
  :after (casual avy)
  :demand t
  :bind ("M-g" . casual-avy-tmenu))


(provide '07-tools)
;;; 07-tools.el ends here
