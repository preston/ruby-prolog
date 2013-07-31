ruby-prolog
====

ruby-prolog allows you to solve complex logic problems on the fly using a dynamic, Prolog-like DSL inline with your normal Ruby code. Basic use is encompassed by stating basic facts using your data, defining rules, and then asking questions. Why is this cool? Because ruby-prolog allows you to leave your normal object-oriented vortex on demand and step into the alternate reality of declarative languages.

With ruby-prolog:

* There are no classes.
* There are no functions.
* There are no variables.
* There are no control flow statements.

You *can* use all these wonder things -- it’s still Ruby after all -- but they’re not needed, and mainly useful for getting data and results into/out of the interpreter. Prolog still tends to be favored heavily in artificial intelligence and theorem proving applications and is still relevant to computer science curricula as well, so I hope this updated release proves useful for your logic evaluation needs!

ruby-prolog is written using object-oriented-ish pure Ruby, and should work under all most popular Ruby interpreters. Please report compatibility problems. The core engine is largely based on tiny_prolog, though numerous additional enhancements have been made such as object-oriented refactorings and integration of ideas from the interwebs. Unfortunately I cannot read Japanese and cannot give proper attribution to the original tiny_prolog author. (If *you* can, let me know and I'll update this document!)


Usage
----

    gem install ruby-prolog

Two runnable examples are included in the 'bin' directory. The first..

    ruby-prolog-acls

..shows the ruby-prolog dynamic DSL used to trivially implement access control checks. The second..


    ruby-prolog-hanoi

..is a ruby-prolog solution to the well-known "Towers of Hanoi" problem in computer science. It's not clear, but something Prolog hackers will be interested in. If you have other useful or clever examples, please send a pull request! See the test/ directory for additional examples.

Features
----

* Pure Ruby.
* No wacko dependencies.
* Tested with Ruby 2.0.0! 
* Object-oriented.
* Multiple Prolog environments can be created and manipulated simultaneously.
* Concurrent access to different core instances should be safe.
* Concurrent access to a single core instance might probably explode in odd ways.



License
----

Released under the Apache 2 license. Copyright (c) 2013 Preston Lee. All rights reserved. http://prestonlee.com
