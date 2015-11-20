<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
     xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="sp">
        <xsl:variable name="speaker" select="xs:string(speaker)"/>
        <xsl:choose>
            <xsl:when test="p">
                <xsl:for-each select="p">
                    <xsl:element name="said">
                        <xsl:attribute name="who" select="concat('#',$speaker)"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:for-each>        
            </xsl:when>
            <xsl:when test="l">
                <xsl:for-each select="l">
                    <xsl:element name="said">
                        <xsl:attribute name="who" select="concat('#',$speaker)"/>
                        <xsl:attribute name="n" select="@n"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:for-each>        
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="said">
                    <xsl:attribute name="who" select="concat('#',$speaker)"/>
                    <xsl:apply-templates select="*[not(local-name() = 'speaker')]"></xsl:apply-templates>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="node()">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    
</xsl:stylesheet>