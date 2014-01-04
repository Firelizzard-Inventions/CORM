ORDA
====

The Objective Relational Database Abstraction (ORDA) is a collection of Objective-C frameworks that aims to be an implementation agnostic tool for accessing and manipulating SQL-based and SQL-like relational databases. There is a base framework, ORDA, and multiple 'driver' frameworks that link against implementation specific C libraries.

ORDA's paradigm is loosely based on that of [JDBC](http://docs.oracle.com/javase/7/docs/technotes/guides/jdbc/index.html) in that drivers must be registered before use, a driver is associated with a [URL/URI scheme](https://en.wikipedia.org/wiki/URI_scheme), and connections are made from a central class that determines the driver to delegate to based on the URL scheme. All drivers must conform to the protocols that make up the 'specification'.

Note: ORDA depends on [TypeExtensions](https://github.com/Lens-Flare/TypeExtensions).

ORDA.framework
--------------

The outward facing components of the ORDA framework include a number of protocols that specify the behavior of and relationship between components and a class, ORDA. The ORDA class is a singleton (accessed via `+[ORDA sharedInstance]`) that has two methods, one for registering new driver classes, and one for opening connections, or 'governors'. The other components of ORDA are partial implementations of protocols that provide a base to build drivers on top of.

### Specification

  * ORDAResult - the base protocol. Most return values in the framework conform to this protocol and errors are indicated by returning an instance of an error class that conforms to this protocol. Thus, if `-[ORDAResult isError]` returns true, it is not safe to assume the result object is what it would be upon success.
  * ORDADriver - the driver protocol. API consumers should not interact with this at all. Instances conforming to this protocol are hidden behind the ORDA class.
  * ORDAGovernor - the 'governor' or connection protocol. This protocol governs/manages an individual connection to a database. This is not called 'ORDAConnection' because some implementations, such as SQLite, do not use connections per se. This protocol could conceivably be implemented as a connection pool, but no such implementation currently exists.
  * ORDAStatement - the SQL statement protocol. Instances conforming to this protocol represent prepared SQL statements. 'Unprepared' statements may be achieved simply by not using binding parameters in the SQL.
  * ORDAStatementResult - the statement result protocol. Results from instances of ORDAStatement conform to this protocol. It is used to retreive statement result data.
  * ORDATable - the relational database table protocol. See Tables below.
  * ORDATableResult - the ORDATable result protocol. Serves a similar purpose in relation to ORDATable as ORDAStatementResult does to ORDAStatement.

### Tables

The goal of the table system is to provide an intuitive and uncomplicated API that allows for easy manipulation of tables while returning results are bindable to other model elements and remain in sync with the database. The table result protocol does not have the `changed` or `lastID` fields that `ORDAStatementResult` has. The result of an insert statement contains the last inserted row; the result of an update statement contains the updated rows. A select statement contains the selected rows, of course. However, unlike `ORDAStatementResult`, table results are not indexable as a dictionary of arrays, only as an array of 'dictionaries'. The 'dictionaries' are actually custom implementations that are synchronized with the database. Each entry: listens to its own properties with [KVO](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueObserving/) and updates the database whenever one of its properties changes, listenes for updates on the database (driver specific implementation) and updates its properties whenever the corresponding row and column are updated, and maintains a dictionary of locks to prevent the two aforementioned processes from triggering each other. The other important feature of tables is that A) each one maintains a dictionary of these entries such that there is only ever one entry per row per table and B) this dictionary is an instance of [NSMutableDictionary_NonRetaining_Zeroing](https://github.com/Lens-Flare/TypeExtensions/blob/master/TypeExtensions/Collection%20Extensions/NSMutableDictionary_NonRetaining_Zeroing.h), meaning that any entries that have no other references are safely deallocated and removed from the table's dictionary.

Driver Frameworks
-----------------

All driver frameworks in this repository register themselves in `+[NSObject initialize]`, however, as the driver classes should not be exposed, that method call cannot be directly triggered. Thus, all driver frameworks should expose a class with a (class) method, such as `+[ORDASQLite register]` that contains a call such as `[ORDASQLiteDriver class]` or `[[ORDA sharedInstance] registerDriver:someDriverInstance]`. As well, it is good practice to expose a `+ (NSString *)scheme` method in the same class that returns the URL scheme the driver manages.

### Existing drivers

  * ORDASQLite.framework - links against libsqlite3 (included in this project).

### In progress

  * ORDAMySQL.framework - links against libmysqlclient (included in this project).

### Building

The two existing drivers are built within the same project as ORDA.framework and thus have access to the header files of the protocols' partial implementations.

Linking
-------

Projects built against this system must include TypeExtensions.framework, ORDA.framework, the needed driver frameworks, and the libraries the latter link against.
