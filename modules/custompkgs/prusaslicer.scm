;; PrusaSlicer packaging.
;;
;; PrusaSlicer 2.9.x built natively (from source, or as an AppImage) hits
;; an open upstream bug where the plater's 3D viewport renders solid
;; black under NVIDIA + Wayland/XWayland (GL error 1286,
;; GL_INVALID_FRAMEBUFFER_OPERATION). See prusa3d/PrusaSlicer#14527.
;; Rebuilding from source against Guix's current library versions also
;; hits real CGAL 6.x API breakage (not just CMake glue) in
;; CutSurface.cpp. Upstream also stopped shipping Linux AppImages after
;; 2.8.1, moving to Flathub as the only Linux channel from 2.9.0 onward.
;;
;; `prusa-slicer-flatpak` is a thin `prusa-slicer` wrapper around the
;; official Flathub build (see (custompkgs flatpak) for the portal
;; plumbing this needs) — its bundled runtime avoids the render bug
;; entirely, so this is how to get a current PrusaSlicer (needed for
;; Prusa CORE One support).

(define-module (custompkgs prusaslicer)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages package-management)
  #:export (prusa-slicer-flatpak))

;; A thin `bin/prusa-slicer` wrapper around `flatpak run
;; com.prusa3d.PrusaSlicer`, so both the plain `prusa-slicer` command and
;; the prusaslicer:// URL handler (used for the OAuth login callback, and
;; for the "Send to PrusaSlicer" flow from printables.com) resolve to the
;; Flatpak build. See (custompkgs flatpak) for the portal/D-Bus plumbing
;; Flatpak itself needs here, and flatpak-prusaslicer-activation-gexp for
;; how the app itself gets installed.
(define prusa-slicer-flatpak
  (package
    (name "prusa-slicer-flatpak")
    (version "2.9.6")
    (source #f)
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils))
          (let ((bindir (string-append #$output "/bin")))
            (mkdir-p bindir)
            (call-with-output-file (string-append bindir "/prusa-slicer")
              (lambda (port)
                (format port "#!~a
exec ~a run --user com.prusa3d.PrusaSlicer \"$@\"
"
                        #$(file-append bash-minimal "/bin/bash")
                        #$(file-append flatpak "/bin/flatpak"))))
            (chmod (string-append bindir "/prusa-slicer") #o755)))))
    (inputs (list bash-minimal flatpak))
    (synopsis "PrusaSlicer (Flathub build, wrapped)")
    (description
     "A `prusa-slicer` command that runs the official PrusaSlicer Flatpak
from Flathub. Its bundled runtime avoids the NVIDIA + Wayland/XWayland
black-viewport bug that affects natively-built PrusaSlicer 2.9.x, so this
is how to get a current version with Prusa CORE One support.")
    (home-page "https://www.prusa3d.com/prusaslicer/")
    (license license:agpl3)))
