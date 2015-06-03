<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
<!--
    Add urn to documents
    Example doc :
    <root>
        <document>
            <path>canonicals/canonical-greekLit/data/tlg0001/tlg001/tlg0001.tlg001.perseus-grc2.xml</path>
            <urn>urn:cts:greekLit:tlg0001.tlg001.perseus-grc2</urn>
        </document>
    </root>
 -->
    <xsl:template match="/">
        <xsl:for-each select="//document">
            <xsl:call-template name="document">
                <xsl:with-param name="path" select="./path/text()" />
                <xsl:with-param name="urn" select="./urn/text()" />
                <xsl:with-param name="doc" select="doc(./path/text())" />
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="document">
        <xsl:param name="path"/>
        <xsl:param name="urn"/>
        <xsl:param name="doc"/>
        
        <xsl:result-document method="xml" href="canonicals-edit/{$path}">
         <xsl:apply-templates select="$doc/*">
             <xsl:with-param name="urn" select="$urn" />
             <xsl:with-param name="count" select="count($doc//*:div[@type='edition' or @type='translation'])" />
         </xsl:apply-templates>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="*:text|*:div[@type='edition' or @type='translation']" >
        <xsl:param name="urn"/>
        <xsl:param name="count"/>
        <xsl:choose>
            <xsl:when test="((local-name(.) = 'text' and $count = 0) or (local-name(.) = 'div'))">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="n"><xsl:value-of select="$urn" /></xsl:attribute>
                    <xsl:apply-templates select="node()|comment()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>  
                    <xsl:apply-templates select="@*" />
                    <xsl:apply-templates>
                        <xsl:with-param name="urn" select="$urn" />
                        <xsl:with-param name="count" select="$count" />
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="node()|comment()">
        <xsl:param name="urn"/>
        <xsl:param name="count"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()|comment()">
                <xsl:with-param name="urn" select="$urn" />
                <xsl:with-param name="count" select="$count" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>