FAQs
=====

### I'm getting an SSL error

If your output contains something like

```
SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed
```

that usually means you are using an outdated version of OpenSSL. Make sure to install the latest one using [homebrew](http://brew.sh/).

```
brew update && brew upgrade openssl
```
