ruby-prolog
====

An object-oriented pure Ruby implementation of a Prolog-like DSL for easy AI and logical programming. It should work under all popular Ruby interpreters. Please report compatibility problems.

The core engine is largely based on tiny_prolog, though numerous additional enhancements have been made
such as object-oriented refactorings and integration of ideas from the interwebs. Unfortunately I cannot
read Japanese and cannot give proper attribution to the original tiny_prolog author. (If *you* can, let
me know and I'll update this document!)


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
