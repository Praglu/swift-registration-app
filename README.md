# Swift app for creating and storing users in a SQLite database - login and registration processes included!
This is a small Swift application which was written for a collage project. The functionality is about registration new users' accounts and storing them in a SQLite base.

## Feel free to use!
App contains 2 views:
* Main View with login form:
    + Checks if provided *username* and *password* parameters are stored in the database.
    + If true: gives an information about successful login.
    + Else: gives an information about bad credentials. 
There is also a button for deleting data from user's table.

* Registration View:
    + Checks whether provided e-mail contains a format of an e-mail.
    + Checks if password is not none.
    + Checks if both provided passwords are the same.
    + Checks whether provided e-mail already exists in the database.

The *DatabaseManager* creates and manages a database. **Singleton** used so the database is used globally and not sperately on both views.
For every DatabaseManager method result there are information printed. It is easy to track where something broke down.
There are also information printed in Views while calling those methods, so you can track whether something crashed in database or in view.

## Warning!
Solution used for creating and managing this database is **full of vulnerabilities**! E.g. since login process takes both paramteres (*username* and *password*) and puts them into a string SQL Query, it can be bypassed easily with a simple SQLInjection.
**For your and users' safety DO NOT use this solution in a commercial purpose!**

### Most of the popup messages and texts are written in polish but all of the prints are written in english, so feel free to change them. Hope you gonna figure out what information should be placed where.
