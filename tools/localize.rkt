#lang racket

;; ============================================================
;; Constants
;; ============================================================

(define description-attr "description")
(define placeholders-attr "placeholders")
(define type-attr "type")
(define format-attr "format")


;; ============================================================
;; Data
;; ============================================================
;; Instructions:
;; - The default language is "en". Specify other languages using
;;   codes such as "ja-rJP".
;; - Use "*" to mark strings that should not be translated.
;;   These strings are included only in the default file and are
;;   marked with translatable="false".
;; - Specify the output directories for localized files in
;;   `lang-list`.
;; - Specify the strings in `value-list`.
;; - Specify additional attributes after the string.

(define lang-list '((en "../lib/l10n/app_en.arb")
                    (ja "../lib/l10n/app_ja.arb")
                    (hu "../lib/l10n/app_hu.arb")
                    ;; (fr-rFR "../lib/l10n/app_fr.arb")
                    ;; (zh-rCN "../lib/l10n/app_zh.arb")
                    ))


(define value-list
  `(("dec"
     ((en "δ")
      (ja "δ")
      (hu "δ")))
    ("ra"
     ((en "α")
      (ja "α")
      (hu "α")))
    ("hourAngle"
     ((en "Hour Angle")
      (ja "時角")
      (hu "Óraszög")))
    ("ha"
     ((en "HA")
      (ja "HA")
      (hu "t")))
    ("latitude"
     ((en "Latitude")
      (ja "緯度")
      (hu "Szélesség")))
    ("longitude"
     ((en "Longitude")
      (ja "経度")
      (hu "Hosszúság")))
    ("northSign"
     ((en "N")
      (ja "北")
      (hu "É")))
    ("northEastSign"
     ((en "NE")
      (ja "北東")
      (hu "ÉK")))
    ("eastSign"
     ((en "E")
      (ja "東")
      (hu "K")))
    ("southEastSign"
     ((en "SE")
      (ja "南東")
      (hu "DK")))
    ("southSign"
     ((en "S")
      (ja "南")
      (hu "D")))
    ("southWestSign"
     ((en "SW")
      (ja "南西")
      (hu "DNy")))
    ("westSign"
     ((en "W")
      (ja "西")
      (hu "Ny")))
    ("northWestSign"
     ((en "NW")
      (ja "北西")
      (hu "ÉNy")))
    ("azimuth"
     ((en "Azimuth")
      (ja "方位")
      (hu "Azimut")))
    ("az"
     ((en "A")
      (ja "A")
      (hu "A")))
    ("altitude"
     ((en "Altitude")
      (ja "高度")
      (hu "Magasság")))
    ("alt"
     ((en "h")
      (ja "h")
      (hu "m")))
    ("auto"
     ((en "Auto")
      (ja "自動")
      (hu "Auto")))
    ("azimuthalGrid"
     ((en "Horizontal coordinate grid")
      (ja "方位角・高度")
      (hu "Azimutháló")))
    ("brightestStars"
     ((en "Brightest stars")
      (ja "明るい恒星")
      (hu "Legfényesebb csillagok")))
    ("clock"
     ((en "Clock")
      (ja "時計")
      (hu "Óra")))
    ("comets"
     ((en "Comets")
      (ja "彗星")
      (hu "Üstökösök")))
    ("constellationLabels"
     ((en "Constellation name")
      (ja "星座名")
      (hu "Csillagkép feliratok")))
    ("constellationLines"
     ((en "Constellation line")
      (ja "星座線")
      (hu "Csillagkép vonalak")))
    ("dwarfPlanets"
     ((en "Dwarf Planets")
      (ja "準惑星")
      (hu "Törpebolygók")))
    ("equatorialGrid"
     ((en "Equatorial coordinate grid")
      (ja "赤経・赤緯")
      (hu "Egyenlítői háló")))
    ("fov"
     ((en "Field of view")
      (ja "視野")
      (hu "Látómező")))
    ("hash"
     ((en "#")
      (ja "#")
      (hu "#")))
    ("interval"
     ((en "Interval: ")
      (ja "間隔: ")
      (hu "Időköz: ")))
    ("locationSetting"
     ((en "Location Setting")
      (ja "観測地設定")
      (hu "Hely beállítása")))
    ("mapOrientation"
     ((en "Map Orientation")
      (ja "星図の向き")
      (hu "Térkép Tájolás")))
    ("meanSolarTime"
     ((en "Mean Solar Time")
      (ja "平均太陽時")
      (hu "Középszoláris idő")))
    ("messierNumber"
     ((en "number")
      (ja "番号")
      (hu "Szám")))
    ("messierObjects"
     ((en "Messier objects")
      (ja "メシエ天体")
      (hu "Messier objektumok")))
    ("momentarySkyView"
     ((en "Momentary sky view")
      (ja "ある時点の夜空")
      (hu "Átmeneti égbolt")))
    ("northUp"
     ((en "North up")
      (ja "北が上")
      (hu "Észak fent")))
    ("objectList"
     ((en "Object list")
      (ja "天体リスト")
      (hu "Objekt lista")))
    ("orbit"
     ((en "Orbit")
      (ja "軌道")
      (hu "Pálya")))
    ("planets"
     ((en "Planets")
      (ja "惑星")
      (hu "Bolygók")))
    ("properName"
     ((en "Proper name")
      (ja "名称")
      (hu "Név")))
    ("repetition"
     ((en "Repetition: ")
      (ja "回数: ")
      (hu "Ismétlés: ")))
    ("shortIntroduction"
     ((en "An astronomical simulator")
      (ja "天文シミュレーター")
      (hu "Csillagászati szimulátor")))
    ("siderealTime"
     ((en "Sidereal Time")
      (ja "恒星時")
      (hu "Csillagidő")))
    ("southUp"
     ((en "South up")
      (ja "南が上")
      (hu "Dél fent")))
    ("standardTime"
     ((en "Standard Time")
      (ja "標準時")
      (hu "Zónaidő")))
    ("trueFov"
     ((en "True field fo view")
      (ja "実視界")
      (hu "Valódi látómező")))
    ("timeOffset"
     ((en "Offset")
      (ja "オフセット")
      (hu "Időeltolódás")))
    ("timeZone"
     ((en "Time zone")
      (ja "タイムゾーン")
      (hu "Időzóna")))
    ("type"
     ((en "Type")
      (ja "種別")
      (hu "Típus")))
    ("tzArea"
     ((en "Area")
      (ja "地域")
      (hu "Terület")))
    ("useLocationTimeZone"
     ((en "Use 'Location' time zone")
      (ja "「地名」のタイムゾーンを使う")
      (hu "Használ a „Hely” időzónát")))
    ("useLocationCoordinates"
     ((en "Use 'Location' coordinates")
      (ja "「地名」の経緯度を使う")
      (hu "Használ a „Hely” koordinátákat")))
    ("tzLocation"
     ((en "Location")
      (ja "地名")
      (hu "Hely")))
    ("universalTime"
     ((en "Universal Time")
      (ja "世界時")
      (hu "Világidő")))
    ("utcOffset"
     ((en "UTC Offset")
      (ja "UTCとの差")
      (hu "Időeltolódás az UTC-től")))
    ("wholeNightSkyView"
     ((en "Whole night sky view")
      (ja "一晩の夜空")
      (hu "Egész ejszakai égbolt")))
    ("sun"
     ((en "Sun")
      (ja "太陽")
      (hu "Nap")))
    ("moon"
     ((en "Moon")
      (ja "月")
      (hu "Hold")))
    ("mercury"
     ((en "Mercury")
      (ja "水星")
      (hu "Mercúr")))
    ("venus"
     ((en "Venus")
      (ja "金星")
      (hu "Vénusz")))
    ("earth"
     ((en "Earth")
      (ja "地球")
      (hu "Föld")))
    ("mars"
     ((en "Mars")
      (ja "火星")
      (hu "Mars")))
    ("jupiter"
     ((en "Jupiter")
      (ja "木星")
      (hu "Jupiter")))
    ("saturn"
     ((en "Saturn")
      (ja "土星")
      (hu "Saturnusz")))
    ("uranus"
     ((en "Uranus")
      (ja "天王星")
      (hu "Uránusz")))
    ("neptune"
     ((en "Neptune")
      (ja "海王星")
      (hu "Neptunusz")))
    ("ceres"
     ((en "Ceres")
      (ja "セレス")
      (hu "Ceres")))
    ("pluto"
     ((en "Pluto")
      (ja "冥王星")
      (hu "Pluto")))
    ("eris"
     ((en "Eris")
      (ja "エリス")
      (hu "Eris")))
    ("haumea"
     ((en "Haumea")
      (ja "ハウメア")
      (hu "Haumea")))
    ("makemake"
     ((en "Makemake")
      (ja "マケマケ")
      (hu "Makemake")))
    ("halley"
     ((en "1P/Halley")
      (ja "ハレー彗星")
      (hu "Halley-üstökös")))
    ("encke"
     ((en "2P/Encke")
      (ja "エンケ彗星")
      (hu "Encke-üstökös")))
    ("biela"
     ((en "3P/Biela")
      (ja "ビエラ彗星")
      (hu "Biela-üstökös")))
    ("faye"
     ((en "4P/Faye")
      (ja "フェイ彗星")
      (hu "Faye-üstökös")))
    ("brorsen"
     ((en "5P/Brorsen")
      (ja "ブローセン彗星")
      (hu "Brorsen-üstökös")))
    ("dArrest"
     ((en "6P/d'Arrest")
      (ja "ダレスト彗星")
      (hu "d'Arrest-üstökös")))
    ("ponsWinnecke"
     ((en "7P/Pons-Winneckel")
      (ja "ポンス・ヴィネッケ彗星")
      (hu "Pons-Winneckel-üstökös")))
    ("tuttle"
     ((en "8P/Tuttle")
      (ja "タットル彗星")
      (hu "Tuttle-üstökös")))
    ("tempel1"
     ((en "9P/Tempel 1")
      (ja "テンペル第1彗星")
      (hu "Tempel 1 üstökös")))
    ("tempel2"
     ((en "10P/Tempel 2")
      (ja "テンペル第2彗星")
      (hu "Tempel 2 üstökös")))
    ("startUTC"
     ((en "Start (UTC): {date}"
          (,description-attr "A message with a date parameter")
          (,placeholders-attr ("date"
                               (,type-attr "DateTime")
                               (,format-attr "yMd"))))
      (ja "開始日 (UTC): {date}")
      (hu "Kezdő (UTC): {date}")))
    ("nDays"
     ((en "{count, plural, =0{0 days} =1{1 day} other{{count} days}}"
          (,description-attr "A plural message")
          (,placeholders-attr ("count"
                               (,type-attr "num")
                               (,format-attr "compact"))))
      (ja "{count, plural, other{{count}日}}")
      (hu "{count, plural, other{{count} nap}}")))
    ("nYears"
     ((en "{count, plural, =0{0 years} =1{1 year} other{{count} years}}"
          (,description-attr "A plural message")
          (,placeholders-attr ("count"
                               (,type-attr "num")
                               (,format-attr "compact"))))
      (ja "{count, plural, other{{count}年}}")
      (hu "{count, plural, other{{count} év}}")))


    ))


;; ============================================================
;; Processing
;; ============================================================
;; Usage:
;;   racket localize.rkt
;;
;; Run from the directory containing this file.
;;
;; Revision history:
;; - 2026-10-19: Initial version.

(define (create-xml-doc lst lang)
  `("{"
    ,(string-append "  \"@@locale\": \"" (symbol->string lang) "\",")
    ,@(flatten (entry->string (get-entries-with-lang lst lang) 1))
    "}"))

(define (get-entries-with-lang lst lang)
  (filter
   list?
   (map (lambda (entry)
          (let ([key (first entry)] [vals (second entry)])
            (cond [(assq lang vals)
                   => (lambda (val) (cons key (cdr val)))]
                  [else (error "missing localized strings" lang entry)])))
        lst)))

(define (entry->string entries idx)
  (add-delimiter-between
   (map (lambda (x)
          (let ([key (car x)] [content (cadr x)] [attrs (cddr x)])
            (if (null? attrs)
                (string-append (make-string (* 2 idx) #\space) "\""
                               key "\": \"" content "\"")
                `(,(string-append (make-string (* 2 idx) #\space)
                                  "\"" key "\": \"" content "\",")
                  ,(string-append (make-string (* 2 idx) #\space)
                                  "\"@" key "\": {")
                  ,(values->string attrs (add1 idx))
                  ,(string-append (make-string (* 2 idx) #\space)
                                  "}")))))
        entries)))

(define (values->string entries idx)
  (add-delimiter-between
   (map (lambda (x)
          (let ([key (car x)] [val (cdr x)])
            (cond [(list? (car val))
                   `(,(string-append (make-string (* 2 idx) #\space)
                                     "\"" key "\": {")
                     ,(values->string val (add1 idx))
                     ,(string-append (make-string (* 2 idx) #\space)
                                     "}"))]
                  [(string? (car val))
                   (string-append (make-string (* 2 idx) #\space)
                                  "\"" key "\": \"" (car val) "\"")]
                  [else (error "malform" x)])))
        entries)))

(define (add-delimiter-between lst)
  (foldr (lambda (x acc)
           (if (null? acc)
               (list x)
               (cons (add-delimiter-at-end x) acc)))
         '()
         lst))

(define (add-delimiter-at-end x)
  (if (string? x)
      (string-append x ",")
      (let ([r (reverse x)])
        (reverse (cons (add-delimiter-at-end (car r)) (cdr r))))))

(for-each (lambda (x)
            (let ([lang (first x)]
                  [path (second x)])
              (call-with-output-file (string->path path)
                (lambda (out)
                  (for-each (lambda (ln) (displayln ln out))
                            (create-xml-doc value-list lang)))
                #:exists 'replace)))
          lang-list)

(displayln "Completed!")
