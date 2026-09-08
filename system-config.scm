(use-modules (gnu)
	     (gnu packages glib)
	     (gnu packages window-management)
	     (nongnu packages nvidia)
	     (nongnu services nvidia)
	     (nonguix transformations)
	     (nongnu packages linux)
	     (nongnu system linux-initrd))

(use-service-modules desktop sound xorg)

((nonguix-transformation-nvidia #:driver nvda)
 (operating-system
   (kernel linux)
   (initrd microcode-initrd)
   (firmware (cons* iwlwifi-firmware 
   		    linux-firmware
		    %base-firmware))
   (kernel-arguments
     (cons* "modprobe.blacklist=nouveau,amdgpu"
	    "nvidia_drm.modeset=1"
            "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
	    %default-kernel-arguments))
   (kernel-loadable-modules (list nvidia-module #;nvidia-driver))

   (locale "en_SG.utf8")
   (timezone "Asia/Singapore")
   (keyboard-layout (keyboard-layout "us"))
   (host-name "flatwhite")

   ;; The list of user accounts ('root' is implicit).
   (users (cons* (user-account
                   (name "skybound")
                   (comment "Kyriel Abad")
                   (group "users")
                   (home-directory "/home/skybound")
                   (supplementary-groups '("wheel" "netdev" "audio" "video")))
                 %base-user-accounts))

   ;; Packages installed system-wide.  Users can also install packages
   ;; under their own account: use 'guix search KEYWORD' to search
   ;; for packages and 'guix install PACKAGE' to install a package.
   (packages 
     (append (map specification->package
		  (list #;"llama-cpp"
		        "niri"
		        "xwayland-satellite"
		        "xorg-server-xwayland"
 	                "foot"
 	                "noctalia-git"
                        "ranger"
                        "btop"
                        "tmux"
                        "git"
                        "vim"
			"openssh"))
     %base-packages))

   ;; Below is the list of system services.  To search for available
   ;; services, run 'guix system search KEYWORD' in a terminal.
   (services
     (cons* (service nvidia-service-type)
	    (service pam-limits-service-type
		     (list (pam-limits-entry "@audio" 'both 'rtprio 99)
			   (pam-limits-entry "@audio" 'both 'memlock 'unlimited)))
	    (service greetd-service-type
		     (greetd-configuration
		       (greeter-supplementary-groups (list "video" "input"))
		       (terminals
			 (list
			   (greetd-terminal-configuration
			     (terminal-vt "7")
			     (terminal-switch #t)
			     (default-session-command
			       (greetd-agreety-session
				 (command (greetd-user-session
			           (command (file-append dbus "/bin/dbus-run-session"))
				   (command-args (list (file-append niri "/bin/niri") "--session")))))))))))
   	    (modify-services %desktop-services
			     (delete gdm-service-type)
			     (delete pulseaudio-service-type))))

   (bootloader (bootloader-configuration
                 (bootloader grub-efi-bootloader)
                 (targets '("/boot/efi"))
		 (menu-entries 
		   (list (menu-entry
			   (label "NixOS")
			   (chain-loader "/EFI/NixOS-boot/grubx64.efi")))) 
			   (keyboard-layout keyboard-layout)))

   ;; The list of file systems that get "mounted".  The unique
   ;; file system identifiers there ("UUIDs") can be obtained
   ;; by running 'blkid' in a terminal.
   (file-systems (cons* (file-system
                          (mount-point "/slowdisk")
                          (device (uuid
                                   "5296c0e9-e5cd-4679-9c06-e6b976f61fe2"
                                   'ext4))
                          (type "ext4"))
                        (file-system
                          (mount-point "/fastdisk")
                          (device (uuid
                                   "d73e4110-48d2-4f5a-aff9-c0dabb29452d"
                                   'ext4))
                          (type "ext4"))
                        (file-system
                          (mount-point "/")
                          (device (uuid
                                   "eecfbb00-763a-4078-9619-9d60fa071508"
                                   'ext4))
                          (type "ext4"))
                        (file-system
                          (mount-point "/boot/efi")
                          (device (uuid "CB77-1709"
                                        'fat32))
                          (type "vfat")) %base-file-systems))))
