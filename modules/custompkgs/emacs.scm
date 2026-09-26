;; emacs-evil-tutor: the evil-mode equivalent of vimtutor, run inside
;; Emacs via M-x evil-tutor-start. Not packaged in Guix upstream, so we
;; define it here directly from its upstream git repository.

(define-module (custompkgs emacs)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module ((guix licenses) #:prefix license:))

(define-public emacs-evil-tutor
  (let ((commit "4e124cd3911dc0d1b6817ad2c9e59b4753638f28")
        (revision "0"))
    (package
      (name "emacs-evil-tutor")
      (version (git-version "0.1.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/syl20bnr/evil-tutor")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "00yfq8aflxvp2nnz7smgq0c5wlb7cips5irj8qs6193ixlkpffvx"))))
      (build-system emacs-build-system)
      (arguments
       (list #:include #~(cons* "^tutor\\.txt$" %default-include)))
      (propagated-inputs (list emacs-evil))
      (home-page "https://github.com/syl20bnr/evil-tutor")
      (synopsis "Evil Tutorial, similar to what @code{vimtutor} provides for Vim")
      (description
       "This package provides an evil tutorial, much like @code{vimtutor}
provides a Vim tutorial.  Use @code{M-x evil-tutor-start} to launch it.")
      (license license:gpl3+))))
