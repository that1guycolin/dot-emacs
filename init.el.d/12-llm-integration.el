;;; 12-llm-integration.el --- LLM Integration -*- lexical-binding: t; -*-

;;; Packages included:
;; elisp-dev-mcp, ellama, gptel, gptel-commit, gptel-forge-prs, gptel-magit,
;; org-mcp

;;; Commentary:
;; Support Emacs in executing tasks not typical of a text editor/IDE, such as
;; media playback, or chatting with an LLM right in your coding buffer.

;;; Code:
;; =======  VARIABLES & FUNCTIONS  =======
(defvar user/ollama-alist
  `((gpt-oss:120b-cloud     . ,(* 16 4096))
    (llama3.1:latest        . ,(* 16 4096))
    (qwen3-coder:480b-cloud . ,(* 16 4096))
    (qwen3-coder-next:cloud . ,(* 16 4096))
    (qwen3.5:cloud          . ,(* 16 4096))
    (granite-code:8b        . ,(* 2 4096))
    (llama3:8b              . ,(* 2 4096))
    (llama3.1:8b            . ,(* 1 4096))
    (opencoder:8b           . ,(* 2 4096))
    (qwen3:8b               . ,(* 2 4096))
    (codellama:7b-instruct  . ,(* 1 4096))
    (qwen2.5-coder:7b       . ,(* 2 4096))
    (starcoder2:7b          . ,(* 2 4096))
    (qwen3:4b               . ,(* 2 4096))
    (gemma4:e4b             . ,(* 1 4096))
    (phi4-mini:3.8b         . ,(* 2 4096))
    (granite-code:3b        . ,(* 1 4096))
    (granite3.1-moe:3b      . ,(* 1 4096))
    (llama3.2:3b            . ,(* 1 4096))
    (qwen2.5-coder:3b       . ,(* 1 4096))
    (stable-code:3b         . ,(* 1 4096))
    (starcoder2:3b          . ,(* 1 4096))
    (gemma4:e2b             . ,(* 1 4096))
    (codegemma:2b           . ,(* 1 4096))
    (qwen3:1.7b             . ,(* 1 4096))
    (opencoder:1.5b         . ,(* 1 4096))
    (qwen2.5:1.5b           . ,(* 1 4096))
    (qwen2.5-coder:1.5b     . ,(* 1 4096))
    (yi-coder:1.5b          . ,(* 1 4096))
    (granite3.1-moe:1b      . ,(* 1 4096))
    (llama3.2:1b            . ,(* 1 4096))
    (starcoder:1b           . ,(* 1 4096))
    (qwen3:0.6b             . ,(* 1 4096))
    (qwen2.5:0.5b           . ,(* 1 4096))
    (qwen2.5-coder:0.5b     . ,(* 1 4096)))
  "Alist containing Ollama models and their context length.
Models on this list are either cloud-based or have already been downloaded
to the user's device.")

(defvar user/openrouter-list
  '(
    openai/gpt-oss-120b:free qwen/qwen3-coder:free
    meta-llama/llama-3.3-70b-instruct:free qwen/qwen3-4b:free
    google/gemma-3-27b-it:free openrouter/free)
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


;; =======  MCP  =======
(use-package org-mcp
  :defer t
  :commands org-mcp-enable
  :config
  (setq org-mcp-allowed-files
	(directory-files "~/org/llm" t directory-files-no-dot-files-regexp))
  (dolist (file '("~/org/.notes" "~/org/tasks/inbox.org"
		  "~/org/tasks/org-gtd-tasks.org"))
    (add-to-list 'org-mcp-allowed-files (expand-file-name file))))

(use-package elisp-dev-mcp
  :defer t
  :commands elisp-dev-mcp-enable)

;; =======  GPTEL  =======
(declare-function auth-source-pick-first-password "auth-source")
(use-package gptel
  :defer t
  :commands gptel gptel-send
  
  :functions
  gptel-make-ollama gptel-make-openai gptel-get-backend

  :defines
  gptel-backend user/gptel--backend-map

  :config
  (user/ensure-ollama-system-service)
  (setq
   gptel-backend (gptel-make-ollama "Ollama"
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
    :models user/openrouter-list)

  (defvar user/gptel--backend-map
    `(("Ollama" . (name "Ollama" models ,(mapcar #'car user/ollama-alist)))
      
      ("OpenRouter"  . (name "OpenRouter"  models user/openrouter-alist)))
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
	     (format "Model [%s]: " backend-name)
	     models nil t)))
      (setq gptel-backend (gptel-get-backend gptel-name)
	    gptel-model   (if (consp (car models))
			      (cdr (assoc model models))
			    (intern model)))
      (message "[gptel] Backend → %s | Model → %s"
	       backend-name gptel-model))))

(use-package gptel-magit
  :defer t
  :functions gptel-magit-install
  :after gptel
  :config
  (add-hook 'magit-mode-hook (lambda ()
			       (when (featurep 'gptel)
				 (gptel-magit-install)))))

(defvar git-commit-mode-map)
(use-package gptel-commit
  :defer t
  :after gptel
  :functions
  gptel-commit gptel-commit-rationale
  :custom
  (gptel-commit-stream t)
  :config
  (when (featurep 'gptel)
    (bind-keys
     :map git-commit-mode-map
     ("C-c g" . gptel-commit)
     ("C-c G" . gptel-commit-rationale))))

(use-package gptel-forge-prs
  :after forge
  :functions gptel-forge-prs-install
  :config
  (when (featurep 'gptel)
    (gptel-forge-prs-install)))


;; =======  ELLAMA  =======
(use-package ellama
  :ensure (:wait t)
  :defer t
  :commands ellama-transient-main-menu
  :functions
  make-llm-ollama user/ellama-set-tier user/ellama-switch-tier
  user/ellama-switch-model ellama-disable-scroll ellama-enable-scroll
  :init
  (setopt ellama-language "English")
  :config
  (require 'llm-ollama)

  ;; ----------- MODEL TYPES -----------
  ;; Fast:
  (defvar user/ellama-model-fast-chat
    (make-llm-ollama
     :chat-model "llama3.2:3b"
     :embedding-model "nomic-embed-text"
     :default-chat-non-standard-params '(("num_ctx" . 4096))))

  (defvar user/ellama-model-fast-code
    (make-llm-ollama
     :chat-model "codegemma:2b"
     :embedding-model "nomic-embed-text"
     :default-chat-non-standard-params '(("num_ctx" . 4096))))

  ;; Balanced:
  (defvar user/ellama-model-balanced-chat
    (make-llm-ollama
     :chat-model "phi4-mini:3.8b"
     :embedding-model "nomic-embed-text"
     :default-chat-non-standard-params '(("num_ctx" . 8192))))

  (defvar user/ellama-model-balanced-summary
    (make-llm-ollama
     :chat-model "qwen3:4b"
     :embedding-model "nomic-embed-text"
     :default-chat-non-standard-params '(("num_ctx" . 8192))))

  (defvar user/ellama-model-balanced-code
    (make-llm-ollama
     :chat-model "codellama:7b-instruct"
     :embedding-model "nomic-embed-text"
     :default-chat-non-standard-params '(("num_ctx" . 4096))))

  ;; Heavy
  (defvar user/ellama-model-heavy-chat
    (make-llm-ollama
     :chat-model "llama3.1:8b"
     :embedding-model "nomic-embed-text"
     :default-chat-non-standard-params '(("num_ctx" . 4096))))

  (defvar user/ellama-model-heavy-code
    (make-llm-ollama
     :chat-model "qwen2.5-coder:7b"
     :embedding-model "nomic-embed-text"
     :default-chat-non-standard-params '(("num_ctx" . 4096))))

  ;; Defaults:
  (setopt ellama-provider user/ellama-model-fast-chat)
  (setopt ellama-coding-provider user/ellama-model-fast-code)
  (setopt ellama-summarization-provider user/ellama-model-balanced-summary)

  ;; ----------- FUNCTIONS -----------
  (defun user/ellama-set-tier (tier)
    "Activate default models for TIER."
    (pcase tier
      ('fast
       (setopt ellama-provider user/ellama-model-fast-chat)
       (setopt ellama-coding-provider user/ellama-model-fast-code)
       (setopt ellama-summarization-provider user/ellama-model-fast-chat)
       (message "Ellama tier → FAST"))

      ('balanced
       (setopt ellama-provider user/ellama-model-balanced-chat)
       (setopt ellama-coding-provider user/ellama-model-balanced-code)
       (setopt ellama-summarization-provider user/ellama-model-balanced-summary)
       (message "Ellama tier → BALANCED"))

      ('heavy
       (setopt ellama-provider user/ellama-model-heavy-chat)
       (setopt ellama-coding-provider user/ellama-model-heavy-code)
       (setopt ellama-summarization-provider user/ellama-model-balanced-summary)
       (message "Ellama tier → HEAVY"))))

  (defun user/ellama-switch-tier ()
    (interactive)
    (let ((choice (completing-read
                   "Select ellama tier: "
                   '("fast" "balanced" "heavy"))))
      (user/ellama-set-tier (intern choice))))

  (defun user/ellama-switch-model ()
    "Interactively select a model."
    (interactive)
    (let* ((model-names (mapcar #'car user/ollama-alist))
           (choice (completing-read "Select model: " model-names nil t))
	   (choice-sym (intern choice))
           (ctx (cdr (assoc choice-sym user/ollama-alist))))
      (setopt ellama-provider
              (make-llm-ollama
               :chat-model choice
               :embedding-model "nomic-embed-text"
               :default-chat-non-standard-params
               `(("num_ctx" . ,ctx))))
      (message "Ellama model → %s" choice)))

  ;; ----------- DISPLAY -----------
  (setopt ellama-chat-display-action-function #'display-buffer-full-frame)
  (setopt ellama-instant-display-action-function #'display-buffer-at-bottom)

  (advice-add 'pixel-scroll-precision :before #'ellama-disable-scroll)
  (advice-add 'end-of-buffer :after #'ellama-enable-scroll))


;; =======  TRANSIENT  =======
(declare-function transient-define-prefix "transient")
(defvar user/llm-dispatch nil)
(transient-define-prefix
  user/llm-dispatch ()
  "Commands to interact with LLMs in Emacs."
  ["LLM Integrations"
   ["Gptel"
    ("g ." "Activate @ cursor" gptel-send)
    ("g b" "Chat buffer" gptel)
    ("g s" "Switch backend" user/gptel-switch-backend)]
   ["Ellama"
    ("e e" "Ellama Menu" ellama-transient-main-menu)
    ("e t" "Switch Tier" user/ellama-switch-tier)
    ("e m" "Switch Model" user/ellama-switch-model)]])
(declare-function user/llm-dispatch "12-llm-integration")
(bind-keys ("C-c a" . user/llm-dispatch))


(provide '12-llm-integration)
;;; 12-llm-integration.el ends here
