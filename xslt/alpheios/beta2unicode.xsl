<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="beta-uni-util.xsl"/>

<!--
  Copyright 2008-2009 Cantus Foundation
  http://alpheios.net

  This file is part of Alpheios.
 
  Alpheios is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
 
  Alpheios is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
 
  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 -->

  <!--
    Test whether text is in betacode
    Parameters:
      $a_in         string/node to be tested
    Output:
      1 if encoded in betacode, else 0
    (Note: Boolean return value does not seem to work
    reliably, perhaps because of recursion.)
  -->
  <xsl:template name="is-beta">
    <xsl:param name="a_in"/>

    <xsl:choose>
      <!-- if xml:lang says betacode, so be it -->
      <xsl:when test="lang('grc-x-beta')">
        <xsl:value-of select="1"/>
      </xsl:when>

      <!-- if no input, can't be betacode -->
      <xsl:when test="string-length($a_in) = 0">
        <xsl:value-of select="0"/>
      </xsl:when>

      <!-- otherwise, check the characters in input -->
      <xsl:otherwise>
        <xsl:variable name="head" select="substring($a_in, 1, 1)"/>

        <xsl:choose>
          <!-- if betacode base letter, assume it's betacode -->
          <xsl:when
            test="contains($s_betaUppers, $head) or
                  contains($s_betaLowers, $head)">
            <xsl:value-of select="1"/>
          </xsl:when>

          <xsl:otherwise>
            <!-- look up unicode in table -->
            <xsl:variable name="beta">
              <xsl:apply-templates select="$s_betaUniTable" mode="u2b">
                <xsl:with-param name="a_key" select="$head"/>
              </xsl:apply-templates>
            </xsl:variable>

            <xsl:choose>
              <!-- if found in unicode table, it's not betacode -->
              <xsl:when test="string-length($beta) > 0">
                <xsl:value-of select="0"/>
              </xsl:when>

              <!-- otherwise, skip letter and check remainder of string -->
              <xsl:otherwise>
                <xsl:call-template name="is-beta">
                  <xsl:with-param name="a_in" select="substring($a_in, 2)"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Convert Greek betacode to Unicode
    Parameters:
      $a_in           betacode input string to be converted
      $a_pending      character waiting to be output
      $a_state        diacritics associated with pending character
      $a_precomposed  whether to put out precomposed or decomposed Unicode
      $a_partial      whether this is a partial word
                      (If true, do not use final sigma for last letter)

    Output:
      $a_in transformed to equivalent Unicode

    The characters in the state string are maintained in a canonical order,
    which allows the lookup table to contain a single entry for each
    combination of base character and diacritics.  The diacritics may appear
    in any order in the input.

    Diacritics associated with (either preceding or following) a base
    character are accumulated until either a non-diacritic character or end
    of input are encountered, at which point the pending character is output.
  -->
  <xsl:template name="beta-to-uni">
    <xsl:param name="a_in"/>
    <xsl:param name="a_pending" select="''"/>
    <xsl:param name="a_state" select="''"/>
    <xsl:param name="a_precomposed" select="true()"/>
    <xsl:param name="a_partial" select="false()"/>

    <xsl:variable name="head" select="substring($a_in, 1, 1)"/>

    <xsl:choose>
      <!-- if no more input -->
      <xsl:when test="string-length($a_in) = 0">
        <!-- output last pending char -->
        <xsl:choose>
          <!-- final sigma: S with no state -->
          <xsl:when
            test="(($a_pending = 's') or ($a_pending = 'S')) and
                  not($a_partial) and (string-length($a_state) = 0)">
            <xsl:call-template name="output-uni-char">
              <xsl:with-param name="a_char" select="$a_pending"/>
              <xsl:with-param name="a_state" select="'2'"/>
              <xsl:with-param name="a_precomposed" select="$a_precomposed"/>
            </xsl:call-template>
          </xsl:when>

          <xsl:otherwise>
            <xsl:call-template name="output-uni-char">
              <xsl:with-param name="a_char" select="$a_pending"/>
              <xsl:with-param name="a_state" select="$a_state"/>
              <xsl:with-param name="a_precomposed" select="$a_precomposed"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <!-- if input starts with "*" -->
      <xsl:when test="$head = '*'">
        <!-- output pending char -->
        <xsl:call-template name="output-uni-char">
          <xsl:with-param name="a_char" select="$a_pending"/>
          <xsl:with-param name="a_state" select="$a_state"/>
          <xsl:with-param name="a_precomposed" select="$a_precomposed"/>
        </xsl:call-template>

        <!-- recurse, capitalizing next char, erasing any saved state -->
        <xsl:call-template name="beta-to-uni">
          <xsl:with-param name="a_in" select="substring($a_in, 2)"/>
          <xsl:with-param name="a_state" select="'*'"/>
          <xsl:with-param name="a_pending" select="''"/>
          <xsl:with-param name="a_precomposed" select="$a_precomposed"/>
          <xsl:with-param name="a_partial" select="$a_partial"/>
        </xsl:call-template>
      </xsl:when>

      <!-- if input starts with diacritic -->
      <xsl:when test="contains($s_betaDiacritics, $head)">
        <!-- update state with new character -->
        <xsl:variable name="newstate">
          <xsl:call-template name="insert-diacritic">
            <xsl:with-param name="a_string" select="$a_state"/>
            <xsl:with-param name="a_char" select="$head"/>
          </xsl:call-template>
        </xsl:variable>

        <!-- recurse with updated state -->
        <xsl:call-template name="beta-to-uni">
          <xsl:with-param name="a_in" select="substring($a_in, 2)"/>
          <xsl:with-param name="a_state" select="$newstate"/>
          <xsl:with-param name="a_pending" select="$a_pending"/>
          <xsl:with-param name="a_precomposed" select="$a_precomposed"/>
          <xsl:with-param name="a_partial" select="$a_partial"/>
        </xsl:call-template>
      </xsl:when>

      <!-- if not special char -->
      <xsl:otherwise>
        <!-- output pending char -->
        <xsl:choose>
          <!-- final sigma: S with no state followed by word break -->
          <xsl:when
            test="(($a_pending = 's') or ($a_pending = 'S')) and
                  (string-length($a_state) = 0) and
                  (contains($s_betaSeparators, $head) or
                   contains($s_betaSeparators2, $head))">
            <xsl:call-template name="output-uni-char">
              <xsl:with-param name="a_char" select="$a_pending"/>
              <xsl:with-param name="a_state" select="'2'"/>
              <xsl:with-param name="a_precomposed" select="$a_precomposed"/>
            </xsl:call-template>
          </xsl:when>

          <xsl:otherwise>
            <xsl:call-template name="output-uni-char">
              <xsl:with-param name="a_char" select="$a_pending"/>
              <xsl:with-param name="a_state" select="$a_state"/>
              <xsl:with-param name="a_precomposed" select="$a_precomposed"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>

        <!-- reset state if there was a pending character -->
        <xsl:variable name="newstate">
          <xsl:choose>
            <xsl:when test="$a_pending"/>
            <xsl:otherwise>
              <xsl:value-of select="$a_state"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <!-- recurse with head as pending char -->
        <xsl:call-template name="beta-to-uni">
          <xsl:with-param name="a_in" select="substring($a_in, 2)"/>
          <xsl:with-param name="a_state" select="$newstate"/>
          <xsl:with-param name="a_pending" select="$head"/>
          <xsl:with-param name="a_precomposed" select="$a_precomposed"/>
          <xsl:with-param name="a_partial" select="$a_partial"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Output a single character with diacritics
    Parameters:
      $a_char         character to be output
      $a_state        diacritics associated with character
      $a_precomposed  whether to put out precomposed or decomposed Unicode
  -->
  <xsl:template name="output-uni-char">
    <xsl:param name="a_char"/>
    <xsl:param name="a_state"/>
    <xsl:param name="a_precomposed"/>

    <xsl:choose>
      <!-- if no character pending -->
      <xsl:when test="string-length($a_char) = 0">
        <!-- if we have state and we're not processing a capital -->
        <xsl:if
          test="(string-length($a_state) > 0) and
                      (substring($a_state, 1, 1) != '*')">
          <!-- output just the state -->
          <!-- here precomposed=true means don't make it combining -->
          <xsl:apply-templates select="$s_betaUniTable" mode="b2u">
            <xsl:with-param name="a_key" select="$a_state"/>
            <xsl:with-param name="a_precomposed" select="true()"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:when>

      <!-- if character is pending -->
      <xsl:otherwise>
        <!-- translate to lower and back -->
        <xsl:variable name="lowerchar"
          select="translate($a_char, $s_betaUppers, $s_betaLowers)"/>
        <xsl:variable name="upperchar"
          select="translate($a_char, $s_betaLowers, $s_betaUppers)"/>
        <xsl:choose>
          <!-- if upper != lower, we have a letter -->
          <xsl:when test="$lowerchar != $upperchar">
            <!-- use letter+state as key into table -->
            <xsl:apply-templates select="$s_betaUniTable" mode="b2u">
              <xsl:with-param name="a_key"
                              select="concat($lowerchar, $a_state)"/>
              <xsl:with-param name="a_precomposed" select="$a_precomposed"/>
            </xsl:apply-templates>
          </xsl:when>

          <!-- if upper = lower, we have a non-letter -->
          <xsl:otherwise>
            <!-- output character, if any, then use state as key into table -->
            <!-- this handles the case of isolated diacritics -->
            <xsl:value-of select="$a_char"/>
            <xsl:if test="string-length($a_state) > 0">
              <xsl:apply-templates select="$s_betaUniTable" mode="b2u">
                <xsl:with-param name="a_key" select="$a_state"/>
                <xsl:with-param name="a_precomposed" select="$a_precomposed"/>
              </xsl:apply-templates>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
