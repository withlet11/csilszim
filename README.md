# Csilszim

An astronomical simulator (hu: Csillagászati szimulátor) project.

---

## Contents

### Clocks
* UTC
* Local Time
* Local Mean Time
* Sidereal Time

### Momentary sky view

### Orbits of Planets
* Planets  
  Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune 
* Dwarf planets  
  Ceres, Pluto, Haumea, Makemake, Eris

### Whole night sky view
* Civil, nautical and astronomical twilight
* Planets
* Messier objects

---

## References

### [Multi-Language VSOP87 Source Code Generator Tool](https://neoprogrammics.com/vsop87/source_code_generator_tool/)
https://neoprogrammics.com/vsop87/source_code_generator_tool/

For Calculating the positions of planets.

### [Planetary Fact Sheets](https://nssdc.gsfc.nasa.gov/planetary/planetfact.html)
https://nssdc.gsfc.nasa.gov/planetary/planetfact.html

#### Saturn Fact Sheet

##### North Pole of Rotation

Right Ascension: 40.589 - 0.036T  
Declination    : 83.537 - 0.004T
Reference Date : 12:00 UT 1 Jan 2000 (JD 2451545.0)  
T = Julian centuries from reference date 

### [N. Capitaine, P. T. Wallace, and J. Chapront. _Expressions for IAU 2000 precession quantities_, Astromy & Astrophysics 412, 567–586 (2003)](https://www.aanda.org/articles/aa/pdf/2003/48/aa4068.pdf)

#### obliquity of the equator on the moving ecliptic
equation 13.  
ε0 = 8438100″.448

equation 14.  
εA = ε0 − 4600″.84024 t − 000″.00059 t^2 + 000″.001813 t^3

### Dálya, Gergely (2021). _Bevezetés a Csillagászatba: Az Atommagoktól a Galaxis-szuperhalmazokig_, OOK-Press Kft. ISBN 978-963-8361-58-5

#### Calculates hour angle from declination and latitude
Equation 4.26  
sin _h_ = sin _φ_ sin _δ_ + cos _φ_ cos _δ_ cos _t_

### [IAU Office of Astronomy for Education](https://www.astro4edu.org/)

#### [GLOSSARY TERM: AZIMUTH](https://www.astro4edu.org/resources/glossary/term/36/)

Description: In a horizontal coordinate system, azimuth refers to the direction
(along the horizon) at which the object is found. It is measured in degrees
starting from the north and towards the east. Azimuth values cover a full circle
from 0 deg. to 360 deg. In other words, if you draw an imaginary arc on the
celestial sphere from the object to the horizon and perpendicular to the horizon,
the azimuth will tell you the location of the point where this arc meets the
horizon. <ins>An object located directly north would have 0 deg</ins>. azimuth, an object
directly east would have 90 deg. azimuth and so on. <ins>In older textbooks used in
multiple countries, the convention was to start measuring the azimuth from the
south towards the west.</ins> Thus, azimuth values in those textbooks would be shifted
by 180 deg.

---

## Terminology

| English                         | Hungarian                        | Japanese |
|---------------------------------|----------------------------------|----------|
| argument of periapsis           | pericentrum argumentuma          | 近点引数　    |
| apoapsis                        | xxxx                             | 遠点距離     |
| azimuth                         | azimut                           | 方位       |
| Coordinated Universal Time      | Egyezményes koordinált világidő  | 世界協定時    |
| constellation                   | csillagkép                       | 星座       |
| declination                     | deklinácio                       | 赤緯       | 
| eccentric anomaly               | excentikus anomália              | 離心近点角　   |
| eccentricity                    | excentricitás                    | 離心率　     |
| ecliptic coordinate system      | ekliptikai koordináta-rendszer   | 黄道座標系　   |
| equatorial coordinate system    | ekvatoriális koordináta-rendszer | 赤道座標系　   |
| epoch                           | epocha                           | 元期       |
| height                          | magasság                         | 高度       |
| horizontal coordinate system    | horizontális koordináta-rendszer | 地平座標系　   |
| inclination                     | inklináció                       | 起動傾斜角    |
| Julian days                     | Julián dátum                     | ユリウス通日   |
| hour angle                      | óraszög                          | 時角       |
| longitude of the ascending node | felszálló csomó hossza           | 昇交点黄経　   |
| longitude of perihelion         | xxxxxxxxx                        | 近日点黄経　   |
| Mean anomaly                    | középanomália                    | 平均近点角　   |
| Mean motion                     | középmozgás                      | 平均運動　    |
| meridian                        | meridián                         | 子午線　     |
| nadir                           | nadír                            | 天底       |
| obliquely                       | ferdeség                         | 傾斜 　     |
| orbital elements                | Pályaelemek                      | 軌道要素　    |
| periapsis                       | xxxx                             | 近点距離     |
| right ascension                 | rektaszcenzió                    | 赤経       |
| semi-major axis                 | fél nagytengely                  | 軌道長半径    |
| sidereal time                   | csillagidő                       | 恒星時      |
| terrestrial time                | xxxxxx                           | 地球時      |
| terrestrial dynamical time      | xxxxxx                           | 地球力学時    |
| Time of periapsis               | pericentrumátmenet időpontja     | xxxxxx   |
| true anomaly                    | valódi anomália                  | 真近点角　    |
| zenith                          | zenit                            | 天頂       |

