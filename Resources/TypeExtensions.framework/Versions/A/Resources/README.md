TypeExtensions
==============

Various Objective-C extensions to existing types

### Categories

  * Collection - extensions to collection classes (arrays, dictionaries)
  * Design Pattern - extensions for design patterns not present in vanilla Objective-C (abstract classses, singleton)
  * Protocol - various extensions relating to protocols
  * String - various extensions relating to string objects
  * Notification - various extensions relating to the notification system
  * Null - extensions involving testing for nil, handing nil method arguments, and returning nil instead of throwing a range exception
  * KVC - various extensions relating to key value coding
  * Value - extensions for converting one type to another, related type - substitutes for `+[NSSomeClass someObjectWithSomeOtherObject:]`
  * Other/Misc - uncategorized extensions

### Voodoo Warning

`NSObject (DeallocListener)` and `NSObject (zeroingWeakReferenceProxy)` contain some serious runtime voodoo.
