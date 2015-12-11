<?xml version="1.0"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
    
    <p:input port="source" sequence="false" kind="document" /> 
    <p:input port="parameters" kind="parameter"/>
    <p:variable name="path" select=" tokenize(document-uri(.), '/')[last()]" />
    
    <p:xslt name="strip-p">
        <p:input port="stylesheet">
            <p:document href="strop_p.xsl"/>
        </p:input>
    </p:xslt>
    
    <p:xslt name="betacode">
        <p:input port="source"> 
            <p:pipe step="strip-p" port="result"/> 
        </p:input> 
        <p:input port="stylesheet">
            <p:document href="alpheios/text-beta-uni.xsl"/>
        </p:input>
    </p:xslt>
    
    <p:xslt name="first-milestone"> 
        <p:input port="source"> 
            <p:pipe step="betacode" port="result"/> 
        </p:input> 
        <p:input port="stylesheet"> 
            <p:document href="milestone_to_div.xsl"/>
        </p:input> 
    </p:xslt> 
    
    <p:xslt name="second-milestone"> 
        <p:input port="source"> 
            <p:pipe step="first-milestone" port="result"/> 
        </p:input> 
        <p:input port="stylesheet"> 
            <p:document href="milestone_section.xsl"/>
        </p:input>
    </p:xslt> 
    
    <p:store >
        <p:with-option name="href" select="concat('../phi001/', $path)"/>
    </p:store>
</p:declare-step> 