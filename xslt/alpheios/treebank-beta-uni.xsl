<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"   
    exclude-result-prefixes="xs xd"
    version="1.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Mar 16, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> Bridget</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
   <xsl:output media-type="text/xml" omit-xml-declaration="no" method="xml" indent="no"/>
   <xsl:preserve-space elements="*"/>
    <xsl:include href="beta2unicode.xsl"/>    
            
    <xsl:template match="@*|node()">
                    <xsl:copy>
                        <xsl:apply-templates select="@*"></xsl:apply-templates>
                        <xsl:apply-templates select="node()"></xsl:apply-templates>
                    </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@span|@lemma|@form">
        <xsl:choose>
            <xsl:when test="ancestor::treebank[@xml:lang='grc' or @xml:lang='greek']">
                <xsl:attribute name="{local-name(.)}">
                    <xsl:call-template name="beta-to-uni">
                        <xsl:with-param name="a_in" select="."/>                    
                    </xsl:call-template>              
                </xsl:attribute>    
            </xsl:when>
            <xsl:otherwise><xsl:copy/></xsl:otherwise>
        </xsl:choose>
                   
    </xsl:template>
    
</xsl:stylesheet>