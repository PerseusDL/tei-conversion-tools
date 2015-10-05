<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:include href="beta2unicode.xsl"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="@*|node()">        
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:choose>
            <xsl:when test="(ancestor::*[local-name(.) = 'foreign' and (@xml:lang='greek' or @lang='greek')]) or
                ancestor::*[local-name(.) = 'text'] and not(ancestor::*[local-name(.) = 'note']) 
                and not(ancestor::*[local-name(.) = 'title']) and not(ancestor::*[local-name(.) = 'bibl']) and 
                (not(ancestor-or-self::*[@xml:lang or @lang]) or not(ancestor-or-self::*[@xml:lang !='greek' or @lang != 'greek']))">
                <xsl:call-template name="beta-to-uni">
                    <xsl:with-param name="a_in" select="."/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise><xsl:copy/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>    
</xsl:stylesheet>
