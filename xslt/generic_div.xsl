<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output indent="yes"></xsl:output>
    <xsl:param name="lang" select="'lat'"/>
    <xsl:variable name="namespace">
        <xsl:choose>
            <xsl:when test="$lang eq 'lat'">latinLit</xsl:when>
            <xsl:otherwise>greekLit</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
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
            
        </xsl:element>
    </xsl:template>
    <xsl:template match="revisionDesc">
        <xsl:element name="revisionDesc">
        <xsl:apply-templates select="node()|comment()" />
        <!--xsl:element name="revisionDesc">
            <xsl:element name="change">
                <xsl:attribute name="who" select="'gcrane'" />
                <xsl:attribute name="when" select="concat(.//date/text(), '-01-01')" />
                <xsl:value-of select=".//resp/text()"/>
            </xsl:element>
        </xsl:element-->
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="text">
        <xsl:element name="text">
            <xsl:attribute name="xml:lang"><xsl:value-of select="@lang"/></xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="body">
        <xsl:element name="body">
            <xsl:element name="div">
                <xsl:attribute name="xml:lang" select="$lang" />
                <xsl:attribute name="type" select="'edition'" />
                <xsl:attribute name="n" select="concat('urn:cts:', $namespace, ':',  replace(tokenize(base-uri(.), '/')[last()], '.xml', ''))" />
                
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
            <xsl:apply-templates select="refsDecl"/>
            <xsl:apply-templates select="comment()"/>
            <xsl:apply-templates select="node()[local-name(.) != 'refsDecl']"/>
        </encodingDesc>
    </xsl:template>
    <xsl:template match="language">
        <xsl:element name="language">
          <xsl:attribute name="ident" select="@id"/>
          <xsl:apply-templates select="node()|comment()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- this needs work before general use because if there is no who attribute we end up with invalid data 
    <xsl:template match="sp">
        <xsl:element name="sp">
          <xsl:attribute name="who" select="concat('#', @who)" />
          <xsl:apply-templates select="node()|comment()"/>
        </xsl:element>
    </xsl:template>
    -->
    
    <xsl:template match="div1|div2|div3">
        <xsl:element name="div">
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="subtype" select="@type"/>
            <xsl:attribute name="type">textpart</xsl:attribute>
            <xsl:apply-templates select="node()|comment()"/>
        </xsl:element>
    </xsl:template>
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
    <xsl:template match="castList">
        <listPerson>
            <xsl:apply-templates select="node()|comment()"/>
        </listPerson>
    </xsl:template>
    <xsl:template match="castItem">
        <person>
            <persName role="{roleDesc/text()}"><xsl:value-of select="role"/></persName>
        </person>
    </xsl:template>
    
</xsl:stylesheet>