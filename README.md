Pants Build System `pants` shim
===============================


Install this shim script on your PATH, and will locate and run the closest `pants` script from your
`CWD` or in a parent directory.

This allows you to run `pants ...` from anywhere in your repo tree, rather than `./pants` only from
your the root of your repo.


Warning
=======

This is a proof of concept, and when used from anywhere else than the repo root, things may or may
not work as expected.
