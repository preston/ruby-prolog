
require_relative '../../test_helper'



describe RubyProlog do  
  
  it 'should not pollute the global namespace with predicates.' do
    
    # We'll create numerous instances of the engine and assert they do not interfere with each other.
     one = RubyProlog::Core.new
     one.instance_eval do
       query(male[:X]).length.must_equal 0
     end

     two = RubyProlog::Core.new
     two.instance_eval do
       male[:preston].fact
       query(male[:X]).length.must_equal 1
     end
     
     three = RubyProlog::Core.new
     three.instance_eval do
       query(male[:X]).length.must_equal 0
     end
     
     one.instance_eval do
       query(male[:X]).length.must_equal 0
     end

  end
  


  it 'should be able to query simple family trees.' do

    c = RubyProlog::Core.new
    c.instance_eval do
      # Basic family tree relationships..
      sibling[:X,:Y] <<= [ parent[:Z,:X], parent[:Z,:Y], noteq[:X,:Y] ]
      mother[:X,:Y] <<= [parent[:X, :Y], female[:X]]
      father[:X,:Y] <<= [parent[:X, :Y], male[:X]]
      grandparent[:G,:C] <<= [ parent[:G,:P], parent[:P,:C]]
      ancestor[:A, :C] <<= [parent[:A, :X], parent[:X, :B]]
      mothers[:M, :C] <<= mother[:M, :C]
      mothers[:M, :C] <<= [mother[:M, :X], mothers[:X, :C]]
      fathers[:F, :C] <<= father[:F, :C]
      fathers[:F, :C] <<= [father[:F, :X], fathers[:X, :C]]
      widower[:W] <<= [married[:W, :X], deceased[:X], nl[deceased[:W]]]
      widower[:W] <<= [married[:X, :W], deceased[:X], nl[deceased[:W]]]

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
      
      # Runs some queries..
      
      # p "Who are Silas's parents?"
      # Silas should have two parents: Matt and Julie.
      r = query(parent[:P, 'Silas'])
      r.length.must_equal 2
      r[0][0].args[0].must_equal 'Matt'
      r[1][0].args[0].must_equal 'Julie'
      
      # p "Who is married?"
      # We defined 5 married facts.
      query(married[:A, :B]).length.must_equal 5
        
      # p 'Are Karen and Julie siblings?'
      # Yes, through two parents.
      query(sibling['Karen', 'Julie']).length.must_equal 2
      
      
      # p "Who likes to play games?"
      # Four people.
      query(interest[:X, 'Games']).length.must_equal 4
      
      
      # p "Who likes to play checkers?"
      # Nobody.
      query(interest[:X, 'Checkers']).length.must_equal 0

      # p "Who are Karen's ancestors?"
      # query(ancestor[:A, 'Karen'])

      # p "What grandparents are also widowers?"
      # Marge, twice, because of two grandchildren.
      query(widower[:X], grandparent[:X, :G]).length.must_equal 2
    end

  end


  it 'should be able to query simple family trees.' do

    c = RubyProlog::Core.new
    c.instance_eval do

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
      
      kind['laptop']
      kind['monitor']
      kind['phone']
      
      model[:M] <<= [manfactures[:V, :M]]
      
      vendor_of[:V, :K] <<= [vendor[:V], manufactures[:V, :M], is_a[:M, :K]]
      # not_vendor_of[:V, :K] <<= [vendor[:V], nl[vendor_of[:V, :K]]]

      query(is_a[:K, 'laptop']).length == 2
      query(vendor_of[:V, 'phone']) == 1
      # pp query(not_vendor_of[:V, 'phone'])
    end
    
  end
  
  
  it 'should solve the Towers of Hanoi problem.' do
    c = RubyProlog::Core.new
    c.instance_eval do

      move[0,:X,:Y,:Z] <<= :CUT   # There are no more moves left
      move[:N,:A,:B,:C] <<= [
        is(:M,:N){|n| n - 1}, # reads as "M IS N - 1"
        move[:M,:A,:C,:B],
        # write_info[:A,:B],
        move[:M,:C,:B,:A]
      ]
      write_info[:X,:Y] <<= [
        # write["move a disc from the "],
        # write[:X], write[" pole to the "],
        # write[:Y], writenl[" pole "]
      ]

       hanoi[:N] <<=  move[:N,"left","right","center"]
       query(hanoi[5]).length.must_equal 1

       # do_stuff[:STUFF].calls{|env| print env[:STUFF]; true}

    end  
    
  end
end
