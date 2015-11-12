<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    <xsl:output exclude-result-prefixes="#all" ></xsl:output>
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="tei:lemma">
        <xsl:element name="app" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:element name="lem" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="./@*"/>
            <xsl:apply-templates  select="node()|comment()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template match="node()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="./@*"/>
            <xsl:apply-templates  select="node()|comment()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>