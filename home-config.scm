;; This is a sample Guix Home configuration which can help setup your
;; home directory in the same declarative manner as Guix System.
;; For more information, see the Home Configuration section of the manual.
(define-module (guix-home-config)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  #:use-module (gnu packages machine-learning)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services fontutils)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services sound)
  #:use-module (gnu home services ssh)
  #:use-module (gnu home services xdg)
  #:use-module (gnu services)
  #:use-module (gnu system shadow)
  #:use-module (gnu packages base)
  #:use-module (nongnu packages nvidia)
  #:use-module (claude-code-guix packages claude-code)
  #:use-module (pi-guix packages pi))

(define (llama-server-home-shepherd-service name port model-path extra-args)
  (shepherd-service
    (documentation (string-append "llama.cpp server for " name))
    (provision (list (string->symbol (string-append "llama-" name))))
    (auto-start? #t)
    (respawn? #t)
    (start
      #~(make-forkexec-constructor
	  (list #$(file-append llama-cpp "/bin/llama-server")
		"-m" #$model-path
		"--host" "127.0.0.1"
		"--port" #$(number->string port)
		#$@extra-args)
	  #:log-file #$(string-append "/home/skybound/.local/state/llama-" name ".log")))
    (stop #~(make-kill-destructor))))

(define (disk-mount disk)
  (let ((mount (string-append "/" (symbol->string disk))))
    (unless (file-exists? mount)
      (error "disk-links: mount point does not exist" mount))
    mount))

(define %disk-links
  '(("calibre-library" . slowdisk)
    ("documents"       . slowdisk)
    ("Downloads"       . slowdisk)
    ("pictures"        . slowdisk)
    ("games"           . fastdisk)
    ("projects"        . fastdisk)))

(define (disk-links-activation-gexp links)
  #~(for-each
      (lambda (pair)
        (let* ((name (car pair))
               (mount (cdr pair))
               (target (string-append mount "/" (getenv "USER") "/" name))
               (link (string-append (getenv "HOME") "/" name)))
          (system* #$(file-append coreutils "/bin/mkdir") "-p" target)
          (unless (file-exists? link)
            (system* #$(file-append coreutils "/bin/ln") "-s" target link))))
      '#$(map (lambda (pair) (cons (car pair) (disk-mount (cdr pair))))
              links)))

(define home-config
  (home-environment
    (packages 
      (append
        (list claude-code pi-coding-agent)
        (specifications->packages
          (list "prusa-slicer"
		"cowsay"
		"neofetch"
                "glib-networking"))
        (specifications->packages
          (list "rust" "rust:cargo" "rust:tools" "rust:rust-src" "rust-analyzer"
                "ocaml" "dune" "ocaml-lsp-server" "ocamlformat" "ocaml-utop" "opam"
                "node"
                "gcc-toolchain" "make" "pkg-config"))
        (map (compose replace-mesa specification->package)
          (list "pavucontrol"
	        "xdg-utils"
	        "alsa-utils"
	        "foot"
	        "emacs"
	        "neovim"
	        "firefox"
	        "telegram-desktop"
	        "font-iosevka"
	        "font-google-noto-emoji"))))
    (services
      (append
        (list
          ;; Uncomment the shell you wish to use for your user:
          ;(service home-bash-service-type)
          ;(service home-fish-service-type)
          (service home-zsh-service-type)
	  (service home-ssh-agent-service-type)
	  (service home-openssh-service-type
		   (home-openssh-configuration
		     (add-keys-to-agent "yes")
		     (hosts
		       (list
			 (openssh-host
			   (name "eclair")
			   (host-name "10.6.2.114")
			   (user "skybound")
			   (identity-file "~/.ssh/id_ed25519"))))))
	  (service home-dbus-service-type)
	  (service home-pipewire-service-type
		   (home-pipewire-configuration
		     (enable-pulseaudio? #t)))
          (simple-service 'font-prefs
	           home-fontconfig-service-type
                      (list
                        '(alias
                           (family "monospace")
                           (prefer (family "Iosevka")
                                   (family "Noto Color Emoji")))))

	  (simple-service 'foot-config
			  home-xdg-configuration-files-service-type
			  (list (list "foot/foot.ini"
				      (local-file "foot/.config/foot/foot.ini"))))

	  (simple-service 'wireplumber-dp-audio
			  home-xdg-configuration-files-service-type
			  (list (list "wireplumber/wireplumber.conf.d/51-nvidia-dp-audio.conf"
				      (local-file "wireplumber/.config/wireplumber/wireplumber.conf.d/51-nvidia-dp-audio.conf"))))

	  (simple-service 'niri-config
			  home-xdg-configuration-files-service-type
			  (list (list "niri/config.kdl"
				      (local-file "niri/.config/niri/config.kdl"))))

          ;; dummy proxy resolver stops libproxy crashing PrusaSlicer's WebKit network process
          (simple-service 'webkit-login-env
                          home-environment-variables-service-type
                          '(("GIO_EXTRA_MODULES" .
                             "$HOME/.guix-home/profile/lib/gio/modules:/run/current-system/profile/lib/gio/modules")
                            ("GIO_USE_PROXY_RESOLVER" . "dummy")))

          (service home-xdg-mime-applications-service-type
                   (home-xdg-mime-applications-configuration
                     (default
                       '((x-scheme-handler/http        . firefox.desktop)
                         (x-scheme-handler/https       . firefox.desktop)
                         (text/html                    . firefox.desktop)
                         (x-scheme-handler/prusaslicer . prusaslicer-url.desktop)))
                     (desktop-entries
                       (list
                         (xdg-desktop-entry
                           (file "prusaslicer-url")
                           (name "PrusaSlicer URL Handler")
                           (type 'application)
                           (config
                             '((exec . "prusa-slicer %u")
                               (icon . "PrusaSlicer")
                               (terminal . #f))))))))

          (service home-files-service-type
           `((".guile" ,%default-dotguile)
             (".Xdefaults" ,%default-xdefaults)))

          (service home-xdg-configuration-files-service-type
           `(("gdb/gdbinit" ,%default-gdbinit)
             ("nano/nanorc" ,%default-nanorc)))

          (simple-service 'disk-symlinks
                          home-activation-service-type
                          (disk-links-activation-gexp %disk-links))

          (simple-service 'llama-servers
                          home-shepherd-service-type
                          (list
                            (llama-server-home-shepherd-service
                              "qwen3.6-35b-a3b" 48772
                              "/fastdisk/models/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf"
                              '("-ncmoe" "35" "-ngl" "999" "-c" "131072"
                                "-fa" "on" "-b" "4096" "-ub" "4096"
                                "-t" "8" "-tb" "16" "-np" "1")))))

        %base-home-services))))

home-config
