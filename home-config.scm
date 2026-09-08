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
        (map (compose replace-mesa specification->package)
          (list "pavucontrol"
	        "alsa-utils"
	        "foot"
	        "emacs"
	        "neovim"
	        "firefox"
	        "prusa-slicer"
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

          (service home-files-service-type
           `((".guile" ,%default-dotguile)
             (".Xdefaults" ,%default-xdefaults)))

          (service home-xdg-configuration-files-service-type
           `(("gdb/gdbinit" ,%default-gdbinit)
             ("nano/nanorc" ,%default-nanorc))))

        %base-home-services))))

home-config
