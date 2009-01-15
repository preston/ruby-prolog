
require File.join(File.dirname(__FILE__), %w[spec_helper])

require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib family_tree]))


describe RubyProlog do

  before :each do

  end
  
  # TODO refactor query return and assert stuff!
  it 'needs to actually assert stuff!!!' do

    # Now let's ask some questions!

    p "Who are Silas's parents?"
    query(parent[:P, 'Silas'])

    p 'Are Karen and Julie siblings?'
    query(sibling['Karen', 'Julie'])

    p "Who are cousins?"
    query(cousin[:A, :B])

    p "Who likes to play games?"
    query(interest[:X, 'Games'])

    p "Who are Karen's ancestors?"
    query(ancestor[:A, 'Karen'])

    p "Who is married?"
    query(married[:A, :B])

    p "What grandparents are also widowers?"
    query(widower[:X], grandparent[:X, :C])
  end


end
