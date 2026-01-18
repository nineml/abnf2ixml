<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:rddl="http://www.rddl.org/"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="3.0">

<xsl:import href="https://cdn.docbook.org/release/xsltng/current/xslt/print.xsl"/>

<xsl:param name="presentation-mode" select="'false'"/>
<xsl:param name="verbatim-numbered-elements" select="''"/>
<xsl:param name="component-numbers" select="'false'"/>
<xsl:param name="section-numbers" select="'false'"/>

<xsl:template match="*" mode="m:html-head-links">
  <xsl:next-match/>
  <link rel="stylesheet" href="css/print.css"/>
</xsl:template>

<xsl:variable xmlns:tmp="http://docbook.org/ns/docbook/templates"
              name="v:templates" as="document-node()">
  <xsl:document>
    <db:book><header></header></db:book>
    <db:article context="empty(parent::*) or parent::db:book">
      <header>
        <tmp:apply-templates select="db:title">
          <h1><tmp:content/></h1>
        </tmp:apply-templates>
        <tmp:apply-templates select="db:subtitle">
          <h2><tmp:content/></h2>
        </tmp:apply-templates>
        <tmp:apply-templates select="db:authorgroup">
          <div class="authorgroup">
            <tmp:apply-templates select="db:author">
              <div class="author">
                <h3><tmp:content/></h3>
              </div>
            </tmp:apply-templates>
          </div>
        </tmp:apply-templates>
        <tmp:apply-templates select="db:author">
          <div class="author">
            <h3><tmp:content/></h3>
            <tmp:apply-templates select="db:affiliation/db:orgname">
              <h4><tmp:content/></h4>
            </tmp:apply-templates>
          </div>
        </tmp:apply-templates>
        <tmp:apply-templates select="db:pubdate">
          <p class="pubdate"><tmp:content/></p>
        </tmp:apply-templates>

        <tmp:apply-templates select="db:confgroup">
          <div class="confgroup">
            <tmp:apply-templates select="db:conftitle">
              <span><tmp:content/></span>
            </tmp:apply-templates>
            <span>, </span>
            <tmp:apply-templates select="db:confdates">
              <span><tmp:content/></span>
            </tmp:apply-templates>
          </div>
        </tmp:apply-templates>

        <tmp:apply-templates select="db:copyright"/>
        <tmp:apply-templates select="db:legalnotice"/>
        <tmp:apply-templates select="db:abstract"/>
        <p>See also <a href="https://github.com/nineml/abnf2ixml/">https://github.com/nineml/abnf2ixml/</a></p>
      </header>
    </db:article>
  </xsl:document>
</xsl:variable>

<xsl:template match="db:conftitle|db:confdates" mode="m:docbook">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="db:bibliography" mode="m:docbook">
  <xsl:variable name="gi" select="'section'"/>
  <xsl:element name="{$gi}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:generate-titlepage"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="processing-instruction('br')" mode="m:docbook">
  <br>
    <xsl:if test=". != ''">
      <xsl:attribute name="class" select="."/>
    </xsl:if>
  </br>
</xsl:template>

</xsl:stylesheet>
