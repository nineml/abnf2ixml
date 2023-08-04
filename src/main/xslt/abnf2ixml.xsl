<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:cs="http://nineml.com/ns/coffeesacks"
                xmlns:f="https://nineml.org/ns/functions"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all"
                expand-text="yes"
                version="3.0">

<xsl:output method="xml" encoding="utf-8" indent="yes"/>
<xsl:strip-space elements="*"/>
<xsl:preserve-space elements="char-val"/>

<xsl:key name="definitions" match="rule" use="rulename"/>
<xsl:key name="uses" match="rulename[not(parent::rule)]" use="."/>

<xsl:param name="marks" select="()"/>

<xsl:variable name="parser" select="cs:load-grammar('marks.ixml')"/>

<xsl:variable name="marklist" as="element(marks)?"
              select="$marks ! $parser(unparsed-text(.))/*"/>

<xsl:variable name="marked" as="map(xs:string, xs:string)">
  <xsl:variable name="root" select="/"/>
  <xsl:map>
    <xsl:iterate select="$marklist/*">
      <xsl:param name="selected" select="()"/>

      <xsl:variable name="mark" select="@mark/string()"/>
      <xsl:variable name="elements" as="element()*">
        <xsl:choose>
          <xsl:when test="self::rule">
            <xsl:evaluate context-item="$root" as="element()*"
                          xpath="'/rulelist/rule[rulename='''||normalize-space(.)||''']'"/>
          </xsl:when>
          <xsl:when test="self::token">
            <!--<xsl:message select="string(.)"/>-->
            <xsl:evaluate context-item="$root" as="element()*"
                          xpath="string(.)"/>
          </xsl:when>
          <xsl:when test="self::renametoken">
            <!-- nop -->
          </xsl:when>
          <xsl:when test="self::rename">
            <!-- nop -->
          </xsl:when>
          <xsl:otherwise>
            <xsl:message select="'Unrecognized mark:', ."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:for-each select="$elements">
        <xsl:if test="not(generate-id(.) = $selected)">
          <xsl:map-entry key="generate-id(.)" select="$mark"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:next-iteration>
        <xsl:with-param name="selected" select="($selected, $elements ! generate-id(.))"/>
      </xsl:next-iteration>
    </xsl:iterate>
  </xsl:map>
</xsl:variable>

<xsl:variable name="renamed" as="map(xs:string, xs:string)">
  <xsl:variable name="root" select="/"/>
  <xsl:map>
    <xsl:iterate select="$marklist/*">
      <xsl:param name="selected" select="()"/>

      <xsl:variable name="rename" select="@name/string()"/>
      <xsl:variable name="elements" as="element()*">
        <xsl:choose>
          <xsl:when test="self::rule">
            <!-- nop -->
          </xsl:when>
          <xsl:when test="self::token">
            <!-- nop -->
          </xsl:when>
          <xsl:when test="self::renametoken">
            <!--<xsl:message select="string(.)"/>-->
            <xsl:evaluate context-item="$root" as="element()*"
                          xpath="string(.)"/>
          </xsl:when>
          <xsl:when test="self::rename">
            <!-- nop -->
          </xsl:when>
          <xsl:otherwise>
            <xsl:message select="'Unrecognized mark:', ."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:for-each select="$elements">
        <xsl:if test="not(generate-id(.) = $selected)">
          <xsl:map-entry key="generate-id(.)" select="$rename"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:next-iteration>
        <xsl:with-param name="selected" select="($selected, $elements ! generate-id(.))"/>
      </xsl:next-iteration>
    </xsl:iterate>
  </xsl:map>
</xsl:variable>

<xsl:variable name="core-rules" as="element()">
  <core-rules>
    <rule mark='-' name='ALPHA'>
      <alt>
        <inclusion>
          <member from='A' to='Z'/>
          <member from='a' to='z'/>
        </inclusion>
      </alt>
    </rule>
    <rule mark='-' name='BIT'>
      <alt>
        <literal string='0'/>
      </alt>
      <alt>
        <literal string='1'/>
      </alt>
    </rule>
    <rule mark='-' name='CR'>
      <alt>
        <literal tmark='-' hex='0D'/>
      </alt>
    </rule>
    <rule mark='-' name='CRLF'>
      <alt>
        <nonterminal name='CR'/>
        <nonterminal name='LF'/>
      </alt>
      <alt>
        <nonterminal name='LF'/>
      </alt>
    </rule>
    <rule mark='-' name='DIGIT'>
      <alt>
        <inclusion>
          <member from='0' to='9'/>
        </inclusion>
      </alt>
    </rule>
    <rule mark='-' name='DQUOTE'>
      <alt>
        <literal tmark='-' hex='22'/>
      </alt>
    </rule>
    <rule mark='-' name='HEXDIG'>
      <alt>
        <nonterminal name='DIGIT'/>
      </alt>
      <alt>
        <inclusion>
          <member from='A' to='F'/>
        </inclusion>
      </alt>
      <alt>
        <inclusion>
          <member from='a' to='f'/>
        </inclusion>
      </alt>
    </rule>
    <rule mark='-' name='HTAB'>
      <alt>
        <literal hex='09'/>
      </alt>
    </rule>
    <comment> horizontal tab </comment>
    <rule mark='-' name='LF'>
      <alt>
        <literal tmark='-' hex='0A'/>
      </alt>
    </rule>
    <rule mark='-' name='SP'>
      <alt>
        <literal hex='20'/>
      </alt>
    </rule>
    <rule mark='-' name='VCHAR'>
      <alt>
        <inclusion>
          <member from='#21' to='#7E'/>
        </inclusion>
      </alt>
    </rule>
    <rule mark='-' name='WSP'>
      <alt>
        <nonterminal name='SP'/>
      </alt>
      <alt>
        <nonterminal name='HTAB'/>
      </alt>
    </rule>
    <rule mark='-' name='CHAR'>
      <alt>
        <inclusion>
          <member from='#01' to='#7F'/>
        </inclusion>
      </alt>
    </rule>
    <rule mark='-' name='CTL'>
      <alt>
        <inclusion>
          <member from='#00' to='#1F'/>
          <literal hex='7F'/>
        </inclusion>
      </alt>
    </rule>
    <rule mark='-' name='LWSP'>
      <alt>
        <nonterminal name='CR'/>
        <nonterminal name='LF'/>
      </alt>
      <alt>
        <nonterminal name='LF'/>
      </alt>
    </rule>
    <rule name='LWSP'>
      <alt>
        <repeat0>
          <alts>
            <alt>
              <nonterminal name='WSP'/>
            </alt>
            <alt>
              <nonterminal name='CRLF'/>
              <nonterminal name='WSP'/>
            </alt>
          </alts>
        </repeat0>
      </alt>
    </rule>
    <rule mark='-' name='OCTET'>
      <alt>
        <inclusion>
          <member from='#00' to='#FF'/>
        </inclusion>
      </alt>
    </rule>
  </core-rules>
</xsl:variable>

<xsl:template match="rulelist">
  <xsl:variable name="rules" select="."/>
  <ixml>
    <prolog>
      <version string='1.1-nineml'/>
    </prolog>
    <xsl:apply-templates/>
    <xsl:for-each select="$core-rules/rule">
      <xsl:variable name="name" select="@name/string()"/>
      <xsl:if test="empty(key('definitions', $name, $rules))
                    and exists(key('uses', $name, $rules))">
        <xsl:sequence select="."/>
      </xsl:if>
    </xsl:for-each>
  </ixml>
</xsl:template>

<xsl:template match="rule">
  <xsl:variable name="name" select="rulename/string()"/>
  <rule name='{$name}'>
    <xsl:sequence select="f:mark(.)"/>
    <xsl:if test="$marklist/rename[@name = $name]">
      <xsl:attribute name="rename" select="normalize-space($marklist/rename[@name = $name])"/>
    </xsl:if>
    <xsl:apply-templates/>
  </rule>
</xsl:template>

<xsl:template match="alternation">
  <alts>
    <xsl:apply-templates/>
  </alts>
</xsl:template>

<xsl:template match="group/alternation" priority="10">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="rule/alternation" priority="10">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="alternation/*" priority="10">
  <alt>
    <xsl:next-match/>
  </alt>
</xsl:template>

<xsl:template match="group">
  <alts>
    <xsl:apply-templates/>
  </alts>
</xsl:template>

<xsl:template match="repetition">
  <xsl:message terminate="yes" select="'Unhandled repetition type:', ."/>
</xsl:template>

<xsl:template match="repetition[not(repeat)]">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="repetition[repeat='+']">
  <repeat1>
    <xsl:apply-templates select="* except repeat"/>
  </repeat1>
</xsl:template>

<xsl:template match="repetition[repeat castable as xs:integer]">
  <xsl:variable name="item" select="* except repeat"/>
  <xsl:for-each select="1 to xs:integer(repeat)">
    <xsl:apply-templates select="$item"/>
  </xsl:for-each>
</xsl:template>

<xsl:template match="repetition[repeat='0']" priority="10">
  <alts>
    <alt/>
  </alts>
</xsl:template>

<xsl:template match="repetition[matches(repeat, '\d*\*\d*')]">
  <xsl:variable name="item" select="* except repeat"/>
  <xsl:variable name="min"
                select="if (substring-before(repeat, '*') = '')
                        then 0
                        else xs:integer(substring-before(repeat, '*'))"/>
  <xsl:variable name="max"
                select="if (substring-after(repeat, '*') = '')
                        then ()
                        else xs:integer(substring-after(repeat, '*'))"/>

  <xsl:if test="$min gt 0">
    <xsl:for-each select="1 to $min">
      <xsl:apply-templates select="$item"/>
    </xsl:for-each>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="exists($max)">
      <xsl:for-each select="$min to $max">
        <xsl:apply-templates select="$item"/>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <repeat0>
        <xsl:apply-templates select="$item"/>
      </repeat0>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="option">
  <option>
    <xsl:apply-templates/>
  </option>
</xsl:template>

<xsl:template match="char-val">
  <literal string='{.}'>
    <xsl:sequence select="f:tmark(.)"/>
  </literal>
</xsl:template>

<xsl:template match="hex-val">
  <xsl:variable name="attr" select="f:tmark(.)"/>
  <xsl:for-each select="tokenize(., '\.')">
    <literal hex='{.}'>
      <xsl:sequence select="$attr"/>
    </literal>
  </xsl:for-each>
</xsl:template>

<xsl:template match="hex-val[contains(., '-')]">
  <xsl:variable name="attr" select="f:tmark(.)"/>
  <xsl:variable name="first" select="substring-before(., '-')"/>
  <xsl:variable name="last" select="substring-after(., '-')"/>
  <alts>
    <alt>
      <inclusion>
        <member from='#{$first}' to='#{$last}'>
          <xsl:sequence select="$attr"/>
        </member>
      </inclusion>
    </alt>
  </alts>
</xsl:template>

<xsl:template match="rulename">
  <nonterminal name='{.}'>
    <xsl:sequence select="f:mark(.)"/>
    <xsl:sequence select="f:rename(.)"/>
  </nonterminal>
</xsl:template>

<xsl:template match="rule/rulename"/>

<xsl:template match="comment">
  <comment>
    <xsl:apply-templates/>
  </comment>
</xsl:template>

<!-- ============================================================ -->

<xsl:function name="f:hex-to-dec" as="xs:integer">
  <xsl:param name="hex" as="xs:string"/>
  <xsl:iterate select="reverse(string-to-codepoints(upper-case($hex)))">
    <xsl:param name="dec" select="0"/>
    <xsl:param name="pow" select="1"/>
    <xsl:on-completion select="$dec"/>
    <xsl:variable name="digit" select="if (. gt 64) then . - 55 else . - 48"/>
    <xsl:next-iteration>
      <xsl:with-param name="dec" select="$dec + ($digit * $pow)"/>
      <xsl:with-param name="pow" select="$pow * 16"/>
    </xsl:next-iteration>
  </xsl:iterate>
</xsl:function>

<xsl:function name="f:dec-to-hex" as="xs:string">
  <xsl:param name="dec" as="xs:integer"/>

  <xsl:choose>
    <xsl:when test="$dec lt 16">
      <xsl:sequence select="substring('0123456789ABCDEF', $dec+1, 1)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="newdec" select="$dec idiv 16"/>
      <xsl:variable name="digit"  select="$dec - ($newdec * 16)"/>
      <xsl:sequence select="f:dec-to-hex($newdec)||substring('0123456789ABCDEF', $digit+1, 1)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:mark" as="attribute()?">
  <xsl:param name="node" as="element()"/>
  <xsl:if test="map:contains($marked, generate-id($node))">
    <xsl:attribute name="mark" select="map:get($marked, generate-id($node))"/>
  </xsl:if>
</xsl:function>

<xsl:function name="f:tmark" as="attribute()?">
  <xsl:param name="node" as="element()"/>
  <xsl:if test="map:contains($marked, generate-id($node))">
    <xsl:attribute name="tmark" select="map:get($marked, generate-id($node))"/>
  </xsl:if>
</xsl:function>

<xsl:function name="f:rename" as="attribute()?">
  <xsl:param name="node" as="element()"/>
  <xsl:if test="map:contains($renamed, generate-id($node))">
    <xsl:attribute name="rename" select="map:get($renamed, generate-id($node))"/>
  </xsl:if>
</xsl:function>

</xsl:stylesheet>
