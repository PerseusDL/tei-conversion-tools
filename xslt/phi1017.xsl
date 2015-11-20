<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output indent="yes"></xsl:output>
    <xsl:template match="node()|@*|comment()">
        <!-- Copy the current node -->
        <xsl:copy>
            <!-- Including any child nodes it has and any attributes -->
            <xsl:apply-templates select="node()|@*|comment()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="sourceDesc">
        <xsl:element name="sourceDesc">
            <xsl:apply-templates select="node()|@*|comment()" />
            <xsl:element name="listPerson">
                <xsl:for-each select="//role">
                    <xsl:element name="person">
                        <xsl:attribute name="xml:id" select="current()/@id"/>
                        <xsl:element name="persName" >
                            <xsl:attribute name="xml:lang" select="'eng'"/>
                            <xsl:value-of select="current()/text()"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template match="revisionDesc">
        <xsl:element name="revisionDesc">
            <xsl:element name="change">
                <xsl:attribute name="who" select="'gcrane'" />
                <xsl:attribute name="when" select="concat(.//date/text(), '-01-01')" />
                <xsl:value-of select=".//resp/text()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template match="body">
        <xsl:element name="body">
            <xsl:element name="div">
                <xsl:attribute name="xml:lang" select="'lat'" />
                <xsl:attribute name="type" select="'edition'" />
                <xsl:attribute name="n" select="concat('urn:cts:latinLit:',  replace(tokenize(base-uri(.), '/')[last()], '.xml', ''))" />
                
                <xsl:apply-templates select="node()|comment()" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template match="encodingDesc">
        <encodingDesc>
            <refsDecl n="CTS">
                <cRefPattern n="line"
                    matchPattern="(\w+)"
                    replacementPattern="#xpath(/tei:TEI/tei:text/tei:body/tei:div//tei:l[@n='$1'])">
                    <p>This pointer pattern extracts line</p>
                </cRefPattern>
            </refsDecl>
            <refsDecl n="TEI.2">
                <refState unit="card"/>
            </refsDecl>
        </encodingDesc>
    </xsl:template>
    <xsl:template match="language">
        <xsl:element name="language">
          <xsl:attribute name="ident" select="@id"/>
          <xsl:apply-templates select="node()|comment()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="sp">
        <xsl:element name="sp">
          <xsl:attribute name="who" select="concat('#', @who)" />
          <xsl:apply-templates select="node()|comment()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="castList"></xsl:template>
    <xsl:template match="pb">
        <xsl:element name="pb">
            <xsl:attribute name="n" select="@id" />
        </xsl:element>
    </xsl:template>
    <xsl:template match="gap">
        <xsl:element name="gap">
           <xsl:choose>
               <xsl:when test="parent::node()/text() = '*'">
                   <xsl:attribute name="reason" select="'lost'" />
               </xsl:when>
               <xsl:otherwise>
                   <xsl:attribute name="reason" select="'omitted'" />
               </xsl:otherwise>
           </xsl:choose>
         <xsl:apply-templates select="node()|@*|comment()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="TEI.2">
        <xsl:element name="TEI">
            <xsl:apply-templates select="node()|@*|comment()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="teiHeader">
        <xsl:element name="teiHeader">
            <xsl:attribute name="type" select="'text'"/>
            <xsl:apply-templates select="node()|comment()"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>