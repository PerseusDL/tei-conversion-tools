<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="*:div1|*:div2|*:div3">
        <xsl:element name="div">
            <xsl:attribute name="type" select="'textpart'" />
            <xsl:attribute name="subtype" select="@type" />
            <xsl:attribute name="n" select="@n" />
            <xsl:apply-templates  select="node()|comment()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="node()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="./@*"/>
            <xsl:apply-templates  select="node()|comment()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>