OCurl
=====
OAuth2 curl script using Username/Password authentication flow.

Description
-----------
The script will connect to a given OAuth2 token endpoint and request an OAuth2 token, then use the retrieved token for curl requests.  The script will present you with a shell where you can type any curl commands, and they will be executed with the earlier requested OAuth2 token.

Arguments
---------
```
-c|--client: client_id (default $client_id)
-s|--secret: client_secret (default $client_secret)
-u|--user: username (default $username)
-p|--password: password (default $password)
-t|--tokenURL: token_url (default $token_url)
-k|--token: OAuth2 token to use (optional)
-f|--file: File to use for curl inputs
-q|--quit: Enter q to quit instead of blank line
-h|--help: Display this help message
```

Requrements
-----------
* Perl
* cpanm

Some Ubuntu installs may require the following packages:
zlib1g-dev
libxml2-dev

Install
-------
Run the install.pl script inside of the install/ directory.

