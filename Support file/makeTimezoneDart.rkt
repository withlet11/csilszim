#lang racket

(define (split-values line)
  (let ([values (string-split line "\t")])
    (let ([country-codes (first values)]
          [coordinate (second values)]
          [tz-name (third values)])
      (string-append "TimeZone(countryCode: "
                     (split-country-code country-codes)
                     ", "
                     (split-coordinate coordinate)
                     ", name: '"
                     tz-name
                     "')"))))

(define (split-country-code codes)
  (string-join
   (map (lambda (x) (string-append "'" x "'"))
        (string-split codes ","))
   ", "
   #:before-first "["
   #:after-last "]"))

(define (split-coordinate coordinate)
  (let ([lat-and-long (cond [(= 15 (string-length coordinate))
                             (list (substring coordinate 0 7)
                                   (substring coordinate 7 15))]
                            [else (list (substring coordinate 0 5)
                                        (substring coordinate 5 11))])])
    (let ([lat-string (first lat-and-long)]
          [long-string (second lat-and-long)])
      (let ([lat (cond [(=  7 (string-length lat-string))
                        (make-DmsAngle (substring lat-string 0 1)
                                       (substring lat-string 1 3)
                                       (substring lat-string 3 5)
                                       (substring lat-string 5 7))]
                       [else (make-DmsAngle (substring lat-string 0 1)
                                            (substring lat-string 1 3)
                                            (substring lat-string 3 5)
                                            "00")])]
            [long (cond [(= 8 (string-length long-string))
                         (make-DmsAngle (substring long-string 0 1)
                                        (substring long-string 1 4)
                                        (substring long-string 4 6)
                                        (substring long-string 6 8))]
                        [else (make-DmsAngle (substring long-string 0 1)
                                             (substring long-string 1 4)
                                             (substring long-string 4 6)
                                             "00")])])
        (string-append "lat: "
                       (string-append lat)
                       ", long: "
                       (string-append long))))))

(define (make-DmsAngle neg deg min sec)
  (string-append "DmsAngle("
                 (if (string=? neg "-") "false" "true")
                 ", "
                 (if (= (string-length deg) 3)
                     (if (char=? (string-ref deg 0) #\0)
                         (if (char=? (string-ref deg 1) #\0)
                             (substring deg 2 3)
                             (substring deg 1 3))
                         deg)
                     (if (char=? (string-ref deg 0) #\0)
                         (substring deg 1 2)
                         deg))
                 ", "
                 (if (char=? (string-ref min 0) #\0) (substring min 1 2) min)
                 ", "
                 (if (char=? (string-ref sec 0) #\0) (substring sec 1 2) sec)
                 ")"))

(define tz-name-list
  (call-with-input-file
    "zone1970.tab"
    (lambda (in) (let iter ([list '()]
                            [line (read-line in)])
                   (cond [(eof-object? line) list]
                         [(or (zero? (string-length line))
                              (string=? "#" (substring line 0 1)))
                          (iter list (read-line in))]
                         [else (iter (cons (split-values line) list)
                                     (read-line in))])))))

(displayln "final cityList = [\n")
(displayln (string-join tz-name-list ",\n"))
(displayln "];\n")
