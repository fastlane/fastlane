This version has a required fix for authenticating with Apple via Apple ID. Apple started using their own variant of SRP (Secure Remote Password) using SHA-256 and 2048 bit hashing in the sign in flow. Any previous _fastlane_ versions will likely response a "503 Service Temporarily Unavailable" when authenicating with an Apple ID.

* [spaceship] New AppleID Auth with SRP (#26415) via Josh Holtz (@snatchev and @joshdholtz)
