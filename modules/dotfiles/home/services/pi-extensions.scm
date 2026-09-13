;; Declarative extension management for the pi coding agent.

(define-module (dotfiles home services pi-extensions)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix records)
  #:use-module (guix monads)
  #:use-module (guix store)
  #:use-module (guix base32)
  #:use-module (gnu packages base)
  #:use-module (gnu packages node)
  #:use-module (gnu home services)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:export (pi-extension
            pi-extension?
            pi-extension-type
            pi-extension-source
            pi-extension-ref
            pi-extension-version
            pi-extension-hash
            pi-skill
            pi-skill?
            pi-skill-type
            pi-skill-source
            pi-skill-ref
            pi-skill-hash
            pi-extensions->home-services))

(define %pi-extensions-node node-lts)

(define-record-type* <pi-extension>
  pi-extension make-pi-extension
  pi-extension?
  (type    pi-extension-type)
  (source  pi-extension-source)
  (ref     pi-extension-ref (default #f))
  (version pi-extension-version (default #f))
  (hash    pi-extension-hash (default #f)))

;; pi's "skills" array in settings.json is a separate mechanism from
;; "packages": plain filesystem paths, recursively scanned for SKILL.md, no
;; git:/npm: prefix syntax. Since Guix store paths are immutable, we can
;; point straight at a git-fetch checkout or local-file - no copying needed.
(define-record-type* <pi-skill>
  pi-skill make-pi-skill
  pi-skill?
  (type   pi-skill-type)                 ; 'git or 'local
  (source pi-skill-source)               ; "host/owner/repo" (git) or a
                                          ; file-like object (local)
  (ref    pi-skill-ref (default #f))     ; git commit/tag - git only
  (hash   pi-skill-hash (default #f)))   ; base32 sha256 - git only

(define (pi-skill-path skill)
  (match (pi-skill-type skill)
    ('git (unless (pi-skill-hash skill)
            (error "pi-skill: git skills require #:hash" (pi-skill-source skill)))
          (origin
            (method git-fetch)
            (uri (git-reference
                   (url (string-append "https://" (pi-skill-source skill)))
                   (commit (pi-skill-ref skill))))
            (file-name (string-append
                         (last (string-split (pi-skill-source skill) #\/))
                         "-checkout"))
            (sha256 (base32 (pi-skill-hash skill)))))
    ('local (pi-skill-source skill))))

;; pi normalizes a local install to a path relative to ~/.pi/agent, no
;; matter what form you gave it (verified empirically: absolute input paths
;; still come out relative). relative-path (defined inside the gexp below,
;; where it actually runs) computes the same thing.
(define (pi-extension->settings-string-gexp ext home-directory)
  (match (pi-extension-type ext)
    ('git #~(string-append "git:" #$(pi-extension-source ext)
                            "@" #$(pi-extension-ref ext)))
    ('npm #~#$(pi-extension-source ext))
    ('local #~(relative-path (string-append #$home-directory "/.pi/agent")
                              #$(pi-extension-source ext)))))

(define* (pi-settings-file extensions
                            #:key
                            (skills '())
                            (theme "dark")
                            (default-provider #f)
                            (default-model #f)
                            (last-changelog-version #f)
                            (home-directory (getenv "HOME"))
                            (subagents-json #f))
  (computed-file "settings.json"
    (with-imported-modules '((guix build utils))
      #~(begin
          (define (relative-path base target)
            (define (segments p)
              (filter (lambda (s) (not (string-null? s))) (string-split p #\/)))
            (let loop ((b (segments base)) (t (segments target)))
              (if (and (pair? b) (pair? t) (string=? (car b) (car t)))
                  (loop (cdr b) (cdr t))
                  (string-join (append (map (const "..") b) t) "/"))))
          (call-with-output-file #$output
            (lambda (port)
              (display
                (string-append
                  "{\n"
                  #$(if last-changelog-version
                        (string-append "  \"lastChangelogVersion\": \""
                                       last-changelog-version "\",\n")
                        "")
                  "  \"theme\": \"" #$theme "\""
                  #$(if default-provider
                        (string-append ",\n  \"defaultProvider\": \""
                                       default-provider "\"")
                        "")
                  #$(if default-model
                        (string-append ",\n  \"defaultModel\": \""
                                       default-model "\"")
                        "")
                  ",\n  \"packages\": [\n"
                  (string-join
                    (list #$@(map (lambda (e)
                                    #~(string-append
                                        "    \""
                                        #$(pi-extension->settings-string-gexp
                                            e home-directory)
                                        "\""))
                                  extensions))
                    ",\n")
                  "\n  ]"
                  #$(if (null? skills)
                        ""
                        #~(string-append
                            ",\n  \"skills\": [\n"
                            (string-join
                              (list #$@(map (lambda (s)
                                              #~(string-append
                                                  "    \"" #$(pi-skill-path s) "\""))
                                            skills))
                              ",\n")
                            "\n  ]"))
                  #$(if subagents-json
                        (string-append ",\n  \"subagents\": " subagents-json)
                        "")
                  "\n}\n")
                port)))))))

(define (pi-extension-checkout ext)
  (unless (pi-extension-hash ext)
    (error "pi-extension: git extensions require #:hash" (pi-extension-source ext)))
  (origin
    (method git-fetch)
    (uri (git-reference
           (url (string-append "https://" (pi-extension-source ext)))
           (commit (pi-extension-ref ext))))
    (file-name (string-append
                 (last (string-split (pi-extension-source ext) #\/))
                 "-checkout"))
    (sha256 (base32 (pi-extension-hash ext)))))

(define (pi-git-extensions-activation-gexp extensions)
  (define git-extensions
    (filter (lambda (e) (eq? (pi-extension-type e) 'git)) extensions))
  #~(begin
      (use-modules (guix build utils))
      (for-each
        (lambda (pair)
          (let* ((source (car pair))
                 (checkout (cdr pair))
                 (dest (string-append (getenv "HOME")
                                      "/.pi/agent/git/" source)))
            (mkdir-p (dirname dest))
            (when (file-exists? dest) (delete-file-recursively dest))
            (copy-recursively checkout dest #:log #f)
            (for-each (lambda (f) (chmod f #o755))
                      (find-files dest #:directories? #t))))
        (list #$@(map (lambda (e)
                        #~(cons #$(pi-extension-source e)
                                #$(pi-extension-checkout e)))
                      git-extensions)))))

(define (pi-npm-package-json extensions)
  (define npm-extensions
    (filter (lambda (e) (eq? (pi-extension-type e) 'npm)) extensions))
  (computed-file "package.json"
    #~(call-with-output-file #$output
        (lambda (port)
          (display
            (string-append
              "{\n  \"name\": \"pi-extensions\",\n"
              "  \"private\": true,\n  \"dependencies\": {\n"
              #$(string-join
                  (map (lambda (e)
                         (string-append "    \"" (pi-extension-source e)
                                        "\": \""
                                        (or (pi-extension-version e) "*")
                                        "\""))
                       npm-extensions)
                  ",\n")
              "\n  }\n}\n")
            port)))))

(define* (npm-install-fetch package-json hash-algo hash name
                             #:key (system (%current-system))
                             (guile (default-guile)))
  (define build
    (with-imported-modules '((guix build utils))
      #~(begin
          (use-modules (guix build utils))
          (setenv "PATH" #+(file-append coreutils "/bin"))
          (setenv "HOME" (getcwd))
          (setenv "npm_config_cache" (string-append (getcwd) "/.npm-cache"))
          (setenv "npm_config_update_notifier" "false")
          (setenv "npm_config_audit" "false")
          (setenv "npm_config_fund" "false")
          (mkdir "src")
          (copy-file #+package-json "src/package.json")
          (with-directory-excursion "src"
            (invoke #+(file-append %pi-extensions-node "/bin/npm")
                    "install" "--ignore-scripts" "--no-audit" "--no-fund"
                    "--os=linux" "--cpu=x64" "--libc=glibc"))
          (when (file-exists? "src/node_modules/.package-lock.json")
            (delete-file-recursively "src/node_modules/.package-lock.json"))
          (mkdir-p #$output)
          (copy-recursively "src/package.json"
                            (string-append #$output "/package.json") #:log #f)
          (copy-recursively "src/package-lock.json"
                            (string-append #$output "/package-lock.json") #:log #f)
          (copy-recursively "src/node_modules"
                            (string-append #$output "/node_modules") #:log #f))))
  (mlet %store-monad ((guile (package->derivation guile system)))
    (gexp->derivation name build
                      #:system system
                      #:guile-for-build guile
                      #:hash-algo hash-algo
                      #:hash hash
                      #:recursive? #t
                      #:local-build? #f)))

(define* (pi-extensions->home-services extensions
                                        #:key
                                        (skills '())
                                        (theme "dark")
                                        (default-provider #f)
                                        (default-model #f)
                                        (last-changelog-version #f)
                                        (npm-hash #f)
                                        (home-directory (getenv "HOME"))
                                        (subagents-json #f))
  (define npm-extensions
    (filter (lambda (e) (eq? (pi-extension-type e) 'npm)) extensions))
  (unless (or (null? npm-extensions) npm-hash)
    (error "pi-extensions->home-services: npm extensions require #:npm-hash -
compute it with 'guix build' on the resulting .drv and -K to keep the failed
output, or replicate the npm install manually and 'guix hash -x -r' it"))
  (define npm-fetch
    (and (not (null? npm-extensions))
         (origin
           (method npm-install-fetch)
           (uri (pi-npm-package-json extensions))
           (file-name "pi-extensions-node-modules")
           (sha256 (base32 npm-hash)))))
  (list
    (simple-service 'pi-extension-files
                    home-files-service-type
      `((".pi/agent/settings.json"
         ,(pi-settings-file extensions
                             #:skills skills
                             #:theme theme
                             #:default-provider default-provider
                             #:default-model default-model
                             #:last-changelog-version last-changelog-version
                             #:home-directory home-directory
                             #:subagents-json subagents-json))
        ,@(if npm-fetch
              `((".pi/agent/npm/package.json"
                 ,(computed-file "package.json"
                    #~(copy-file (string-append #$npm-fetch "/package.json")
                                 #$output)))
                (".pi/agent/npm/package-lock.json"
                 ,(computed-file "package-lock.json"
                    #~(copy-file (string-append #$npm-fetch "/package-lock.json")
                                 #$output))))
              '())))
    (simple-service 'pi-npm-extensions
                    home-activation-service-type
                    (if npm-fetch
                        #~(begin
                            (use-modules (guix build utils))
                            (let ((dest (string-append (getenv "HOME")
                                                       "/.pi/agent/npm/node_modules")))
                              (when (file-exists? dest)
                                (delete-file-recursively dest))
                              (copy-recursively
                                (string-append #$npm-fetch "/node_modules")
                                dest #:log #f)))
                        #~(begin)))
    (simple-service 'pi-git-extensions
                    home-activation-service-type
                    (pi-git-extensions-activation-gexp extensions))))
