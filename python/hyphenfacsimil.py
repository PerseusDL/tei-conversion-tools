""" Hypen facsimile correction

Python 3 Script

Description :
    This software aims at correcting facsimile xml with hyphenated words. 
    If the facsimile contains \n after each hyphenated word like:

        ἐνηγγύησε νοί. 1, p. 436, Α; 537, Β; — δεκαετὴς et — δεκέ-
        της, quas inter duplices formas interdum etiam libri variant,

    Given a second source file (that can be the same as the facsimile), 
    it will generates a new output file (default "output.txt") that will glue together.

    The regular expression takes care of <lb /> <pb /> <milestone /> and <note...>..</note> 
    that could be between the hyphenated word and the result word. Those will be conserved and 
    put before the corrected word

Syntax :

    python3 hyphenfacsimil.py path/to/source/file path/to/target/file (path/to/output/file)


Requires :
    - regex==2015.7.19

    pip install regex

"""
from sys import argv, path, exit
import regex as re


FALSE_POSITIVES = [
    "UTF-8",
    "xml-model",
    "tei-epidoc",
    "tei-c",
    "Attribution-ShareAlike"
]
print("Fac-simile file :" + argv[1])
print("Target    file  :" + argv[2])

output = "output.xml"
if len(argv) > 3:
    print("Target saving file : " +argv[3])
    output = argv[3]

if input("Are you sure ? [Y/n]").lower() == "n":
    exit()

print("Processing...")

"""
    Searching words in the source file
"""
words = re.compile(
    "(\w+\-)" \
        "(" \
            "\s*<[lp]+b\s+n=\"[0-9a-zA-Z ]+\"\s*/>|" \
            "\s*<note[^>]*>[^<]+</note>|" \
            "\s*<milestone[^/]*/>" \
        ")*" \
    "\s*[’]*(\w+)"
)
hyphens = []
with open(argv[1], "r") as source:
    hyphens = words.findall(source.read())

print("Found {0} matched hyphen-words".format(len(hyphens)))

# Filter hyphens based on FALSE_POSITIVES
hyphens = [m for m in hyphens if m[0]+m[-1] not in FALSE_POSITIVES]

"""
    Searching same words in the target file
"""

with open(argv[2]) as f:
    text = f.read()

matches = []

regexp = "("\
    "({0})" \
        "(" \
            "\s*<[lp]+b\s+n=\"[0-9a-zA-Z ]+\"\s*/>|" \
            "\s*<note[^>]*>[^<]+</note>|" \
            "\s*<milestone[^/]*/>" \
        ")*" \
    "\s*[’]*({1})" \
    ")+"

regs = []

def replace(match):
    # We make a list of matches and remove the full match
    match = list(match.groups())
    submatch = match[1:]
    # We filter the None
    word = submatch[0][0:-1] + submatch[-1]
    tags = match[0][len(submatch[0]):-len(submatch[-1])]

    if not tags:
        return word
    elif tags[0] == " ":
        return word + tags
    else:
        return word + " " + tags


for w in hyphens:
    # Check
    regs.append(regexp.format(w[0], w[-1]))
    # Compile
    c = re.compile(
        regexp.format(w[0], w[-1]),
        re.UNICODE,
        count=1
    )
    # Find
    i = c.findall(text)
    # Filter, flatten, move to list
    i = [x for z in i for x in z]
    # Add to matches
    matches.append(
        i
    )
    # If we got some result, replace
    if len(i) > 0:
        text = c.sub(replace, text)

for i in range(0, len(matches)):
    if len(matches[i]) == 0:
        print("Not founds : " + hyphens[i][0] + hyphens[i][-1])

with open("logs-hyphen.txt", "w") as f:

    f.write("###################\n")
    f.write("Found hypenated words on source\n")
    f.write("###################\n")
    f.write("\n".join([w[0]+w[-1] for w in hyphens]))

    f.write("\n###################\n")
    f.write("Not found hypenated words from source on target\n")
    f.write("###################\n")
    f.write("\n".join([hyphens[i][0] + hyphens[i][-1] for i in range(0, len(matches)) if len(matches[i]) == 0]))

    f.write("\n###################\n")
    f.write("Found hypenated words on target\n")
    f.write("###################\n")
    f.write("\n".join([w[0]+w[-1] for w in matches if len(w) > 0]))

# Remove double space
text = re.sub("  ", " ", text)
with open(output, "w") as f:
    f.write(text)