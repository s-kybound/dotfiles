;; This is a sample Guix Home configuration which can help setup your
;; home directory in the same declarative manner as Guix System.
;; For more information, see the Home Configuration section of the manual.
(add-to-load-path (string-append (dirname (current-filename)) "/modules"))

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
  #:use-module (pi-guix packages pi)
  #:use-module (dotfiles home services pi-extensions))

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
	  #:log-file #$(string-append (getenv "HOME") "/.local/state/llama-" name ".log")))
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

(define %pi-extensions
  (list
    (pi-extension (type 'git)
                  (source "github.com/ayghri/i-have-adhd")
                  (ref "6f1f982d0a47c65899af3c5a7450b7098bc65325")
                  (hash "15iigxii7s7aj80lcy6hm1xv9q96z6wsvys9jsqyav857lrknd4a"))
    (pi-extension (type 'git)
                  (source "github.com/v2nic/pi-caveman")
                  (ref "2480692ffabddc3d1efec8eb822e664ff7e0e5ef")
                  (hash "03964sxm5ll3f6p4s2ba4rxj78qkp8q260lc82y7b7wbksz9pli7"))
    (pi-extension (type 'npm) (source "pi-hermes-memory") (version "^0.9.9"))
    (pi-extension (type 'npm) (source "pi-observational-memory") (version "^3.0.4"))
    (pi-extension (type 'npm) (source "teach-me") (version "^2.0.0"))
    (pi-extension (type 'npm) (source "tdd-enforcer") (version "^0.3.10"))))

(define %pi-subagents-extension
  (pi-code-extension
    (name "subagent")
    (source "github.com/nicobailon/pi-subagents")
    (ref "f6d2135ec2ca4010b83b7d5ee46774176d49d1e6")
    (hash "0y1fb4zsxbaxagl5rqbxqbm8gvi1xjgvlbwjly268siasr1rxxds")
    (node-modules-hash "1pj94hwr29z0dz9idb5kg6gcas19smxj7xrrlxd455ah2nszfbwz")))

(define %pi-skills
  (list
    (pi-skill (type 'git)
              (source "github.com/mattpocock/skills")
              (ref "3cca18b368ae95cdbdebbff572ccafa662551015")
              (hash "13fzf6bb6qa8n274jjcqy2jvyaa9fcjlaj1xbkfag7n7p3gn4pkl"))))

(define home-config
  (home-environment
    (packages 
      (append
        (list claude-code pi-coding-agent)
        (specifications->packages
          (list "prusa-slicer"
          	"calibre"
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
             (".Xdefaults" ,%default-xdefaults)
             (".pi/agent/models.json" ,(local-file "pi/.pi/agent/models.json"))))

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
                              '("-ncmoe" "40" "-ngl" "999" "-c" "131072"
                                "-fa" "on" "-b" "2048" "-ub" "2048"
                                "-t" "8" "-tb" "16" "-np" "1"))
                            (llama-server-home-shepherd-service
                              "qwen3-4b-subagent" 48774
                              "/fastdisk/models/Qwen3-4B-Q5_K_M.gguf"
                              '("-ngl" "999" "-c" "8192"
                                "-fa" "on" "-b" "1024" "-ub" "1024"
                                "-t" "8" "-tb" "16" "-np" "1"))))

          (pi-code-extension->home-service %pi-subagents-extension))

        (pi-extensions->home-services
          %pi-extensions
          #:skills %pi-skills
          #:default-provider "local-qwen"
          #:default-model "qwen3.6-35b-a3b"
          #:last-changelog-version "0.85.1"
          #:npm-hash "08w6k2fbx2rkwh7i44sh32z00gnc50lfz2db4hfs8fxsaag3px8n"
          #:subagents-json
          "{
    \"defaultModel\": \"local-qwen-fast/qwen3-4b\",
    \"defaultThinking\": \"off\",
    \"agentOverrides\": {
      \"oracle\": {
        \"model\": \"local-qwen/qwen3.6-35b-a3b\",
        \"thinking\": \"high\"
      }
    }
  }")

        %base-home-services))))

home-config
