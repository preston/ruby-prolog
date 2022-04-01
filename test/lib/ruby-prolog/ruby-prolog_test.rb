#!/usr/bin/env ruby

require_relative '../../test_helper'

describe RubyProlog do

  it 'should not pollute the global namespace with predicates.' do

    # We'll create numerous instances of the engine and assert they do not interfere with each other.
    one = RubyProlog::Core.new
    _( one.query{ male[:X] }.length ).must_equal 0

    two = RubyProlog::Core.new
    two.instance_eval do
      male[:preston].fact
    end
    _( two.query{ male[:X] }.length ).must_equal 1

    three = RubyProlog::Core.new
    _( three.query{ male[:X] }.length ).must_equal 0

    _( one.query{ male[:X] }.length ).must_equal 0
  end


  it 'returns hashes of solutions' do
    one = RubyProlog.new do
      foo['a', 'b'].fact
      foo['a', 'b'].fact
      foo['a', 'c'].fact
      foo['d', 'e'].fact
      foo['d', 'c'].fact
    end
    _( one.query {_= foo['a', :X] } ).must_equal [{ X: 'b' }, { X: 'b' }, { X: 'c' }]
    _( one.query {_= foo['a', :X], foo['d', :X] } ).must_equal [{ X: 'c' }]
    _(one.to_prolog.class).must_equal String
  end

  it 'works with numbers' do
    one = RubyProlog.new do
      foo[10, 20].fact
      foo[10, 30].fact
    end
    _( one.query {_= foo[10, :X] } ).must_equal [{ X: 20 }, { X: 30 }]

    _(one.to_prolog.class).must_equal String
  end

  it 'considers all predicates dynamic' do
    one = RubyProlog::Core.new
    one.instance_eval do
      foo[10] << [bar[20]]
    end
    _( one.query {_= foo[:X] } ).must_equal []
  end

  it 'supports underscore' do
    one = RubyProlog::Core.new
    one.instance_eval do
      foo[10, 200].fact
      foo[10, 300].fact
      foo[20, 400].fact

      bar[50, :_].fact
    end
    _( one.query { foo[:X, :_] } ).must_equal [{X: 10}, {X: 10}, {X: 20}]
    _( one.query { bar[50, 99] } ).must_equal [{}]
    one.to_prolog
  end

  it 'supports clone' do
    one = RubyProlog::Core.new
    one.instance_eval do
      foo[10].fact
    end
    _( one.query {_= foo[:X] } ).must_equal [{X: 10}]

    two = one.clone
    _( one.query {_= foo[:X] } ).must_equal [{X: 10}]
    _( two.query {_= foo[:X] } ).must_equal [{X: 10}]

    one.instance_eval{ foo[20].fact }

    _( one.query {_= foo[:X] } ).must_equal [{X: 10}, {X: 20}]
    _( two.query {_= foo[:X] } ).must_equal [{X: 10}]

    two.instance_eval{ foo[30].fact }
    _( one.query {_= foo[:X] } ).must_equal [{X: 10}, {X: 20}]
    _( two.query {_= foo[:X] } ).must_equal [{X: 10}, {X: 30}]
  end

  it 'supports false' do
    db = RubyProlog.new do
      foo[:_] << [false]
      foo['x'].fact

      bar[:_] << [:CUT, false]
      bar['x'].fact

      baz[false].fact
    end

    _( db.query{ foo['x'] } ).must_equal [{}]
    _( db.query{ bar['x'] } ).must_equal []
    _( db.query{ baz[false] } ).must_equal [{}]
  end

  it 'should be able to query simple family trees.' do

    c = RubyProlog.new do
      # Basic family tree relationships..
      sibling[:X,:Y] << [ parent[:Z,:X], parent[:Z,:Y], noteq[:X,:Y] ]
      mother[:X,:Y] << [parent[:X, :Y], female[:X]]
      father[:X,:Y] << [parent[:X, :Y], male[:X]]

      grandparent[:G,:C] << [ parent[:G,:P], parent[:P,:C]]

      ancestor[:A, :C] << [parent[:A, :C]]
      ancestor[:A, :C] << [parent[:A, :X], parent[:X, :C]]

      mothers[:M, :C] << mother[:M, :C]
      mothers[:M, :C] << [mother[:M, :X], mothers[:X, :C]]

      fathers[:F, :C] << father[:F, :C]
      fathers[:F, :C] << [father[:F, :X], fathers[:X, :C]]

      widower[:W] << [married[:W, :X], deceased[:X], nl[deceased[:W]]]
      widower[:W] << [married[:X, :W], deceased[:X], nl[deceased[:W]]]

      # Basic parents relationships as could be stored in a typical relational database.
      parent['Ms. Old', 'Marge'].fact

      parent['Carol', 'Ron'].fact
      parent['Kent', 'Ron'].fact
      parent['Marge', 'Marcia'].fact
      parent['Pappy', 'Marcia'].fact

      parent['Marcia', 'Karen'].fact
      parent['Marcia', 'Julie'].fact
      parent['Ron', 'Karen'].fact
      parent['Ron', 'Julie'].fact

      parent['Matt', 'Silas'].fact
      parent['Julie', 'Silas'].fact
      parent['Preston', 'Cirrus'].fact # Technically our dog.. but whatever :)
      parent['Karen', 'Cirrus'].fact


      # Gender facts..
      male['Preston'].fact
      male['Kent'].fact
      male['Pappy'].fact
      male['Ron'].fact
      male['Matt'].fact
      female['Ms. Old'].fact
      female['Carol'].fact
      female['Marge'].fact
      female['Marcia'].fact
      female['Julie'].fact
      female['Karen'].fact


      # People die :(
      deceased['Pappy'].fact


      # Let's marry some people..
      married['Carol', 'Kent'].fact
      married['Marge', 'Pappy'].fact
      married['Ron', 'Marcia'].fact
      married['Matt', 'Julie'].fact
      married['Preston', 'Karen'].fact


      # And add some facts on personal interests..
      interest['Karen', 'Music'].fact
      interest['Karen', 'Movies'].fact
      interest['Karen', 'Games'].fact
      interest['Karen', 'Walks'].fact
      interest['Preston', 'Music'].fact
      interest['Preston', 'Movies'].fact
      interest['Preston', 'Games'].fact

      interest['Silas', 'Games'].fact
      interest['Cirrus', 'Games'].fact
      interest['Karen', 'Walks'].fact
      interest['Ron', 'Walks'].fact
      interest['Marcia', 'Walks'].fact
    end

    # Runs some queries..

    # p "Who are Silas's parents?"
    # Silas should have two parents: Matt and Julie.
    _( c.query{ parent[:P, 'Silas'] } ).must_equal [{P: 'Matt'}, {P: 'Julie'}]

    # p "Who is married?"
    # We defined 5 married facts.
    _( c.query{ married[:A, :B] }.length ).must_equal 5

    # p 'Are Karen and Julie siblings?'
    # Yes, through two parents.
    _( c.query{ sibling['Karen', 'Julie'] }.length ).must_equal 2


    # p "Who likes to play games?"
    # Four people.
    _( c.query{ interest[:X, 'Games'] }.length ).must_equal 4


    # p "Who likes to play checkers?"
    # Nobody.
    _( c.query{ interest[:X, 'Checkers'] }.length ).must_equal 0

    # p "Who are Karen's ancestors?"
    _( c.query{ ancestor[:A, 'Karen'] } ).must_equal [
      {A: 'Marcia'},
      {A: 'Ron'},
      {A: 'Carol'},
      {A: 'Kent'},
      {A: 'Marge'},
      {A: 'Pappy'},
    ]

    # p "What grandparents are also widowers?"
    # Marge, twice, because of two grandchildren.
    _( c.query{_= widower[:X], grandparent[:X, :G] }.length ).must_equal 2

    _(c.to_prolog.class).must_equal String
  end


  it 'should be able to query simple family trees.' do

    c = RubyProlog.new do

      vendor['dell'].fact
      vendor['apple'].fact

      model['ultrasharp'].fact
      model['xps'].fact
      model['macbook'].fact
      model['iphone'].fact

      manufactures['dell', 'ultrasharp'].fact
      manufactures['dell', 'xps'].fact
      manufactures['apple', 'macbook'].fact
      manufactures['apple', 'iphone'].fact

      is_a['xps', 'laptop'].fact
      is_a['macbook', 'laptop'].fact
      is_a['ultrasharp', 'monitor'].fact
      is_a['iphone', 'phone'].fact

      kind['laptop'].fact
      kind['monitor'].fact
      kind['phone'].fact

      model[:M] << [manfactures[:V, :M]]

      vendor_of[:V, :K] << [vendor[:V], manufactures[:V, :M], is_a[:M, :K]]
      not_vendor_of[:V, :K] << [vendor[:V], not_[vendor_of[:V, :K]]]
    end

    _( c.query{ is_a[:K, 'laptop'] }.length ).must_equal 2
    _( c.query{ vendor_of[:V, 'phone'] } ).must_equal [{V: 'apple'}]
    _( c.query{ not_vendor_of[:V, 'phone'] } ).must_equal [{V: 'dell'}]
    _(c.to_prolog.class).must_equal String
  end


  it 'should solve the Towers of Hanoi problem.' do
    c = RubyProlog.new do

      move[0,:X,:Y,:Z] << :CUT   # There are no more moves left
      move[:N,:A,:B,:C] << [
        is(:M,:N){|n| n - 1}, # reads as "M IS N - 1"
        move[:M,:A,:C,:B],
        # write_info[:A,:B],
        move[:M,:C,:B,:A]
      ]
      write_info[:X,:Y] << [
        # write["move a disc from the "],
        # write[:X], write[" pole to the "],
        # write[:Y], writenl[" pole "]
      ]

       hanoi[:N] <<  move[:N,"left","right","center"]
    end

    _( c.query{ hanoi[5] } ).must_equal [{}]

    _(c.to_prolog.class).must_equal String
  end

  it 'works on the other examples in the readme' do
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

    _( db.query{ implication['c', :X] } ).must_equal [{ X: 'd' }, { X: 'x' }]
    _( db.query{ implication[:X, :_] } ).must_equal [{ X: 'a' }, { X: 'b' }, { X: 'c' }, { X: 'c' }]
    _( db.query{_= implies['a', :X] } ).must_equal [{ X: 'b' }, { X: 'c' }, { X: 'd' }, { X: 'x' }]

    _( db.query{[ implication['b', :S], implies[:S, :B] ]} ).must_equal [{:S=>"c", :B=>"d"}, {:S=>"c", :B=>"x"}]
    _( db.query{_= implication['b', :S], implies[:S, :B] } ).must_equal [{:S=>"c", :B=>"d"}, {:S=>"c", :B=>"x"}]

    # For good measure
    _( db.query{_= implies['a', 'b'] } ).must_equal [{}]
    _( db.query{_= implies['a', 'd'] } ).must_equal [{}]
    _( db.query{_= implies['a', 'idontexist'] } ).must_equal []
  end

  it 'supports zero-arity predicates' do
    db = RubyProlog.new do
      data['a'].fact
      foo_1[] << data['a']
      bar_1[].fact

      foo_2 << data['b']
      bar_2.fact
    end

    _( db.query{ foo_1[] } ).must_equal [{}]
    _( db.query{ bar_1[] } ).must_equal [{}]

    _( db.query{ foo_2 } ).must_equal []
    _( db.query{ bar_2 } ).must_equal [{}]
  end
end
