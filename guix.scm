; SPDX-License-Identifier: MPL-2.0
;; guix.scm — GNU Guix package definition for natsci-studio
;; Usage: guix shell -f guix.scm

(use-modules (guix packages)
             (guix build-system gnu)
             (guix licenses))

(package
  (name "natsci-studio")
  (version "0.1.0")
  (source #f)
  (build-system gnu-build-system)
  (synopsis "natsci-studio")
  (description "natsci-studio — part of the hyperpolymath ecosystem.")
  (home-page "https://github.com/hyperpolymath/natsci-studio")
  (license mpl2.0))
