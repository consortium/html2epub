<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:html="http://www.w3.org/1999/xhtml" 
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  version="2.0">

  <xsl:variable name="config-doc" select="collection()[1]" as="document-node()"/>
  <xsl:variable name="html-doc" select="collection()[2]" as="document-node()"/>
  
  
  <xsl:template match="@*|*|comment()">
    <xsl:copy>
      <xsl:apply-templates select="@*|*|comment()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="metadata" exclude-result-prefixes="xs xsi html ncx cx c">
    <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
      <xsl:apply-templates select="dc:identifier"/>
      <xsl:apply-templates select="$html-doc/html:html/html:body/*[matches(@property, '^http://purl.org/dc/')]"/>
    </metadata>
  </xsl:template>

  <xsl:template match="*[matches(@property, '^http://purl.org/dc/')]" exclude-result-prefixes="#all">
    <xsl:variable name="meta-type" select="replace(@property, '.*/', '')"/>
    <xsl:element name="dc:{$meta-type}">
<!--      <xsl:apply-templates select="@*"/>-->
      <xsl:value-of select="string-join(.//text(), ' ')"/>
    </xsl:element>
  </xsl:template>
  
</xsl:stylesheet>