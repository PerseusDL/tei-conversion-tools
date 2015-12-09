<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="tei:l[not(@n) and @part]">
        <xsl:variable name="container" select="ancestor::tei:div[@type='edition']" />
        <xsl:variable name="seq" select="$container//tei:l" />
        <xsl:variable name="n" select="index-of($seq, current())-1"/>
        <xsl:copy>
            <xsl:attribute name="n" select="concat($seq[$n]/@n, 'b')"/>
            <xsl:attribute name="part" select="current()/@part"/>
            <xsl:apply-templates  select="node()|comment()"/>
        </xsl:copy>
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