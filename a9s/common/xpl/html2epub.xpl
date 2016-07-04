<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:epub="http://transpect.io/epubtools"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tr="http://transpect.io"
    version="1.0"
    name="html2epub">
  
    <p:output port="result" primary="true">
      <p:pipe port="result" step="html52epub"/>
    </p:output>
    <p:output port="htmlreport" sequence="true">
      <p:pipe port="result" step="patch"/>
    </p:output>
    <p:serialization port="htmlreport" omit-xml-declaration="false" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
  
    <p:option name="file" required="true"/>
    <p:option name="debug" required="false" select="'no'"/>
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
      <p:with-option name="filename" select="$file"/>
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
      <p:when test="contains($file, '.html') or contains($file, '.xhtml')">
        <tr:file-uri name="html-file">
          <p:with-option name="filename" select="$file"/>
        </tr:file-uri>
      </p:when>
      <p:otherwise>
        <p:error code="wrong-format">
          <p:input port="source">
            <p:inline>
              <message>Wrong document format. Only single or zipped HTML files allowed.</message>
            </p:inline>
          </p:input>
        </p:error>
      </p:otherwise>
      </p:choose>
    </p:group>

    <tr:store-debug>
      <p:with-option name="pipeline-step" select="concat('zip-output-html/', replace($file, '^.+/', ''))"/>
      <p:with-option name="active" select="$debug"/>
      <p:with-option name="base-uri" select="$debug-dir-uri"/>
    </tr:store-debug>  
   
    <p:group name="html5-input">
    <p:variable name="input-uri" select="/*/@local-href"/>

    <p:try>
      <p:group>
        <p:load>
          <p:with-option name="href" select="$input-uri"/>
        </p:load>
      </p:group>
      <p:catch>
        <p:documentation>Use validator.nu for HTML5 parsing…</p:documentation>
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

      </p:catch>
    </p:try>
      
      <tr:store-debug name="group-output">
        <p:with-option name="pipeline-step" select="concat('single-html/', replace($input-uri, '^.+/', ''))"/>
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      
      <p:load name="load-xml-for-fixed-ibooks-view">
        <p:with-option name="href" select="'http://transpect.io/epubtools/modules/create-ocf/xml/com.apple.ibooks.display-options.xml'"/>
      </p:load>
      
      <p:store name="store-xml-for-fixed-ibooks-view">
        <p:with-option name="href" select="concat(replace($input-uri,'(^.*/).*', '$1'), 'com.apple.ibooks.display-options.xml')"/>
      </p:store>
      
      <p:identity name="group-identity-output">
        <p:input port="source">
          <p:pipe port="result" step="group-output"/>
        </p:input>
      </p:identity>
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
        <p:pipe port="result" step="html5-output"/>
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
  
  <p:sink/>

  <p:xslt name="insert-metadata" cx:depends-on="html5-output">
    <p:input port="source">
      <p:document href="http://this.transpect.io/conf/epub-config.xml"/>
      <p:pipe port="result" step="html5-output"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="http://this.transpect.io/a9s/common/xsl/insert-metadata.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

  <tr:store-debug>
    <p:with-option name="pipeline-step" select="'single-html/insert-metadata.xml'"/>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

    <epub:convert name="html52epub" cx:depends-on="insert-metadata">
      <p:input port="source">
        <p:pipe port="result" step="html5-output"/>
      </p:input>
        <p:input port="conf">
            <p:document href="http://this.transpect.io/conf/hierarchy.xml"/>
        </p:input>
        <p:input port="meta">
          <p:pipe port="result" step="insert-metadata"/>
        </p:input>
        <p:with-option name="target" select="'EPUB3'"/>
        <p:with-option name="terminate-on-error" select="'yes'"/>
        <p:with-option name="clean-target-dir" select="'no'"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="debug" select="$debug"/>
    </epub:convert>
    
    <p:group>
      <p:variable name="input-uri" select="/c:result/@os-path">
        <p:pipe port="result" step="locate-file"/>
      </p:variable>
      
      <p:choose>
        <p:when test="contains($file, '.zip')">
        <cx:message>
          <p:with-option name="message" select="$file"/>
          <p:with-option name="log" select="'info'"/>
        </cx:message>
          
        <cx:message>
          <p:with-option name="message" select="$input-uri"/>
          <p:with-option name="log" select="'info'"/>
        </cx:message>
        <cx:message>
          <p:with-option name="message" select="concat($input-uri, '.tmp/', replace(replace($file, '^.+/', ''), 'zip', 'epub'))"/>
          <p:with-option name="log" select="'info'"/>
        </cx:message>
          <cxf:move name="move-epub-from-tmp-to-outdir">
            <p:with-option name="href" select="concat('file:///',$input-uri,'.tmp/', replace(replace($file, '^.+/', ''), 'zip', 'epub'))"/>
            <p:with-option name="target" select="concat('file:///',replace($input-uri,'zip$', 'epub'))"/>
          </cxf:move>
        </p:when>
        <p:otherwise>
          <p:sink/>
        </p:otherwise>
      </p:choose>
    </p:group>

  <tr:patch-svrl name="patch">
      <p:input port="source">
        <p:pipe port="result" step="srcpaths"/>
      </p:input>
      <p:input port="reports">
        <p:pipe port="report" step="sch_validate"/>
        <p:pipe port="report" step="html52epub"/>
      </p:input>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      <p:input port="params">
        <p:pipe port="result" step="paths"/>
      </p:input>
    </tr:patch-svrl>

    <p:sink/>
  
</p:declare-step>