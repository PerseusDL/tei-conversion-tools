<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="2.0">
    <xsl:output indent="yes" method="xml"/>
    <xsl:variable name="path" select="'/home/thibault/dev/canonicals/tei-conversion-tools/phi001'"/>
    <xsl:variable name="lang" select=".//tei:text/@xml:lang"/>
    <xsl:template match="tei:TEI">
        <xsl:copy>
            <xsl:copy-of select="tei:teiHeader"/>
            <xsl:element name="text" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element name="body" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="n" select="concat('urn:cts:latinLit:phi1002.phi001.perseus-', $lang, '1')" />
                        <xsl:attribute name="type" select="'edition'" />
                        <xsl:for-each select="collection(concat($path, '?select=*-', $lang ,'[0-9]+.xml'))">
                            <xsl:sort select="number(current()/tei:TEI/tei:text/tei:body/tei:div/@n)" />
                            <xsl:variable name="volume" select="replace(current()//tei:title[@type='work']/text(), '^.*\s([0-9]+-[0-9]+).*$', '$1') "/>
                           <xsl:apply-templates select="current()//tei:body" >
                               <xsl:with-param name="volume" select="$volume" />
                           </xsl:apply-templates>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:body">
        <xsl:param name="volume" />
        <xsl:apply-templates select="node()|comment()|@*" >
            <xsl:with-param name="volume" select="$volume" />
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="node()|@*|comment()">
        <xsl:param name="volume" />
        <!-- Copy the current node -->
        <xsl:copy>
            <!-- Including any child nodes it has and any attributes -->
            <xsl:apply-templates select="node()|@*|comment()">
                <xsl:with-param name="volume" select="$volume" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:pb">
        <xsl:param name="volume" />
        <xsl:copy>
            <xsl:if test="count(./@xml:id)">
                <xsl:attribute name="n" select="concat('v', $volume, ' ', ./@xml:id)" />
            </xsl:if>
            <xsl:if test="count(./@n)">
                <xsl:attribute name="n" select="concat('v', $volume, ' ', ./@n)" />
            </xsl:if>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
