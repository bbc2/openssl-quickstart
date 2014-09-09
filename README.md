OpenSSL CA quickstart
=====================

To use this tool, clone this repository and perform the actions you need using
`make` and `openssl`.  The Makefile runs OpenSSL with local configuration files
(see `CA_CONF` and `CRT_CONF` variables in `Makefile`).  You can commit
generated files locally if you fear you might break the database.

This work has been dedicated to the public domain.  See `COPYING` for more
information.

Quickstart
----------

Execute:

    make clean
    make ca
    make example.crt

And you have a shiny new key pair `example.key` signed by your brand new CA.

CA
--

To generate a self-signed CA key pair, use:

    make ca

This will generate `ca/ca.key` and `ca/ca.crt` according to `CA_CONF`.  You can
also use your own CA files by giving them the forementioned names.

Key
---

A key can be generated with:

    make example.key

The algorithm defaults to RSA with 4096 bits (see `Makefile`).

Request
-------

To generate a certificate signing request for a key `example.key`, use:

    make example.csr

If the key does not exist, it will be generated.

Certificate
-----------

To generate a certificate for a request `example.csr`, use:

    make example.crt

This task expects `ca/ca.key` and `ca/ca.crt` to exist and uses `CRT_CONF`.  If
`example.csr` does not exist, it will be generated and subsequently removed.
If you just want to renew a certificate, make sure the key already exists so
that it is not generated on-the-fly.
