#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib ruby_prolog]))

# Basic family tree relationships..
sibling[:X,:Y] <<= [ parent[:Z,:X], parent[:Z,:Y], noteq[:X,:Y] ]
mother[:X,:Y] <<= [parent[:X, :Y], female[:X]]
father[:X,:Y] <<= [parent[:X, :Y], male[:X]]
grandparent[:G,:C] <<= [ parent[:G,:P], parent[:P,:C]]
cousin[:A, :B] <<= [parent[:X, :A], parent[:Y, :B], sibling[:X, :Y], noteq[:A, :B]]
ancestor[:A, :C] <<= [parent[:A, :X], parent[:X, :B]]
mothers[:M, :C] <<= mother[:M, :C]
mothers[:M, :C] <<= [mother[:M, :X], mothers[:X, :C]]
fathers[:F, :C] <<= father[:F, :C]
fathers[:F, :C] <<= [father[:F, :X], fathers[:X, :C]]
widower[:W] <<= [married[:W, :X], deceased[:X], nl[deceased[:W]]]
widower[:W] <<= [married[:X, :W], deceased[:X], nl[deceased[:W]]]
# married[:A, :B] <<= married[:B, :A]


# Basic mother/father relationships as would be stored in a typical relational database.
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


# Let's "tag" up some people..
married['Carol', 'Kent'].fact
married['Marge', 'Pappy'].fact
married['Ron', 'Marcia'].fact
married['Matt', 'Julie'].fact
married['Preston', 'Karen'].fact

# Now let's ask some questions!

p "Who are Silas's parents?"
query(parent[:P, 'Silas'])

p 'Are Karen and Julie siblings?'
query(sibling['Karen', 'Julie'])

p "Who are cousins?"
query(cousin[:A, :B])

p "Who are Karen's ancestors?"
query(ancestor[:A, 'Karen'])

p "Who is married?"
query(married[:A, :B])

p "What grandparents are also widowers?"
query(widower[:X], grandparent[:X, :C])
