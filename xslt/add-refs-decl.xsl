<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:param name="e_decl"/>
    
    <xsl:variable name="refsDecl" select="doc($e_decl)/tei:refsDecl"></xsl:variable>
    <xsl:output indent="yes"></xsl:output>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:encodingDesc">
        <xsl:copy>
            <xsl:copy-of select="$refsDecl"/>    
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="node()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()|comment()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>