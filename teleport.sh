#!/usr/bin/guile \
-e main -s
!#
(use-modules (ice-9 match) (dbi dbi))

(read-enable 'hungry-eol-escapes)

(define (show-not-found target)
  (display
    (string-append "With searching comes loss
  and the presence of absence:
    \"" target "\" not found.")
    (current-error-port)))

(define db
  (let ((xdg (getenv "XDG_CONFIG_HOME"))
        (sub "sqlite3"))
    (if xdg
      (dbi-open sub (string-append xdg "/tp/db"))
      (dbi-open sub (string-append (getenv "HOME") "/.tp/db")))))

(define (init-db)
  (dbi-query db "create table locations(mnemo varchar(64), target varchar(255), primary key(mnemo))"))

(define (insert! mnemo target)
  (let ((q (string-append "insert or replace into locations values ('" mnemo "', '" target "')")))
    (dbi-query db q)))

(define (query mnemo)
  (let ((q (string-append "select target from locations where mnemo = '" mnemo "'")))
    (dbi-query db q)
    (match (dbi-get_row db)
      (#f (show-not-found mnemo) #f)
      (((_ . target)) target))))

(define (find prefix)
  (define (f)
    (let ((r (dbi-get_row db)))
      (when r
        (display (cdr (car r)) (current-error-port))
        (newline (current-error-port))
        (f))))
  (let ((q (string-append "select mnemo from locations where mnemo like('" prefix "%')")))
    (dbi-query db q)
    (f)))

(define (teleport target)
  (if target
    (display (string-append "cd " target))
    (display "false")))

(define (help)
  (display "usage: tp {--init | --list mnemo-prefix | --add mnemo | mnemo}\n" (current-error-port)))

(define (main args)
  (match args
    ((_) (help))
    ((_ "--init") (init-db))
    ((or (_ "-l" . prefix) (_ "--list" . prefix))
      (find (string-join prefix)))
    ((or (_ "-a" . mnemo) (_ "--add" . mnemo))
      (insert! (string-join mnemo) (getcwd)))
    ((_ . mnemo)
      (teleport (query (string-join mnemo))))
    (else (help))))
