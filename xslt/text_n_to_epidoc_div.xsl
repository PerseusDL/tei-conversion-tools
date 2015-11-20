<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei xs" 
    version="2.0">
    
    <xsl:template match="tei:text">
        <xsl:variable name="urn" select="@n" />
        <xsl:variable name="lang" select="@xml:lang" />
        <xsl:element name="text" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:element name="body" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:apply-templates select="./tei:body/@*"/>
                <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type">edition</xsl:attribute>
                    <xsl:attribute name="n" select="$urn"/>
                    <xsl:attribute name="xml:lang" select="$lang"/>
                    <xsl:apply-templates select="./tei:body/node()|./tei:body/comment()|comment()|./node()[local-name(.) != 'body']"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="node()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="./@*"/>
            <xsl:apply-templates select="node()|comment()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>