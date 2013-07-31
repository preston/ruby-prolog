ruby_prolog
====

The core engine is largely based on tiny_prolog, though numerous additional enhancements have been made
such as object-oriented refactorings and integration of ideas from the interwebs. Unfortunately I cannot
read Japanese and cannot give proper attribution to the original tiny_prolog author. If *you* can, let
me know and I'll update this document!

Description
----
An object-oriented pure Ruby implementation of a Prolog-like DSL for easy AI and logical programming. It should work under all popular Ruby interpreters. Please report compatibility problems.

Features
----

* Pure Ruby.
* Tested with Ruby 2.0.0! 
* Object-oriented.
* Multiple Prolog environments can be created and manipulated simultaneously.
* Concurrent access to different core instances should be safe.
* Concurrent access to a single core instance might probably explode in odd ways.


Installation
----

    gem install ruby_prolog

See ruby_prolog_spec.rb for usage examples. 


License
----

Released under the Apache 2 license.

Copyright (c) 2013 Preston Lee. All rights reserved. http://prestonlee.com
