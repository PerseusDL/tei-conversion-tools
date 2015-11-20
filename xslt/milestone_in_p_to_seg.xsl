<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    >
    <xsl:output method="xml" encoding="UTF-8" exclude-result-prefixes="#all"/>
    <xsl:template match="node()|@*|comment()">
        <!-- Copy the current node -->
        <xsl:copy>
            <!-- Including any child nodes it has and any attributes -->
            <xsl:apply-templates select="node()|@*|comment()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="p[./milestone[@unit='section']]">
        <xsl:element name="p">
            <xsl:apply-templates select="@n" />
            <xsl:attribute name="type">textpart</xsl:attribute>
            <xsl:attribute name="subtype" select="current()/@type" />
            <xsl:for-each-group select="node()" group-starting-with="milestone">
                <xsl:if test="current()/@n">
                  <seg>
                      <xsl:sequence select="current()/@n"/>
                      <xsl:attribute name="type">textpart</xsl:attribute>
                      <xsl:attribute name="subtype">section</xsl:attribute>
                      <xsl:apply-templates select="current-group()[not(self::milestone)]"/>
                  </seg>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
