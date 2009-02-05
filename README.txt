ruby_prolog
    by Preston Lee
    http://openrain.com
	The core engine is largely based on tiny_prolog, though numerous additional enhancements have been made
	such as object-oriented refactorings and integration of ideas from the interwebs. Unfortunately I cannot
	read Japanese and cannot give proper attribution to the original tiny_prolog author. If *you* can, let
	me know and I'll update this document!

== DESCRIPTION:

	An object-oriented pure Ruby implementation of a Prolog-like DSL for easy AI and logical programming.

== FEATURES/PROBLEMS:

* Pure Ruby.
* Tested with Ruby 1.8.7 (MRI). 
* Object-oriented.
* Multiple Prolog environments can be created and manipulated simultaneously.
* Concurrent access to different core instances should be safe.
* Concurrent access to a single core instance might probably explode in odd ways.

== SYNOPSIS:

  See ruby_prolog_spec.rb for usage examples.

== REQUIREMENTS:

* Should work under all popular Ruby interpreters. Please report compatibility problems.

== INSTALL:

* sudo gem install ruby_prolog

== LICENSE:

(The MIT License)

Copyright (c) 2008 OpenRain, LLC

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
