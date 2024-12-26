
;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-xcode)
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 13 :weight 'regular))

(setq fancy-splash-image (concat doom-private-dir "enso.png"))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq! org-directory (concat (getenv "HOME") "/Notes/Org"))
(setq org-download-image-dir (concat (getenv "HOME") "/Notes/Assets/"))
(after! org
  (add-hook 'org-mode-hook #'yas-minor-mode)
  (set-company-backend! 'org-mode nil)
  (set-company-backend! 'org-mode 'company-capf 'company-yasnippet))
;;(toggle-frame-fullscreen)

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;


(defun org-babel-edit-prep:c (babel-info)
  (setq-local buffer-file-name (->> babel-info caddr (alist-get :tangle)))
  (lsp))

;; (defun org-babel-edit-prep:cpp (babel-info)
;;   (setq-local buffer-file-name (->> babel-info caddr (alist-get :tangle)))
;;   (lsp))

(defun replace-string-in-current-buffer (from-string to-string)
  "Replace FROM-STRING with TO-STRING in the current buffer."
  (save-excursion
    (goto-char (point-min))
    (while (search-forward from-string nil t)
      (replace-match to-string nil t))))

(defun get-number-of-lines ()
  "Retrieve the current number of lines"
  (interactive)
  (count-lines (point-min) (point-max)))

(defun delete-hidden-text ()
  "Remove all lines from top of the buffer that would be revealed by a call to `widen'"
  (interactive)
  (-let [src-lines (get-number-of-lines)]
    (widen)
    (setq-local widen-number-of-lines (get-number-of-lines))
    (goto-char (point-min))
    (kill-line (- widen-number-of-lines src-lines))))

(defun string-contains-only-newlines-p (str)
  "Check if the string contains only newline characters."
  (unless (or (string-empty-p str)
              (with-temp-buffer
                (insert str)
                (goto-char (point-min))
                (re-search-forward "[^[:space:]\n]" nil t)))
    t))

;; Make sure rustic gets activated in the org-src block and add the original file's source code.
(defun org-babel-edit-prep:cpp (babel-info)
  ;; get source code in org source block
  (setq-local src-code (nth 1 babel-info))
  ;; get filename
  ;; TODO: needs edge case when tangle = yes
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
  (without-restriction)
  ;; major mode is automatiically enabled by org-edit-src-code
  )

(defun org-babel-edit-prep:python (babel-info)
  ;; get source code in org source block
  (setq-local src-code (nth 1 babel-info))
  ;; get filename
  ;; TODO: needs edge case when tangle = yes
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
  (without-restriction)
  ;; major mode is automatiically enabled by org-edit-src-code
  )

;; removes narrowed content on exit/save
;; IMPORTANT: only runs when using C-c C-c!
(define-advice org-edit-src-exit
    (:before (&rest _args))
  (when (buffer-narrowed-p)
    (delete-hidden-text)))

(define-advice org-edit-src-save
    (:before (&rest _args))
  (when (buffer-narrowed-p)
    (delete-hidden-text)))

(defun org-babel-tangle-block ()
  "Tangle a single file under cursor"
  (interactive)
  (let ((current-prefix-arg '(4)))
    (call-interactively 'org-babel-tangle)))
;; This elisp code uses use-package, a macro to simplify configuration. It will
;; install it if it's not available, so please edit the following code as
;; appropriate before running it.

;; Note that this file does not define any auto-expanding YaSnippets.
;; AucTeX settings - almost no changes
(use-package! latex
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

(use-package! preview
  :after latex
  :hook ((LaTeX-mode . preview-larger-previews))
  :config
  (defun preview-larger-previews ()
    (setq preview-scale-function
          (lambda () (* 1.25
                        (funcall (preview-scale-from-face)))))))

;; CDLatex settings
(use-package! cdlatex
  :ensure t
  :hook (LaTeX-mode . turn-on-cdlatex)
  :bind ((:map cdlatex-mode-map
               ("<tab>" . cdlatex-tab))
         (:map org-cdlatex-mode-map
               (";" . cdlatex-math-modify))))

;; Yasnippet settings
(use-package! yasnippet
  :ensure t
  :hook ((LaTeX-mode . yas-minor-mode)
         (post-self-insert . my/yas-try-expanding-auto-snippets))
  :config
  (use-package! warnings
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

;; CDLatex integration with YaSnippet: Allow cdlatex tab to work inside Yas
;; fields
(use-package! cdlatex
  :hook ((cdlatex-tab . yas-expand)
         (cdlatex-tab . cdlatex-in-yas-field))
  :config
  (use-package! yasnippet
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
        (yas-next-field-or-maybe-expand)))))

;; Array/tabular input with org-tables and cdlatex
(use-package! org-table
  :after cdlatex
  :bind (:map orgtbl-mode-map
              ("<tab>" . lazytab-org-table-next-field-maybe)
              ("TAB" . lazytab-org-table-next-field-maybe))
  :init
  (add-hook 'cdlatex-tab-hook 'lazytab-cdlatex-or-orgtbl-next-field 90)
  ;; Tabular environments using cdlatex
  (add-to-list 'cdlatex-command-alist '("smat" "Insert smallmatrix env"
                                        "\\left( \\begin{smallmatrix} ? \\end{smallmatrix} \\right)"
                                        lazytab-position-cursor-and-edit
                                        nil nil t))
  (add-to-list 'cdlatex-command-alist '("bmat" "Insert bmatrix env"
                                        "\\begin{bmatrix} ? \\end{bmatrix}"
                                        lazytab-position-cursor-and-edit
                                        nil nil t))
  (add-to-list 'cdlatex-command-alist '("pmat" "Insert pmatrix env"
                                        "\\begin{pmatrix} ? \\end{pmatrix}"
                                        lazytab-position-cursor-and-edit
                                        nil nil t))
  (add-to-list 'cdlatex-command-alist '("tbl" "Insert table"
                                        "\\begin{table}\n\\centering ? \\caption{}\n\\end{table}\n"
                                        lazytab-position-cursor-and-edit
                                        nil t nil))
  :config
  ;; Tab handling in org tables
  (defun lazytab-position-cursor-and-edit ()
    ;; (if (search-backward "\?" (- (point) 100) t)
    ;;     (delete-char 1))
    (cdlatex-position-cursor)
    (lazytab-orgtbl-edit))

  (defun lazytab-orgtbl-edit ()
    (advice-add 'orgtbl-ctrl-c-ctrl-c :after #'lazytab-orgtbl-replace)
    (orgtbl-mode 1)
    (open-line 1)
    (insert "\n|"))

  (defun lazytab-orgtbl-replace (_)
    (interactive "P")
    (unless (org-at-table-p) (user-error "Not at a table"))
    (let* ((table (org-table-to-lisp))
           params
           (replacement-table
            (if (texmathp)
                (lazytab-orgtbl-to-amsmath table params)
              (orgtbl-to-latex table params))))
      (kill-region (org-table-begin) (org-table-end))
      (open-line 1)
      (push-mark)
      (insert replacement-table)
      (align-regexp (region-beginning) (region-end) "\\([:space:]*\\)& ")
      (orgtbl-mode -1)
      (advice-remove 'orgtbl-ctrl-c-ctrl-c #'lazytab-orgtbl-replace)))

  (defun lazytab-orgtbl-to-amsmath (table params)
    (orgtbl-to-generic
     table
     (org-combine-plists
      '(:splice t
        :lstart ""
        :lend " \\\\"
        :sep " & "
        :hline nil
        :llend "")
      params)))

  (defun lazytab-cdlatex-or-orgtbl-next-field ()
    (when (and (bound-and-true-p orgtbl-mode)
               (org-table-p)
               (looking-at "[[:space:]]*\\(?:|\\|$\\)")
               (let ((s (thing-at-point 'sexp)))
                 (not (and s (assoc s cdlatex-command-alist-comb)))))
      (call-interactively #'org-table-next-field)
      t))

  (defun lazytab-org-table-next-field-maybe ()
    (interactive)
    (if (bound-and-true-p cdlatex-mode)
        (cdlatex-tab)
      (org-table-next-field))))

;; tufte export: https://damitr.org/2014/01/09/latex-tufte-class-in-org-mode/
;;
;; (defun my/org-latex-title-command (info)
;;   "Custom LaTeX title command to include email."
;;   (let ((title (org-export-data (plist-get info :title) info))
;;         (author (org-export-data (plist-get info :author) info))
;;         (email (plist-get info :email)))
;;     (concat
;;      (format "\\title{%s}\n" title)
;;      (format "\\author{%s}\n" author)
;;      (if email (format "\\email{%s}\n" email) "")
;;      "\\maketitle\n")))

;; (setq org-latex-title-command #'my/org-latex-title-command)

(after! ox-latex
  ;; Add Tufte-book to org-latex-classes
  (add-to-list 'org-latex-classes
               '("tuftebook"
                 "\\documentclass{tufte-book}
\\usepackage{color}
\\usepackage{gensymb}
\\usepackage{nicefrac}
\\usepackage{units}"
                 ("\\chapter{%s}" . "\\chapter*{%s}")
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ;; Leave subsubsection empty, so it's handled manually
                 ("\\newthought{%s}" . "")))

  ;; Customize the export behavior for subsubsections
  (defun my-org-latex-newthought-filter (text backend info)
    "Replace subsubsection headings with \\newthought{} in LaTeX export."
    (when (and (org-export-derived-backend-p backend 'latex)
               (string-match "\\\\subsubsection{\\(.*?\\)}" text))
      (replace-match "\\\\newthought{\\1}" nil nil text)))

  ;; Add the filter to LaTeX export
  (add-to-list 'org-export-filter-final-output-functions #'my-org-latex-newthought-filter)

  ;; tufte-handout class for writing classy handouts and papers
  (add-to-list 'org-latex-classes
               '("tuftehandout"
                 "\\documentclass{tufte-handout}
                \\usepackage{color}
                \\usepackage{gensymb}
                \\usepackage{nicefrac}
                \\usepackage{units}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
  (add-to-list 'org-latex-classes
               '("tuftethesis"
                 "\\documentclass[boxey, colorful]{tufte-style-thesis}"))

  (add-to-list 'org-latex-classes
               '("siggraph"
                 "\\documentclass[sigconf]{acmart}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")))

  (add-to-list 'org-latex-classes
               '("siggraph-acmtog"
                 "\\documentclass[acmtog]{acmart}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")))

  (add-to-list 'org-latex-classes
               '("siggraph-review"
                 "\\documentclass[acmtog,anonymous,review]{acmart}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}"))))


(defun me/screenshot ()
  "Take a screenshot into a time stamped unique-named file in the
same directory as the org-buffer and insert a link to this file."
  (interactive)
  (setq dirname
        (file-name-sans-extension (buffer-name)))

  ;; create the dir if it doesnt exist
  (unless
      (file-directory-p dirname)
    (make-directory (concat org-download-image-dir dirname) t))

  (setq filename
        (concat (format-time-string "%Y%m%d_%H%M%S") ".png"))
  (call-process "screencapture" nil nil nil "-i" (concat
                                                  org-download-image-dir
                                                  dirname
                                                  "/"
                                                  filename))
  ;; use relative paths to use multiple devices without any trouble
  (insert (concat "~/Notes/Assets/" dirname "/" filename)))

(map! :after org
      :map org-mode-map
      :localleader
      :desc "Open screencapture and insert file path at current position" "a s" #'me/screenshot)


;; required otherwise won't produce the table of contents file
;; (setq! org-latex-pdf-process
;;        '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
;;          "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))


(setq! citar-bibliography '("~/Notes/references.bib"))

(defun my/pipenv-activate-and-restart-lsp ()
  "Activate pipenv environment and restart LSP workspace."
  (interactive)
  ;; Activate pipenv environment
  (pipenv-activate)
  ;; Wait for the pipenv environment to activate
  (sit-for 2) ;; Adjust the wait time if necessary
  ;; Restart LSP workspace
  (lsp-restart-workspace))

;; Optionally, bind it to a key for convenience
(map! :localleader
      :mode python-mode
      :desc "Activate pipenv and restart LSP" "e x" #'my/pipenv-activate-and-restart-lsp)

(defun my/roam-open-ref ()
  "Opens the current references for the roam-node. Mainly used to take notes from paper annotations."
  (interactive)
  (require 'citar-org-roam) ;; necessary: sometimes citar-org-roam is not loaded, thus the function does not exist
  (evil-window-vsplit)
  (citar-org-roam-open-current-refs))

(defun my/open-ref ()
  "Opens the refernce for the current roam node."
  (interactive)
  (require 'citar-org-roam)
  (citar-org-roam-open-current-refs))


(map! :after org
      :map org-mode-map
      :localleader
      :desc "Open the reference in vsplit." "m v" #'my/roam-open-ref)

(map! :after org
      :map org-mode-map
      :localleader
      :desc "Open the reference in the roam-node." "m p" #'my/open-ref)


(use-package! pet
  :config
  (add-hook 'python-mode-hook 'pet-mode -10))

(defun set-warning-level-org ()
  "Sets warning level to ignore ox warnings"
  (setq-local warning-minimum-level :emergency))

(add-hook! 'org-mode-hook #'set-warning-level-org)

(after! dap-mode
  (require 'dap-python)
  (require 'dap-lldb)
  (setq dap-python-debugger 'debugpy)
  (setq dap-lldb-debug-program '("lldb-vscode"))
  (setq dap-lldb-debugged-program-function (lambda () (read-file-name "Select file to debug: ")))

  (defun my/set-pythonpath-to-project-root ()
    "Set PYTHONPATH to the project's root directory for Python debugging."
    (let ((project-root (or (projectile-project-root)
                            (lsp-workspace-root)
                            (default-directory))))
      (setenv "PYTHONPATH" project-root)
      (message "Set PYTHONPATH to %s" project-root)))

  (add-hook 'dap-stopped-hook #'my/set-pythonpath-to-project-root)

  (dap-register-debug-template
   "C++ LLDB Debug"
   (list :type "lldb"
         :request "launch"
         :program nil
         :cwd (projectile-parent (projectile-project-name))
         :stopOnEntry t
         :args []))

  (dap-register-debug-template
   "Python Debug"
   (list :type "python"
         :debugger "debugpy"
         :request "launch"
         :program nil
         :cwd (projectile-parent (projectile-project-name))
         :stopOnEntry t
         :args [])))


(defun cpp-auto-dot-to-arrow ()
  "Automatically replace `.` with `->` if it follows a pointer variable."
  (interactive)
  (let ((char-before (char-before (point))))
    (if (and char-before
             (eq char-before ?.) ; Check if the last character was `.`
             (save-excursion
               (backward-char) ; Move back to inspect context
               (skip-syntax-backward "w_") ; Skip over word/pointer characters
               (looking-at-p "->"))) ; Check for existing arrow use
        (progn
          (delete-char -1) ; Remove the `.`
          (insert "->"))
      (insert ".")))) ; Default behavior if not a pointer

(defun enable-auto-dot-to-arrow ()
  "Enable auto dot-to-arrow conversion for C++ mode."
  (local-set-key (kbd ".") #'cpp-auto-dot-to-arrow))

(use-package! gptel
  :config
  ;; Set the default model and backend
  (setq!
   auth-sources '("~/.authinfo")
   gptel-api-key (auth-source-pick-first-password :host "api.openai.com")
   gptel-model 'gemini-2.0-flash-exp
   gptel-backend (gptel-make-gemini "Gemini"
                   :key (auth-source-pick-first-password :host "generativelanguage.googleapis.com")
                   :stream t))

  (gptel-make-anthropic "Claude"
    :key (auth-source-pick-first-password :host "api.anthropic.com")
    :stream t)

  :custom
  (gptel-use-curl nil)
  (gptel-default-mode 'org-mode))


(use-package! elfeed
  ;; may also want to add elfeed-org
  :config
  (setq! elfeed-feeds
         ;;                            |- allows us to specify tags for the feed
         '(("https://gpuopen.com/feed/" graphics))))
