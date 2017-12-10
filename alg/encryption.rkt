#lang racket

(provide (all-defined-out))
(require "../common.rkt")
(require "waterfall.rkt")


(define (encrypt-file in-fname password)
  ; Takes a file as input and prints the encrypted version of the file to a
  ; .locknut file. Get string from source file, add password to front. Remove
  ; .txt and add .locknut extension

  ; @in-fname   string
  ; @password   string
  ; @return     none

  (let ((plain-text
          (string-append password (file->listChars in-fname)))
        (out-fname
          (swap-extension in-fname ".txt" ".locknut")))

    ;Remove the older version of the output file if necessary
    (when (file-exists? out-fname)
      (delete-file out-fname))

    ;Encrypt and print
    (print-this
      (waterfall
        plain-text
        (list->string (map integer->char  key-list))
        #t)
      out-fname)

    (delete-file in-fname)))


(define (decrypt-file in-fname password callback)
  ; Takes an encrypted .locknut file as input and prints the decrypted version
  ; of the file to a text file.  If glancing, open the file in notepad and
  ; delete when the user is finished.  Otherwise, rename the decrypted text
  ; file to the original name of the input

  ; @in-fname   string
  ; @password   string
  ; @callback   function (string, string, string) -> none
  ; @return     none

  (let ((chars-list
          (string->list (file->listChars in-fname)))

        (out-fname
          (swap-extension in-fname ".locknut" ".txt")))

    ;Remove the older version of output file, if necessary
    (when (file-exists? out-fname)
      (delete-file out-fname))

    ;Decrypt the file with the given buffered password
    (let ((decrypted-file
            (waterfall
              (list->string chars-list)
              (list->string (map integer->char key-list))
              #f)) )

      ;Verify password against buffered password, and decrypt
      (if (equal? (substring decrypted-file 0 50) password)

        (callback decrypted-file in-fname out-fname)

        ;Invalid password
        #f)) ))
