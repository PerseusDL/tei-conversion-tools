#!/usr/bin/python

'''
© by Tabea Selle, Oct 2015
- script for adding line numbering to xml-files (adding <l>-tags)
- asks for beginning and ending line number
    (so as not to have to run over text that isn't supposed to change)
    also: counter alwys starts at 1, so any new part should be added at a second run
    -> change input/output file names accordingly
- I used this on different documents with different requirements,
    so I put everything I don't need atm as a comment for later use in case I need it again
'''

import sys
import re

def add_line_numbers(ftext):
    # counter for linenumber
    n = 0
    # string for linenumber
    nstring = ""
    # generic variable for matching regular expressions
    match = ""
    # changed list (sometimes need more than one for several changes)
    newtext = []
    # for tracking several lines
    tracker = False
    # keeping information on alternate line numbering
    old_n = 0

    # resulting list
    resultingtext = []

    # escape certain lines from alteration, that are not text (in this case: footnotes)
    # that may span several lines
    for line in ftext:
        if re.search(r'footnote', line) != None:
            # keep track of open tag
            tracker = True
            
        if re.search(r'</note>', line) != None:
            # replace tag that would otherwise be altered
            line = line.replace('<lb/>', '@')
            # previously open tag is closed
            tracker = False

        # if it spans more than two lines
        if tracker == True:
            # also want to keep ist
            line = line.replace('<lb/>', '@')

        newtext.append(line)
       

    
    # loops over every line in the specified area
    for line in newtext:
    
        
        # print(line)
        # other: <lb[ 0-9n="]*/>
        if re.search(r'<lb/>', line) != None and re.search(r'note', line) == None:
            match = re.search(r'(<lb/>)', line)
            match = match.group(1)         
            
            """
            else:
                n = n + 1
                nstring = str(n)

            line = line.replace(match, "")
            """
            
            # print(line)
            
            # removes old <lb/>-tags
            line = line.replace(match, "")

            # if the line starts with a number and has a be (alternative)
            if re.match(r'\s+[0-9]+b', line) != None:
                match = re.match(r'\s+([0-9b]+)', line)
                match = match.group(1)
                # reserve 'b', don't increase counter
                nstring = match
                line = line.replace(match + " ", "")
            # number without "b"
            elif re.match(r'\s+[0-9]+', line) != None:
                match = re.match(r'\s+([0-9^b]+)', line)
                match = match.group(1)
                # this is the number the counter should have (retains gaps in numbering or minimizes wrong numbers due to other stuff)
                n = int(match)
                nstring = str(n)
                line = line.replace(match + " ", "")
            # anything else: increase counter
            else:
                n = n + 1
                nstring = str(n)
            
            # removes multiple whitespaces before the text to make handling easier
            whites = re.search(r'(\s+)[^\s]', line)
            whites = whites.group(1)
            line = line.replace(whites, "")      

            """
            # used to restore messed up italic-tags occasionally spanning several lines
            while re.search(r'<hi rend="italic">', line) != None:
                line = line.replace('<hi rend="italic">', '@')

            while re.search(r'</hi>', line) != None:
                line = line.replace('</hi>', '%')

            # print(line)

            if tracker == True and re.search(r'%', line) == None:
                line = "@ " + line
                line = line.replace("\n", "%\n")
            
            if re.search(r'@[^%]+$', line) != None:
                # print(line)
                line = line.replace("\n", "%\n")
                tracker = True
            if re.search(r'^[^@]+%', line) != None:
                # print(line)
                line = "@ " + line
                tracker = False

            while re.search(r'@', line) != None:
                line = line.replace('@', '<hi rend="italic">')

            while re.search(r'%', line) != None:
                line = line.replace('%', '</hi>')

            """

                
            #  n = n + 1

            """
            # <lb>-Tags with numbers: changed into <milestone>-tags for alternative line numbering
            if match.find("n") != -1:
                newmatch = re.search(r'<lb n="([0-9]+)"/>', line)
                newmatch = newmatch.group(1)
                # n = int(newmatch)
                # nstring = str(n)
                line = line.replace(match, "")
                line = line.replace('\n', '<milestone n="' + newmatch + '" unit="altline"/>\n')
            """

            
            # adding <l>-tags
            line = line.replace('\n', '</l>\n')
            line = '            <l n="' + str(n) + '">' + line

        

        """
        # match existing <l>-tags
        if re.match(r'\s+<l', line) != None:
            # increase line count
            n = n + 1
            # match content of existing <l>-tag
            match = re.match(r'\s+<l n="([0-9a\-]+)">', line)
            match = match.group(1)

            # replace with new line number
            line = line.replace(match, str(n))

            # keep previous line count (every five)
            if match.endswith("0") or match.endswith("5"):
                old_n = int(match)
                line = line.replace('</l>','<milestone n="' + str(old_n) + '" unit="altline"/></l>')
                # print(line)

            old_n = 0

            # print(line)
        # 
        """

        # change symbol bag (wanting to keep <lb/>-tags outside relevant text)
        line = line.replace("@", "<lb/>")
        
        # add (possibly) altered line to resulting list
        # print(line)
        resultingtext.append(line)


    return resultingtext

def main():
    # open specific file
    f_in = open("stoa0215b.stoa002.opp-lat1_lines2.xml", 'rU',errors="surrogateescape")
    # variable for text preceeding the text to be altered
    pre = []
    # variable for relevant text
    text = []
    # variable for text succeeding relevant text
    post = []
    # previously used to keep track of current list
    listid = 1
    # line counter
    n = 0
    # match variable for regular expression
    match = ""

    # input for beginning and end of relevant text (line numbers)
    start = int(input("Beginning line number: "))
    end = int(input("Ending line number: "))

    # loops over each line in the input file
    for line in f_in:
        """
        # obsolete way of dividing text
        
        if re.search(r'<p><milestone unit="para"/>', line) != None:
            listid = 2
        if re.search(r'</p>', line) != None and listid == 2:
            listid = 3

        # print(line + str(listid))

        if listid == 1:
            pre.append(line)
        elif listid == 2:
            text.append(line)
            # print(line)
        elif listid == 3:
            post.append(line)
        """

        # increase line count
        n = n + 1

        # while specified line has not been reached
        if n < start:
            # store text in list
            pre.append(line)
        # specified lines
        elif n >= start and n <= end:
            # minor alteration beforehand
            if re.search(r'<milestone n="[0-9]+" unit="altline"/>', line) != None:
                match = re.search(r'(<milestone n="[0-9]+" unit="altline"/>)', line)
                match = match.group(1)
                line = line.replace(match, "")
            # store text to be altered in list
            text.append(line)
            # print(line)
        # everything after that in another list (preserves order)
        elif n > end:
            post.append(line)

    f_in.close()

    # calls function to alter or add line numbers
    text = add_line_numbers(text)

    # output file
    f_out = open('stoa0215b.stoa002.opp-lat1_lines3.xml', 'w')

    # everything in order
    for line in pre:
        f_out.write(line)

    for line in text:
        f_out.write(line)

    for line in post:
        f_out.write(line)
    

main()
