<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ti="http://chs.harvard.edu/xmlns/cts"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output
        method="xml"
        indent="yes"/> 
    
    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>
    <xsl:template match="ti:edition|ti:translation">
        <xsl:choose>
            <xsl:when test="count(./@workUrn) = 0">
                <xsl:copy>
                    <xsl:copy-of select="./@*" />
                    <xsl:attribute name="workUrn">
                        <xsl:value-of select="./ancestor::ti:work/@urn" />
                    </xsl:attribute>
                    <xsl:apply-templates />
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates />
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="node()|comment()">
        <xsl:param name="e_ref"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()|comment()">
                <xsl:with-param name="e_ref" select="$e_ref" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>