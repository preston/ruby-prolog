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

Say you want to write the following Prolog code:

```
implication(a, b).
implication(b, c).
implication(c, d).
implication(c, x).

implies(A, B) :- implication(A, B).
implies(A, B) :- implication(A, Something), implies(Something, B).
```

Here's the equivalent Ruby code using this library:

```rb
db = RubyProlog.new do
  implication['a', 'b'].fact
  implication['b', 'c'].fact
  implication['c', 'd'].fact
  implication['c', 'x'].fact

  implies[:A, :B] << implication[:A, :B]
  implies[:A, :B] << [
    implication[:A, :Something],
    implies[:Something, :B]
  ]
end
```

Now you can run some queries:

```rb
# What are all the direct implications of 'c'?
db.query{ implication['c', :X] }
#=> [{ X: 'd' }, { X: 'x' }]

# What are all the things that can directly imply?
db.query{ implication[:X, :_] }
#=> [{ X: 'a' }, { X: 'b' }, { X: 'c' }, { X: 'c' }]

# What are all the things 'a' implies?
db.query{ implies['a', :X] }
#=> [{ X: 'b' }, { X: 'c' }, { X: 'd' }, { X: 'x' }]
```

Unfortunately if you have **two** predicates in a query, you can't just use a comma. There two ways to solve this problem:

```rb
# Solution 1: Use an array
db.query{[ implication['b', :S], implies[:S, :B] ]}

# Solution 2: Use a beneign assignment
db.query{_= implication['b', :S], implies[:S, :B] }
```

If you need to add to your database, you can call `instance_eval`:

```rb
db = RubyProlog.new do
  implication['a', 'b'].fact
  implication['b', 'c'].fact
end

# Later...
db.instance_eval do
  implication['c', 'd'].fact
  implication['c', 'x'].fact
end
```

This will mutate your database. If you want to "fork" your database instead, you can call `db.clone`, which will return a new instance with all stored data. Cloning like this is optimized to copy as little as possible.

Examples
----

    gem install ruby-prolog

Two runnable examples are included in the 'bin' directory. The first..

    ruby-prolog-acls

..shows the ruby-prolog dynamic DSL used to trivially implement access control checks. The second..


    ruby-prolog-hanoi

..is a ruby-prolog solution to the well-known "Towers of Hanoi" problem in computer science. It's not clear, but something Prolog hackers will be interested in. If you have other useful or clever examples, please send a pull request!

See the test/ directory for additional examples.

Features
----

* Pure Ruby.
* No wacko dependencies.
* Tested with Ruby 2.0.0!
* Object-oriented.
* Multiple Prolog environments can be created and manipulated simultaneously.
* Concurrent access to different core instances should be safe.
* Concurrent access to a single core instance might probably explode in odd ways.

Development
----

```
$ git clone https://github.com/preston/ruby-prolog
$ cd ruby-prolog
$ bundle
$ rake test
```

License
----

Released under the Apache 2 license. Copyright (c) 2013 Preston Lee. All rights reserved. http://prestonlee.com
