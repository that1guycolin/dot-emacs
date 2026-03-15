;;; 10-external-connections.el --- Configure Emacs to work with external programs -*- lexical-binding: t; -*-

;;; Packages included:
;; elisp-dev-mcp, emms, gptel, gptel-commit, gptel-forge-prs, gptel-magit

;;; Commentary:
;; Support Emacs in executing tasks not typical of a text editor/IDE, such as
;; media playback, or chatting with an LLM right in your coding buffer.

;;; Code:
;; =======  LLMs  =======
;; Define variables (lists of LLMs
;;   from select providers)
;; `gptel' (call LLM from anywhere)
;; Extensions enhance magit
;; ======================
(use-package elisp-dev-mcp
  :defer t
  :commands mcp-server-lib-start)

(declare-function auth-source-pick-first-password "auth-source")
(use-package gptel
  :commands
  gptel
  gptel-send
  :defer t
  :functions
  ollama--alive-p
  gptel-make-ollama
  gptel-make-openai
  user/switch-to-gptel--ollama
  user/switch-to-gptel--openrouter
  user/switch-gptel-backend
  :config
  (defvar user/gptel--backend nil
    "The current gptel backend.")

  (defvar user/gptel--ollama-list
    '(
      gpt-oss:120b-cloud llama3.1:latest qwen3-coder:480b-cloud
      qwen3-coder-next:cloud qwen3.5:cloud granite-code:8b llama3:8b llama3.1:8b
      opencoder:8b qwen3:8b codellama:7b-instruct qwen2.5-coder:7b starcoder2:7b
      qwen3:4b phi4-mini:3.8b granite-code:3b granite3.1-moe:3b llama3.2:3b
      qwen2.5-coder:3b stable-code:3b starcoder2:3b codegemma:2b qwen3:1.7b
      opencoder:1.5b qwen2.5:1.5b qwen2.5-coder:1.5b yi-coder:1.5b
      granite3.1-moe:1b llama3.2:1b starcoder:1b qwen3:0.6b qwen2.5:0.5b
      qwen2.5-coder:0.5b)
    "Sybmol is a list of user-selected LLMs available through Ollama.
Models on this list are either cloud-based or have already been downloaded
to the user's device.")

  (defvar user/gptel--openrouter-list
    '(
      openai/gpt-oss-120b:free qwen/qwen3-coder:free
      meta-llama/llama-3.3-70b-instruct:free qwen/qwen3-4b:free
      google/gemma-3-27b-it:free openrouter/free)
    "Symbol is a list of user-selected LLMs available through OpenRouter.")

  (defun ollama--alive-p ()
    "Return non‑nil if an HTTP request to the Ollama server succeeds.
We use the cheap `/api/version` endpoint – it returns 200
when the daemon is running."
    (require 'url)
    (let ((url-request-method "GET")
          (url (url-generic-parse-url "http://localhost:11434/api/version"))
          (buf (url-retrieve-synchronously
		"http://localhost:11434/api/version"
  		
		nil t 2)))
      (when buf
	(with-current-buffer buf
          (unwind-protect
              (progn
		(goto-char (point-min))
		;; `url-http-response-status' is set by `url-http' parser
		(when (boundp 'url-http-response-status)
                  (= url-http-response-status 200)))
            (kill-buffer buf))))))
  
  (defun user/switch-to-gptel--ollama ()
    "Set `gptel-backend' to \"Ollama\" and `gptel-model' to \"llama3.2:3b\".
Any Ollama model can then be selected with \"(setq gptel-model \='model)\"."
    (unless (ollama--alive-p)
      (run-with-timer
       20 nil
       (lambda ()
	 (when (ollama--alive-p)
	   (setq
	    gptel-backend
	    (gptel-make-ollama "Ollama"
	      :host "localhost:11434"
	      :stream t
	      :models user/gptel--ollama-list)
	    gptel-model 'llama3.2:3b
	    user/gptel--backend "Ollama"))))))

  (defun user/switch-to-gptel--openrouter ()
    "Set `gptel-backend' to \"OpenRouter\" and `gptel-model' to
\"openai/gpt-oss-120b:free\". Any OpenRouter model can then be selected with
\"(setq gptel-model \='model)\"."
    (setq
     gptel-backend
     (gptel-make-openai "OpenRouter"
       :host "openrouter.ai"
       :endpoint "/api/v1/chat/completions"
       :stream t
       :key (lambda ()
	      (auth-source-pick-first-password
	       :host "openrouter.ai"
	       :user "apikey"))
       :models user/gptel--openrouter-list)
     gptel-model `openai/gpt-oss-120b:free
     user/gptel--backend "OpenRouter"))

  (defun user/switch-gptel-backend ()
    "Switch gptel backend between Ollama and OpenRouter."
    (interactive)
    (if (eq user/gptel--backend 'Ollama)
	(user/switch-to-gptel--openrouter)
      (user/switch-to-gptel--ollama)))
  (user/switch-to-gptel--ollama))

(use-package gptel-magit
  :after (gptel magit)
  :hook (magit-mode . gptel-magit-install))

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


;; =======  EMMS  =======
;; Configure `emms' for
;; video playback in Emacs
;; ======================
(defvar user-projects-directory)
(declare-function defhydra "hydra")
(use-package emms
  :defer t
  :bind ("<f6>" . emms-browser)
  :functions
  emms-all
  emms-seek
  emms-pause
  emms-next
  emms-previous
  emms-playlist-shuffle
  emms-seek-backward
  emms-seek-forward
  user/seek-backward-med
  user/seek-forward-med
  user/seek-backward-long
  user/seek-forward-long
  emms-play-playlist
  emms-play-file
  emms-play-find
  emms-playlist-save
  emms-playlist-new
  emms-show
  emms-sort
  emms-playlist-mode-yank
  emms-playlist-mode-go-popup
  :defines
  emms-info-functions
  emms-playlist-mode-map
  :config
  (require 'emms-setup)
  (emms-all)
  (setq emms-player-list '(emms-player-mpv))
  (add-to-list 'load-path
	       (expand-file-name "emms-info-ffprobe" user-projects-directory))
  (require 'emms-info-ffprobe)
  (setq emms-info-functions '(emms-info-ffprobe))
  (defun user/seek-backward-med ()
    "Seek backwards 30 seconds in Emms."
    (interactive)
    (emms-seek -30))

  (defun user/seek-forward-med ()
    "Seek forward 30 seconds in Emms."
    (interactive)
    (emms-seek 30))

  (defun user/seek-backward-long ()
    "Seek backwards 2 minutes in Emms."
    (interactive)
    (emms-seek (* -2 60)))

  (defun user/seek-forward-long ()
    "Seek forward 2 minutes in Emms."
    (interactive)
    (emms-seek (* 2 60)))

  (let ((map emms-playlist-mode-map))
    (define-key map (kbd "SPC")   #'emms-pause)
    (define-key map (kbd "m")     #'emms-next)
    (define-key map (kbd "n")     #'emms-previous)
    (define-key map (kbd "s")     #'emms-playlist-shuffle)
    (define-key map (kbd "j")     #'emms-seek-backward)
    (define-key map (kbd "k")     #'emms-seek-forward)
    (define-key map (kbd "J")     #'user/seek-backward-med)
    (define-key map (kbd "K")     #'user/seek-forward-med)
    (define-key map (kbd "M-j")   #'user/seek-backward-long)
    (define-key map (kbd "M-k")   #'user/seek-forward-long)
    (define-key map (kbd "p")     #'emms-play-playlist)
    (define-key map (kbd "f")     #'emms-play-file)
    (define-key map (kbd "d")     #'emms-play-find)
    (define-key map (kbd "C-s")   #'emms-playlist-save)
    (define-key map (kbd "C-x n") #'emms-playlist-new)
    (define-key map (kbd "i")     #'emms-show)
    (define-key map (kbd "l")     #'emms-sort)
    (define-key map (kbd "y")     #'emms-playlist-mode-yank)
    (define-key map (kbd "C-p")   #'emms-playlist-mode-go-popup))

  ;; At the end of the emms :config, after all the defuns and keybindings:
  (defvar hydra-emms-playlist)
  (with-eval-after-load 'hydra
    (defhydra hydra-emms-playlist
      (:pre    (message "EMMS playlist hydra: q/? to quit")
	       :post   (message "Leaving EMMS playlist hydra")
	       :hint   nil
	       :color  amaranth
	       :exit   nil
	       :columns 3
	       :body-pre   (message "⏯")
	       :map emms-playlist-mode-map
	       :key "?")
      "
  EMMS Playlist
  ════════════════════════════════════════════════
   Playback          Seek                Playlist
  ────────────────  ──────────────────  ──────────────────
   [SPC] pause       [j]   -5s           [p] play playlist
   [m]   next        [k]   +5s           [f] play file
   [n]   previous    [J]   -30s          [d] find & play
   [s]   shuffle     [K]   +30s          [C-s] save
   [i]   show info   [M-j] -2min         [C-x n] new playlist
                     [M-k] +2min         [l]   sort
                                         [y]   yank
                                         [C-p] go popup
  ────────────────────────────────────────────────
   [?] help   [q] quit
  "
      ;; Playback – stay in hydra (`nil` means “do not exit”)
      ("SPC" emms-pause            nil)
      ("m"   emms-next             nil)
      ("n"   emms-previous         nil)
      ("s"   emms-playlist-shuffle nil)
      ("i"   emms-show             nil)

      ;; Seek – also stay in hydra
      ("j"   emms-seek-backward      nil)
      ("k"   emms-seek-forward       nil)
      ("J"   user/seek-backward-med  nil)
      ("K"   user/seek-forward-med   nil)
      ("M-j" user/seek-backward-long nil)
      ("M-k" user/seek-forward-long  nil)

      ;; Playlist operations – exit after running (`:exit t`)
      ("p"     emms-play-playlist      :exit t)
      ("f"     emms-play-file          :exit t)
      ("d"     emms-play-find          :exit t)
      ("C-s"   emms-playlist-save      :exit t)
      ("C-x n" emms-playlist-new       :exit t)
      ("l"     emms-sort                   nil)
      ("y"     emms-playlist-mode-yank     nil)
      ("C-p"   emms-playlist-mode-go-popup nil)

      ;; Dismiss / help
      ("?"   nil :exit t)   ; just close the hint
      ("q"   nil :exit t))))

(provide '10-external-connections)
;;; 10-external-connections.el ends here
