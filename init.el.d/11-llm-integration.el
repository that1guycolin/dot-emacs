;;; 11-llm-integration.el --- LLM Integration -*- lexical-binding: t; -*-

;;; Packages included:
;; elisp-dev-mcp, emms, gptel, gptel-commit, gptel-forge-prs,
;; ollama-magit-gen-commit

;;; Commentary:
;; Support Emacs in executing tasks not typical of a text editor/IDE, such as
;; media playback, or chatting with an LLM right in your coding buffer.

;;; Code:

;; =======  VARIABLES & FUNCTIONS  =======
(defvar user/ollama-alist
  '(
    gpt-oss:120b-cloud llama3.1:latest qwen3-coder:480b-cloud
    qwen3-coder-next:cloud qwen3.5:cloud granite-code:8b llama3:8b llama3.1:8b
    opencoder:8b qwen3:8b codellama:7b-instruct qwen2.5-coder:7b starcoder2:7b
    qwen3:4b phi4-mini:3.8b granite-code:3b granite3.1-moe:3b llama3.2:3b
    qwen2.5-coder:3b stable-code:3b starcoder2:3b codegemma:2b qwen3:1.7b
    opencoder:1.5b qwen2.5:1.5b qwen2.5-coder:1.5b yi-coder:1.5b
    granite3.1-moe:1b llama3.2:1b starcoder:1b qwen3:0.6b qwen2.5:0.5b
    qwen2.5-coder:0.5b)
  "A list of user-selected LLMs available through Ollama.
Models on this list are either cloud-based or have already been downloaded
to the user's device.")

(defvar user/openrouter-alist
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

;; `user/ensure-ollama-system-service' eliminates need for below function.
;; Saving because possiblity exists it will be useful again at some point.
(defun user/ollama--alive-p ()
  "Return non-nil if an HTTP request to the Ollama server succeeds."
  (require 'url)
  (let* ((url-request-method "GET")
         (buf (url-retrieve-synchronously
	       "http://localhost:11434/api/version" t t 2)))
    (when buf
      (with-current-buffer buf
        (unwind-protect
            (and (boundp 'url-http-response-status)
                 (numberp url-http-response-status)
                 (= url-http-response-status 200))
          (kill-buffer buf))))))


;; =======  MCP  =======
(use-package elisp-dev-mcp
  :functions mcp-server-lib-start
  :config
  (mcp-server-lib-start))


;; =======  GPTEL  =======
(declare-function auth-source-pick-first-password "auth-source")
(use-package gptel
  :defer t
  :commands
  gptel
  gptel-send
  
  :functions
  gptel-make-ollama
  gptel-make-openai
  gptel-get-backend

  :defines
  gptel-backend

  :config
  (user/ensure-ollama-system-service)
  (setq
   gptel-backend (gptel-make-ollama "Ollama"
		   :host "localhost:11434"
		   :stream t
		   :models user/ollama-alist)
   gptel-model 'llama3.2:3b)

  (gptel-make-openai "OpenRouter"
    :host "openrouter.ai"
    :endpoint "/api/v1/chat/completions"
    :stream t
    :key (lambda ()
	   (auth-source-pick-first-password
	    :host "openrouter.ai"
	    :user "apikey"))
    :models user/openrouter-alist)

  (defvar user/gptel--backend-map
    '(("Ollama"      . (name "Ollama"      models user/ollama-alist))
      ("OpenRouter"  . (name "OpenRouter"  models user/openrouter-alist)))
    "Alist mapping display names to backend metadata plists.")

  (defun user/gptel-switch-backend ()
    "Interactively select a gptel backend, then select a model for it.
The user is allowed to select their already-active backend, so this function
doubles as a model-switcher."
    (interactive)
    (let* (
           (backend-name
	    (completing-read
	     (format "Backend (current: %s): "
		     (gptel-backend-name gptel-backend))
	     user/gptel--backend-map
	     nil
	     t))
           (meta   (cdr (assoc backend-name user/gptel--backend-map)))
           (gptel-name (plist-get meta 'name))
           (models-sym (plist-get meta 'models))
           (models (symbol-value models-sym))
           (model
	    (completing-read
	     (format "Model [%s]: " backend-name)
	     models
	     nil
	     t)))
      (setq gptel-backend (gptel-get-backend gptel-name)
	    gptel-model   (if (consp (car models))
			      (cdr (assoc model models))
			    model))
      (message "[gptel] Backend → %s | Model → %s"
	       backend-name gptel-model))))

(use-package ollama-magit-gen-commit
  :ensure (ollama-magit-gen-commit
	   :host github
	   :repo "that1guycolin/ollama-magit-gen-commit")
  :commands magit-ggc-generate-commit-message
  :demand t
  :after (gptel magit))

(defvar git-commit-mode-map)
(use-package gptel-commit
  :after (gptel magit)
  :functions
  gptel-commit
  gptel-commit-rationale
  :custom
  (gptel-commit-stream t)
  :config
  (with-eval-after-load 'magit
    (bind-keys
     :map git-commit-mode-map
     ("C-c g" . gptel-commit)
     ("C-c G" . gptel-commit-rationale))))

(use-package gptel-forge-prs
  :after forge
  :functions gptel-forge-prs-install
  :config
  (gptel-forge-prs-install))


;; =======  TRANSIENT  =======
(declare-function transient-define-prefix "transient")
(defvar user/llm-dispatch nil)
(transient-define-prefix
  user/llm-dispatch ()
  "Commands to interact with LLMs in Emacs."
  ["Gptel"
   ("g ." "Activate @ cursor" gptel-send)
   ("g b" "Chat buffer" gptel)
   ("g s" "Switch backend" user/gptel-switch-backend)])
(declare-function user/llm-dispatch "11-llm-integration")
(bind-keys ("C-c a" . user/llm-dispatch))


(provide '11-llm-integration)
;;; 11-llm-integration.el ends here
