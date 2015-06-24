v0.0.12 - 2015-06-24
---

* Force client to connect with TLSv1.2 instead of attempting SSLv2, SSLv3 which resulted in intermittent HTTPS errors.
* `Certificate.create!` now accepts a CSR as a `String` when read from a file or `OpenSSL::X509::Request` when generated via `OpenSSL`
