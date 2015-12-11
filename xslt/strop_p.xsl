<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output method="xml" encoding="UTF-8" exclude-result-prefixes="#all"/>
    <xsl:template match="node()|@*|comment()">
        <!-- Copy the current node -->
        <xsl:copy>
            <!-- Including any child nodes it has and any attributes -->
            <xsl:apply-templates select="node()|@*|comment()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:p[ancestor::tei:body]">
        <xsl:apply-templates select="node()|comment()"/>
    </xsl:template>
    <xsl:template match="tei:div[@type='edition' or @type='translation']">
        <xsl:copy>
            <xsl:attribute name="n" select="@n" />
            <xsl:attribute name="type" select="'textpart'" />
            <xsl:attribute name="subtype" select="'book'" />
            <xsl:apply-templates select="node()|comment()" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
