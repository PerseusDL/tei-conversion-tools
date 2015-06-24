<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:output xml:space="preserve" indent="yes" method="xml" />

    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>
    
    <xsl:template match="tei:cRefPattern">
        <xsl:element name="cRefPattern" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="n">
                <xsl:value-of select="tokenize(./tei:p/text(), '\s+')[last()]" />
            </xsl:attribute>
            <xsl:apply-templates select="attribute()"/>
            <xsl:apply-templates select="node()|comment()" />
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:choose>
            <xsl:when test="name(.) = 'id' and . = 'CTS'">
                <xsl:attribute name="n">
                    <xsl:value-of select="." />
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()|comment()" />
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>