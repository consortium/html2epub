<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:epub="http://transpect.io/epubtools"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tr="http://transpect.io"
    version="1.0"
    name="html2epub">
  <!--
    <p:output port="result" primary="true">
      <!-\-<p:pipe port="result" step="html52epub"></p:pipe>-\->
      <p:empty></p:empty>
    </p:output>-->
    <p:output port="htmlreport" sequence="true">
      <p:pipe port="result" step="patch"></p:pipe>
    </p:output>
    <p:serialization port="htmlreport" omit-xml-declaration="false" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
  
    <p:option name="file" required="true"></p:option>
    <p:option name="debug" required="false" select="'no'"></p:option>
    <p:option name="debug-dir-uri" required="false" select="'debug'"/>
    <p:option name="status-dir-uri" required="false" select="'debug'"/>
    <p:option name="extract-dir" required="false" select="''"/>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="http://transpect.io/calabash-extensions/transpect-lib.xpl"/>
    <p:import href="http://transpect.io/epubtools/xpl/epub-convert.xpl"/>
    <p:import href="http://transpect.io/cascade/xpl/paths.xpl"/>
    <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
    <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
    <p:import href="http://transpect.io/htmlreports/xpl/validate-with-schematron.xpl"/>
    <p:import href="http://transpect.io/cascade/xpl/paths.xpl"/>
  
    <tr:paths name="paths" pipeline="html2epub.xpl">
      <p:with-option name="clades" select="'html2epub'">
        <p:empty/>
      </p:with-option>
      <p:with-option name="file" select="$file"/>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-option name="progress" select="'yes'"/>
      <p:input port="stylesheet">
        <p:document href="http://transpect.io/cascade/xsl/paths.xsl"/>
      </p:input>
      <p:input port="conf">
        <p:document href="http://this.transpect.io/conf/transpect-conf.xml"/>
      </p:input>
    </tr:paths>
    
    <p:sink/>
   
    <tr:file-uri name="locate-file">
      <p:with-option name="filename" select="$file"></p:with-option>
    </tr:file-uri>
  
    <tr:store-debug>
      <p:with-option name="pipeline-step" select="concat('zip-output-html/', 'packageuris', '')"/>
      <p:with-option name="active" select="$debug"/>
      <p:with-option name="base-uri" select="$debug-dir-uri"/>
    </tr:store-debug>  
    
    <p:group>
    
      <p:choose name="input_check">
      <p:when test="contains($file, '.zip')">
        <tr:unzip name="unzip">
          <p:with-option name="zip" select="/c:result/@os-path">
            <p:pipe step="locate-file" port="result"/>
          </p:with-option>
          <p:with-option name="dest-dir"
            select="if ($extract-dir = '') 
            then concat(/c:result/@os-path, '.tmp')
            else $extract-dir">
            <p:pipe step="locate-file" port="result"/>
          </p:with-option>
          <p:with-option name="overwrite" select="'yes'"/>
        </tr:unzip>
        <tr:file-uri>
          <p:with-option name="filename"
            select="concat(
              /c:files/@xml:base,
              (/c:files/c:file/@name[matches(., '^.+.html$')])[1]
              )"
          />
        </tr:file-uri>
      </p:when>
      <p:when test="contains($file, '.html')">
        <tr:file-uri name="html-file">
          <p:with-option name="filename" select="$file"></p:with-option>
        </tr:file-uri>
      </p:when>
        <p:otherwise>
          <cx:message>
            <p:with-option name="log" select="'error'"></p:with-option>
            <p:with-option name="message" select="'Input needs to be either an HTML document or a ZIP container'"></p:with-option>
          </cx:message>
        </p:otherwise>
      </p:choose>
    </p:group>

    <tr:store-debug>
      <p:with-option name="pipeline-step" select="concat('zip-output-html/', replace($file, '^.+/', ''))"/>
      <p:with-option name="active" select="$debug"/>
      <p:with-option name="base-uri" select="$debug-dir-uri"/>
    </tr:store-debug>  
   
    <p:group name="html5-input">
      <p:variable name="input-uri" select="/*/@local-href"></p:variable>
      
      <p:add-attribute attribute-name="href" match="/*">
        <p:input port="source">
          <p:inline>
            <c:request method="GET"/>
          </p:inline>
        </p:input>
        <p:with-option name="attribute-value" select="$input-uri"/>
      </p:add-attribute>
      
      <p:http-request/>
      
      <p:unescape-markup content-type="text/html"/>
      
      <p:unwrap match="/c:body"/>
      
      <p:add-attribute match="/*" attribute-name="xml:base">
        <p:with-option name="attribute-value" select="$input-uri"/>
      </p:add-attribute>
      
      <tr:store-debug>
        <p:with-option name="pipeline-step" select="concat('single-html/', replace($input-uri, '^.+/', ''))"/>
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
    </p:group>
    <p:identity name="html5-output"/>
  
    <p:label-elements attribute="srcpath" replace="false" name="srcpaths"
      match="*[local-name() = ( 'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
                                'div', 'nav', 'section', 'main',
                                'ol', 'ul', 'li', 'dd', 'dt', 
                                'td', 'th', 
                                'em', 'span', 'b', 'i', 'strong', 
                                'code', 'pre',
                                'a', 'img')]">
      <p:documentation>For the epubtools Schematron checks, we need to add srcpaths on elements that
        don’t have them yet.</p:documentation>
    </p:label-elements>
    
    <tr:validate-with-schematron name="sch_validate">
      <p:input port="html-in">
        <p:pipe port="result" step="html5-output"></p:pipe>
      </p:input>
      <p:input port="parameters">
        <p:pipe port="result" step="paths"/>
      </p:input>
      <p:with-param name="family" select="'html'"/>
      <p:with-param name="step-name" select="'sch_validate'"/>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    </tr:validate-with-schematron>
    
    <tr:store-debug>
        <p:with-option name="pipeline-step" select="'single-html/aftersrcadding.xml'"/>
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
  <!--
    <epub:convert name="html52epub">
        <p:input port="conf">
            <p:document href="http://this.transpect.io/conf/hierarchy.xml"></p:document>
        </p:input>
        <p:input port="meta">
          <p:document href="http://this.transpect.io/conf/epub-config.xml"></p:document>
        </p:input>
        <p:with-option name="target" select="'EPUB3'"></p:with-option>
        <p:with-option name="terminate-on-error" select="'yes'"></p:with-option>
        <p:with-option name="clean-target-dir" select="'no'"></p:with-option>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"></p:with-option>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"></p:with-option>
    </epub:convert>
  -->  
    <p:sink></p:sink>
  
    <tr:patch-svrl name="patch">
      <p:input port="source">
        <p:pipe port="result" step="srcpaths"/>
      </p:input>
      <p:input port="reports">
        <p:pipe port="report" step="sch_validate"/>
      </p:input>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      <p:input port="params">
        <p:pipe port="result" step="paths"/>
      </p:input>
    </tr:patch-svrl>
  
<!--    <tr:store-debug extension="html">
      <p:input port="source">
        <p:pipe port="result" step="patch"/>
      </p:input>
      <p:with-option name="pipeline-step" select="concat(replace($file, '^.+/|\..+$', ''), '_htmlreport')"/>
      <p:with-option name="active" select="$debug"/>
      <p:with-option name="base-uri" select="$debug-dir-uri"/>
    </tr:store-debug>--> 
  
    <p:sink/>
  
</p:declare-step>