CORM
====

(Objective) C Object-Relational Mapping

CORM is pre-alpha.

CORM is a framework that connects to a SQLite database and enables the developer to retreive database rows as Objective-C objects. Referenced and referencing rows are automatically and seamlessly loaded from the database as they are neaded. If a class is not defined for a table, CORM can be configured to automatically generate a class definition, at run-time, for that table.

CORM uses [CocoaSQLite](https://github.com/Firelizzard-Inventions/CocoaSQLite) as it's database library. CocoaSQLite is built off of the [ORDA](https://github.com/Firelizzard-Inventions/ORDA) framework project. Because of CORM's dependance on ORDA, changes to CORM objects or to the underlying database are automatically and immediately reflected in the other.

CORM can use [CocoaMySQL](https://github.com/Firelizzard-Inventions/CocoaMySQL), but not all features are available. While changes to CORM objects will be reflected in a MySQL database, the reverse is not currently true.
