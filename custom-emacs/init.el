(set-language-environment "UTF-8")
(require 'package)
(setq package-archives '(("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("elpa" . "https://elpa.gnu.org/packages")
                         ("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; allow recent-file caching
(recentf-mode 1)
(setq history-length 25)
(savehist-mode 1)
(save-place-mode 1)

;; remove spash screen
(setq inhibit-startup-message t)

;; remove UI elements
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode 1)

;; disable some line numbers
(dolist (mode '(term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-horizon t)
  (doom-themes-visual-bell-config)
  ;(doom-themes-neotree-config)
  ;(setq doom-themes-treemacs-theme "doom-horizon")
  (doom-themes-org-config))

(use-package nerd-icons
  :ensure t)

(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode)
  :config
  (setq doom-modeline-height 30))

(global-auto-revert-mode 1)
(setq use-dialog-box nil
      global-auto-revert-non-file-buffers t)

(defun rune/evil-hook ()
  (dolist (mode '(custom-mode
                  eshell-mode
                  git-rebase-mode
                  erc-mode
                  circe-server-mode
                  circle-chat-mode
                  circle-query-mode
                  sauron-mode
                  term-mode))
    (add-to-list 'evil-emacs-state-modes mode)))

(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil)
  :hook (evil-mode . rune/evil-hook)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :hook (evil-mode . evil-collection-init)
  :config
  (evil-collection-init))

(use-package which-key
  :hook (after-init . which-key-mode)
  :config
  (setq which-key-idle-delay 1))

(defun lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy)

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
              ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 2)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

;; Yasnippet settings
(use-package yasnippet
  :ensure t
  :hook ((LaTeX-mode . yas-minor-mode)
         (post-self-insert . my/yas-try-expanding-auto-snippets))
  :config
  (use-package warnings
    :config
    (cl-pushnew '(yasnippet backquote-change)
                warning-suppress-types
                :test 'equal))

  (setq yas-triggers-in-field t)

  ;; Function that tries to autoexpand YaSnippets
  ;; The double quoting is NOT a typo!
  (defun my/yas-try-expanding-auto-snippets ()
    (when (and (boundp 'yas-minor-mode) yas-minor-mode)
      (let ((yas-buffer-local-condition ''(require-snippet-condition . auto)))
        (yas-expand)))))

;; Note that this file does not define any auto-expanding YaSnippets.

;; AucTeX settings - almost no changes
(use-package latex
  :ensure auctex
  :hook ((LaTeX-mode . prettify-symbols-mode))
  :bind (:map LaTeX-mode-map
         ("C-S-e" . latex-math-from-calc))
  :config
  ;; Format math as a Latex string with Calc
  (defun latex-math-from-calc ()
    "Evaluate `calc' on the contents of line at point."
    (interactive)
    (cond ((region-active-p)
           (let* ((beg (region-beginning))
                  (end (region-end))
                  (string (buffer-substring-no-properties beg end)))
             (kill-region beg end)
             (insert (calc-eval `(,string calc-language latex
                                          calc-prefer-frac t
                                          calc-angle-mode rad)))))
          (t (let ((l (thing-at-point 'line)))
               (end-of-line 1) (kill-line 0)
               (insert (calc-eval `(,l
                                    calc-language latex
                                    calc-prefer-frac t
                                    calc-angle-mode rad))))))))

;; CDLatex settings
(use-package cdlatex
  :ensure t
  :hook (LaTeX-mode . turn-on-cdlatex)
  :bind (:map cdlatex-mode-map
              ("<tab>" . cdlatex-tab)))
  :config
  (use-package yasnippet
    :bind (:map yas-keymap
           ("<tab>" . yas-next-field-or-cdlatex)
           ("TAB" . yas-next-field-or-cdlatex))
    :config
    (defun cdlatex-in-yas-field ()
      ;; Check if we're at the end of the Yas field
      (when-let* ((_ (overlayp yas--active-field-overlay))
                  (end (overlay-end yas--active-field-overlay)))
        (if (>= (point) end)
            ;; Call yas-next-field if cdlatex can't expand here
            (let ((s (thing-at-point 'sexp)))
              (unless (and s (assoc (substring-no-properties s)
                                    cdlatex-command-alist-comb))
                (yas-next-field-or-maybe-expand)
                t))
          ;; otherwise expand and jump to the correct location
          (let (cdlatex-tab-hook minp)
            (setq minp
                  (min (save-excursion (cdlatex-tab)
                                       (point))
                       (overlay-end yas--active-field-overlay)))
            (goto-char minp) t))))

    (defun yas-next-field-or-cdlatex nil
      (interactive)
      "Jump to the next Yas field correctly with cdlatex active."
      (if
          (or (bound-and-true-p cdlatex-mode)
              (bound-and-true-p org-cdlatex-mode))
          (cdlatex-tab)
        (yas-next-field-or-maybe-expand))))

;; Array/tabular input with org-tables and cdlatex
;(require 'org-table
 ; :after cdlatex
 ; :bind (:map orgtbl-mode-map
 ;             ("<tab>" . lazytab-org-table-next-field-maybe)
 ;             ("TAB" . lazytab-org-table-next-field-maybe))
 ; :init
 ; (add-hook 'cdlatex-tab-hook 'lazytab-cdlatex-or-orgtbl-next-field 90)
 ; ;; Tabular environments using cdlatex
 ; (add-to-list 'cdlatex-command-alist '("smat" "Insert smallmatrix env"
 ;                                      "\\left( \\begin{smallmatrix} ? \\end{smallmatrix} \\right)"
 ;                                      lazytab-position-cursor-and-edit
 ;                                      nil nil t))
 ; (add-to-list 'cdlatex-command-alist '("bmat" "Insert bmatrix env"
 ;                                      "\\begin{bmatrix} ? \\end{bmatrix}"
 ;                                      lazytab-position-cursor-and-edit
 ;                                      nil nil t))
 ; (add-to-list 'cdlatex-command-alist '("pmat" "Insert pmatrix env"
 ;                                      "\\begin{pmatrix} ? \\end{pmatrix}"
 ;                                      lazytab-position-cursor-and-edit
 ;                                      nil nil t))
 ; (add-to-list 'cdlatex-command-alist '("tbl" "Insert table"
 ;                                       "\\begin{table}\n\\centering ? \\caption{}\n\\end{table}\n"
 ;                                      lazytab-position-cursor-and-edit
 ;                                      nil t nil))
  ;:config
  ;;; Tab handling in org tables
  ;(defun lazytab-position-cursor-and-edit ()
  ;  ;; (if (search-backward "\?" (- (point) 100) t)
  ;  ;;     (delete-char 1))
  ;  (cdlatex-position-cursor)
  ;  (lazytab-orgtbl-edit))

  ;(defun lazytab-orgtbl-edit ()
  ;  (advice-add 'orgtbl-ctrl-c-ctrl-c :after #'lazytab-orgtbl-replace)
  ;  (orgtbl-mode 1)
  ;  (open-line 1)
  ;  (insert "\n|"))

  ;(defun lazytab-orgtbl-replace (_)
  ;  (interactive "P")
  ;  (unless (org-at-table-p) (user-error "Not at a table"))
  ;  (let* ((table (org-table-to-lisp))
  ;         params
  ;         (replacement-table
  ;          (if (texmathp)
  ;              (lazytab-orgtbl-to-amsmath table params)
  ;            (orgtbl-to-latex table params))))
  ;    (kill-region (org-table-begin) (org-table-end))
  ;    (open-line 1)
  ;    (push-mark)
  ;    (insert replacement-table)
  ;    (align-regexp (region-beginning) (region-end) "\\([:space:]*\\)& ")
  ;    (orgtbl-mode -1)
  ;    (advice-remove 'orgtbl-ctrl-c-ctrl-c #'lazytab-orgtbl-replace)))

  ;(defun lazytab-orgtbl-to-amsmath (table params)
  ;  (orgtbl-to-generic
  ;   table
  ;   (org-combine-plists
  ;    '(:splice t
  ;              :lstart ""
  ;              :lend " \\\\"
  ;              :sep " & "
  ;              :hline nil
  ;              :llend "")
  ;    params)))

  ;(defun lazytab-cdlatex-or-orgtbl-next-field ()
  ;  (when (and (bound-and-true-p orgtbl-mode)
  ;             (org-table-p)
  ;             (looking-at "[[:space:]]*\\(?:|\\|$\\)")
  ;             (let ((s (thing-at-point 'sexp)))
  ;               (not (and s (assoc s cdlatex-command-alist-comb)))))
  ;    (call-interactively #'org-table-next-field)
  ;    t))

  ;(defun lazytab-org-table-next-field-maybe ()
  ;  (interactive)
  ;  (if (bound-and-true-p cdlatex-mode)
  ;      (cdlatex-tab)
  ;    (org-table-next-field))))

(defun efs/org-mode-setup ()
    (org-indent-mode)
    (variable-pitch-mode 1)
    (visual-line-mode 1))

  (use-package org
    :hook (org-mode . efs/org-mode-setup)
    :config
    (setq org-ellipsis " ▾")

    (setq org-agenda-start-with-log-mode t)
    (setq org-log-done 'time)
    (setq org-log-into-drawer t)

    (setq org-agenda-files
          '("~/Projects/Code/emacs-from-scratch/OrgFiles/Tasks.org"
            "~/Projects/Code/emacs-from-scratch/OrgFiles/Habits.org"
            "~/Projects/Code/emacs-from-scratch/OrgFiles/Birthdays.org"))

    (require 'org-habit)
    (add-to-list 'org-modules 'org-habit)
    (setq org-habit-graph-column 60)

    (setq org-todo-keywords
          '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
            (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

    (setq org-refile-targets
          '(("Archive.org" :maxlevel . 1)
            ("Tasks.org" :maxlevel . 1)))

    ;; Save Org buffers after refiling!
    (advice-add 'org-refile :after 'org-save-all-org-buffers)

    (setq org-tag-alist
          '((:startgroup)
                                          ; Put mutually exclusive tags here
            (:endgroup)
            ("@errand" . ?E)
            ("@home" . ?H)
            ("@work" . ?W)
            ("agenda" . ?a)
            ("planning" . ?p)
            ("publish" . ?P)
            ("batch" . ?b)
            ("note" . ?n)
            ("idea" . ?i)))

    ;; Configure custom agenda views
    (setq org-agenda-custom-commands
          '(("d" "Dashboard"
             ((agenda "" ((org-deadline-warning-days 7)))
              (todo "NEXT"
                    ((org-agenda-overriding-header "Next Tasks")))
              (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

            ("n" "Next Tasks"
             ((todo "NEXT"
                    ((org-agenda-overriding-header "Next Tasks")))))

            ("W" "Work Tasks" tags-todo "+work-email")

            ;; Low-effort next actions
            ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
             ((org-agenda-overriding-header "Low Effort Tasks")
              (org-agenda-max-todos 20)
              (org-agenda-files org-agenda-files)))

            ("w" "Workflow Status"
             ((todo "WAIT"
                    ((org-agenda-overriding-header "Waiting on External")
                     (org-agenda-files org-agenda-files)))
              (todo "REVIEW"
                    ((org-agenda-overriding-header "In Review")
                     (org-agenda-files org-agenda-files)))
              (todo "PLAN"
                    ((org-agenda-overriding-header "In Planning")
                     (org-agenda-todo-list-sublevels nil)
                     (org-agenda-files org-agenda-files)))
              (todo "BACKLOG"
                    ((org-agenda-overriding-header "Project Backlog")
                     (org-agenda-todo-list-sublevels nil)
                     (org-agenda-files org-agenda-files)))
              (todo "READY"
                    ((org-agenda-overriding-header "Ready for Work")
                     (org-agenda-files org-agenda-files)))
              (todo "ACTIVE"
                    ((org-agenda-overriding-header "Active Projects")
                     (org-agenda-files org-agenda-files)))
              (todo "COMPLETED"
                    ((org-agenda-overriding-header "Completed Projects")
                     (org-agenda-files org-agenda-files)))
              (todo "CANC"
                    ((org-agenda-overriding-header "Cancelled Projects")
                     (org-agenda-files org-agenda-files)))))))

    (setq org-capture-templates
          `(("t" "Tasks / Projects")
            ("tt" "Task" entry (file+olp "~/Projects/Code/emacs-from-scratch/OrgFiles/Tasks.org" "Inbox")
             "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

            ("j" "Journal Entries")
            ("jj" "Journal" entry
             (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
             "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
             ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
             :clock-in :clock-resume
             :empty-lines 1)
            ("jm" "Meeting" entry
             (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
             "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
             :clock-in :clock-resume
             :empty-lines 1)

            ("w" "Workflows")
            ("we" "Checking Email" entry (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
             "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

            ("m" "Metrics Capture")
            ("mw" "Weight" table-line (file+headline "~/Projects/Code/emacs-from-scratch/OrgFiles/Metrics.org" "Weight")
             "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)))

    (define-key global-map (kbd "C-c j")
                (lambda () (interactive) (org-capture nil "jj"))))

  (use-package org-bullets
    :after org
    :hook (org-mode . org-bullets-mode))

  (use-package org-modern
    :hook (org-mode . org-modern-mode)
    :config
(modify-all-frames-parameters
 '((right-divider-width . 40)
   (internal-border-width . 40)))
(dolist (face '(window-divider
                window-divider-first-pixel
                window-divider-last-pixel))
  (face-spec-reset-face face)
  (set-face-foreground face (face-attribute 'default :background)))
(set-face-background 'fringe (face-attribute 'default :background))

(setq
 ;; Edit settings
 org-auto-align-tags nil
 org-tags-column 0
 org-catch-invisible-edits 'show-and-error
 org-special-ctrl-a/e t
 org-insert-heading-respect-content t

 ;; Org styling, hide markup etc.
 org-hide-emphasis-markers t
 org-pretty-entities t

 ;; Agenda styling
 org-agenda-tags-column 0
 org-agenda-block-separator ?─
 org-agenda-time-grid
 '((daily today require-timed)
   (800 1000 1200 1400 1600 1800 2000)
   " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
 org-agenda-current-time-string
 "◀── now ─────────────────────────────────────────────────")

;; Ellipsis styling
(setq org-ellipsis "…")
(set-face-attribute 'org-ellipsis nil :inherit 'default :box nil))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (C . t)
   (python . t)))

(defun replace-string-in-current-buffer (from-string to-string)
  "replace from-string with to-string in the current buffer."
  (save-excursion
    (goto-char (point-min))
    (while (search-forward from-string nil t)
      (replace-match to-string nil t))))

(defun get-number-of-lines ()
  "retrieve the current number of lines"
  (interactive)
  (count-lines (point-min) (point-max)))

(defun delete-hidden-text ()
  "remove all lines from top of the buffer that would be revealed by a call to `widen'"
  (interactive)
  (-let [src-lines (get-number-of-lines)]
    (widen)
    (setq-local widen-number-of-lines (get-number-of-lines))
    (goto-char (point-min))
    (kill-line (- widen-number-of-lines src-lines))))

(defun string-contains-only-newlines-p (str)
  "check if the string contains only newline characters."
  (unless (or (string-empty-p str)
              (with-temp-buffer
                (insert str)
                (goto-char (point-min))
                (re-search-forward "[^[:space:]\n]" nil t)))
    t))

(define-advice org-edit-src-exit
    (:before (&rest _args))
  (when (buffer-narrowed-p)
    (delete-hidden-text)))

(define-advice org-edit-src-save
    (:before (&rest _args))
  (when (buffer-narrowed-p)
    (delete-hidden-text)))

(defun org-babel-tangle-block ()
  "tangle a single file under cursor"
  (interactive)
  (let ((current-prefix-arg '(4)))
    (call-interactively 'org-babel-tangle)))

(defun org-babel-edit-prep:c (babel-info)
  (setq-local buffer-file-name (->> babel-info caddr (alist-get :tangle)))
  (lsp))

(defun org-babel-edit-prep:python (babel-info)
  (setq-local buffer-file-name (->> babel-info caddr (alist-get :tangle)))
  (lsp))

;; make sure rustic gets activated in the org-src block and add the original file's source code.
;; only triggers on c-c c-c
(defun org-babel-edit-prep:cpp (babel-info)
  ;; get source code in org source block
  (setq-local src-code (nth 1 babel-info))
  ;; get filename
  ;; todo: needs edge case when tangle = yes
  (setq-local buffer-file-name (->> babel-info caddr (alist-get :tangle)))
  (message (format "%s" src-code))
  ;; go to first point and insert file content
  (goto-char (point-min))
  (insert-file-contents buffer-file-name)
  ;; replace source code if exists and only if not empty or newlines
  (unless (string-contains-only-newlines-p (format "%s" src-code))
    (replace-string-in-current-buffer src-code ""))
  ;; count current lines
  (setq-local n-lines (get-number-of-lines))
  ;; go to the end of the lines
  (goto-line n-lines)
  ;; insert the source block
  (insert src-code)
  ;; jump back to the prior position
  (goto-line n-lines)
  ;; narrow the region without restriction
  (narrow-to-region (point) (point-max))
  (without-restriction)) ;; major mode is automatiically enabled by org-edit-src-code
