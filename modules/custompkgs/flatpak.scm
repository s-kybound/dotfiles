;; Flatpak + the portal infrastructure it needs, plus a declarative
;; install of PrusaSlicer from Flathub.
;;
;; Why: PrusaSlicer 2.9.x built natively (from source or as an AppImage)
;; hits an open upstream bug where the plater's 3D viewport renders solid
;; black under NVIDIA + Wayland/XWayland (GL_INVALID_FRAMEBUFFER_OPERATION,
;; prusa3d/PrusaSlicer#14527). Upstream also stopped shipping Linux
;; AppImages after 2.8.1, moving to Flathub as the only Linux channel from
;; 2.9.0 onward. The Flatpak build's bundled runtime avoids the render bug
;; entirely, so this is how we get PrusaSlicer 2.9.x (needed for Prusa
;; CORE One support) instead of being stuck on 2.8.1.
;;
;; Getting Flatpak itself working here needed two things beyond just the
;; package, neither of which Guix Home provides out of the box:
;;
;;   1. xdg-desktop-portal + a backend (xdg-desktop-portal-gtk) running as
;;      background services, for portal-mediated functionality apps expect
;;      (file choosers, icon loading, etc).
;;
;;   2. Flatpak's own portal, org.freedesktop.portal.Flatpak (provided by
;;      the `flatpak-portal` binary), registered as a D-Bus session
;;      service so it can be auto-activated. Without this, nested sandbox
;;      spawns fail outright: GTK's newer "glycin" image-loader sandboxes
;;      every image decode in its own nested bwrap sandbox via this
;;      portal, and if it's missing, that nested spawn fails, which GLib
;;      treats as a fatal error and the app aborts on startup.

(define-module (custompkgs flatpak)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:export (flatpak-packages
            flatpak-portal-shepherd-services
            flatpak-dbus-service-files
            flatpak-prusaslicer-activation-gexp))

(define flatpak-packages
  (list flatpak xdg-desktop-portal xdg-desktop-portal-gtk))

(define (portal-shepherd-service name provision-name package binary env)
  (shepherd-service
    (documentation (string-append "Portal service: " name))
    (provision (list (string->symbol provision-name)))
    (auto-start? #t)
    (respawn? #t)
    (start
      #~(make-forkexec-constructor
          (list #$(file-append package binary))
          #:environment-variables (append '#$env (environ))
          #:log-file #$(string-append (getenv "HOME") "/.local/state/"
                                       provision-name ".log")))
    (stop #~(make-kill-destructor))))

(define flatpak-portal-shepherd-services
  ;; home-shepherd starts before niri exports WAYLAND_DISPLAY into its
  ;; environment, so these services never see it via plain inheritance;
  ;; hardcode it. This is a single-seat setup where niri always comes up
  ;; on wayland-1, so this is stable in practice.
  (let ((base-env '("XDG_CURRENT_DESKTOP=GNOME" "WAYLAND_DISPLAY=wayland-1")))
    (list
      (portal-shepherd-service
        "xdg-desktop-portal" "xdg-desktop-portal"
        xdg-desktop-portal "/libexec/xdg-desktop-portal"
        base-env)
      (portal-shepherd-service
        "xdg-desktop-portal-gtk" "xdg-desktop-portal-gtk"
        xdg-desktop-portal-gtk "/libexec/xdg-desktop-portal-gtk"
        base-env))))

;; Registers Flatpak's own org.freedesktop.portal.Flatpak D-Bus service
;; under the user's D-Bus service directory, so the session bus can
;; auto-activate it (nested sandbox spawns need this; see module
;; docstring above). This is what home-files-service-type installs to
;; ~/.local/share/dbus-1/services/.
(define flatpak-dbus-service-files
  (list
    (list "dbus-1/services/org.freedesktop.portal.Flatpak.service"
          (mixed-text-file "org.freedesktop.portal.Flatpak.service"
            "[D-BUS Service]\n"
            "Name=org.freedesktop.portal.Flatpak\n"
            "Exec=" (file-append flatpak "/libexec/flatpak-portal") "\n"
            "SystemdService=flatpak-portal.service\n"))))

;; Adds the Flathub remote and installs PrusaSlicer on home activation,
;; idempotently (skips if already installed/added).
(define flatpak-prusaslicer-activation-gexp
  #~(let ((flatpak #$(file-append flatpak "/bin/flatpak")))
      (system* flatpak "remote-add" "--if-not-exists" "--user"
               "flathub" "https://flathub.org/repo/flathub.flatpakrepo")
      (unless (zero? (status:exit-val
                        (system* flatpak "info" "--user"
                                 "com.prusa3d.PrusaSlicer")))
        (system* flatpak "install" "--user" "-y" "flathub"
                 "com.prusa3d.PrusaSlicer"))
      ;; GNOME's newer "glycin" image loader and WebKitGTK both try to
      ;; nest a second sandbox inside Flatpak's own sandbox (for
      ;; per-image-decode isolation, and for WebProcess/NetworkProcess
      ;; isolation respectively). Whether that's needed for the OAuth
      ;; login WebView to work reliably here wasn't fully isolated, but
      ;; both are safe no-ops if the nested sandbox would have worked
      ;; anyway, so leave them on.
      (system* flatpak "override" "--user"
               "--env=GLYCIN_DISABLE_SANDBOX=i-know-the-risks"
               "com.prusa3d.PrusaSlicer")
      (system* flatpak "override" "--user"
               "--env=WEBKIT_DISABLE_SANDBOX=1"
               "com.prusa3d.PrusaSlicer")))
