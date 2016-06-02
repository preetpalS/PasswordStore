# Password Store

Designed to help you keep track of your passwords (hashes only).
Although this application cannot give you your password back directly,
it will store the hash of your password so that you can keep on guessing
till you get it (which you cannot typically do on a server (due to the
fact that you will become locked out after a limited number of attempts)).
Each stored password hash is generated using bcrypt (with a configurable
cost factor which has a default of 20). Password hashes are stored with
both the cost factor and the random salt used in the hashing process.

Passwords are stored in a SQLite3 database (temporal schema; see src/res/schema.sql).
This application was built primarily for learning purposes. Require Ruby version 2.1
or greater (primarily because of the use of required keyword arguments).
