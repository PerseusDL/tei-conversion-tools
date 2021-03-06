<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="/">
        <xsl:for-each select="//document">
            <xsl:call-template name="document">
                <xsl:with-param name="e_decl" select="./path/text()" />
                <xsl:with-param name="doc" select="doc(./path/text())" />
                <xsl:with-param name="e_ref" select="./*:refsDecl" />
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="document">
        <xsl:param name="e_decl"/>
        <xsl:param name="e_ref"/>
        <xsl:param name="doc"/>
        
        <xsl:result-document method="xml" href="hre{normalize-space($e_decl)}">
            <xsl:call-template name="openDoc">
                <xsl:with-param name="e_decl" select="$e_decl" />
                <xsl:with-param name="e_ref" select="$e_ref" />
                <xsl:with-param name="doc" select="$doc" />
            </xsl:call-template>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="openDoc" >
        <xsl:param name="e_decl"/>
        <xsl:param name="e_ref"/>
        <xsl:param name="doc"/>
            <xsl:apply-templates select="$doc/*">
                <xsl:with-param name="e_ref" select="$e_ref" />
            </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*:encodingDesc" >
        <xsl:param name="e_ref"/>
        <xsl:copy>
            <xsl:copy-of select="$e_ref"/>    
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:param name="e_ref"/>
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="node()[not(name(.) = 'document')]|comment()">
        <xsl:param name="e_ref"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()|comment()">
                <xsl:with-param name="e_ref" select="$e_ref" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>