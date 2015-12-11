<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    >
    <xsl:output method="xml" encoding="UTF-8" exclude-result-prefixes="#all" indent="yes" />
    <xsl:template match="node()|@*|comment()">
        <!-- Copy the current node -->
        <xsl:copy>
            <!-- Including any child nodes it has and any attributes -->
            <xsl:apply-templates select="node()|@*|comment()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:div[./tei:milestone[@unit='chapter']]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="node()|comment()" group-starting-with="tei:milestone[@unit='chapter']">
                <xsl:choose>
                    <xsl:when test="current()/@n">
                        <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:sequence select="current()/@n"/>
                            <xsl:attribute name="type">textpart</xsl:attribute>
                            <xsl:attribute name="subtype">chapter</xsl:attribute>
                            <xsl:apply-templates select="current-group()[not(self::tei:milestone and @unit='chapter')]"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
