<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:output indent="yes" />
    
    <xsl:template match="*:teiHeader">
        <xsl:choose>
            <xsl:when test="count(*:revisionDesc) = 0">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()|comment()" />
                    <xsl:element name="revisionDesc">
                         <xsl:element name="change">
                             <xsl:attribute name="when">2015-12-07</xsl:attribute>
                             <xsl:attribute name="who">Thibault Clérice</xsl:attribute>
                             <xsl:text>Epidoc and CTS. URN updated accordingly</xsl:text>
                         </xsl:element>
                    </xsl:element>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*:revisionDesc">
        <xsl:copy>
             <xsl:apply-templates select="@*|node()|comment()" />
             <xsl:element name="change">
                 <xsl:attribute name="when">2015-12-07</xsl:attribute>
                 <xsl:attribute name="who">Thibault Clérice</xsl:attribute>
                 <xsl:text>Epidoc and CTS. URN updated accordingly</xsl:text>
             </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*:div[@type='edition' or @type='translation']">
        <xsl:copy>
             <xsl:attribute name="n" select="replace(@n, 'lat1', 'lat2')"/>
             <xsl:apply-templates select="@*[name(.) != 'n']" />
             <xsl:apply-templates select="node()|comment()" />
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