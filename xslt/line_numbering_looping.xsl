<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:saxon="http://saxon.sf.net/"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!--
        This XSLT has been developed to complete the lines' number of existing and partially numbered texts. It completes

        ########################################
        #
        #        HOW TO USE
        #
        ########################################

        - Before running this XSLT, I highly advise to 
            - look at the text
            - number manually parts of the texts that have interchanged number (ie line ares numbered [5 - 8 - - 10], you should number it [5 6 8 9 10])
                > This part is extremely important !
        - Change the template "poemloop" so that the div that is targeted corresponds to your own situation (div2, div1, div, type="book", etc.)
        - Change potentially the saxon:threads="N" parameter to fit your computer power. If things do not work, remove threads
        - Run the XSL transformation as you usually do

        ########################################
        #
        #        Warning
        #
        ########################################

        This transformation takes for now a lot of time : it is basically re-running on each poem until everything is numbered by increasing the previous line number. If the previous is not numbered, then it will be in iteration n + 1. So there is a maximum of n+1 runs where n is the maximal amount of lines not numbered in one section.

        # Developer : Thibault Clérice, Leipzig Universitat
    -->

    <xsl:template match="*:l[not(@n) or (@n = 'NaN') or (@n = '')]">
        <xsl:variable name="container" select="./ancestor::*[@type='poem']" />
        <xsl:variable name="seq" select="$container//*:l" />
        <xsl:variable name="prev" select="preceding-sibling::*:l[position() = 1]"/>
        <xsl:message><xsl:value-of select="not(./@n = 'NaN') or not(./@n = '')"/></xsl:message>
        <xsl:message><xsl:copy-of select="$prev" /></xsl:message>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="@n and not(./@n = 'NaN' or ./@n = '')">
                    <xsl:attribute name="n" select="./@n"/>
                </xsl:when>
                <xsl:when test="count($prev) and $prev/@n">
                    <xsl:message><xsl:copy-of select="$prev" /></xsl:message>
                    <xsl:attribute name="n" select="number($prev/@n)+1"/>
                </xsl:when>
                <xsl:when test="count($prev) = 0">
                    <xsl:attribute name="n" select="1"/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="node()|comment()" />
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="./@*"/>
            <xsl:apply-templates select="node()|comment()" />
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy />
    </xsl:template>
    
    
    <xsl:template name="poemloop" match="*:div1[@type='poem' and count(.//*:l[not(@n) or (@n = 'NaN') or (@n = '')])]" saxon:threads="8">
        <xsl:call-template name="loop">
            <xsl:with-param name="doc" select="." />
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="loop">
        <xsl:param name="doc" />
        <xsl:variable name="document">
            <xsl:for-each select="($doc)">
                <xsl:copy >
                   <xsl:apply-templates select="@*" />
                   <xsl:apply-templates select="node()|comment()" />
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="count($document//*:l[not(@n) or (@n = 'NaN')])">
                <xsl:call-template name="loop">
                    <xsl:with-param name="doc" select="$document" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$document" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>