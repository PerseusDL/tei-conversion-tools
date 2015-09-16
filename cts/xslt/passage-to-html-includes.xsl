<?xml version="1.0" encoding="UTF-8"?>
<!-- Sample Overrides FOR TRANSFORMATION OF CTS 5 GetPassage Responses for Perseus Texts
     That uses the standard TEI P5 html5 transformation 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:teida="http://data.perseus.org/namespaces/teida"
    xmlns:cnt="http://www.w3.org/2011/content#"
    xmlns:dcmit="http://purl.org/dc/dcmitype/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:oa="http://www.w3.org/ns/oa#"
    xmlns:perseus="http://data.perseus.org/"
    xmlns:lawd="http://lawd.info/ontology/"
    xmlns:lode="http://linkedevents.org/ontology/#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:prov="http://www.w3.org/ns/prov#"
    xmlns:CTS="http://chs.harvard.edu/xmlns/cts"
    exclude-result-prefixes="tei xsl teida">
    
    <xsl:output indent="yes" method="html"/>
    <xsl:preserve-space elements="*"/>
    
    <!-- set some variables from the metadata in the response -->
    <xsl:variable name="urn" select="//CTS:reply/CTS:urn"/>
    <xsl:variable name="title" select="concat(//CTS:reply//CTS:groupname[1],', ',//CTS:reply//CTS:title[1])"/>
    <xsl:variable name="version">
        <xsl:analyze-string select="$urn[1]" regex="^(urn:cts:.*?:.*?):">
            <xsl:matching-substring><xsl:value-of select="regex-group(1)"/></xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:variable>
    
    <!-- the reply contains the content to transform -->
    <xsl:template match="CTS:reply">
        <!-- if we switch to wrapping passage responses in TEI elements we can override the default TEI hooks to
             add HTML header data and links - without it we have to roll our own
        -->
        <html>
            <head>
                <meta charset="utf-8" /> 
                <title><xsl:value-of select="$title"/></title>
                <!-- the css variables are params from the main tei driver -->
                <link rel="stylesheet" type="text/css" href="{$cssFile}"/>
                <xsl:if test="$cssSecondaryFile">
                    <link rel="stylesheet" type="text/css" href="{$cssSecondaryFile}"/>
                </xsl:if>
            </head>
            <body>
                <div id="logo">
                </div>
                <xsl:apply-templates/>
                <footer>
                    <xsl:call-template name="copyrightStatement"></xsl:call-template>
                </footer>
            </body>
        </html>
    </xsl:template>
    
    <!-- navigation might be nice at some point -->
    <xsl:template match="CTS:prevnext"/>
    
    <!-- might want to optionally show the request info, just hide for now -->
    <xsl:template match="CTS:request"/>
    
    <!-- make a header from the the CTS metadata -->
    <xsl:template match="CTS:label">
        <header>
            <div class="cts-label">
                <xsl:apply-templates/>
            </div>
        </header>
    </xsl:template>
    
    <!-- urn handled in variables -->
    <xsl:template match="CTS:urn"/>
    
    <xsl:template match="CTS:groupname"><div class="docAuthor"><xsl:value-of select="."/></div></xsl:template>
    
    <xsl:template match="CTS:title"><div class="docTitle"><xsl:value-of select="."/></div></xsl:template>
    
    <!-- add RDF-A for citation info -->
    <xsl:template match="CTS:work">
        <div id="cts-passage-uri" resource="http://data.perseus.org/citations/{$urn}" typeof="http://lawd.info/ontology/Citation">
            <span class="data-label">Citation URI:</span>http://data.perseus.org/citations/<xsl:value-of select="$urn"></xsl:value-of>
            <xsl:if test="$version">
                <div id="cts-text-uri" resource="http://data.perseus.org/texts/{$version}" typeof="http://lawd.info/ontology/WrittenWork" property="http://lawd.info/ontology/represents">
                    <span class="data-label">Text URI:</span> http://data.perseus.org/texts/<xsl:value-of select="$version"/>
                    <div id="cts-work-uri" resource="http://data.perseus.org/texts/{.}" typeof="http://lawd.info/ontology/ConceptualWork" property="http://lawd.info/ontology/embodies">
                        <span class="data-label">Work URI:</span>http://data.perseus.org/texts/<xsl:value-of select="."/>
                    </div>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template match="CTS:citation"><div id="cts-citation-scheme"><span class="data-label">Passage Components:</span><xsl:value-of select="."/></div></xsl:template>
    
    <!-- override default id generation for divs -->
    <xsl:template match="tei:div" mode="ident">
        <!-- use random ids to avoid collision between source and translation -->
        <xsl:value-of select="generate-id()"></xsl:value-of>
    </xsl:template>
    
    <!-- override author refs for now they won't contain targets that make sense outside of P4?? -->
    <xsl:template match="tei:ref[matches(@target,'author')]">
        <xsl:copy-of select="."/>
    </xsl:template>
        
    <!-- if a tei:name element contains a linkable reference, link it-->
    <xsl:template match="tei:name[matches(@ref,'^http.*')]">
        <a class="name" href="{@ref}"><xsl:apply-templates/></a>        
    </xsl:template>
    
    <!-- convert CTS URNs in @n attributes in citations to links to Perseus -->
    <!-- Ideally this would look up the base uri from a CTS resolver service -->
    <xsl:template match="tei:quote[@n[starts-with(.,'urn:cts')]]">
        <a class="citquote" href="{concat('http://data.perseus.org/citations/',@n)}"><xsl:apply-templates/></a>
    </xsl:template>
    
    <!-- standard Perseus Copyright -->
    <xsl:template name="copyrightStatement">
        <p class="cc_rights">
            <a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/us/">
                <img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-sa/3.0/us/88x31.png"></img>
            </a><br/>This work is licensed under a 
                <a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/us/">Creative Commons Attribution-ShareAlike 3.0 United States License</a>.
        </p>
    </xsl:template>
        
    <!-- just ignore these for now -->
    <xsl:template match="tei:milestone[@unit='para']"/>
        
</xsl:stylesheet>