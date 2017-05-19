;; script-fu-export-favicons.scm
;; Gimp Script-fu for exporting favicons as provided by http://www.favicomatic.com/

;; Use the following embedding code
;; ----------------------------------
;; <link rel="apple-touch-icon-precomposed" sizes="57x57" href="/favicons/apple-touch-icon-57x57.png" />
;; <link rel="apple-touch-icon-precomposed" sizes="114x114" href="/favicons/apple-touch-icon-114x114.png" />
;; <link rel="apple-touch-icon-precomposed" sizes="72x72" href="/favicons/apple-touch-icon-72x72.png" />
;; <link rel="apple-touch-icon-precomposed" sizes="144x144" href="/favicons/apple-touch-icon-144x144.png" />
;; <link rel="apple-touch-icon-precomposed" sizes="60x60" href="/favicons/apple-touch-icon-60x60.png" />
;; <link rel="apple-touch-icon-precomposed" sizes="120x120" href="/favicons/apple-touch-icon-120x120.png" />
;; <link rel="apple-touch-icon-precomposed" sizes="76x76" href="/favicons/apple-touch-icon-76x76.png" />
;; <link rel="apple-touch-icon-precomposed" sizes="152x152" href="/favicons/apple-touch-icon-152x152.png" />
;; <link rel="icon" type="image/png" href="/favicons/favicon-196x196.png" sizes="196x196" />
;; <link rel="icon" type="image/png" href="/favicons/favicon-96x96.png" sizes="96x96" />
;; <link rel="icon" type="image/png" href="/favicons/favicon-32x32.png" sizes="32x32" />
;; <link rel="icon" type="image/png" href="/favicons/favicon-16x16.png" sizes="16x16" />
;; <link rel="icon" type="image/png" href="/favicons/favicon-128x128.png" sizes="128x128" />
;; <meta name="application-name" content="&nbsp;"/>
;; <meta name="msapplication-TileColor" content="#FFFFFF" />
;; <meta name="msapplication-TileImage" content="/favicons/mstile-144x144.png" />
;; <meta name="msapplication-square70x70logo" content="/favicons/mstile-70x70.png" />
;; <meta name="msapplication-square150x150logo" content="/favicons/mstile-150x150.png" />
;; <meta name="msapplication-wide310x150logo" content="/favicons/mstile-310x150.png" />
;; <meta name="msapplication-square310x310logo" content="/favicons/mstile-310x310.png" />

;; Copyright (C) 2017 by Abhinav Tushar, abhinav.tushar.vs@gmail.com.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

(define (path-separator directory)
  "Guess system path separator like everyone else does.
Defaults to linux separator."
  (if (< (length (strbreakup directory "/"))
         (length (strbreakup directory "\\")))
      "\\" "/"))

(define (script-fu-export-favicons image export-dir)
  (gimp-image-undo-group-start image)
  (let* ((drawable (car (gimp-image-merge-visible-layers image 0)))
         (sep (path-separator export-dir))
         (outpngs '(("mstile-310x310.png"           . 310)
                    ("favicon-196x196.png"          . 196)
                    ("apple-touch-icon-152x152.png" . 152)
                    ("mstile-150x150.png"           . 150)
                    ("apple-touch-icon-144x144.png" . 144)
                    ("mstile-144x144.png"           . 144)
                    ("favicon-128x128.png"          . 128)
                    ("apple-touch-icon-120x120.png" . 120)
                    ("apple-touch-icon-114x114.png" . 114)
                    ("favicon-96x96.png"            . 96)
                    ("apple-touch-icon-76x76.png"   . 76)
                    ("apple-touch-icon-72x72.png"   . 72)
                    ("mstile-70x70.png"             . 70)
                    ("apple-touch-icon-60x60.png"   . 60)
                    ("apple-touch-icon-57x57.png"   . 57)
                    ("favicon-32x32.png"            . 32)
                    ("favicon-16x16.png"            . 16)))
         (width-original (car (gimp-image-width image)))
         (height-original (car (gimp-image-height image)))
         (dummy-layer (car (gimp-layer-new image width-original height-original RGBA-IMAGE "" 0.0 NORMAL-MODE)))
         (file-name "")
         (file-resolution 0))

    ;; Create backup of full size image
    (gimp-selection-all image)
    (gimp-edit-copy drawable)

    ;; Export pngs
    (while (not (null? outpngs))
      (set! file-resolution (cdr (car outpngs)))
      (set! file-name (string-append export-dir sep (car (car outpngs))))
      (gimp-image-scale image file-resolution file-resolution)
      (file-png-save-defaults RUN-NONINTERACTIVE
                              image
                              drawable
                              file-name
                              file-name)
      (set! outpngs (cdr outpngs)))

    ;; Export ico
    (set! file-resolution 16)
    (set! file-name (string-append export-dir sep "favicon.ico"))
    (gimp-image-scale image file-resolution file-resolution)
    (file-ico-save RUN-NONINTERACTIVE
                   image
                   drawable
                   file-name
                   file-name)

    ;; Export that weird asymmetric tile
    (gimp-image-resize image width-original height-original 0 0)
    (gimp-selection-all image)
    (gimp-edit-clear drawable)
    (gimp-image-insert-layer image dummy-layer 0 1)
    (set! drawable (car (gimp-image-merge-visible-layers image 0)))
    (gimp-edit-paste drawable 1)
    (set! drawable (car (gimp-image-merge-visible-layers image 0)))

    (set! file-name (string-append export-dir sep "mstile-310x150.png"))
    (gimp-image-scale image 310 310)
    (gimp-image-crop image 310 150 0 80)
    (file-png-save-defaults RUN-NONINTERACTIVE
                            image
                            drawable
                            file-name
                            file-name))
  (gimp-image-undo-group-end image))

(script-fu-register
 "script-fu-export-favicons"
 "Export Favicons"
 "Export the current image to all favicon sizes as provided by http://www.favicomatic.com/"
 "Abhinav Tushar"
 "copyright 2017, Abhinav Tushar"
 "May 19, 2017"
 ""

 SF-IMAGE      "Image"                                                   0
 SF-DIRNAME    "Export directory (files will be created directly in it)" "")

(script-fu-menu-register "script-fu-export-favicons" "<Image>/Automation")
