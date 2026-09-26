;;; pi-guix --- Guix package for the pi coding agent
;;;
;;; The upstream npm tarball ships a pre-bundled CLI (dist/bundle/cli.js) but
;;; still resolves a handful of runtime packages (typebox, photon wasm,
;;; prebuilt clipboard bindings, ...) from node_modules.  Those dependencies
;;; are pinned by the upstream npm-shrinkwrap.json, so we materialise them in
;;; a fixed-output derivation (`npm ci --ignore-scripts`) whose result is
;;; verified against a content hash.  The actual package build is then
;;; entirely offline: copy files, drop a wrapper in bin/.

(define-module (custompkgs pi)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix monads)
  #:use-module (guix store)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages node)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages bash))

(define %pi-version "0.85.1")

;; Node/npm used *inside* the node_modules fixed-output derivation.  It is the
;; npm version here that decides the on-disk layout `npm ci' produces, hence
;; the pi-node-modules content hash.  Keep it on a named, slower-moving binding
;; (node-lts) rather than the rolling `node' so that a `guix pull' bumping the
;; default Node major does not silently churn the lock tree and break the build
;; for channel users.  Bumping this is a deliberate re-pin of pi-node-modules.
(define %pi-build-node node-lts)

(define pi-source
  (origin
    (method url-fetch)
    (uri (string-append
          "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/"
          "pi-coding-agent-" %pi-version ".tgz"))
    (sha256
     (base32 "1x3s597x67grwaz174l1rhacdwrbv6s9628ns53ydp4vchlqfj8z"))))

;;;
;;; Fixed-output fetch of node_modules from an npm-shrinkwrap.json.
;;;

(define* (npm-shrinkwrap-fetch source hash-algo hash name
                               #:key (system (%current-system))
                               (guile (default-guile)))
  "Return a fixed-output derivation named NAME that runs `npm ci' against the
shrinkwrap contained in the npm package tarball SOURCE and captures the
resulting node_modules directory."
  (define build
    (with-imported-modules '((guix build utils))
      #~(begin
          (use-modules (guix build utils))
          (setenv "PATH" (string-append #+(file-append gzip "/bin") ":"
                                        #+(file-append tar "/bin")))
          (setenv "HOME" (getcwd))
          (setenv "npm_config_cache" (string-append (getcwd) "/.npm-cache"))
          (setenv "npm_config_update_notifier" "false")
          (setenv "npm_config_audit" "false")
          (setenv "npm_config_fund" "false")
          (mkdir "src")
          (invoke "tar" "-xzf" #+source "-C" "src" "--strip-components=1")
          (with-directory-excursion "src"
            ;; The shrinkwrap only pins production dependencies; `npm ci'
            ;; refuses to run while package.json lists devDependencies it
            ;; cannot find in the lock file.
            (invoke #+(file-append %pi-build-node "/bin/node") "-e"
                    "const fs=require('fs');
                     const p=JSON.parse(fs.readFileSync('package.json'));
                     delete p.devDependencies; delete p.scripts;
                     fs.writeFileSync('package.json', JSON.stringify(p,null,2));")
            ;; Pin the target triple so os/cpu/libc-gated optional deps don't
            ;; depend on the build host.
            (invoke #+(file-append %pi-build-node "/bin/npm")
                    "ci" "--ignore-scripts" "--omit=dev"
                    "--no-audit" "--no-fund"
                    "--os=linux" "--cpu=x64" "--libc=glibc"))
          ;; node_modules/.package-lock.json embeds nothing host specific,
          ;; but drop it anyway: nothing at runtime needs it.
          (delete-file-recursively "src/node_modules/.package-lock.json")
          ;; Keep a directory literally named `node_modules' in the output:
          ;; Node resolves imports made *inside* a dependency from that
          ;; file's realpath, walking up until it finds a `node_modules'
          ;; ancestor.  A bare store path would break e.g. chord -> esbuild.
          (mkdir-p #$output)
          (copy-recursively "src/node_modules"
                            (string-append #$output "/node_modules")
                            #:log #f))))
  (mlet %store-monad ((guile (package->derivation guile system)))
    (gexp->derivation name build
                      #:system system
                      #:guile-for-build guile
                      #:hash-algo hash-algo
                      #:hash hash
                      #:recursive? #t
                      #:local-build? #t)))

(define pi-node-modules
  (origin
    (method npm-shrinkwrap-fetch)
    (uri pi-source)
    (file-name (string-append "pi-coding-agent-" %pi-version "-node-modules"))
    (sha256
     (base32 "1xyp2q0z1yc6zalwv3z7d4l0a32ywrdskbhsk4ngw266dn67ywjk"))))

;;;
;;; The package.
;;;

(define-public pi-coding-agent
  (package
    (name "pi-coding-agent")
    (version %pi-version)
    (source pi-source)
    (build-system copy-build-system)
    ;; The node_modules fixed-output derivation carries a single content hash,
    ;; but `npm ci' resolves os/cpu-gated optional dependencies (native
    ;; prebuilds) against the build machine.  One hash cannot honestly cover
    ;; more than one architecture, and the pinned hash was produced on x86_64,
    ;; so restrict the package rather than fail with a puzzling hash mismatch
    ;; (or a wrong-arch *.node) elsewhere.
    (supported-systems '("x86_64-linux"))
    (arguments
     (list
      #:install-plan
      #~'(("." "lib/node_modules/@earendil-works/pi-coding-agent"
           #:exclude ("node_modules")))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-node-modules
            (lambda _
              (symlink (string-append #$pi-node-modules "/node_modules")
                       (string-append
                        #$output
                        "/lib/node_modules/@earendil-works/pi-coding-agent"
                        "/node_modules"))))
          (add-after 'install-node-modules 'install-wrapper
            (lambda _
              (let* ((bin (string-append #$output "/bin"))
                     (pi (string-append bin "/pi"))
                     (node #$(this-package-input "node"))
                     (cli (string-append
                           #$output
                           "/lib/node_modules/@earendil-works/pi-coding-agent"
                           "/dist/bundle/cli.js")))
                (mkdir-p bin)
                (call-with-output-file pi
                  (lambda (port)
                    (format port "#!~a/bin/sh
# Generated by pi-guix.
export PATH=\"~a/bin${PATH:+:$PATH}\"
exec \"~a/bin/node\" \"~a\" \"$@\"
"
                            #$(this-package-input "bash-minimal")
                            node node cli)))
                (chmod pi #o555)))))))
    (inputs (list bash-minimal node))
    (home-page "https://github.com/earendil-works/pi")
    (synopsis "Minimal, extensible terminal coding agent")
    (description
     "@command{pi} is a coding agent CLI with read, bash, edit and write
tools, session management, a TUI, and an extension system.  Ships the
upstream pre-bundled release together with its pinned runtime
dependencies.")
    (license license:expat)))

pi-coding-agent
