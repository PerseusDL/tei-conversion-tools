<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output indent="yes"></xsl:output>
    <xsl:template match="castList">
        <xsl:element name="listPerson">
            <xsl:for-each select=".//role">
                <xsl:element name="person">
                    <xsl:attribute name="xml:id" select="current()/@id"/>
                    <xsl:element name="persName" >
                        <xsl:attribute name="xml:lang" select="'eng'"/>
                        <xsl:value-of select="current()/text()"/>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>