<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:name">
        <xsl:element name="name" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*[not(name(.) = 'reg')]"/>
            <xsl:if test="@reg">
                <xsl:element name="reg" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:value-of select="@reg"></xsl:value-of>
                </xsl:element>        
            </xsl:if>
            <xsl:apply-templates select="node()|comment()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="node()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates  select="node()|comment()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>