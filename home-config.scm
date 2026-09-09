;; This is a sample Guix Home configuration which can help setup your
;; home directory in the same declarative manner as Guix System.
;; For more information, see the Home Configuration section of the manual.
(define-module (guix-home-config)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services fontutils)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services sound)
  #:use-module (gnu home services ssh)
  #:use-module (gnu home services xdg)
  #:use-module (gnu services)
  #:use-module (gnu system shadow)
  #:use-module (nongnu packages nvidia)
  #:use-module (claude-code-guix packages claude-code)
  #:use-module (pi-guix packages pi))

(define home-config
  (home-environment
    (packages 
      (append
        (list claude-code pi-coding-agent)
        ;; kept off replace-mesa (it corrupts prusa-slicer's viewport); glib-networking backs its login webview's TLS
        (map specification->package
          (list "prusa-slicer"
                "glib-networking"))
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
		     (add-keys-to-agent "yes")))
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
				      (local-file ".guix/foot.ini"))))

	  (simple-service 'wireplumber-dp-audio
			  home-xdg-configuration-files-service-type
			  (list (list "wireplumber/wireplumber.conf.d/51-nvidia-dp-audio.conf"
				      (local-file ".guix/wireplumber-dp-audio.conf"))))

	  (simple-service 'niri-config
			  home-xdg-configuration-files-service-type
			  (list (list "niri/config.kdl"
				      (local-file ".guix/niri.kdl"))))

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
             ("nano/nanorc" ,%default-nanorc))))

        %base-home-services))))

home-config
