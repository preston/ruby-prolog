#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib ruby_prolog]))


parent[:X,:Y] <<= father[:X,:Y]
parent[:X,:Y] <<= mother[:X,:Y]

sibling[:X,:Y] <<= [ parent[:Z,:X], parent[:Z,:Y], noteq[:X,:Y] ]
grandparent[:G,:C] <<= [ parent[:G,:P], parent[:P,:C]]
cousin[:A, :B] << [parent[:X, :A], parent[:Y, :B], sibling[:X, :Y], noteq[:A, :B]]

mother['Carol', 'Ron'].fact
father['Kent', 'Ron'].fact
mother['Marge', 'Marcia'].fact
father['Pappy', 'Marcia'].fact

mother['Marcia', 'Karen'].fact
mother['Marcia', 'Julie'].fact
father['Ron', 'Karen'].fact
father['Ron', 'Julie'].fact

# grandparent['Ron', 'Silas'].fact

father['Matt', 'Silas'].fact
mother['Julie', 'Silas'].fact
father['Preston', 'Cirrus'].fact
mother['Karen', 'Cirrus'].fact

# query sibling[:X, "Karen"]
# query(sibling[:X, :Y])
# query(parent[:P, 'Silas'])
# query(parent[:P, 'Cirrus'])
# query(sibling['Karen', 'Julie'])
# query grandparent[:X, 'Silas']
# query grandparent[:X, 'Cirrus']
query(cousin[:A, :B])
