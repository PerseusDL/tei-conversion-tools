<?xml version="1.0"?>
<!-- |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX| -->
<!-- |XX          Gabriel BODARD 2008-11-20              XX| -->
<!-- |XX      w/contribution from TE,HC,EM,RV          XX| -->
<!-- |XX         Last update 2010-06-14                         XX| -->
<!-- |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX| -->

<!--FURTHER UPDATE 
  2013-12-05 Pietro Liuzzo 
  2014-02-12 Pietro Liuzzo
  for BSR in EAGLE PROJECT
  
  - update link to epidoc schema DONE
  - remove rs:textType and create keyword/term with that value DONE
  - in url of resource it needs to be populated with this structure of url http://irt.kcl.ac.uk/irt2009/IRT045.html DONE
  - graphic needs to get a url in the structure of the : http://images.cch.kcl.ac.uk/irt/liv/full/0068.jpg DONE
  - the statement of availability shall be added standard to each graphic DONE as by definition in Giovenco Alessandra email 5-02-2014
  - in availability add <licence/> DONE
  - from content of /TEI.2/teiHeader/profileDesc/textClass/keywords/term/geogName[@type='modernCountry']
                      create /TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/country/placeName[@type='modern'] DONE
                      
  - from content of /TEI.2/teiHeader/profileDesc/textClass/keywords/term/placeName[@type='modernFindspot']
                      create /TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/region/placeName[@type='modern'] DONE
                      
  - from content of /TEI.2/teiHeader/profileDesc/textClass/keywords/term/geogName[@type='ancientRegion']
                      create /TEI/teiHeader/fileDesc/sourceDesc/msDesc/history/origin/origPlace/placeName[@type='provinceItalicRegion'] DONE
                      
  - <ref type="inscription">62</ref> must become something with an explicit uri link to that inscription DONE
  
  - in orgi date fix the criteria so that it does not go in the attribute but remains as text DONE
  
  - from content of /TEI.2/text/body/div/p/rs/placeName/@type[ancientFindspot]
                       create /TEI/teiHeader/fileDesc/sourceDesc/msDesc/history/origin/origPlace/placeName DONE
                       
  -from content of /TEI.2/text/body/div/p/rs/@type[lastLocation]
                        create /TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/settlement/placeName DONE
                       
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <!-- |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX| -->
  <!-- |XX          copy all existing elements                     XX| -->
  <!-- |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX| -->
 
  <xsl:template match="*">
    <xsl:element name="{local-name()}">
      <xsl:copy-of
        select="@*[not(local-name()=('id','lang','default','org','sample','part','full','cert','status','anchored','degree','type'))]"/>
      <xsl:if test="@id">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@lang">
        <xsl:attribute name="xml:lang">
          <xsl:value-of select="@lang"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@cert='low'">
        <xsl:copy-of select="@cert"/>
      </xsl:if>
      <xsl:if test="number(@degree)">
        <xsl:copy-of select="@degree"/>
      </xsl:if>
      <xsl:if test="@type">
        <xsl:attribute name="type">
          <xsl:value-of select="translate(@type,' +','-_')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@part != 'N'">
        <xsl:copy-of select="@part"/>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX| -->
  <!-- |XX                   copy all comments                       XX| -->
  <!-- |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX| -->

  <xsl:template match="//comment()">
    <xsl:comment>
      <xsl:value-of select="."/>
    </xsl:comment>
  </xsl:template>

  <!-- |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX| -->
  <!-- |XX                           EXCEPTIONS                     XX| -->
  <!-- |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX| -->

  <xsl:template match="TEI.2">
    <xsl:processing-instruction name="oxygen ">
      RNGSchema="http://www.stoa.org/epidoc/schema/latest/tei-epidoc.rng"
      type="xml"</xsl:processing-instruction>
    <!--
      RNGSchema="file:///C:/Documents and Settings/gbodard/Desktop/sourceforge/schema/tei-epidoc.rng"
      -->
    <!--<?xml-model
href="http://www.stoa.org/epidoc/schema/latest/tei-epidoc.rng" schematypens="http://relaxng.org/ns/structure/1.0"
?>-->
    <xsl:element name="TEI">
      <xsl:copy-of select="@*[not(local-name() = ('id','lang'))]"/>
      <xsl:attribute name="xml:id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <xsl:attribute name="xml:lang">
        <xsl:choose>
          <xsl:when test="@lang">
            <xsl:value-of select="@lang"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>en</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>



  <xsl:template match="add">
    <xsl:element name="{local-name()}">
      <xsl:copy-of select="@*[not(local-name() = 'place')]"/>
      <xsl:attribute name="place">
        <xsl:choose>
          <xsl:when test="@place = 'supralinear'">
            <xsl:text>above</xsl:text>
          </xsl:when>
          <xsl:when test="@place = 'infralinear'">
            <xsl:text>below</xsl:text>
          </xsl:when>
          <xsl:when test="@place = 'verso'">
            <xsl:text>overleaf</xsl:text>
          </xsl:when>
          <xsl:when test="@place">
            <xsl:value-of select="@place"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>unspecified</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="app[@type='previouslyread']">
    <xsl:element name="supplied">
      <xsl:attribute name="reason">
        <xsl:text>undefined</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="evidence">
        <xsl:text>previous-editor</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="lem/node()"/>
    </xsl:element>
  </xsl:template>
    
  <xsl:template match="certainty"/>
  <!--STRIPPING CERTAINTY ELEMENTS BECAUSE IN PRACTICE ALL FOLLOW GAP OR SPACE-->

  <xsl:template match="date">
    <xsl:element name="{local-name()}">
      <xsl:copy-of select="@*[not(local-name()=('precision','exact','cert','value','dur'))]"/>
      <xsl:if test="@cert='low'">
        <xsl:copy-of select="@cert"/>
      </xsl:if>
      <xsl:if test="@dur">
        <xsl:attribute name="when-iso">
          <xsl:value-of select="@dur"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@exact='none'">
          <xsl:attribute name="precision">
            <xsl:text>low</xsl:text>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@precision='circa'">
          <xsl:attribute name="precision">
            <xsl:text>low</xsl:text>
          </xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="@value">
        <xsl:attribute name="when">
          <xsl:value-of select="@value"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:if test="@exact=('notAfter','notBefore')">
        <xsl:element name="precision">
          <xsl:attribute name="match">
            <xsl:text>../</xsl:text>
            <xsl:choose>
              <xsl:when test="@exact='notBefore'">
                <xsl:text>@notAfter</xsl:text>
              </xsl:when>
              <xsl:when test="@exact='notAfter'">
                <xsl:text>@notBefore</xsl:text>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>
        </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="div[@type='description']"/>
  <xsl:template match="div[@type='history'][@subtype='locations']"/>
  <xsl:template match="div[@type='history'][@subtype='text-constituted-from']"/>
  
  
  <xsl:template match="profileDesc">
  <xsl:element name="profileDesc"> 
      <xsl:element name="langUsage">
        <xsl:for-each select="/TEI.2/teiHeader/profileDesc/langUsage/language">
          <xsl:element name="language">
          <xsl:attribute name="ident">
            <xsl:value-of select="@id"/>
          </xsl:attribute>
          <xsl:value-of select="."/>
        </xsl:element></xsl:for-each>
      </xsl:element>
    <xsl:element name="textClass">
      <xsl:element name="keywords">  
       <xsl:element name="term">
         <xsl:value-of select="..//preceding::rs[@type='textType']"/>
   </xsl:element> 
      </xsl:element>
    </xsl:element>  
  </xsl:element>
  </xsl:template>
  

  
  
  <xsl:template match="div[@type=('edition','translation')]">
    <xsl:element name="{local-name()}">
      <xsl:copy-of
        select="@*[not(local-name()=('lang','default','org','sample','part','full','status','anchored'))]"/>
      <xsl:if test="@lang">
        <xsl:attribute name="xml:lang">
          <xsl:value-of select="@lang"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="xml:space">
        <xsl:text>preserve</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="encodingDesc">
    <xsl:element name="{local-name()}">
      <xsl:element name="p">
        <xsl:text>Marked-up according to the EpiDoc Guidelines version 8</xsl:text>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="teiHeader">
    <xsl:element name="teiHeader">
      
      <xsl:apply-templates/>
      
    </xsl:element>
    <xsl:element name="facsimile">
      
      
      <xsl:for-each select="/TEI.2/text/body/div/p/figure">
          <xsl:element name="graphic">
            <xsl:attribute name="n">
              <xsl:value-of select="@href"/>
            </xsl:attribute>
            <xsl:attribute name="url">
              <xsl:text>http://images.cch.kcl.ac.uk/irt/liv/full/</xsl:text><xsl:value-of select="@href"/><xsl:text>.jpg</xsl:text>
            </xsl:attribute>
            <xsl:element name="desc">
              <xsl:value-of select="."/>
            <xsl:element name="ref">
              <xsl:attribute name="type">licence</xsl:attribute>
              <!--        
              BSR - CC-By-SA 
              SOPR  CC-By-NC-ND
              -->
              <xsl:attribute name="target">
<xsl:choose>
  <xsl:when test="figDesc[contains(.,'Sopr')]">http://www.europeana.eu/rights/rr-f/</xsl:when>
  <xsl:otherwise>http://creativecommons.org/licenses/by-sa/3.0/</xsl:otherwise>
</xsl:choose>
                </xsl:attribute>
              <xsl:choose>
                <xsl:when test="figDesc[contains(.,'Sopr')]"><xsl:text>Rights Reserved – Free Access from The British School at Rome</xsl:text></xsl:when>
                <xsl:otherwise><xsl:text>The British School at Rome: CC-By-SA</xsl:text></xsl:otherwise>
              </xsl:choose>
              <!--  <xsl:text></xsl:text>
                <xsl:text></xsl:text>-->
            </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
    </xsl:element>
    </xsl:template>
  <xsl:template match="div[@type='figure']"/>
  <xsl:template match="gap">
    <xsl:element name="{local-name()}">
      <xsl:copy-of select="@reason"/>
      <xsl:choose>
        <xsl:when test="@extent and @extentmax">
          <xsl:attribute name="atLeast">
            <xsl:value-of select="@extent"/>
          </xsl:attribute>
          <xsl:attribute name="atMost">
            <xsl:value-of select="@extentmax"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="number(@extent)">
          <xsl:attribute name="quantity">
            <xsl:value-of select="@extent"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="not(number(@extent))">
          <xsl:copy-of select="@extent"/>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="@unit">
        <xsl:copy-of select="@unit"/>
      </xsl:if>
      <xsl:if test="@precision='circa'">
        <xsl:attribute name="precision">
          <xsl:text>low</xsl:text>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@desc">
        <xsl:element name="desc">
          <xsl:value-of select="@desc"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="@id and following-sibling::certainty">
        <xsl:element name="certainty">
          <xsl:attribute name="match">
            <xsl:text>..</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="locus">
            <xsl:text>name</xsl:text>
          </xsl:attribute>
        </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="keywords">
    <xsl:element name="{local-name()}">
    
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!--<xsl:template match="language">
    
  </xsl:template>
-->
  <xsl:template match="lb[@type='worddiv']">
    <xsl:element name="lb">
      <xsl:copy-of select="@*[not(local-name() = 'type')]"/>
      <xsl:attribute name="break">
        <xsl:text>no</xsl:text>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="measure">
    <xsl:choose>
      <xsl:when test="@dim=('height','width','depth')">
        <xsl:element name="{@dim}">
          <xsl:copy-of select="@*[not(local-name()=('type','dim','precision','value','from','to'))]"/>
          <xsl:if test="@precision='circa'">
            <xsl:attribute name="precision">
              <xsl:text>low</xsl:text>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@value">
            <xsl:attribute name="quantity">
              <xsl:value-of select="@value"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@from">
            <xsl:attribute name="atLeast">
              <xsl:value-of select="@from"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@to">
            <xsl:attribute name="atMost">
              <xsl:value-of select="@to"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="dim">
          <xsl:copy-of select="@*[not(local-name()=('type','dim','precision','from','to'))]"/>
          <xsl:attribute name="type">
            <xsl:value-of select="@dim"/>
          </xsl:attribute>
          <xsl:if test="@precision='circa'">
            <xsl:attribute name="precision">
              <xsl:text>low</xsl:text>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@from">
            <xsl:attribute name="atLeast">
              <xsl:value-of select="@from"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@to">
            <xsl:attribute name="atMost">
              <xsl:value-of select="@to"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="persName|name|placeName|geogName">
    <xsl:element name="{local-name()}">
      <xsl:copy-of select="@*[not(local-name() = ('reg','full','cert'))]"/>
      <xsl:if test="@cert='low'">
        <xsl:copy-of select="@cert"/>
      </xsl:if>
      <xsl:if test="@reg">
        <xsl:attribute name="nymRef">
          <!--<xsl:value-of select="local-name()"/>
          <xsl:text>AL#</xsl:text>-->
          <xsl:value-of select="@reg"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="publicationStmt">
    <xsl:element name="{local-name()}">
      <xsl:element name="authority">
        <xsl:text>Centre for Computing in the Humanities, King's College London</xsl:text>
      </xsl:element>
      <xsl:element name="idno">
        <xsl:attribute name="type">
          <xsl:text>URI</xsl:text>
        </xsl:attribute>
        <xsl:text>http://irt.kcl.ac.uk/irt2009/</xsl:text><xsl:value-of select="ancestor::TEI.2/@id"/><xsl:text>.html</xsl:text>
      </xsl:element>
      <xsl:if test="starts-with(//titleStmt/title,'JMR:')">
        <xsl:for-each select="tokenize(//titleStmt/title,'; ')">
          <xsl:choose>
            <xsl:when test="starts-with(.,'JMR')">
              <xsl:element name="idno">
                <xsl:attribute name="type">
                  <xsl:text>JMR</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="substring-after(.,'JMR: ')"/>
              </xsl:element>
            </xsl:when>
            <xsl:when test="starts-with(.,'Excel')">
              <xsl:element name="idno">
                <xsl:attribute name="type">
                  <xsl:text>Excel</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="substring-after(.,'Excel: ')"/>
              </xsl:element>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:if>
      <xsl:element name="availability">
<xsl:element name="licence">
  <xsl:apply-templates select="p"/>
</xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="revisionDesc">
    <xsl:element name="{local-name()}">
      <xsl:element name="change">
        <xsl:attribute name="when">
          <xsl:value-of select="substring(string(current-date()),1,10)"/>
        </xsl:attribute>
        <xsl:attribute name="who">
          <xsl:text>PML</xsl:text>
        </xsl:attribute>
        <xsl:text>Converted from TEI P4 (EpiDoc DTD v. 6) to P5 (EpiDoc RNG schema v. 8), checked conformance to EALGE Metadata Model, added licence statements to figures and full URLs.</xsl:text>
      </xsl:element>
      <xsl:for-each select="change">
        <xsl:element name="{local-name()}">
          <xsl:attribute name="when">
            <xsl:choose>
              <xsl:when test="contains(date, '.')">
                <xsl:value-of select="substring(date,7,4)"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="substring(date,4,2)"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="substring(date,1,2)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="date"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:attribute name="who">
            <xsl:value-of select="normalize-space(respStmt)"/>
          </xsl:attribute>
          <xsl:value-of select="normalize-space(item)"/>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
   
  <xsl:template match="rs">
    <xsl:choose>
      <xsl:when test="@type='dimensions'">
        <xsl:element name="dimensions">
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="@type='material'">
        <xsl:element name="material">
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{local-name()}">
          <xsl:copy-of select="@*[not(local-name() = ('reg','full','cert'))]"/>
          <xsl:if test="not(@type)">
            <xsl:attribute name="type">
              <xsl:text>RS-NEEDS-TYPE</xsl:text>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@reg">
            <xsl:attribute name="key">
              <!--<xsl:value-of select="@type"/>
              <xsl:text>AL#</xsl:text>-->
              <xsl:value-of select="@reg"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates/>
          <xsl:if test="@cert='low'">
            <xsl:element name="certainty">
              <xsl:attribute name="match">
                <xsl:text>..</xsl:text>
              </xsl:attribute>
              <xsl:attribute name="locus">
                <xsl:text>value</xsl:text>
              </xsl:attribute>
            </xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="seg">
    <xsl:choose>
      <xsl:when test="@cert='low'">
        <xsl:apply-templates/>
        <xsl:element name="certainty">
          <xsl:attribute name="match">
            <xsl:text>..</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="locus">
            <xsl:text>value</xsl:text>
          </xsl:attribute>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{local-name()}">
          <xsl:copy-of select="@*[not(local-name() = ('cert','part'))]"/>
          <xsl:if test="@part != 'N'">
            <xsl:copy-of select="@part"/>
          </xsl:if>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="sic[not(ancestor::choice)]">
    <xsl:element name="surplus">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="sourceDesc">
    <xsl:element name="{local-name()}">
      <xsl:for-each select=".//bibl">
        <xsl:apply-templates select="self::bibl"/>
      </xsl:for-each>
      <xsl:element name="msDesc">
        <xsl:element name="msIdentifier">
          <xsl:if test="//rs[@type='invNo']">
            <xsl:element name="idno">
              <xsl:attribute name="type">
                <xsl:text>invNo</xsl:text>
              </xsl:attribute>
              <xsl:value-of select="//rs[@type='invNo'][1]"/>
            </xsl:element>
          </xsl:if>


        <xsl:if test="//rs[@type='invNo'][2]">
          <xsl:element name="msIdentifier">
            <xsl:attribute name="type">
              <xsl:text>invNo</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="//rs[@type='invNo'][2]"/>
          </xsl:element>
        </xsl:if>
        <xsl:for-each select="/TEI.2/teiHeader/profileDesc/textClass/keywords/term/geogName[@type='modernCountry']">
          <xsl:element name="country">
            <xsl:element name="placeName">
              <xsl:attribute name="type">modern</xsl:attribute>
              <xsl:value-of select="."/>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="/TEI.2/teiHeader/profileDesc/textClass/keywords/term/placeName[@type='modernFindspot'][@key]">
          <xsl:element name="region">
            <xsl:element name="placeName">
              <xsl:attribute name="type">modern</xsl:attribute>
              <xsl:attribute name="ref"><xsl:value-of select="@key"/></xsl:attribute>
              <xsl:value-of select="."/>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="/TEI.2/text/body/div/p/rs[@type='lastLocation']">
          <xsl:element name="settlement">
            <xsl:element name="placeName">
              <xsl:value-of select="."/>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
        </xsl:element>
        <xsl:element name="physDesc">
          <xsl:element name="objectDesc">
            <xsl:element name="supportDesc">
              <xsl:element name="support">
                <xsl:element name="objectType">
                  <xsl:value-of select="/TEI.2/text/body/div/p/rs[@type='objectType']"/>
                </xsl:element>
                <xsl:apply-templates select="//div[@type='description'][@subtype='monument']/p"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="layoutDesc">
              <xsl:for-each select="//div[@type='description'][@subtype='text']/p">
                <xsl:element name="layout">
                  <xsl:apply-templates/>
                </xsl:element>
              </xsl:for-each>
            </xsl:element>
          </xsl:element>
          <xsl:element name="handDesc">
            <xsl:for-each select="//div[@type='description'][@subtype='letters']/p">
              <xsl:element name="handNote">
                <xsl:apply-templates/>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
        <xsl:element name="history">
          <xsl:element name="origin">
            <xsl:element name="p">
              <xsl:value-of select="//TEI.2/text/body/div[@type='history'][@subtype='text-constituted-from']"/>
            </xsl:element>
            <xsl:element name="origPlace">
  <!--            from content of /TEI.2/text/body/div/p/rs/placeName/@type[ancientFindspot]
              create /TEI/teiHeader/fileDesc/sourceDesc/msDesc/history/origin/origPlace/placeName-->
              <xsl:for-each select="/TEI.2/text/body/div/p/rs/placeName[@type='ancientFindspot']">
                <xsl:element name="placeName">
                  <xsl:value-of select="."/><xsl:text>: </xsl:text>
                  <xsl:for-each select="//following-sibling::rs[@type='monuList']">
                    <xsl:value-of select="."/>
                  </xsl:for-each>
                </xsl:element>
              </xsl:for-each>
              <xsl:for-each select="/TEI.2/teiHeader/profileDesc/textClass/keywords/term/geogName[@type='ancientRegion']">
                  <xsl:element name="placeName">
                    <xsl:attribute name="type">provinceItalicRegion</xsl:attribute>
                    <xsl:value-of select="."/>
                  </xsl:element>
              </xsl:for-each>
            </xsl:element>
            <xsl:element name="origDate">
              <xsl:for-each select="//div[@type='description'][@subtype='date']//date[1]">
                <xsl:copy-of
                  select="@*[not(local-name()=('precision','exact','cert','type','value'))]"/>
                <xsl:if test="@cert='low'">
                  <xsl:copy-of select="@cert"/>
                </xsl:if>
                <xsl:choose>
                  <xsl:when test="@value">
                    <xsl:attribute name="when">
                      <xsl:value-of select="@value"/>
                    </xsl:attribute>
                  </xsl:when>
                  <xsl:when test="@exact='none'">
                    <xsl:attribute name="precision">
                      <xsl:text>low</xsl:text>
                    </xsl:attribute>
                  </xsl:when>
                  <xsl:when test="@precision='circa'">
                    <xsl:attribute name="precision">
                      <xsl:text>low</xsl:text>
                    </xsl:attribute>
                  </xsl:when>
                </xsl:choose>
                </xsl:for-each>
              <xsl:for-each select="//div[@type='description'][@subtype='date']/p">
                <xsl:value-of select="normalize-space(.)"/>
              </xsl:for-each>
            </xsl:element>
            <xsl:if
              test="//div[@type='description'][@subtype='date']//date/@exact=('notAfter','notBefore')">
              <xsl:element name="precision">
                <xsl:attribute name="match">
                  <xsl:text>//origDate/</xsl:text>
                  <xsl:choose>
                    <xsl:when test="@exact='notBefore'">
                      <xsl:text>@notAfter</xsl:text>
                    </xsl:when>
                    <xsl:when test="@exact='notAfter'">
                      <xsl:text>@notBefore</xsl:text>
                    </xsl:when>
                  </xsl:choose>
                </xsl:attribute>
              </xsl:element>
            </xsl:if>
          </xsl:element>
          <xsl:element name="provenance">
            <xsl:element name="listEvent">
              <xsl:element name="event">
                <xsl:attribute name="type">
                  <xsl:text>found</xsl:text>
                </xsl:attribute>
                <xsl:element name="p">
                  <xsl:apply-templates select="//rs[@type='found']/node()"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="event">
                <xsl:attribute name="type">
                  <xsl:text>observed</xsl:text>
                </xsl:attribute>
                <xsl:element name="p">
                  <xsl:apply-templates select="//rs[@type='lastLocation']/node()"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match="rs[@type='criteria']"/>
  <xsl:template match="event[@type='found']"/>
  <xsl:template match="term"/>
  
  <xsl:template match="space">
    <xsl:element name="{local-name()}">
      <xsl:choose>
        <xsl:when test="number(@extent)">
          <xsl:attribute name="quantity">
            <xsl:value-of select="@extent"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="not(number(@extent))">
          <xsl:copy-of select="@extent"/>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="@unit">
        <xsl:copy-of select="@unit"/>
      </xsl:if>
      <xsl:if test="@precision='circa'">
        <xsl:attribute name="precision">
          <xsl:text>low</xsl:text>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@id and following-sibling::certainty">
        <xsl:element name="certainty">
          <xsl:attribute name="match">
            <xsl:text>..</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="locus">
            <xsl:text>name</xsl:text>
          </xsl:attribute>
        </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="unclear">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="xptr">
    <xsl:element name="ptr">
      <xsl:copy-of select="@*[not(local-name()=('targOrder','evaluate','to','from'))]"/>
      <xsl:if test="@type">
        <xsl:attribute name="type">
          <xsl:value-of select="translate(@type,' ','-')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@from">
        <xsl:attribute name="target">
          <xsl:value-of select="@from"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="xref">
    <xsl:element name="ref">
      <xsl:copy-of select="@*[not(local-name()=('targOrder','evaluate','to','from','href'))]"/>
      <xsl:if test="@type">
        <xsl:attribute name="type">
          <xsl:value-of select="translate(@type,' ','-')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@href">
        <xsl:attribute name="target">
          <xsl:value-of select="@href"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@type='inscription'">
          <xsl:attribute name="target">
            <xsl:text>http://irt.kcl.ac.uk/irt2009/IRT</xsl:text><xsl:value-of select="format-number(number(.), '000')"/><xsl:text>.html</xsl:text>
          </xsl:attribute>
        
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  
</xsl:stylesheet>
