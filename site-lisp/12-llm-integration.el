;;; 12-llm-integration.el --- LLM Integration -*- lexical-binding: t; -*-

;;; Packages included:
;; elisp-dev-mcp, ellama, gptel, gptel-forge-prs, llm, mcp-server-lib, org-mcp

;;; Commentary:
;; Support Emacs in executing tasks not typical of a text editor/IDE, such as
;; media playback, or chatting with an LLM right in your coding buffer.

;;; Code:
;;; Base package:
(use-package llm
  :demand t)

(use-package llm-ollama
  :ensure nil
  :after (llm)
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

  :functions make-llm-ollama)


;;; MCP:
(use-package mcp-server-lib
  :defer t
  :commands (mcp-server-lib-start mcp-server-lib-stop))

(use-package org-mcp
  :defer t
  :commands (org-mcp-enable)
  :custom
  (org-mcp-allowed-files
   (directory-files-recursively org-directory "\\.org\\'")))

(use-package elisp-dev-mcp
  :defer t
  :commands (elisp-dev-mcp-enable))


;;; GPTel
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
  
  :commands gptel gptel-send
  :functions gptel-get-backend gptel-make-ollama gptel-make-openai
  :defines gptel-backend

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


;;; Ellama:
(use-package ellama
  :defer t
  :commands ellama-transient-main-menu
  :functions
  ellama-disable-scroll ellama-enable-scroll
  :init
  (setopt ellama-language "English")
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


;;; Transient:
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
  (keymap-global-set "C-c a" #'user/llm-dispatch))


(provide '12-llm-integration)
;;; 12-llm-integration.el ends here
