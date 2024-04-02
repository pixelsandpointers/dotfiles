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
(setq doom-theme 'doom-one)
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 13))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/notes/Org")


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

(defun org-babel-edit-prep:c (babel-info)
  (setq-local buffer-file-name (->> babel-info caddr (alist-get :tangle)))
  (lsp))

;; (defun org-babel-edit-prep:cpp (babel-info)
;;   (setq-local buffer-file-name (->> babel-info caddr (alist-get :tangle)))
;;   (lsp))

(defun org-babel-edit-prep:python (babel-info)
  (setq-local buffer-file-name (->> babel-info caddr (alist-get :tangle)))
  (lsp))

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
  (message "This ran for no reason")
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
