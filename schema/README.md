This directory contains XML schemas which is not part of NXML distribution.

How to convert XSD into RNC
---------------------------

To add XML schema in .xsd format, you need to use two tools; `rngconv`
and `trang`.

If you cannot find rngconv, here is a working link:

        http://java.net/downloads/msv/nightly/rngconv.20060319.zip

With `rngconv`, you can convert `.xsd` into `.rng`:

        $ rngconv sample.xsd > sample.rng

(You may want to use http://debeissat.nicolas.free.fr/XSDtoRNG.php
instead `rngconv`.)

With `trang`, you can convert `.rng` into `.rnc`:

        $ trang sample.rng sample.rnc

Place the `.rnc` file into `$HOME/.emacs.d/schema/` and add the entry
in `$HOME/.emacs.d/schema/schemas.xml`:

