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
interest['Karen', 'Music']
interest['Karen', 'Movies']
interest['Karen', 'Games']
interest['Karen', 'Walks']
interest['Preston', 'Music']
interest['Preston', 'Movies']
interest['Preston', 'Games']

interest['Silas', 'Games']
interest['Cirrus', 'Games']
interest['Karen', 'Walks']
interest['Ron', 'Walks']
interest['Marcia', 'Walks']
