""" Div1 / Div2 old Perseus data to Div/Div + RefsDecl converter

Authors : Aaron Plasek and Ariane Pinche
Adaptation : Thibault Clérice

Python 3 Script

Description :
    This software will transform old Perseus files into CTS compliant files if their structure is div1/div2 based

    Example of file needing this : 
        https://raw.githubusercontent.com/PerseusDL/canonical-greekLit/598aea1eb719be1709f720839e4428a087e43ad6/data/tlg0612/tlg001/tlg0612.tlg001.perseus-grc1.xml
    Example of output :

Syntax :

    python3 div1_div2.py [Url of the original file on raw.github] [URN] [lang]


Requires :
    - requests
    - lxml
    - MyCapytain

    pip install ...

"""
# Import command line informations
from sys import argv
# Import required library
from lxml import etree
import requests
# Import library for CTS 
import MyCapytain.resources.texts.tei

def transform(url, urn, lang):
    """ Download an xml file and add line numbering and ctsize it

    :param url: A Perseus Github Raw address
    :type url: str
    :param urn: The urn of the text
    :type urn: str
    :param lang: Iso code for lang
    :type lang: str

    """

    """
        Downloading the resource 
    """
    # Download the resource
    response = requests.get(url)
    # Ensure there was no errors
    response.raise_for_status()

    # Get the file name by splitting the url
    filename = url.split("/")[-1]

    """ 
        Caching the resource 
    """

    # Save the original response
    with open("original-"+filename, 'w') as f:
        # Don't forget to write the reponse.text and not response itself
        read_data = f.write(response.text)

    # Open it and parse it
    with open("original-"+filename) as f:
        # We use the etree.parse property
        parsed = etree.parse(f)

    """
        Change div1 to div, moving their @type to @subtype 
    """    

    # We find divs called div1
    div1_group = parsed.xpath("//div1")
    for div1 in div1_group:
        # We change it's tag
        div1.tag = "div"
        # To deal with different subtype, we get the former attribute value of type and put it to subtype
        div1_subtype = div1.get("type")
        div1.set("subtype", div1_subtype)
        div1.set("type", "textpart")
                
        
    """
        Change div2 to div, moving their @type to @subtype 
    """    
    # We find divs called div2
    div2_group = parsed.xpath("//div2")
    for div2 in div2_group:
        # We change it's tag
        div2.tag = "div"
        # To deal with different subtype, we get the former attribute value of type and put it to subtype
        div2_subtype = div2.get("type")
        div2.set("subtype", div2_subtype)
        div2.set("type", "textpart")

    """
        Change TEI.2 tag to TEI 
    """
    # We change the main tag
    TEI = parsed.getroot()
    # We change the root tag to TEI
    TEI.tag = "TEI"
    # We change the main tag
    TEI = parsed.getroot()

    """
        Moving every children of //body into a new div with a @n attribute
    """
    body = parsed.xpath("//body")[0]
    # Get its children
    child_body = body.getchildren()

    # For each child of body, remove it from body
    for child in child_body:
        body.remove(child)

    # Create a new div with the informations
    div = etree.Element(
        "div",
        attrib = { 
            "type":"edition",
            "n": urn,
            "{http://www.w3.org/XML/1998/namespace}lang" : lang
        }
    )

    # Add the full list of children of body to the newly created div
    div.extend(child_body)
    # Add this new div in body
    body.append(div)

    """
        Add refsDecl information for CTS
    """
    citations = []
    citations.append(
        MyCapytain.resources.texts.tei.Citation(
            name=div2_subtype, 
            refsDecl="/tei:TEI/tei:text/tei:body/div[@type='edition']/div[@n='$1']/div[@n='$2']"
        )
    )
    citations.append(
        MyCapytain.resources.texts.tei.Citation(
            name=div1_subtype, 
            refsDecl="/tei:TEI/tei:text/tei:body/div[@type='edition']/div[@n='$1']"
        )
    )

    # Add them to the current encodingDesc
    refsDecl = """<tei:refsDecl n="CTS" xmlns:tei="http://www.tei-c.org/ns/1.0">\n""" + "\n".join([str(citation) for citation in citations]) + """\n</tei:refsDecl>"""
    # Parse it
    refsDecl = etree.fromstring(refsDecl)
    # Find encodingDesc
    encodingDesc = parsed.xpath("//encodingDesc")[0]
    encodingDesc.append(refsDecl)

    """
        Search for old //encodingDesc/refsDecl and refsDecl/state and correct them
    """
    refsDecls = parsed.xpath("//encodingDesc/refsDecl[@doctype]")
    for refsDecl in refsDecls:
        refsDecl.set("n", refsDecl.get("doctype"))
        del refsDecl.attrib["doctype"]

    states = parsed.xpath("//encodingDesc/refsDecl/state")
    for state in states:
        state.tag = "refState"

    """
        Change language@id to ident
    """
    languages = parsed.xpath("//langUsage/language[@id]") + parsed.xpath("//langUsage/lang[@id]")
    for lang in languages:
        lang.set("ident", lang.attrib["id"])
        del lang.attrib["id"]

    """
        Change pb@id to pb@n
    """
    pbs = parsed.xpath("//pb[@id]")
    for pb in pbs:
        pb.set("n", pb.attrib["id"])
        del pb.attrib["id"]

    """
        Clean keyboarding/p
    """
    ps = parsed.xpath("//sourceDesc/p")
    for p in ps:
        p.getparent().remove(p)

    """
        Clear attributes of text and body
    """
    body_text = parsed.xpath("//body") + parsed.xpath("//text")
    for tag in body_text:
        for key in tag.attrib:
            del tag.attrib[key]

    # Convert to xml
    """ 
        Create a new document so we can have tei namespace 
    """
    # And now some other CTS Magic
    New_Root = etree.Element(
        "{http://www.tei-c.org/ns/1.0}TEI",
        nsmap = { None : "http://www.tei-c.org/ns/1.0" } # Creating a new element allows us to use a default namespace
    )

    # Add children of old root to New_Root
    New_Root.extend(TEI.getchildren())

    # We create a new document
    New_Doc = etree.ElementTree(New_Root)
    # And now some other CTS Magic
    

    # save xml
    with open ("changed-"+filename, "w") as xmlfile:
        xmlfile.write(etree.tostring(New_Doc, encoding=str))


if __name__ == '__main__':
    transform(*tuple(argv[1:]))