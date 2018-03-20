<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:ns2="http://www.w3.org/1999/xlink">
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" encoding="UTF-8"/>
    <xsl:include href="lookupLists.xsl"/>
	<!--<xsl:include href="header.xsl"/>-->
	<xsl:include href="header_nolink_pdf.xsl"/>	
    <!--<xsl:include href="lookupLists.xsl"/>-->
    <!-- Creates the body of the finding aid.-->
    <xsl:template match="/ead">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>
                    <xsl:value-of select="concat(eadheader/filedesc/titlestmt/titleproper,' ',eadheader/filedesc/titlestmt/subtitle)"/>                
                </title>
                <xsl:call-template name="metadata"/>
                <xsl:call-template name="css"/>
            </head>
            <body>
                    <div id="outer">
						<xsl:call-template name="header"/>
						<xsl:call-template name="toc"/>
					<br/>
					<a name="dummy"><h3><xsl:copy-of select="$DISP_TITEL_MAIN"/></h3></a>
						<xsl:apply-templates select="archdesc/descgrp" mode="main"/>
					</div>		
						<xsl:if test="/ead/archdesc/dsc/c/*">
						<div id="outernew">						
							<xsl:for-each select="archdesc/dsc">
							<br/>
							    <a class="ech3" name="DISP_TITEL_8" style="color:black;"><xsl:copy-of select="$DISP_TITEL_8"/></a>
							    <br/>
								<xsl:apply-templates select="c" mode="detail"/>
								<xsl:call-template name="returnTOC_nohr"/>			
							</xsl:for-each>	
						</div>    	
						</xsl:if>
                    
            </body>
        </html>
    </xsl:template>
    <!-- CSS for styling HTML output. Place all CSS styles in this template.-->
    <xsl:template name="css">
        <style type="text/css">
A:link {color: #d0af14; text-decoration: none;font-weight: bold;}
A:visited {color: #d0af14; text-decoration: none;font-weight: bold;}
A:active {color: #d0af14; text-decoration: none;font-weight: bold;}
A:hover {color: #d0af14; text-decoration: underline;font-weight: bold;}
</style>	  
        <style xmlns:ead="urn:isbn:1-931666-22-9" type="text/css">
body{
font-family: Verdana, Arial, Helvetica, sans-serif; 
	font-size: 100%;	
	background:#fff;
}
            .hrefid  a:link {color: #d0af14; text-decoration: none;} 
            .hrefid a:visited	{color: #d0af14; text-decoration: none;} 
            .hrefid  a:active	{color: #d0af14; }             
            .hrefid  a:hover		{color: #d0af14; }
#outer{
margin-left:1em;
background:#fff;
margin-right:1em;
}
       #outer h3 {margin: 16px 8px 16px 0px;}
        #outer dt {margin: 3px; padding: 4px 0px; font-weight: normal;} 
        #outer dd {margin-top: 3px; margin-left: 16px; padding: 4px 0px;}
        #outer dt a:link, #outer dd a:link {color: black; text-decoration: none;} 
        #outer dt a:visited, #outer dd a:visited {color: black; text-decoration: none;} 
        #outer dt a:active, #outer dd a:active {color: #d0af14;} 
        #outer dt  a:hover, #outer dd  a:hover {color: #d0af14;}
		
#outernew{
margin-left:1em;
background:#fff;
margin-right:10cm;
}
       #outernew h3 {margin: 16px 8px 16px 0px;}
        #outernew dt {margin: 3px; padding: 4px 0px; font-weight: normal;} 
        #outernew dd {margin-top: 3px; margin-left: 16px; padding: 4px 0px;}
        #outernew dt a:link, #outernew dd a:link {color: #d0af14; text-decoration: underline;} 
        #outernew dt a:visited, #outernew dd a:visited {color: #d0af14; text-decoration: underline;} 
        #outernew dt a:active, #outernew dd a:active {color: #d0af14; text-decoration: underline;} 
        #outernew dt  a:hover, #outernew dd  a:hover {color: #d0af14; text-decoration: underline;}		
		
            .returnTOC {font-size: 0.75em; margin-top: 24px;}
            .returnTOC  a:link {color: #d0af14; text-decoration: none;} 
            .returnTOC a:visited	{color: #d0af14; text-decoration: none;} 
            .returnTOC  a:active	{color: #d0af14; }             
            .returnTOC  a:hover		{color: #d0af14; }	
		.ech9 {display:block;font-size: 0.7em; text-align:left; padding-left : 1em;padding-right : 1em;}
		.ech5 {display:block;font-size: 0.8em;font-weight : bold; padding-left : 1em;padding-right : 1em;text-align:left; }
		.ech6 {display:block;font-size: 0.75em;font-weight : bold; padding-left : 1em;padding-right : 1em;text-align:left; }
		.ech6nb {display:block;font-size: 0.75em; padding-left : 1em;padding-right : 1em;text-align:left; }
		.ech6tref {font-size: 0.75em;font-weight : bold; padding-left : 1em;text-align:left; }
		.ech3 {display:block;font-size: 1em; font-weight : bold;}
		
		<!--
		.Archief {display:block;font-size: 1.25em; padding-right : 1em;text-align:left; }
		.Deelarchief {display:block;font-size: 1.25em; padding-right : 1em;text-align:left; }		
		.Afdeling {display:block;font-size: 1.125em; padding-right : 1em;text-align:left; }	
		.Onderafdeling {display:block;font-size: 1.0625em; padding-right : 1em;text-align:left; }		
		.Rubriek {display:block;font-size: 1em; padding-right : 1em;text-align:left; }
		.Subrubriek {display:block;font-size: 0.9375em; padding-right : 1em;text-align:left; }		
		.Reeks {display:block;font-size: 0.875em; padding-right : 1em;text-align:left; }		
		.Reeks - meervoudige beschrijving {display:block;font-size: 0.8125em; padding-right : 1em;text-align:left; }
		.Deelreeks {display:block;font-size: 0.75em; padding-right : 1em;text-align:left; }		
		.Deelreeks - meervoudige beschrijving {display:block;font-size: 0.6875em; padding-right : 1em;text-align:left; }
		.Bestanddeel {display:block;font-size: 0.625em; padding-right : 1em;text-align:left; }				
		.Bestanddeel - meervoudige beschrijving {display:block;font-size: 0.625em; padding-right : 1em;text-align:left; }
		.Subbestanddeel {display:block;font-size: 0.625em; padding-right : 1em;text-align:left; }				
		.Subbestanddeel - meervoudige beschrijving {display:block;font-size: 0.625em; padding-right : 1em;text-align:left; }		
		.Stuk {display:block;font-size: 0.5625em; padding-right : 1em;text-align:left; }
		-->
		.fontarchiefnb {display:block;font-size: 1.25em; display:block; padding-right : 1em;text-align:left; }
		.fontdeelarchiefnb {display:block;font-size: 1.25em; display:block; padding-right : 1em;text-align:left; }		
		.fontafdelingnb {display:block;font-size: 1.125em; display:block; padding-right : 1em;text-align:left; }	
		.fontonderafdelingnb {display:block;font-size: 1.0625em; display:block; padding-right : 1em;text-align:left; }		
		.fontrubrieknb {display:block;font-size: 1em; display:block; padding-right : 1em;text-align:left; }
		.fontsubrubrieknb {display:block;font-size: 0.9375em; display:block; padding-right : 1em;text-align:left; }		
		.fontreeksnb {display:block;font-size: 0.875em; display:block; padding-right : 1em;text-align:left; }		
		.fontreeksmbnb {display:block;font-size: 0.8125em; display:block; padding-right : 1em;text-align:left; }
		.fontdeelreeksnb {display:block;font-size: 0.75em; display:block; padding-right : 1em;text-align:left; }		
		.fontdeelreeksmbnb {display:block;font-size: 0.6875em; display:block; padding-right : 1em;text-align:left; }
		.fontbestanddeelnb {display:block;font-size: 0.625em; display:block; padding-right : 1em;text-align:left; }				
		.fontbestanddeelmbnb {display:block;font-size: 0.625em; display:block; padding-right : 1em;text-align:left; }
		.fontsubbestanddeelnb {display:block;font-size: 0.625em; display:block; padding-right : 1em;text-align:left; }				
		.fontsubbestanddeelmbnb {display:block;font-size: 0.625em; display:block; padding-right : 1em;text-align:left; }		
		.stuknb {display:block;font-size: 0.5625em; display:block; padding-right : 1em;text-align:left; }	
	h2 {	
		font-weight: bold;
		font-size: 15pt; 
	   } 	
	h3 {	
		font-weight: bold;
		font-size: 14pt; 
	   }
		.Archief { font-size: 15pt; }
		.Deelarchief { font-size: 16pt; font-weight: bold;}
		.Afdeling { font-size: 16pt; font-variant:small-caps;}
		.Onderafdeling { font-size: 14pt; font-weight: bold;}
		.Rubriek { font-size: 14pt; font-variant:small-caps;}
		.Subrubriek { font-size: 12pt; font-style:italic}
		.Reeks { font-size: 12pt; text-transform:capitalize}
		.Reeks - meervoudige beschrijving { font-size: 10pt; }
		.Deelreeks { font-size: 12pt; text-decoration:underline}
		.Deelreeks - meervoudige beschrijving { font-size: 10pt; }
		.Bestanddeel { font-size: 10pt; }
		.Bestanddeel - meervoudige beschrijving { font-size: 10pt; }
		.Subbestanddeel { font-size: 10pt; }
		.Subbestanddeel - meervoudige beschrijving { font-size: 10pt; }
		.Stuk { font-size: 10pt; }
</style>
    </xsl:template>
    <!-- This template creates a customizable header  -->
    <xsl:template name="header">
	<div style="text-align:left"><img src="http://www.lias.be/themes/LIAS/images/lias.jpg"/></div>	
	<xsl:if test="normalize-space(eadheader/filedesc/titlestmt/titleproper) != '' or normalize-space(eadheader/filedesc/titlestmt/subtitle) !='' or normalize-space(eadheader/filedesc/titlestmt/author) != ''">
		<div style="text-align:center">
			<xsl:if test="normalize-space(eadheader/filedesc/titlestmt/titleproper[@label='Titel']) != ''">
				<h3><xsl:value-of select="eadheader/filedesc/titlestmt/titleproper[@label='Titel']"/></h3>
			</xsl:if>	
			<xsl:if test="normalize-space(eadheader/filedesc/titlestmt/titleproper[@label='Ondertitel']) != ''">
				<h3><xsl:value-of select="eadheader/filedesc/titlestmt/titleproper[@label='Ondertitel']"/></h3>
			</xsl:if>
			<xsl:if test="normalize-space(eadheader/filedesc/titlestmt/subtitle) !=''">
				<h3><xsl:value-of select="eadheader/filedesc/titlestmt/subtitle"/></h3>
			</xsl:if>			
			<xsl:if test="normalize-space(eadheader/filedesc/titlestmt/author) != ''">
				<h5><xsl:value-of select="eadheader/filedesc/titlestmt/author"/></h5>
			</xsl:if>			
		</div>
	</xsl:if>	
	<p style="text-align:left;" class="ech9">Deze inventaris werd automatisch gegenereerd en gecodeerd.<br/>
	    De EAD-export werd gecontroleerd en gevalideerd door de werkgroep archivarissen van LIAS K.U.Leuven (Leuvens Integraal Archiveringssysteem), <xsl:value-of select="$EAD_DATE"/><br/>
	<a><xsl:attribute name="href"><xsl:value-of select="$XML_SCOPE_OPAC"/><xsl:value-of select="$REC_ID"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute>Volledige beschrijving in databank LIAS</a></p>  
	<hr/> 
    </xsl:template>
    <!-- HTML meta tags for use by web search engines for indexing. -->
    <xsl:template name="metadata">
        <meta http-equiv="Content-Type" name="dc.title"
            content="{concat(eadheader/filedesc/titlestmt/titleproper,' ',eadheader/filedesc/titlestmt/subtitle)}"/>
        <meta http-equiv="Content-Type" name="dc.author"
            content="{/ead/archdesc/descgrp/did/origination}"/>
        <xsl:for-each select="/ead/archdesc/controlaccess/descendant::*">
            <meta http-equiv="Content-Type" name="dc.subject" content="{.}"/>
        </xsl:for-each>
        <meta http-equiv="Content-Type" name="dc.type" content="text"/>
        <meta http-equiv="Content-Type" name="dc.format" content="manuscripts"/>
        <meta http-equiv="Content-Type" name="dc.format" content="finding aids"/>
    </xsl:template>
    <!-- Creates an ordered table of contents that matches the order of the archdesc 
        elements. To change the order rearrange the if/for-each statements. -->  
    <xsl:template name="toc">
			<a name="toc"><h2><xsl:copy-of select="$DISP_TITEL_TOC"/></h2></a>
			<a name="dummy"><h3><xsl:copy-of select="$DISP_TITEL_MAIN"/></h3></a>
            <dl>
				<xsl:for-each select="archdesc/descgrp">
					<xsl:if test="head=$TITEL_1">
					    <dt><a class="ech5" href="#DISP_TITEL_1"><xsl:copy-of select="$DISP_TITEL_1"/></a></dt>
						<dd><a class="ech6" href="#DISP_TITEL_1_1"><xsl:copy-of select="$DISP_TITEL_1_1"/></a></dd>
						<xsl:if test="unititle">
						<dd><a class="ech6" href="#DISP_TITEL_1_2"><xsl:copy-of select="$DISP_TITEL_1_2"/></a></dd>
						</xsl:if>
						<xsl:if test="unitdate">
						<dd><a class="ech6" href="#DISP_TITEL_1_3"><xsl:copy-of select="$DISP_TITEL_1_3"/></a></dd>
						</xsl:if>
						<xsl:if test="physdesc/extent[@label='Omvang']">
						<dd><a class="ech6" href="#DISP_TITEL_1_4"><xsl:copy-of select="$DISP_TITEL_1_4"/></a></dd>						
						</xsl:if>
					</xsl:if>
					<xsl:if test="head=$TITEL_2">
					    <dt><a class="ech5" href="#DISP_TITEL_2"><xsl:copy-of select="$DISP_TITEL_2"/></a></dt>
						<xsl:if test="origination">
							<dd><a class="ech6" href="#DISP_TITEL_2_1"><xsl:copy-of select="$DISP_TITEL_2_1"/></a></dd>
						</xsl:if>	
						<xsl:if test="bioghist/p/text()">
							<dd><a class="ech6" href="#DISP_TITEL_2_2"><xsl:copy-of select="$DISP_TITEL_2_2"/></a></dd>
						</xsl:if>
						<xsl:if test="custodhist/p/text()">
							<dd><a class="ech6" href="#DISP_TITEL_2_3"><xsl:copy-of select="$DISP_TITEL_2_3"/></a></dd>
						</xsl:if>
						<xsl:if test="acqinfo/p/text()">	
							<dd><a class="ech6" href="#DISP_TITEL_2_4"><xsl:copy-of select="$DISP_TITEL_2_4"/></a></dd>
						</xsl:if>	
					</xsl:if>
					<xsl:if test="head=$TITEL_3">
					    <dt><a class="ech5" href="#DISP_TITEL_3"><xsl:copy-of select="$DISP_TITEL_3"/></a></dt>
						<xsl:if test="scopecontent/head=$TITEL_3_1">
							<dd><a class="ech6" href="#DISP_TITEL_3_1"><xsl:copy-of select="$DISP_TITEL_3_1"/></a></dd>
						</xsl:if>	
						<xsl:if test="appraisal/head=$TITEL_3_2">
							<dd><a class="ech6" href="#DISP_TITEL_3_2"><xsl:copy-of select="$DISP_TITEL_3_2"/></a></dd>
						</xsl:if>
						<xsl:if test="accruals/head=$TITEL_3_3">
							<dd><a class="ech6" href="#DISP_TITEL_3_3"><xsl:copy-of select="$DISP_TITEL_3_3"/></a></dd>
						</xsl:if>
						<xsl:if test="arrangement/head=$TITEL_3_4">
							<dd><a class="ech6" href="#DISP_TITEL_3_4"><xsl:copy-of select="$DISP_TITEL_3_4"/></a></dd>
						</xsl:if>
					</xsl:if>					
					<xsl:if test="head=$TITEL_4">
					    <dt><a class="ech5" href="#DISP_TITEL_4"><xsl:copy-of select="$DISP_TITEL_4"/></a></dt>
						<xsl:if test="accessrestrict/head=$TITEL_4_1">
							<dd><a class="ech6" href="#DISP_TITEL_4_1"><xsl:copy-of select="$DISP_TITEL_4_1"/></a></dd>
						</xsl:if>	
						<xsl:if test="userestrict/head=$TITEL_4_2">
							<dd><a class="ech6" href="#DISP_TITEL_4_2"><xsl:copy-of select="$DISP_TITEL_4_2"/></a></dd>
						</xsl:if>
						<xsl:if test="langmaterial/head=$TITEL_4_3">
							<dd><a class="ech6" href="#DISP_TITEL_4_3"><xsl:copy-of select="$DISP_TITEL_4_3"/></a></dd>
						</xsl:if>
						<xsl:if test="phystech/head=$TITEL_4_4">
							<dd><a class="ech6" href="#DISP_TITEL_4_4"><xsl:copy-of select="$DISP_TITEL_4_4"/></a></dd>
						</xsl:if>
						<!--
						<xsl:if test="otherfindaid/head=$TITEL_4_5">
							<dd><a class="ech6" href="#DISP_TITEL_4_5"><xsl:copy-of select="$DISP_TITEL_4_5"/></a></dd>
						</xsl:if>						
						-->
					</xsl:if>
					<xsl:if test="head=$TITEL_5">
					    <dt><a class="ech5" href="#DISP_TITEL_5"><xsl:copy-of select="$DISP_TITEL_5"/></a></dt>
						<xsl:if test="originalsloc/head=$TITEL_5_1">
							<dd><a class="ech6" href="#DISP_TITEL_5_1"><xsl:copy-of select="$DISP_TITEL_5_1"/></a></dd>
						</xsl:if>	
						<xsl:if test="altformavail/head=$TITEL_5_2">
							<dd><a class="ech6" href="#DISP_TITEL_5_2"><xsl:copy-of select="$DISP_TITEL_5_2"/></a></dd>
						</xsl:if>
						<xsl:if test="relatedmaterial/head=$TITEL_5_3">
							<dd><a class="ech6" href="#DISP_TITEL_5_3"><xsl:copy-of select="$DISP_TITEL_5_3"/></a></dd>
						</xsl:if>
						<xsl:if test="bibliography/head=$TITEL_5_4">
							<dd><a class="ech6" href="#DISP_TITEL_5_4"><xsl:copy-of select="$DISP_TITEL_5_4"/></a></dd>
						</xsl:if>
					</xsl:if>					
					<xsl:if test="head=$TITEL_6">
					    <dt><a class="ech5" href="#DISP_TITEL_6"><xsl:copy-of select="$DISP_TITEL_6"/></a></dt>
						<xsl:if test="note/head=$TITEL_6_1">
							<dd><a class="ech6" href="#DISP_TITEL_6_1"><xsl:copy-of select="$DISP_TITEL_6_1"/></a></dd>
						</xsl:if>	
					</xsl:if>
					<xsl:if test="head=$TITEL_7">
					    <dt><a class="ech5" href="#DISP_TITEL_7"><xsl:copy-of select="$DISP_TITEL_7"/></a></dt>
						<xsl:if test="processinfo[@label='Verantwoording']/head=$TITEL_7_1">
							<dd><a class="ech6" href="#DISP_TITEL_7_1"><xsl:copy-of select="$DISP_TITEL_7_1"/></a></dd>
						</xsl:if>	
						<xsl:if test="descrules/head=$TITEL_7_2">
							<dd><a class="ech6" href="#DISP_TITEL_7_2"><xsl:copy-of select="$DISP_TITEL_7_2"/></a></dd>
						</xsl:if>
						<xsl:if test="processinfo[@label='Datering van de beschrijvingen']/head=$TITEL_7_3">
							<dd><a class="ech6" href="#DISP_TITEL_7_3"><xsl:copy-of select="$DISP_TITEL_7_3"/></a></dd>
						</xsl:if>
						<xsl:if test="/ead/archdesc/controlaccess">
							<dd><a class="ech6" href="#DISP_TITEL_7_4"><xsl:copy-of select="$DISP_TITEL_7_4"/></a></dd>
						</xsl:if>
					</xsl:if>					
					
				</xsl:for-each>
			</dl>	
				<xsl:if test="/ead/archdesc/dsc">
					<a class="ech3" href="#DISP_TITEL_8" style="color:black;"><xsl:copy-of select="$DISP_TITEL_8"/></a>
				    <xsl:for-each select="archdesc/dsc">
					<xsl:apply-templates select="c" mode="heading"/>
				    </xsl:for-each>     
				</xsl:if>
				<hr/>
    </xsl:template>
 
     <!-- Named template for a generic p element with a link back to the table of contents  -->
    <xsl:template name="returnTOC">                
        <p class="returnTOC">&#160;&#160;<a href="#toc">Terug naar Inhoudstafel</a></p>
        <hr/>
    </xsl:template>
    <xsl:template name="returnTOC_nohr">                
        <p class="returnTOC">&#160;&#160;<a href="#toc">Terug naar Inhoudstafel</a></p>
    </xsl:template>	
    <xsl:template match="eadheader">
        <h1 id="{generate-id(filedesc/titlestmt/titleproper)}">
            <xsl:apply-templates select="filedesc/titlestmt/titleproper"/>     
        </h1>
        <xsl:if test="normalize-space(filedesc/titlestmt/subtitle) != ''">
            <h2>
                <xsl:apply-templates select="filedesc/titlestmt/subtitle"/>
            </h2>                
        </xsl:if>
    </xsl:template>
    <xsl:template match="filedesc/titlestmt/titleproper">
        <xsl:choose>
            <xsl:when test="@type = 'filing'">
                <xsl:choose>
                    <xsl:when test="count(parent::*/titleproper) &gt; 1"/>
                    <xsl:otherwise>
                        <xsl:value-of select="/ead/archdesc/descgrp/did/unittitle"/>        
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="filedesc/titlestmt/titleproper/num"><br/><xsl:apply-templates/></xsl:template>
    <xsl:template match="archdesc/did">
        <h3>
            <a name="{generate-id(.)}">
                <xsl:choose>
                    <xsl:when test="head">
                        <xsl:value-of select="head"/>
                    </xsl:when>
                    <xsl:otherwise>
                        Summary Information
                    </xsl:otherwise>
                </xsl:choose>
            </a>
        </h3>
        <!-- Determines the order in wich elements from the archdesc did appear, 
            to change the order of appearance for the children of did
            by changing the order of the following statements.-->
        <dl class="summary">
            <xsl:apply-templates select="repository"/>
            <xsl:apply-templates select="origination"/>
            <xsl:apply-templates select="unittitle"/>    
            <xsl:apply-templates select="unitid"/>
            <xsl:apply-templates select="unitdate"/>
            <xsl:apply-templates select="physdesc"/>        
            <xsl:apply-templates select="physloc"/>        
            <xsl:apply-templates select="langmaterial"/>
            <xsl:apply-templates select="materialspec"/>
            <xsl:apply-templates select="container"/>
            <xsl:apply-templates select="abstract"/> 
            <xsl:apply-templates select="note"/>
        </dl>
            <xsl:apply-templates select="../prefercite"/>
        <xsl:call-template name="returnTOC"/>
    </xsl:template>
    <!-- Template calls and formats the children of archdesc/did -->
    <xsl:template match="archdesc/did/repository | archdesc/did/unittitle | archdesc/did/unitid | archdesc/did/origination 
        | archdesc/did/unitdate | archdesc/did/physdesc | archdesc/did/physloc 
        | archdesc/did/abstract | archdesc/did/langmaterial | archdesc/did/materialspec | archdesc/did/container">
        <dt>
            <xsl:choose>
                <xsl:when test="@label">
					<xsl:value-of select="concat(translate( substring(@label, 1, 1 ),
                        'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ), 
                        substring(@label, 2, string-length(@label )))" />
					
                    <xsl:if test="@type"> [<xsl:value-of select="@type"/>]</xsl:if>
                    <xsl:if test="self::origination">
                        <xsl:choose>
                            <xsl:when test="persname[@role != ''] and contains(persname/@role,' (')">
                                - <xsl:value-of select="substring-before(persname/@role,' (')"/>
                            </xsl:when>
                            <xsl:when test="persname[@role != '']">
                                - <xsl:value-of select="persname/@role"/>  
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="self::repository">Repository</xsl:when>
                        <xsl:when test="self::unittitle">Title</xsl:when>
                        <xsl:when test="self::unitid">ID</xsl:when>
                        <xsl:when test="self::unitdate">Date<xsl:if test="@type"> [<xsl:value-of select="@type"/>]</xsl:if></xsl:when>
                        <xsl:when test="self::origination">
                            <xsl:choose>
                                <xsl:when test="persname[@role != ''] and contains(persname/@role,' (')">
                                    Creator - <xsl:value-of select="substring-before(persname/@role,' (')"/>
                                </xsl:when>
                                <xsl:when test="persname[@role != '']">
                                    Creator - <xsl:value-of select="persname/@role"/>  
                                </xsl:when>
                                <xsl:otherwise>
                                    Creator        
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="self::physdesc">Extent</xsl:when>
                        <xsl:when test="self::abstract">Abstract</xsl:when>
                        <xsl:when test="self::physloc">Location</xsl:when>
                        <xsl:when test="self::langmaterial">Language</xsl:when>
                        <xsl:when test="self::materialspec">Technical</xsl:when>
                        <xsl:when test="self::container">Container</xsl:when>
                        <xsl:when test="self::note">Note</xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </dt>
        <dd>
            <xsl:apply-templates/>
        </dd>
    </xsl:template>
    <!-- Templates for publication information  -->
    <xsl:template match="eadheader/filedesc/publicationstmt">
        <h4>Publication Information</h4>
        <p><xsl:apply-templates select="publisher"/>
            <xsl:if test="date">&#160;<xsl:apply-templates select="date"/></xsl:if>
        </p>
    </xsl:template>
    <!-- Templates for revision description  -->
    <xsl:template match="eadheader/revisiondesc">
        <h4>Revision Description</h4>
        <p><xsl:if test="change/item"><xsl:apply-templates select="change/item"/></xsl:if><xsl:if test="change/date">&#160;<xsl:apply-templates select="change/date"/></xsl:if></p>        
    </xsl:template>
    
    <!-- Formats controlled access terms -->
    <xsl:template match="controlaccess">
	
        <xsl:choose>
            <xsl:when test="head"><xsl:apply-templates/></xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="parent::archdesc"><h3><xsl:call-template name="anchor"/>Controlled Access Headings</h3></xsl:when>
                    <xsl:otherwise><h4>Controlled Access Headings</h4></xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="corpname">
            <h4>Corporate Name(s)</h4>
            <ul>
                <xsl:for-each select="corpname">
                    <li><xsl:apply-templates/> </li>
                </xsl:for-each>
            </ul>            
        </xsl:if>
        <xsl:if test="famname">
            <h4>Family Name(s)</h4>
            <ul>
                <xsl:for-each select="famname">
                    <li><xsl:apply-templates/> </li>
                </xsl:for-each>                        
            </ul>
        </xsl:if>
        <xsl:if test="function">
            <h4>Function(s)</h4>
            <ul>
                <xsl:for-each select="function">
                    <li><xsl:apply-templates/> </li>
                </xsl:for-each>                        
            </ul>
        </xsl:if>
        <xsl:if test="genreform">
            <h4>Genre(s)</h4>
            <ul>
                <xsl:for-each select="genreform">
                    <li><xsl:apply-templates/> </li>
                </xsl:for-each>
           </ul>     
        </xsl:if>
        <xsl:if test="geogname">
            <h4>Geographic Name(s)</h4>
            <ul>
                <xsl:for-each select="geogname">
                    <li><xsl:apply-templates/> </li>
                </xsl:for-each>                        
            </ul>
        </xsl:if>
        <xsl:if test="occupation">
            <h4>Occupation(s)</h4>
            <ul>
                <xsl:for-each select="occupation">
                    <li><xsl:apply-templates/> </li>
                </xsl:for-each>                        
            </ul>
        </xsl:if>
        <xsl:if test="persname">
            <h4>Personal Name(s)</h4>
            <ul>
                <xsl:for-each select="persname">
                    <li><xsl:apply-templates/> </li>
                </xsl:for-each>                        
            </ul>
        </xsl:if>
        <xsl:if test="subject">
            <h4>Subject(s)</h4>
            <ul>
                <xsl:for-each select="subject">
                    <li><xsl:apply-templates/> </li>
                </xsl:for-each>                        
            </ul>
        </xsl:if>
        <xsl:if test="parent::archdesc"><xsl:call-template name="returnTOC"/></xsl:if>
    </xsl:template>
    <!-- Formats index and child elements, groups indexentry elements by type (i.e. corpname, subject...)-->
    <xsl:template match="index">
       <xsl:choose>
           <xsl:when test="head"/>
           <xsl:otherwise>
               <xsl:choose>
                   <xsl:when test="parent::archdesc">
                       <h3><xsl:call-template name="anchor"/>Index</h3>
                   </xsl:when>
                   <xsl:otherwise>
                       <h4><xsl:call-template name="anchor"/>Index</h4>
                   </xsl:otherwise>
               </xsl:choose>    
           </xsl:otherwise>
       </xsl:choose>
       <xsl:apply-templates select="child::*[not(self::indexentry)]"/>
                <xsl:if test="indexentry/corpname">
                    <h4>Corporate Name(s)</h4>
                    <ul>
                        <xsl:for-each select="indexentry/corpname">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                     </ul>   
                </xsl:if>
                <xsl:if test="indexentry/famname">
                    <h4>Family Name(s)</h4>
                    <ul>
                        <xsl:for-each select="indexentry/famname">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>    
                </xsl:if>      
                <xsl:if test="indexentry/function">
                    <h4>Function(s)</h4>
                    <ul>
                        <xsl:for-each select="indexentry/function">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                <xsl:if test="indexentry/genreform">
                    <h4>Genre(s)</h4> 
                    <ul>
                        <xsl:for-each select="indexentry/genreform">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>           
                    </ul>
                </xsl:if>
                <xsl:if test="indexentry/geogname">
                    <h4>Geographic Name(s)</h4>
                    <ul>
                        <xsl:for-each select="indexentry/geogname">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>                    
                </xsl:if>
                <xsl:if test="indexentry/name">
                    <h4>Name(s)</h4>
                    <ul>
                        <xsl:for-each select="indexentry/name">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>    
                </xsl:if>
                <xsl:if test="indexentry/occupation">
                    <h4>Occupation(s)</h4> 
                    <ul>
                        <xsl:for-each select="indexentry/occupation">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                <xsl:if test="indexentry/persname">
                    <h4>Personal Name(s)</h4>
                    <ul>
                        <xsl:for-each select="indexentry/persname">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                <xsl:if test="indexentry/subject">
                    <h4>Subject(s)</h4> 
                    <ul>
                        <xsl:for-each select="indexentry/subject">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                <xsl:if test="indexentry/title">
                    <h4>Title(s)</h4>
                    <ul>
                        <xsl:for-each select="indexentry/title">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>         
       <xsl:if test="parent::archdesc"><xsl:call-template name="returnTOC"/></xsl:if>
   </xsl:template>
    <xsl:template match="indexentry">
        <dl class="indexEntry">
            <dt><xsl:apply-templates select="child::*[1]"/></dt>
            <dd><xsl:apply-templates select="child::*[2]"/></dd>    
        </dl>
    </xsl:template>
    <xsl:template match="ptrgrp">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Linking elements. -->
    <xsl:template match="ptr">
        <xsl:choose>
            <xsl:when test="@target">
                <a href="#{@target}"><xsl:value-of select="@target"/></a>
                <xsl:if test="following-sibling::ptr">, </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="ref">
        <xsl:choose>
            <xsl:when test="@target">
                <a href="#{@target}">
                    <xsl:apply-templates/>
                </a>
                <xsl:if test="following-sibling::ref">, </xsl:if>
            </xsl:when>
            <xsl:when test="@ns2:href">
                <a href="#{@ns2:href}">
                    <xsl:apply-templates/>
                </a>
                <xsl:if test="following-sibling::ref">, </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>    
    <xsl:template match="extptr">
        <xsl:choose>
            <xsl:when test="@href">
                <a href="{@href}"><xsl:value-of select="@title"/></a>
            </xsl:when>
            <xsl:when test="@ns2:href"><a href="{@ns2:href}"><xsl:value-of select="@title"/></a></xsl:when>
            <xsl:otherwise><xsl:value-of select="@title"/></xsl:otherwise>
        </xsl:choose> 
    </xsl:template>
    <xsl:template match="extref">
        <xsl:choose>
            <xsl:when test="@href">
                <a href="{@href}"><xsl:value-of select="."/></a>
            </xsl:when>
            <xsl:when test="@ns2:href"><a href="{@ns2:href}"><xsl:value-of select="."/></a></xsl:when>
            <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
        </xsl:choose> 
    </xsl:template>
    
    <!--Creates a hidden anchor tag that allows navigation within the finding aid. 
    In this stylesheet only children of the archdesc and c0* itmes call this template. 
    It can be applied anywhere in the stylesheet as the id attribute is universal. -->
    <xsl:template match="@id">
        <xsl:attribute name="id"><xsl:value-of select="."/></xsl:attribute>
    </xsl:template>
    <xsl:template name="anchor">
        <xsl:choose>
            <xsl:when test="@id">
                <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
            </xsl:otherwise>
            </xsl:choose>
    </xsl:template>
    <xsl:template name="tocLinks">
        <xsl:choose>
            <xsl:when test="self::*/@id">
                <xsl:attribute name="href">#<xsl:value-of select="@id"/></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="href">#<xsl:value-of select="generate-id(.)"/></xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
 
    <!--Bibref, choose statement decides if the citation is inline, if there is a parent element
    or if it is its own line, typically when it is a child of the bibliography element.-->
    <xsl:template match="bibref">
        <xsl:choose>
            <xsl:when test="parent::p">
                <xsl:choose>
                    <xsl:when test="@ns2:href">
                        <a href="{@ns2:href}"><xsl:apply-templates/></a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <p>
                    <xsl:choose>
                        <xsl:when test="@ns2:href">
                            <a href="{@ns2:href}"><xsl:apply-templates/></a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates/>
                        </xsl:otherwise>
                    </xsl:choose>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
   
    <!-- Formats prefered citiation -->
    <xsl:template match="prefercite">
        <div class="citation">
            <xsl:choose>
                <xsl:when test="head"><xsl:apply-templates/></xsl:when>
                <xsl:otherwise><h4>Preferred Citation</h4><xsl:apply-templates/></xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <!-- Applies a span style to address elements, currently addresses are displayed 
        as a block item, display can be changed to inline, by changing the CSS -->
    <xsl:template match="address">
        <span class="address">
            <xsl:for-each select="child::*">
                <xsl:apply-templates/>
                <xsl:choose>
                    <xsl:when test="lb"/>
                    <xsl:otherwise><br/></xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>            
        </span>    
    </xsl:template>
    
    <!-- Formats headings throughout the finding aid -->
    <xsl:template match="head[parent::*/parent::archdesc]">
        <xsl:choose>
            <xsl:when test="parent::accessrestrict or parent::userestrict or
                parent::custodhist or parent::accruals or
                parent::altformavail or parent::acqinfo or
                parent::processinfo or parent::appraisal or
                parent::originalsloc or  
                parent::relatedmaterial or parent::separatedmaterial or parent::prefercite">
                <h4>
                    <xsl:choose>
                        <xsl:when test="parent::*/@id">
                            <xsl:attribute name="id"><xsl:value-of select="parent::*/@id"/></xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="id"><xsl:value-of select="generate-id(parent::*)"/></xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates/>
                </h4>
            </xsl:when>
            <xsl:otherwise>
                <h3>
                    <xsl:choose>
                        <xsl:when test="parent::*/@id">
                            <xsl:attribute name="id"><xsl:value-of select="parent::*/@id"/></xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="id"><xsl:value-of select="generate-id(parent::*)"/></xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates/>
                </h3>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	<!-->
    <xsl:template match="head">
        <h4><xsl:apply-templates/></h4>
    </xsl:template>
	-->
    
    <!-- Digital Archival Object -->
    <xsl:template match="daogrp">
        <xsl:choose>
            <xsl:when test="parent::archdesc">
                <h3><xsl:call-template name="anchor"/>
                    <xsl:choose>
                    <xsl:when test="@ns2:title">
                       <xsl:value-of select="@ns2:title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        Digital Archival Object
                    </xsl:otherwise>
                    </xsl:choose>
                </h3>
            </xsl:when>
            <xsl:otherwise>
                <h4><xsl:call-template name="anchor"/>
                    <xsl:choose>
                    <xsl:when test="@ns2:title">
                       <xsl:value-of select="@ns2:title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        Digital Archival Object
                    </xsl:otherwise>
                </xsl:choose>
                </h4>
            </xsl:otherwise>
        </xsl:choose>   
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="dao">
        <xsl:choose>
            <xsl:when test="child::*">
                <xsl:apply-templates/> 
                <a href="{@ns2:href}">
                    [<xsl:value-of select="@ns2:href"/>]
                </a>
            </xsl:when>
            <xsl:otherwise>
                <a href="{@ns2:href}">
                    <xsl:value-of select="@ns2:href"/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="daoloc">
        <a href="{@ns2:href}">
            <xsl:value-of select="@ns2:title"/>
        </a>
    </xsl:template>
    
    <!--Formats a simple table. The width of each column is defined by the colwidth attribute in a colspec element.-->
    <xsl:template match="table">
        <xsl:for-each select="tgroup">
            <table>
                <tr>
                    <xsl:for-each select="colspec">
                        <td width="{@colwidth}"/>
                    </xsl:for-each>
                </tr>
                <xsl:for-each select="thead">
                    <xsl:for-each select="row">
                        <tr>
                            <xsl:for-each select="entry">
                                <td valign="top">
                                    <strong>
                                        <xsl:value-of select="."/>
                                    </strong>
                                </td>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:for-each select="tbody">
                    <xsl:for-each select="row">
                        <tr>
                            <xsl:for-each select="entry">
                                <td valign="top">
                                    <xsl:value-of select="."/>
                                </td>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each>
                </xsl:for-each>
            </table>
        </xsl:for-each>
    </xsl:template>
	<!--
    <xsl:template match="unitdate">
        <xsl:if test="preceding-sibling::*">&#160;</xsl:if>
        <xsl:choose>
            <xsl:when test="@type = 'bulk'">
                (<xsl:apply-templates/>)                            
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	-->
    <xsl:template match="date">
        <xsl:apply-templates/>
    </xsl:template>
	<!--
    <xsl:template match="unittitle">
        <xsl:choose>
            <xsl:when test="child::unitdate[@type='bulk']">
                <xsl:apply-templates select="node()[not(self::unitdate[@type='bulk'])]"/>
                <xsl:apply-templates select="date[@type='bulk']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	-->
    <!-- Following five templates output chronlist and children in a table -->
    <xsl:template match="chronlist">
        <table class="chronlist">
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="chronlist/listhead">
        <tr>
            <th>
                <xsl:apply-templates select="head01"/>
            </th>
            <th>
                <xsl:apply-templates select="head02"/>
            </th>
        </tr>
    </xsl:template>
    <xsl:template match="chronlist/head">
        <tr>
            <th colspan="2">
                <xsl:apply-templates/>
            </th>
        </tr>
    </xsl:template>
    <xsl:template match="chronitem">
        <tr>
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="(position() mod 2 = 0)">odd</xsl:when>
                    <xsl:otherwise>even</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <td><xsl:apply-templates select="date"/></td>
            <td><xsl:apply-templates select="descendant::event"/></td>
        </tr>
    </xsl:template>
    <xsl:template match="event">
        <xsl:choose>
            <xsl:when test="following-sibling::*">
                <xsl:apply-templates/><br/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    <!-- Output for a variety of list types -->
    <xsl:template match="list">
        <xsl:if test="head"><h4><xsl:value-of select="head"/></h4></xsl:if>
        <xsl:choose>
            <xsl:when test="descendant::defitem">
                <dl>
                    <xsl:apply-templates select="defitem"/>
                </dl>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="@type = 'ordered'">
                        <ol>
                            <xsl:attribute name="class">
                                <xsl:value-of select="@numeration"/>
                            </xsl:attribute>
                            <xsl:apply-templates/>
                        </ol>
                    </xsl:when>
                    <xsl:when test="@numeration">
                        <ol>
                            <xsl:attribute name="class">
                                <xsl:value-of select="@numeration"/>
                            </xsl:attribute>
                            <xsl:apply-templates/>
                        </ol>
                    </xsl:when>
                    <xsl:when test="@type='simple'">
                        <ul>
                            <xsl:attribute name="class">simple</xsl:attribute>
                            <xsl:apply-templates select="child::*[not(head)]"/>
                        </ul>
                    </xsl:when>
                    <xsl:otherwise>
                        <ul>
                            <xsl:apply-templates/>
                        </ul>        
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="list/head"/>
    <xsl:template match="list/item">
        <li><xsl:apply-templates/></li>
    </xsl:template>
    <xsl:template match="defitem">
        <dt><xsl:apply-templates select="label"/></dt>
        <dd><xsl:apply-templates select="item"/></dd>
    </xsl:template>
 
    <!-- Formats list as tabel if list has listhead element  -->         
    <xsl:template match="list[child::listhead]">
        <table>
            <tr>
                <th><xsl:value-of select="listhead/head01"/></th>
                <th><xsl:value-of select="listhead/head02"/></th>
            </tr>
            <xsl:for-each select="defitem">
                <tr>
                    <td><xsl:apply-templates select="label"/></td>
                    <td><xsl:apply-templates select="item"/></td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>
    <!-- Formats notestmt and notes -->
    <xsl:template match="notestmt">
        <h4>Note</h4>
        <xsl:apply-templates/>
    </xsl:template>
	<!--
    <xsl:template match="note">
         <xsl:choose>
             <xsl:when test="parent::notestmt">
                 <xsl:apply-templates/>
             </xsl:when>
             <xsl:otherwise>
                 <xsl:choose>
                     <xsl:when test="@label"><h4><xsl:value-of select="@label"/></h4><xsl:apply-templates/></xsl:when>
                     <xsl:otherwise><h4>Note</h4><xsl:apply-templates/></xsl:otherwise>
                 </xsl:choose>
             </xsl:otherwise>
         </xsl:choose>
     </xsl:template>
	 -->
    
    <!-- Child elements that should display as paragraphs-->
    <xsl:template match="legalstatus">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    <!-- Puts a space between sibling elements -->
	<!--
    <xsl:template match="child::*">
        <xsl:if test="preceding-sibling::*">&#160;</xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
	-->
    <!-- Generic text display elements -->
	<!--
    <xsl:template match="p">
        <p><xsl:apply-templates/></p>
    </xsl:template>
	-->
    <xsl:template match="lb"><br/></xsl:template>
    <xsl:template match="blockquote">
        <blockquote><xsl:apply-templates/></blockquote>
    </xsl:template>
    <xsl:template match="emph"><em><xsl:apply-templates/></em></xsl:template>
    
    <!--Render elements -->
    <xsl:template match="*[@render = 'bold'] | *[@altrender = 'bold'] ">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><strong><xsl:apply-templates/></strong>
    </xsl:template>
    <xsl:template match="*[@render = 'bolddoublequote'] | *[@altrender = 'bolddoublequote']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><strong>"<xsl:apply-templates/>"</strong>
    </xsl:template>
    <xsl:template match="*[@render = 'boldsinglequote'] | *[@altrender = 'boldsinglequote']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><strong>'<xsl:apply-templates/>'</strong>
    </xsl:template>
    <xsl:template match="*[@render = 'bolditalic'] | *[@altrender = 'bolditalic']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><strong><em><xsl:apply-templates/></em></strong>
    </xsl:template>
    <xsl:template match="*[@render = 'boldsmcaps'] | *[@altrender = 'boldsmcaps']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><strong><span class="smcaps"><xsl:apply-templates/></span></strong>
    </xsl:template>
    <xsl:template match="*[@render = 'boldunderline'] | *[@altrender = 'boldunderline']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><strong><span class="underline"><xsl:apply-templates/></span></strong>
    </xsl:template>
    <xsl:template match="*[@render = 'doublequote'] | *[@altrender = 'doublequote']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if>"<xsl:apply-templates/>"
    </xsl:template>
    <xsl:template match="*[@render = 'italic'] | *[@altrender = 'italic']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><em><xsl:apply-templates/></em>
    </xsl:template>
    <xsl:template match="*[@render = 'singlequote'] | *[@altrender = 'singlequote']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if>'<xsl:apply-templates/>'
    </xsl:template>
    <xsl:template match="*[@render = 'smcaps'] | *[@altrender = 'smcaps']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><span class="smcaps"><xsl:apply-templates/></span>
    </xsl:template>
    <xsl:template match="*[@render = 'sub'] | *[@altrender = 'sub']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><sub><xsl:apply-templates/></sub>
    </xsl:template>
    <xsl:template match="*[@render = 'super'] | *[@altrender = 'super']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><sup><xsl:apply-templates/></sup>
    </xsl:template>
    <xsl:template match="*[@render = 'underline'] | *[@altrender = 'underline']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><span class="underline"><xsl:apply-templates/></span>
    </xsl:template>
    <!-- 
        <value>nonproport</value>        
    -->
    <!-- *** Begin templates for Container List *** -->
    <xsl:template match="archdesc/dsc">
        <xsl:choose>
            <xsl:when test="head">
                <xsl:apply-templates select="head"/>
            </xsl:when>
            <xsl:otherwise>
                <h3><xsl:call-template name="anchor"/>Collection Inventory</h3>
            </xsl:otherwise>
        </xsl:choose>
        
        <table class="containerList">
            <xsl:apply-templates select="*[not(self::head)]"/>
            <tr>
                <td/>
                <td style="width: 15%;"/>
                <td style="width: 15%;"/>
                <td style="width: 15%;"/>
            </tr>
            
        </table>
    </xsl:template>
    
    <!--This section of the stylesheet creates a div for each c01 or c 
        It then recursively processes each child component of the c01 by 
        calling the clevel template. -->
    <xsl:template match="c" mode="detail">
			<xsl:if test="@level='Deelarchief' or @level='Afdeling' or @level='Onderafdeling' or @level='Rubriek' or @level='Subrubriek'">	
			<!--<xsl:if test="@level='Afdeling' or @level='Onderafdeling' or @level='Rubriek' or @level='Subrubriek' or @level='Deelarchief'">-->
			<a><xsl:attribute name="name">lnk_<xsl:value-of select="@id"/></xsl:attribute></a>
		</xsl:if>	
		<xsl:for-each select="did">
					<xsl:if test="../@level='Deelarchief' or ../@level='Afdeling' or ../@level='Onderafdeling' or ../@level='Rubriek' or ../@level='Subrubriek' or ../@level='Reeks' or ../@level='Deelreeks'">
					<table cellspacing="0" cellpadding="0">
					<xsl:attribute name="class"><xsl:value-of select="../@level"/></xsl:attribute>
						<xsl:if test="unittitle[@label='Titel']/p/text()">
							<tr>
					
								<xsl:if test="string(unitid)">
									<td valign="top">
										<xsl:if test="not(contains(../../../@level,'meervoudige beschrijving'))">									
										<b><a><xsl:attribute name="href"><xsl:value-of select="$XML_SCOPE_OPAC"/><xsl:value-of select="../@id"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute>
										<xsl:value-of select="unitid"/></a><xsl:if test="substring(unitid,string-length(unitid),1) != '.'"><xsl:value-of select="'.'"/></xsl:if>&#160;</b></xsl:if>
										<xsl:if test="(contains(../../../@level,'meervoudige beschrijving'))">
										<a><xsl:attribute name="href"><xsl:value-of select="$XML_SCOPE_OPAC"/><xsl:value-of select="../@id"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute>
										<xsl:value-of select="unitid"/></a><xsl:if test="substring(unitid,string-length(unitid),1) != '.'"><xsl:value-of select="'.'"/></xsl:if>&#160;</xsl:if>
									</td>
									<td>
										<xsl:if test="unittitle[@label='Formele titel']/p/text()">
											<xsl:value-of select="'&quot;'"/><xsl:value-of select="unittitle[@label='Formele titel']/p/text()"/><xsl:value-of select="'&quot;'"/><xsl:text>. </xsl:text></xsl:if>
										<xsl:value-of select="unittitle[@label='Titel']/p/text()"/>							
									<br/>	
									</td>	
									</xsl:if>
									<xsl:if test="not(string(unitid))">
										<td valign="top">
										<b>
										<a><xsl:attribute name="href"><xsl:value-of select="$XML_SCOPE_OPAC"/><xsl:value-of select="../@id"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute>
										<xsl:if test="unittitle[@label='Formele titel']/p/text()">
											<xsl:value-of select="'&quot;'"/><xsl:value-of select="unittitle[@label='Formele titel']/p/text()"/><xsl:value-of select="'&quot;'"/><xsl:text>. </xsl:text></xsl:if>
										<xsl:value-of select="unittitle[@label='Titel']/p/text()"/>							
										</a>
										</b>
										<br/>	
										</td>										
									</xsl:if>
							</tr>
						</xsl:if>
						<xsl:if test="../@level = 'Subrubriek' or ../@level = 'Reeks' or ../@level = 'Deelreeks'">
						
						<xsl:if test="unitdate[@label='Datum']/p/text()">
							<tr>
								<xsl:if test="string(unitid)">
									<td valign="top">&#160;</td>
								</xsl:if>
								<td valign="top">
									<b>
										<xsl:for-each select="unitdate[@label='Datum']/p/text()">
										<xsl:value-of select="."/><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
										</xsl:for-each>
									<xsl:if test="physdesc/physfacet/p/text()">
										<xsl:for-each select="physdesc/physfacet/p/text()">
											<xsl:value-of select="."/>
											<xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
											<xsl:if test="position()=last()"><xsl:text>. </xsl:text></xsl:if>
										</xsl:for-each>
									</xsl:if>															
									</b>
								</td>
							</tr>
						</xsl:if>
						</xsl:if>

						<xsl:if test="dao">
						<tr>
								<xsl:if test="string(unitid)">
									<td valign="top">&#160;</td>
								</xsl:if>
								
							<td valign="top">	
								<xsl:for-each select="dao">
									<a>
									<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
									<xsl:attribute name="target">_blank</xsl:attribute>
									<xsl:value-of select="@title"/>
									</a>
									<xsl:if test="position()!=last()"><br/></xsl:if>
								</xsl:for-each>
							</td>
						</tr>
						</xsl:if>									
						
						<xsl:if test="not(../@level = 'Subrubriek' or ../@level = 'Reeks' or ../@level = 'Deelreeks')">						
						<xsl:if test="physfacet/p/text()">
						<tr>
								<xsl:if test="string(unitid)">
									<td valign="top">&#160;</td>
								</xsl:if>						
							<td valign="top">
										<xsl:for-each select="physdesc/physfacet/p/text()">
											<xsl:value-of select="."/>
											<xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
											<xsl:if test="position()=last()"><xsl:text>. </xsl:text></xsl:if>
										</xsl:for-each>
							</td>
						</tr>
						</xsl:if>
						</xsl:if>							
						<xsl:if test="physdesc/extent/p/text()">
						<tr>
								<xsl:if test="string(unitid)">
									<td valign="top">&#160;</td>
								</xsl:if>						
							<td valign="top">	
								<xsl:for-each select="physdesc/extent/p/text()">
								<xsl:value-of select="."/>
									<xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
								</xsl:for-each>
							</td>
						</tr>
						</xsl:if>	
						<xsl:for-each select="relatedmaterial/archref">
						<tr>
								<xsl:if test="string(unitid)">
									<td valign="top">&#160;</td>
								</xsl:if>						
						<td>
							<xsl:if test="string(note)">[<xsl:value-of select="note"/>]&#160;:&#160;</xsl:if>
							<a>
								<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute>
								<xsl:value-of select="unittitle"/>
							</a>
						</td>
						</tr>						
						</xsl:for-each>
			            <xsl:if test="controlaccess">
						    	<xsl:if test="string(unitid)">
									<tr><td colspan="2"><br/><b><a name="DISP_TITEL_7_4_C"><xsl:copy-of select="$DISP_TITEL_7_4"/></a></b><br/></td></tr>
								</xsl:if>
						    	<xsl:if test="not(string(unitid))">
									<tr><td><br/><b><a name="DISP_TITEL_7_4_C"><xsl:copy-of select="$DISP_TITEL_7_4"/></a></b><br/></td></tr>
								</xsl:if>								
							<xsl:for-each select="controlaccess/controlaccess">
								<tr>
								<td><br/><xsl:value-of select="head"/><br/></td></tr>
								<xsl:if test="head !='Subjects' and head !='Families'">
								<xsl:for-each select="extref">
								<tr>
								<td>
								<xsl:if test="string(@href)">
								<a>
									<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
									<xsl:attribute name="target">_blank</xsl:attribute>
									<xsl:value-of select="*/."/>
								</a>
								</xsl:if>
								<xsl:if test="not(string(@href))">
								<xsl:value-of select="*/."/>
								</xsl:if>
								<xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
								</td>
								</tr>
								</xsl:for-each>
								</xsl:if>
								<xsl:if test="head ='Subjects'">
								<xsl:for-each select="subject">
								<tr><td><xsl:value-of select="."/></td></tr>
								</xsl:for-each>
								</xsl:if>
								<xsl:if test="head ='Families'">
								<xsl:for-each select="famname">
								<tr><td><xsl:value-of select="."/></td></tr>
								</xsl:for-each>
								</xsl:if>								
							</xsl:for-each>	
						</xsl:if>						
						</table>
						<br/>
					</xsl:if>		
					<xsl:if test="../@level='Reeks - meervoudige beschrijving' or ../@level='Deelreeks - meervoudige beschrijving' or ../@level='Bestanddeel' or ../@level='Bestanddeel - meervoudige beschrijving' or ../@level='Subbestanddeel' or ../@level='Subbestanddeel - meervoudige beschrijving' or ../@level='Stuk'">
						<table cellspacing="0" cellpadding="0">
						<xsl:attribute name="class"><xsl:value-of select="../@level"/></xsl:attribute>
						
							<tr>
					
								<xsl:if test="string(unitid)">
									<td valign="top">
										<xsl:if test="not(contains(../../../@level,'meervoudige beschrijving'))">									
										<b><a><xsl:attribute name="href"><xsl:value-of select="$XML_SCOPE_OPAC"/><xsl:value-of select="../@id"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute>
										<xsl:value-of select="unitid"/></a><xsl:if test="substring(unitid,string-length(unitid),1) != '.'"><xsl:value-of select="'.'"/></xsl:if>&#160;</b></xsl:if>
										<xsl:if test="(contains(../../../@level,'meervoudige beschrijving'))">
										<a><xsl:attribute name="href"><xsl:value-of select="$XML_SCOPE_OPAC"/><xsl:value-of select="../@id"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute>
										<xsl:value-of select="unitid"/></a><xsl:if test="substring(unitid,string-length(unitid),1) != '.'"><xsl:value-of select="'.'"/></xsl:if>&#160;</xsl:if>
									</td>
									<td>
										<xsl:if test="unittitle[@label='Formele titel']/p/text()">
											<xsl:value-of select="'&quot;'"/><xsl:value-of select="unittitle[@label='Formele titel']/p/text()"/><xsl:value-of select="'&quot;'"/><xsl:text>. </xsl:text></xsl:if>
										<xsl:value-of select="unittitle[@label='Titel']/p/text()"/>							
									<br/>	
									</td>	
									</xsl:if>
									<xsl:if test="not(string(unitid))">
										<td valign="top">
										<b>
										<a><xsl:attribute name="href"><xsl:value-of select="$XML_SCOPE_OPAC"/><xsl:value-of select="../@id"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute>
										<xsl:if test="unittitle[@label='Formele titel']/p/text()">
											<xsl:value-of select="'&quot;'"/><xsl:value-of select="unittitle[@label='Formele titel']/p/text()"/><xsl:value-of select="'&quot;'"/><xsl:text>. </xsl:text></xsl:if>
										<xsl:value-of select="unittitle[@label='Titel']/p/text()"/>							
										</a>
										</b>
										<br/>	
										</td>										
									</xsl:if>
							</tr>						
						
						<xsl:if test="unitdate[@label='Datum']/p/text()">
						<tr>
								<xsl:if test="string(unitid)">
									<td valign="top">&#160;</td>
								</xsl:if>
							<td valign="top">
												<xsl:for-each select="unitdate[@label='Datum']/p/text()">
													<xsl:value-of select="."/>
													<xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
													<xsl:if test="position()=last()"><xsl:if test="substring(.,string-length(.),1) != '.'"><xsl:value-of select="'.'"/></xsl:if>&#160;</xsl:if>
												</xsl:for-each>
												<xsl:if test="physdesc/physfacet/p/text()">
																<xsl:for-each select="physdesc/physfacet/p/text()">
																	<xsl:value-of select="."/>
																	<xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
																	<xsl:if test="position()=last()"><xsl:text>. </xsl:text></xsl:if>
																</xsl:for-each>
												</xsl:if>		
							</td>
						</tr>
						</xsl:if>
						
						<xsl:if test="not(unitdate[@label='Datum']/p/text())">
						<xsl:if test="physdesc/physfacet/p/text()">
						<tr>
								<xsl:if test="string(unitid)">
									<td valign="top">&#160;</td>
								</xsl:if>
							<td valign="top">
												
																<xsl:for-each select="physdesc/physfacet/p/text()">
																	<xsl:value-of select="."/>
																	<xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
																	<xsl:if test="position()=last()"><xsl:text>. </xsl:text></xsl:if>
																</xsl:for-each>
							</td>
						</tr>
						</xsl:if>																						
						</xsl:if>

						<xsl:if test="dao">
						<tr>
								<xsl:if test="string(unitid)">
									<td valign="top">&#160;</td>
								</xsl:if>
								
							<td valign="top">	
								<xsl:for-each select="dao">
									<a>
									<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
									<xsl:attribute name="target">_blank</xsl:attribute>
									<xsl:value-of select="@title"/>
									</a>
									<xsl:if test="position()!=last()"><br/></xsl:if>
								</xsl:for-each>
							</td>
						</tr>
						</xsl:if>						
						<xsl:if test="physdesc/extent/p/text()">
						<tr>
								<xsl:if test="string(unitid)">
									<td valign="top">&#160;</td>
								</xsl:if>
							<td valign="top">	
												<xsl:for-each select="physdesc/extent/p/text()">
													<xsl:value-of select="."/>
													<xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
												</xsl:for-each>
							</td>
						</tr>
						</xsl:if>
						
						    <xsl:if test="scopecontent[@label='Inhoud']/p/text()">
						        <tr>
									<xsl:if test="string(unitid)">
										<td valign="top">&#160;</td>
									</xsl:if>
						            <td valign="top">
												<xsl:for-each select="scopecontent[@label='Inhoud']/p/text()">
													<xsl:call-template name="substitute">
														<xsl:with-param name="string" select="." />
													</xsl:call-template>
													<xsl:if test="position()!=last()"><br/></xsl:if>
													</xsl:for-each>
						            </td>
						        </tr>
						    </xsl:if>						    
						<xsl:for-each select="relatedmaterial/archref">
						<tr>
								<xsl:if test="string(unitid)">
									<td valign="top">&#160;</td>
								</xsl:if>
						<td>
												
							<xsl:if test="string(note)">[<xsl:value-of select="note"/>]&#160;:&#160;</xsl:if>
							<a>
								<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute>
								<xsl:value-of select="unittitle"/>
							</a>
						</td>
						</tr>						
						</xsl:for-each>
			            <xsl:if test="controlaccess">
						    	<xsl:if test="string(unitid)">
									<tr><td colspan="2"><br/><b><a name="DISP_TITEL_7_4_C"><xsl:copy-of select="$DISP_TITEL_7_4"/></a></b><br/></td></tr>
								</xsl:if>
						    	<xsl:if test="not(string(unitid))">
									<tr><td><br/><b><a name="DISP_TITEL_7_4_C"><xsl:copy-of select="$DISP_TITEL_7_4"/></a></b><br/></td></tr>
								</xsl:if>												
							
							<xsl:for-each select="controlaccess/controlaccess">
								<tr><td><br/><xsl:value-of select="head"/><br/></td></tr>
								<xsl:if test="head !='Subjects' and head !='Families'">
								<xsl:for-each select="extref">
								<tr>
								<td>
								<xsl:if test="string(@href)">
								<a>
									<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
									<xsl:attribute name="target">_blank</xsl:attribute>
									<xsl:value-of select="*/."/>
								</a>
								</xsl:if>
								<xsl:if test="not(string(@href))">
								<xsl:value-of select="*/."/>
								</xsl:if>
								<xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
								</td>
								</tr>
								</xsl:for-each>
								</xsl:if>
								<xsl:if test="head ='Subjects'">
								<xsl:for-each select="subject">
								<tr><td><xsl:value-of select="."/></td></tr>
								</xsl:for-each>
								</xsl:if>
								<xsl:if test="head ='Families'">
								<xsl:for-each select="famname">
								<tr><td><xsl:value-of select="."/></td></tr>
								</xsl:for-each>
								</xsl:if>								
							</xsl:for-each>	
						</xsl:if>							
						</table>
						<br/>
					</xsl:if>		
					<xsl:apply-templates select="c" mode="detail"/>
			</xsl:for-each>
    </xsl:template>
	
    <!--This is a named template that processes all c0* elements  -->
    <xsl:template name="clevel">
    <!-- Establishes which level is being processed in order to provided indented displays. 
        Indents handled by CSS margins-->
        <xsl:variable name="clevelMargin">c</xsl:variable>
    <!-- Establishes a class for even and odd rows in the table for color coding. 
        Colors are Declared in the CSS. -->
        <xsl:variable name="colorClass">
            <xsl:choose>
                <xsl:when test="ancestor-or-self::*[@level='Bestanddeel' or @level='item']">
                    <xsl:choose>
                        <xsl:when test="(position() mod 2 = 0)">odd</xsl:when>
                        <xsl:otherwise>even</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- Processes the all child elements of the c or c0* level -->
        <xsl:for-each select=".">
            <xsl:choose>
                <!--Formats Series and Groups  -->
                <xsl:when test="@level='subcollection' or @level='subgrp' or @level='series' 
                    or @level='subseries' or @level='collection'or @level='Archief' or 
                    @level='recordgrp' or @level='subfonds' or @level='class' or (@level='otherlevel' and not(child::did/container))">
                    <tr> 
                        <xsl:attribute name="class">
                            <xsl:choose>
                                <xsl:when test="@level='subcollection' or @level='subgrp' or @level='subseries' or @level='subfonds'">subseries</xsl:when>
                                <xsl:otherwise>series</xsl:otherwise>
                            </xsl:choose>    
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="did/container">
                            <td class="{$clevelMargin}">
                            <xsl:choose>                                
                                <xsl:when test="count(did/container) &lt; 1">
                                    <xsl:attribute name="colspan">
                                        <xsl:text>4</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:when test="count(did/container) =1">
                                    <xsl:attribute name="colspan">
                                        <xsl:text>3</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:when test="count(did/container) = 2">
                                    <xsl:attribute name="colspan">
                                        <xsl:text>2</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise/>
                            </xsl:choose>    
                                <xsl:call-template name="anchor"/>
                                <xsl:apply-templates select="did" mode="dsc"/>
                                <xsl:apply-templates select="child::*[not(did) and not(self::did)]"/>
                            </td>
                            <xsl:for-each select="descendant::did[container][1]/container">    
                                <td class="containerHeader">    
                                    <xsl:value-of select="@type"/><br/><xsl:value-of select="."/>       
                                </td>    
                            </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <td colspan="4" class="{$clevelMargin}">
                                    <xsl:call-template name="anchor"/>
                                    <xsl:apply-templates select="did" mode="dsc"/>
                                    <xsl:apply-templates select="child::*[not(did) and not(self::did)]"/>
                                </td>
                            </xsl:otherwise>
                        </xsl:choose>
                    </tr>
                </xsl:when>
                <!-- Items/Files--> 
                <xsl:when test="@level='Bestanddeel' or @level='item' or (@level='otherlevel'and child::did/container)">
                  <!-- Variables to  for Conainer headings, used only if headings are different from preceding heading -->
                   <xsl:variable name="container" select="string(did/container/@type)"/>
                   <xsl:variable name="sibContainer" select="string(preceding-sibling::*[1]/did/container/@type)"/>
                   <xsl:if test="$container != $sibContainer">
                        <xsl:if test="did/container">
                            <tr>
                                <td class="title">
                                    <xsl:choose>                                
                                        <xsl:when test="count(did[container][1]/container) &lt; 1">
                                            <xsl:attribute name="colspan">
                                                <xsl:text>4</xsl:text>
                                            </xsl:attribute>
                                        </xsl:when>
                                        <xsl:when test="count(did[container][1]/container) =1">
                                            <xsl:attribute name="colspan">
                                                <xsl:text>3</xsl:text>
                                            </xsl:attribute>
                                        </xsl:when>
                                        <xsl:when test="count(did[container][1]/container) = 2">
                                            <xsl:attribute name="colspan">
                                                <xsl:text>2</xsl:text>
                                            </xsl:attribute>
                                        </xsl:when>
                                        <xsl:otherwise/>
                                    </xsl:choose>    
                                    <xsl:text/>
                                </td>
                                <xsl:for-each select="did/container">    
                                    <td class="containerHeader">    
                                        <xsl:value-of select="@type"/>
                                    </td>    
                                </xsl:for-each>
                            </tr>
                        </xsl:if> 
                  </xsl:if>
                    <tr class="{$colorClass}"> 
                        <td class="{$clevelMargin}">
                            <xsl:choose>
                                <xsl:when test="count(did/container) &lt; 1">
                                    <xsl:attribute name="colspan">
                                        <xsl:text>4</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:when test="count(did/container) =1">
                                    <xsl:attribute name="colspan">
                                        <xsl:text>3</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:when test="count(did/container) = 2">
                                    <xsl:attribute name="colspan">
                                        <xsl:text>2</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise/>
                            </xsl:choose>                            
                            <xsl:apply-templates select="did" mode="dsc"/>  
                            <xsl:apply-templates select="*[not(self::did) and 
                                not(self::c) and not(self::c02) and not(self::c03) and
                                not(self::c04) and not(self::c05) and not(self::c06) and not(self::c07)
                                and not(self::c08) and not(self::c09) and not(self::c10) and not(self::c11) and not(self::c12)]"/>  
                        </td>
                        <!-- Containers -->    
                        <xsl:for-each select="did/container">    
                            <td class="container">    
                                <xsl:value-of select="."/>        
                            </td>    
                        </xsl:for-each>
                    </tr>  
                </xsl:when>
                <xsl:otherwise>
                    <tr class="{$colorClass}"> 
                        <td class="{$clevelMargin}" colspan="4">
                            <xsl:apply-templates select="did" mode="dsc"/>
                            <xsl:apply-templates select="*[not(self::did) and 
                                not(self::c) and not(self::c02) and not(self::c03) and
                                not(self::c04) and not(self::c05) and not(self::c06) and not(self::c07)
                                and not(self::c08) and not(self::c09) and not(self::c10) and not(self::c11) and not(self::c12)]"/>  
                        </td>
                    </tr>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="did" mode="dsc">
        <xsl:choose>
            <xsl:when test="../@level='subcollection' or ../@level='subgrp' or ../@level='series' 
                or ../@level='subseries'or ../@level='collection'or ../@level='Archief' or 
                ../@level='recordgrp' or ../@level='subfonds'">    
                <h4>
                    <xsl:call-template name="component-did-core"/>
                </h4>
            </xsl:when>
            <!--Otherwise render the text in its normal font.-->
            <xsl:otherwise>
                <p><xsl:call-template name="component-did-core"/></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="component-did-core">
        <!--Inserts unitid and a space if it exists in the markup.-->
        <xsl:if test="unitid">
            <xsl:apply-templates select="unitid"/>
            <xsl:text>&#160;</xsl:text>
        </xsl:if>
        <!--Inserts origination and a space if it exists in the markup.-->
        <xsl:if test="origination">
            <xsl:apply-templates select="origination"/>
            <xsl:text>&#160;</xsl:text>
        </xsl:if>
        <!--This choose statement selects between cases where unitdate is a child of unittitle and where it is a separate child of did.-->
        <xsl:choose>
            <!--This code processes the elements when unitdate is a child of unittitle.-->
            <xsl:when test="unittitle/unitdate">
                <xsl:apply-templates select="unittitle"/>
            </xsl:when>
            <!--This code process the elements when unitdate is not a child of untititle-->
            <xsl:otherwise>
                <xsl:apply-templates select="unittitle"/>
                <xsl:text>&#160;</xsl:text>
                <xsl:for-each select="unitdate[not(self::unitdate[@type='bulk'])]">
                    <xsl:apply-templates/>
                    <xsl:text>&#160;</xsl:text>
                </xsl:for-each>
                <xsl:for-each select="unitdate[@type = 'bulk']">
                    (<xsl:apply-templates/>)
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="physdesc">
            <xsl:text>&#160;</xsl:text>
            <xsl:apply-templates select="physdesc"/>
        </xsl:if>
    </xsl:template>
	
    <xsl:template match="archdesc/descgrp" mode="main">
		<xsl:if test="head=$TITEL_1">
			<a class="ech5" name="DISP_TITEL_1"><xsl:copy-of select="$DISP_TITEL_1"/></a>
			<br/>
			<a class="ech6" name="DISP_TITEL_1_1"><xsl:copy-of select="$DISP_TITEL_1_1"/></a>
			<p class="ech6nb"><xsl:apply-templates select="unitid/@repositorycode"/><br/>
			<xsl:apply-templates select="repository/corpname"/></p>
			<xsl:if test="unititle">
			<a class="ech6" name="DISP_TITEL_1_2"><xsl:copy-of select="$DISP_TITEL_1_2"/></a>
			<p class="ech6nb"><xsl:apply-templates select="unittitle"/></p>
			</xsl:if>
			<xsl:if test="unitdate">
			<a class="ech6" name="DISP_TITEL_1_3"><xsl:copy-of select="$DISP_TITEL_1_3"/></a>
			<p class="ech6nb"><xsl:apply-templates select="unitdate"/></p>
			</xsl:if>
			<xsl:if test="physdesc/extent[@label='Omvang']">
			<a class="ech6" name="DISP_TITEL_1_4"><xsl:copy-of select="$DISP_TITEL_1_4"/></a>
			<p class="ech6nb"><xsl:apply-templates select="physdesc/extent[@label='Omvang']"/></p>
			</xsl:if>
			<xsl:if test="physdesc/extent[@label='Opmerkingen']/p/text()">
				<p class="ech6"><xsl:copy-of select="$DISP_TITEL_OPM"/></p>
				<p class="ech6nb"><xsl:apply-templates select="physdesc/extent[@label='Opmerkingen']"/></p>				
			</xsl:if>
			<xsl:if test="physdesc/extent[@label='Aard archief']/p/text()">
				<p class="ech6"><xsl:copy-of select="$DISP_TITEL_AARD"/></p>
				<p class="ech6nb"><xsl:apply-templates select="physdesc/extent[@label='Aard archief']"/></p>				
			</xsl:if>			
			<xsl:call-template name="returnTOC"/>
		</xsl:if>	
		
		
		<xsl:if test="head=$TITEL_2">
			<a class="ech5" name="DISP_TITEL_2"><xsl:copy-of select="$DISP_TITEL_2"/></a>
			<br/>
			<xsl:if test="origination">
				<a class="ech6" name="DISP_TITEL_2_1"><xsl:copy-of select="$DISP_TITEL_2_1"/></a>
				<p class="ech6nb"><xsl:apply-templates select="origination/extref"/></p>
			</xsl:if>
			<xsl:if test="bioghist/p/text()">
				<a class="ech6" name="DISP_TITEL_2_2"><xsl:copy-of select="$DISP_TITEL_2_2"/></a>
				<p class="ech6nb"><xsl:apply-templates select="bioghist"/></p>
			</xsl:if>
			<xsl:if test="custodhist/p/text()">
				<a class="ech6" name="DISP_TITEL_2_3"><xsl:copy-of select="$DISP_TITEL_2_3"/></a>
				<p class="ech6nb"><xsl:apply-templates select="custodhist"/></p>
			</xsl:if>
			<xsl:if test="acqinfo/p/text()">
				<a class="ech6" name="DISP_TITEL_2_4"><xsl:copy-of select="$DISP_TITEL_2_4"/></a>
				<p class="ech6nb"><xsl:apply-templates select="acqinfo"/></p>
			</xsl:if>
			<xsl:call-template name="returnTOC"/>			
		</xsl:if>	
		<xsl:if test="head=$TITEL_3">
			<a class="ech5" name="DISP_TITEL_3"><xsl:copy-of select="$DISP_TITEL_3"/></a>
			<br/>
			<xsl:if test="scopecontent/head=$TITEL_3_1">
				<a class="ech6" name="DISP_TITEL_3_1"><xsl:copy-of select="$DISP_TITEL_3_1"/></a>
				<p class="ech6nb"><xsl:apply-templates select="scopecontent/scopecontent[@label='Bereik en inhoud']"/></p>
				<xsl:if test="scopecontent/scopecontent[@label='Geografische informatie']/p/text()">
					<p class="ech6"><xsl:copy-of select="$DISP_TITEL_GEO"/></p>
					<p class="ech6nb"><xsl:apply-templates select="scopecontent/scopecontent[@label='Geografische informatie']"/></p>
				</xsl:if>	
				<xsl:if test="scopecontent/scopecontent[@label='Collectie periode']/p/text()">
					<p class="ech6"><xsl:copy-of select="$DISP_TITEL_COLL"/></p>
					<p class="ech6nb"><xsl:apply-templates select="scopecontent/scopecontent[@label='Collectie periode']"/></p>
				</xsl:if>
				<xsl:if test="scopecontent/scopecontent[@label='Gerelateerde organisaties/families/personen']/p/text()">
					<p class="ech6"><xsl:copy-of select="$DISP_TITEL_REL"/></p>
					<p class="ech6nb"><xsl:apply-templates select="scopecontent/scopecontent[@label='Gerelateerde organisaties/families/personen']"/></p>
				</xsl:if>
			</xsl:if>			
		
			<xsl:if test="appraisal/head=$TITEL_3_2">
				<a class="ech6" name="DISP_TITEL_3_2"><xsl:copy-of select="$DISP_TITEL_3_2"/></a>
				<p class="ech6nb"><xsl:apply-templates select="appraisal"/></p>
			</xsl:if>	
	
			<xsl:if test="accruals/head=$TITEL_3_3">
				<a class="ech6" name="DISP_TITEL_3_3"><xsl:copy-of select="$DISP_TITEL_3_3"/></a>
				<p class="ech6nb"><xsl:apply-templates select="accruals"/></p>
			</xsl:if>
			<xsl:if test="arrangement/head=$TITEL_3_4">
				<a class="ech6" name="DISP_TITEL_3_4"><xsl:copy-of select="$DISP_TITEL_3_4"/></a>
				<p class="ech6nb"><xsl:apply-templates select="arrangement"/></p>
			</xsl:if>
			<xsl:call-template name="returnTOC"/>				
		</xsl:if>
		<xsl:if test="head=$TITEL_4">
			<a class="ech5" name="DISP_TITEL_4"><xsl:copy-of select="$DISP_TITEL_4"/></a>
			<br/>
			<xsl:if test="accessrestrict/head=$TITEL_4_1">
				<a class="ech6" name="DISP_TITEL_4_1"><xsl:copy-of select="$DISP_TITEL_4_1"/></a>
				<p class="ech6nb"><xsl:apply-templates select="accessrestrict"/></p>
			</xsl:if>
			<xsl:if test="userestrict/head=$TITEL_4_2">
				<a class="ech6" name="DISP_TITEL_4_2"><xsl:copy-of select="$DISP_TITEL_4_2"/></a>
				<p class="ech6nb"><xsl:apply-templates select="userestrict"/></p>
			</xsl:if>
			<xsl:if test="langmaterial/head=$TITEL_4_3">
				<a class="ech6" name="DISP_TITEL_4_3"><xsl:copy-of select="$DISP_TITEL_4_3"/></a>
				<p class="ech6nb"><xsl:apply-templates select="langmaterial"/></p>
			</xsl:if>
			<xsl:if test="phystech/head=$TITEL_4_4">
				<a class="ech6" name="DISP_TITEL_4_4"><xsl:copy-of select="$DISP_TITEL_4_4"/></a>
				<p class="ech6nb"><xsl:apply-templates select="phystech"/></p>
			</xsl:if>
			<!--
			<xsl:if test="otherfindaid/head=$TITEL_4_5">
				<a class="ech6" name="DISP_TITEL_4_5"><xsl:copy-of select="$DISP_TITEL_4_5"/></a>
				<p class="ech6nb"><xsl:apply-templates select="otherfindaid"/></p>
			</xsl:if>
			-->
			<xsl:call-template name="returnTOC"/>
		</xsl:if>
		
		<xsl:if test="head=$TITEL_5">
			<a class="ech5" name="DISP_TITEL_5"><xsl:copy-of select="$DISP_TITEL_5"/></a>
			<br/>
			<xsl:if test="originalsloc/head=$TITEL_5_1">
				<a class="ech6" name="DISP_TITEL_5_1"><xsl:copy-of select="$DISP_TITEL_5_1"/></a>
				<p class="ech6nb"><xsl:apply-templates select="originalsloc"/></p>
			</xsl:if>
			<xsl:if test="altformavail/head=$TITEL_5_2">
				<a class="ech6" name="DISP_TITEL_5_2"><xsl:copy-of select="$DISP_TITEL_5_2"/></a>
				<p class="ech6nb"><xsl:apply-templates select="altformavail"/></p>
			</xsl:if>
			<xsl:if test="relatedmaterial/head=$TITEL_5_3">
				<a class="ech6" name="DISP_TITEL_5_3"><xsl:copy-of select="$DISP_TITEL_5_3"/></a>
				<p class="ech6nb"><xsl:apply-templates select="relatedmaterial"/></p>
			</xsl:if>
			<xsl:if test="bibliography/head=$TITEL_5_4">
				<a class="ech6" name="DISP_TITEL_5_4"><xsl:copy-of select="$DISP_TITEL_5_4"/></a>
				<p class="ech6nb"><xsl:apply-templates select="bibliography"/></p>
			</xsl:if>
			<xsl:call-template name="returnTOC"/>
		</xsl:if>
		<xsl:if test="head=$TITEL_6">
			<a class="ech5" name="DISP_TITEL_6"><xsl:copy-of select="$DISP_TITEL_6"/></a>
			<br/>
			<xsl:if test="note/head=$TITEL_6_1">
				<a class="ech6" name="DISP_TITEL_6_1"><xsl:copy-of select="$DISP_TITEL_6_1"/></a>
				<p class="ech6nb"><xsl:apply-templates select="note"/></p>
			</xsl:if>
			<xsl:call-template name="returnTOC"/>
		</xsl:if>
				
	
		<xsl:if test="head=$TITEL_7">
			<a class="ech5" name="DISP_TITEL_7"><xsl:copy-of select="$DISP_TITEL_7"/></a>
			<br/>
			<xsl:if test="processinfo[@label='Verantwoording']/head=$TITEL_7_1">
				<xsl:if test="processinfo[@label='Verantwoording']/p/text()">
					<a class="ech6" name="DISP_TITEL_7_1"><xsl:copy-of select="$DISP_TITEL_7_1"/></a>
					<p class="ech6nb"><xsl:apply-templates select="processinfo[@label='Verantwoording']"/></p>
				</xsl:if>	
			</xsl:if>
			<xsl:if test="descrules/head=$TITEL_7_2">
				<a class="ech6" name="DISP_TITEL_7_2"><xsl:copy-of select="$DISP_TITEL_7_2"/></a>
				<p class="ech6nb"><xsl:apply-templates select="descrules"/></p>
			</xsl:if>
			<xsl:if test="processinfo[@label='Datering van de beschrijvingen']/head=$TITEL_7_3">
				<xsl:if test="processinfo[@label='Datering van de beschrijvingen']/p/text()">
					<a class="ech6" name="DISP_TITEL_7_3"><xsl:copy-of select="$DISP_TITEL_7_3"/></a>
					<p class="ech6nb"><xsl:apply-templates select="processinfo[@label='Datering van de beschrijvingen']"/></p>
				</xsl:if>	
			</xsl:if>
			<xsl:if test="/ead/archdesc/controlaccess">
				<a class="ech6" name="DISP_TITEL_7_4"><xsl:copy-of select="$DISP_TITEL_7_4"/></a><br/>
				<xsl:for-each select="/ead/archdesc/controlaccess/controlaccess">
					<a class="ech6"><xsl:value-of select="head"/></a>
				    <p class="ech6tref">
					<xsl:for-each select="extref">
						<a>
							<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
							<xsl:attribute name="target">_blank</xsl:attribute>
							<xsl:value-of select="*/."/>
						</a>
						<xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
					</xsl:for-each>
				    </p>    
				</xsl:for-each>	
			</xsl:if>
			<xsl:call-template name="returnTOC"/>
		</xsl:if>
	</xsl:template>	
    <xsl:template match="archdesc/descgrp" mode="c_child">
		<xsl:if test="head=$TITEL_1">
			<a class="ech5" name="DISP_TITEL_1"><xsl:copy-of select="$DISP_TITEL_1"/></a>
			<br/>
			<a class="ech6" name="DISP_TITEL_1_1"><xsl:copy-of select="$DISP_TITEL_1_1"/></a>
			<p class="ech6nb"><xsl:apply-templates select="unitid/@repositorycode"/><br/>
			<xsl:apply-templates select="repository/corpname"/></p>
			<xsl:if test="unititle">
			<a class="ech6" name="DISP_TITEL_1_2"><xsl:copy-of select="$DISP_TITEL_1_2"/></a>
			<p class="ech6nb"><xsl:apply-templates select="unittitle"/></p>
			</xsl:if>
			<xsl:if test="unitdate">
			<a class="ech6" name="DISP_TITEL_1_3"><xsl:copy-of select="$DISP_TITEL_1_3"/></a>
			<p class="ech6nb"><xsl:apply-templates select="unitdate"/></p>
			</xsl:if>
			<xsl:if test="physdesc/extent[@label='Omvang']">
			<a class="ech6" name="DISP_TITEL_1_4"><xsl:copy-of select="$DISP_TITEL_1_4"/></a>
			<p class="ech6nb"><xsl:apply-templates select="physdesc/extent[@label='Omvang']"/></p>
			</xsl:if>
			<xsl:if test="physdesc/extent[@label='Opmerkingen']/p/text()">
				<p class="ech6"><xsl:copy-of select="$DISP_TITEL_OPM"/></p>
				<p class="ech6nb"><xsl:apply-templates select="physdesc/extent[@label='Opmerkingen']"/></p>				
			</xsl:if>
			<xsl:if test="physdesc/extent[@label='Aard archief']/p/text()">
				<p class="ech6"><xsl:copy-of select="$DISP_TITEL_AARD"/></p>
				<p class="ech6nb"><xsl:apply-templates select="physdesc/extent[@label='Aard archief']"/></p>				
			</xsl:if>			
			<xsl:call-template name="returnTOC"/>
		</xsl:if>	
		
		
		<xsl:if test="head=$TITEL_2">
			<a class="ech5" name="DISP_TITEL_2"><xsl:copy-of select="$DISP_TITEL_2"/></a>
			<br/>
			<xsl:if test="origination">
				<a class="ech6" name="DISP_TITEL_2_1"><xsl:copy-of select="$DISP_TITEL_2_1"/></a>
				<p class="ech6nb"><xsl:apply-templates select="origination/extref"/></p>
			</xsl:if>
			<xsl:if test="bioghist/p/text()">
				<a class="ech6" name="DISP_TITEL_2_2"><xsl:copy-of select="$DISP_TITEL_2_2"/></a>
				<p class="ech6nb"><xsl:apply-templates select="bioghist"/></p>
			</xsl:if>
			<xsl:if test="custodhist/p/text()">
				<a class="ech6" name="DISP_TITEL_2_3"><xsl:copy-of select="$DISP_TITEL_2_3"/></a>
				<p class="ech6nb"><xsl:apply-templates select="custodhist"/></p>
			</xsl:if>
			<xsl:if test="acqinfo/p/text()">
				<a class="ech6" name="DISP_TITEL_2_4"><xsl:copy-of select="$DISP_TITEL_2_4"/></a>
				<p class="ech6nb"><xsl:apply-templates select="acqinfo"/></p>
			</xsl:if>
			<xsl:call-template name="returnTOC"/>			
		</xsl:if>	
		<xsl:if test="head=$TITEL_3">
			<a class="ech5" name="DISP_TITEL_3"><xsl:copy-of select="$DISP_TITEL_3"/></a>
			<br/>
			<xsl:if test="scopecontent/head=$TITEL_3_1">
				<a class="ech6" name="DISP_TITEL_3_1"><xsl:copy-of select="$DISP_TITEL_3_1"/></a>
				<p class="ech6nb"><xsl:apply-templates select="scopecontent/scopecontent[@label='Bereik en inhoud']"/></p>
				<xsl:if test="scopecontent/scopecontent[@label='Geografische informatie']/p/text()">
					<p class="ech6"><xsl:copy-of select="$DISP_TITEL_GEO"/></p>
					<p class="ech6nb"><xsl:apply-templates select="scopecontent/scopecontent[@label='Geografische informatie']"/></p>
				</xsl:if>	
				<xsl:if test="scopecontent/scopecontent[@label='Collectie periode']/p/text()">
					<p class="ech6"><xsl:copy-of select="$DISP_TITEL_COLL"/></p>
					<p class="ech6nb"><xsl:apply-templates select="scopecontent/scopecontent[@label='Collectie periode']"/></p>
				</xsl:if>
				<xsl:if test="scopecontent/scopecontent[@label='Gerelateerde organisaties/families/personen']/p/text()">
					<p class="ech6"><xsl:copy-of select="$DISP_TITEL_REL"/></p>
					<p class="ech6nb"><xsl:apply-templates select="scopecontent/scopecontent[@label='Gerelateerde organisaties/families/personen']"/></p>
				</xsl:if>
			</xsl:if>			
		
			<xsl:if test="appraisal/head=$TITEL_3_2">
				<a class="ech6" name="DISP_TITEL_3_2"><xsl:copy-of select="$DISP_TITEL_3_2"/></a>
				<p class="ech6nb"><xsl:apply-templates select="appraisal"/></p>
			</xsl:if>	
	
			<xsl:if test="accruals/head=$TITEL_3_3">
				<a class="ech6" name="DISP_TITEL_3_3"><xsl:copy-of select="$DISP_TITEL_3_3"/></a>
				<p class="ech6nb"><xsl:apply-templates select="accruals"/></p>
			</xsl:if>
			<xsl:if test="arrangement/head=$TITEL_3_4">
				<a class="ech6" name="DISP_TITEL_3_4"><xsl:copy-of select="$DISP_TITEL_3_4"/></a>
				<p class="ech6nb"><xsl:apply-templates select="arrangement"/></p>
			</xsl:if>
			<xsl:call-template name="returnTOC"/>				
		</xsl:if>
		<xsl:if test="head=$TITEL_4">
			<a class="ech5" name="DISP_TITEL_4"><xsl:copy-of select="$DISP_TITEL_4"/></a>
			<br/>
			<xsl:if test="accessrestrict/head=$TITEL_4_1">
				<a class="ech6" name="DISP_TITEL_4_1"><xsl:copy-of select="$DISP_TITEL_4_1"/></a>
				<p class="ech6nb"><xsl:apply-templates select="accessrestrict"/></p>
			</xsl:if>
			<xsl:if test="userestrict/head=$TITEL_4_2">
				<a class="ech6" name="DISP_TITEL_4_2"><xsl:copy-of select="$DISP_TITEL_4_2"/></a>
				<p class="ech6nb"><xsl:apply-templates select="userestrict"/></p>
			</xsl:if>
			<xsl:if test="langmaterial/head=$TITEL_4_3">
				<a class="ech6" name="DISP_TITEL_4_3"><xsl:copy-of select="$DISP_TITEL_4_3"/></a>
				<p class="ech6nb"><xsl:apply-templates select="langmaterial"/></p>
			</xsl:if>
			<xsl:if test="phystech/head=$TITEL_4_4">
				<a class="ech6" name="DISP_TITEL_4_4"><xsl:copy-of select="$DISP_TITEL_4_4"/></a>
				<p class="ech6nb"><xsl:apply-templates select="phystech"/></p>
			</xsl:if>
			<!--
			<xsl:if test="otherfindaid/head=$TITEL_4_5">
				<a class="ech6" name="DISP_TITEL_4_5"><xsl:copy-of select="$DISP_TITEL_4_5"/></a>
				<p class="ech6nb"><xsl:apply-templates select="otherfindaid"/></p>
			</xsl:if>
			-->
			<xsl:call-template name="returnTOC"/>
		</xsl:if>
		
		<xsl:if test="head=$TITEL_5">
			<a class="ech5" name="DISP_TITEL_5"><xsl:copy-of select="$DISP_TITEL_5"/></a>
			<br/>
			<xsl:if test="originalsloc/head=$TITEL_5_1">
				<a class="ech6" name="DISP_TITEL_5_1"><xsl:copy-of select="$DISP_TITEL_5_1"/></a>
				<p class="ech6nb"><xsl:apply-templates select="originalsloc"/></p>
			</xsl:if>
			<xsl:if test="altformavail/head=$TITEL_5_2">
				<a class="ech6" name="DISP_TITEL_5_2"><xsl:copy-of select="$DISP_TITEL_5_2"/></a>
				<p class="ech6nb"><xsl:apply-templates select="altformavail"/></p>
			</xsl:if>
			<xsl:if test="relatedmaterial/head=$TITEL_5_3">
				<a class="ech6" name="DISP_TITEL_5_3"><xsl:copy-of select="$DISP_TITEL_5_3"/></a>
				<p class="ech6nb"><xsl:apply-templates select="relatedmaterial"/></p>
			</xsl:if>
			<xsl:if test="bibliography/head=$TITEL_5_4">
				<a class="ech6" name="DISP_TITEL_5_4"><xsl:copy-of select="$DISP_TITEL_5_4"/></a>
				<p class="ech6nb"><xsl:apply-templates select="bibliography"/></p>
			</xsl:if>
			<xsl:call-template name="returnTOC"/>
		</xsl:if>
		<xsl:if test="head=$TITEL_6">
			<a class="ech5" name="DISP_TITEL_6"><xsl:copy-of select="$DISP_TITEL_6"/></a>
			<br/>
			<xsl:if test="note/head=$TITEL_6_1">
				<a class="ech6" name="DISP_TITEL_6_1"><xsl:copy-of select="$DISP_TITEL_6_1"/></a>
				<p class="ech6nb"><xsl:apply-templates select="note"/></p>
			</xsl:if>
			<xsl:call-template name="returnTOC"/>
		</xsl:if>
				
	
		<xsl:if test="head=$TITEL_7">
			<a class="ech5" name="DISP_TITEL_7"><xsl:copy-of select="$DISP_TITEL_7"/></a>
			<br/>
			<xsl:if test="processinfo[@label='Verantwoording']/head=$TITEL_7_1">
				<xsl:if test="processinfo[@label='Verantwoording']/p/text()">
					<a class="ech6" name="DISP_TITEL_7_1"><xsl:copy-of select="$DISP_TITEL_7_1"/></a>
					<p class="ech6nb"><xsl:apply-templates select="processinfo[@label='Verantwoording']"/></p>
				</xsl:if>	
			</xsl:if>
			<xsl:if test="descrules/head=$TITEL_7_2">
				<a class="ech6" name="DISP_TITEL_7_2"><xsl:copy-of select="$DISP_TITEL_7_2"/></a>
				<p class="ech6nb"><xsl:apply-templates select="descrules"/></p>
			</xsl:if>
			<xsl:if test="processinfo[@label='Datering van de beschrijvingen']/head=$TITEL_7_3">
				<xsl:if test="processinfo[@label='Datering van de beschrijvingen']/p/text()">
					<a class="ech6" name="DISP_TITEL_7_3"><xsl:copy-of select="$DISP_TITEL_7_3"/></a>
					<p class="ech6nb"><xsl:apply-templates select="processinfo[@label='Datering van de beschrijvingen']"/></p>
				</xsl:if>	
			</xsl:if>
			<xsl:if test="/ead/archdesc/controlaccess">
				<a class="ech6" name="DISP_TITEL_7_4"><xsl:copy-of select="$DISP_TITEL_7_4"/></a><br/>
				<xsl:for-each select="/ead/archdesc/controlaccess/controlaccess">
					<a class="ech6"><xsl:value-of select="head"/></a>
				    <p class="ech6tref">
					<xsl:for-each select="extref">
						<a>
							<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
							<xsl:attribute name="target">_blank</xsl:attribute>
							<xsl:value-of select="*/."/>
						</a>
						<xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
					</xsl:for-each>
				    </p>    
				</xsl:for-each>	
			</xsl:if>
			<xsl:call-template name="returnTOC"/>
		</xsl:if>
	<xsl:apply-templates select="c" mode="detail"/>		
	</xsl:template>		
    <!-- Template calls and formats the children of archdesc/descgrp -->
<!--	
    <xsl:template match="archdesc/descgrp/repository | archdesc/descgrp/unittitle | archdesc/descgrp/unitid | archdesc/descgrp/origination 
        | archdesc/descgrp/unitdate | archdesc/descgrp/physdesc | archdesc/descgrp/physloc 
        | archdesc/descgrp/abstract | archdesc/descgrp/langmaterial | archdesc/descgrp/materialspec | archdesc/descgrp/container">
        <dt>
            <xsl:choose>
                <xsl:when test="@label">
					<xsl:value-of select="concat(translate( substring(@label, 1, 1 ),
                        'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ), 
                        substring(@label, 2, string-length(@label )))" />
					<xsl:if test="@type"> [<xsl:value-of select="@type"/>]</xsl:if>
                    <xsl:if test="self::origination">
                        <xsl:choose>
                            <xsl:when test="persname[@role != ''] and contains(persname/@role,' (')">
                                - <xsl:value-of select="substring-before(persname/@role,' (')"/>
                            </xsl:when>
                            <xsl:when test="persname[@role != '']">
                                - <xsl:value-of select="persname/@role"/>  
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="self::repository">Repository</xsl:when>
                        <xsl:when test="self::unittitle">Title</xsl:when>
                        <xsl:when test="self::unitid">ID</xsl:when>
                        <xsl:when test="self::unitdate">Date<xsl:if test="@type"> [<xsl:value-of select="@type"/>]</xsl:if></xsl:when>
                        <xsl:when test="self::origination">
                            <xsl:choose>
                                <xsl:when test="persname[@role != ''] and contains(persname/@role,' (')">
                                    Creator - <xsl:value-of select="substring-before(persname/@role,' (')"/>
                                </xsl:when>
                                <xsl:when test="persname[@role != '']">
                                    Creator - <xsl:value-of select="persname/@role"/>  
                                </xsl:when>
                                <xsl:otherwise>
                                    Creator        
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="self::physdesc">Extent</xsl:when>
                        <xsl:when test="self::abstract">Abstract</xsl:when>
                        <xsl:when test="self::physloc">Location</xsl:when>
                        <xsl:when test="self::langmaterial">Language</xsl:when>
                        <xsl:when test="self::materialspec">Technical</xsl:when>
                        <xsl:when test="self::container">Container</xsl:when>
                        <xsl:when test="self::note">Note</xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </dt>
        <dd>
            <xsl:apply-templates/>
        </dd>
		
    </xsl:template>	
-->	
	
			
	
 <xsl:template name="prepend-pad">    
  <!-- recursive template to right justify and prepend-->
  <!-- the value with whatever padChar is passed in   -->
    <xsl:param name="padChar"> </xsl:param>
    <xsl:param name="padVar"/>
    <xsl:param name="length"/>
    <xsl:choose>
      <xsl:when test="string-length($padVar) &lt; $length">
        <xsl:call-template name="prepend-pad">
          <xsl:with-param name="padChar" select="$padChar"/>
          <xsl:with-param name="padVar" select="concat($padChar,$padVar)"/>
          <xsl:with-param name="length" select="$length"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of 
	  select="substring($padVar,string-length($padVar) -
	  $length + 1)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="append-pad">    
  <!-- recursive template to left justify and append  -->
  <!-- the value with whatever padChar is passed in   -->
    <xsl:param name="padChar"> </xsl:param>
    <xsl:param name="padVar"/>
    <xsl:param name="length"/>
    <xsl:choose>
      <xsl:when test="string-length($padVar) &lt; $length">
        <xsl:call-template name="append-pad">
          <xsl:with-param name="padChar" select="$padChar"/>
          <xsl:with-param name="padVar" select="concat($padVar,$padChar)"/>
          <xsl:with-param name="length" select="$length"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="substring($padVar,1,$length)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
	<xsl:template match="langmaterial | appraisal | accruals | arrangement | accessrestrict | userestrict | phystech | otherfindaid
	 | originalsloc | altformavail | relatedmaterial | bibliography | note | processinfo[@label='Verantwoording'] | descrules 
	 | processinfo[@label='Datering van de beschrijvingen'] | bioghist | custodhist |acqinfo 
	 | scopecontent/scopecontent[@label='Bereik en inhoud'] | scopecontent/scopecontent[@label='Geografische informatie']
	 | scopecontent/scopecontent[@label='Collectie periode'] | scopecontent/scopecontent[@label='Gerelateerde organisaties/families/personen']
	 | unittitle | unitdate | physdesc/extent[@label='Omvang'] | physdesc/extent[@label='Opmerkingen'] | physdesc/extent[@label='Aard archief']">
		<xsl:for-each select="archref">
		<xsl:if test="string(note)">
		<xsl:value-of select="note"/>&#160;:&#160;
		</xsl:if>
		<a>
			<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute>
			<xsl:value-of select="unittitle"/>
		</a>
		<br/>
		</xsl:for-each>
		<xsl:for-each select="p">
		<!--<xsl:value-of select="." disable-output-escaping="yes"/>-->
			<xsl:call-template name="replace-dest"> <!-- imported template -->
					<xsl:with-param name="text" select="."/>
			</xsl:call-template>

		<xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
		</xsl:for-each>	
	</xsl:template>  
    <!-- Template calls and formats all other children of archdesc many of 
        these elements are repeatable within the dsc section as well.-->
    <xsl:template match="odd | fileplan | separatedmaterial">        
        <xsl:choose>
            <xsl:when test="head"><xsl:apply-templates/></xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="parent::archdesc">
                            <xsl:choose>
                                <xsl:when test="self::bibliography"><h3><xsl:call-template name="anchor"/>Bibliography</h3></xsl:when>
                                <xsl:when test="self::odd"><h3><xsl:call-template name="anchor"/>Other Descriptive Data</h3></xsl:when>
                                <xsl:when test="self::accruals"><h4><xsl:call-template name="anchor"/>Accruals</h4></xsl:when>
                                <xsl:when test="self::arrangement"><h3><xsl:call-template name="anchor"/>Arrangement</h3></xsl:when>
                                <xsl:when test="self::bioghist"><h3><xsl:call-template name="anchor"/>Biography/History</h3></xsl:when>
                                <xsl:when test="self::accessrestrict"><h4><xsl:call-template name="anchor"/>Restrictions on Access</h4></xsl:when>
                                <xsl:when test="self::userestrict"><h4><xsl:call-template name="anchor"/>Restrictions on Use</h4></xsl:when>
                                <xsl:when test="self::custodhist"><h4><xsl:call-template name="anchor"/>Custodial History</h4></xsl:when>
                                <xsl:when test="self::altformavail"><h4><xsl:call-template name="anchor"/>Alternative Form Available</h4></xsl:when>
                                <xsl:when test="self::originalsloc"><h4><xsl:call-template name="anchor"/>Original Location</h4></xsl:when>
                                <xsl:when test="self::fileplan"><h3><xsl:call-template name="anchor"/>File Plan</h3></xsl:when>
                                <xsl:when test="self::acqinfo"><h4><xsl:call-template name="anchor"/>Acquisition Information</h4></xsl:when>
                                <xsl:when test="self::otherfindaid"><h3><xsl:call-template name="anchor"/>Other Finding Aids</h3></xsl:when>
                                <xsl:when test="self::phystech"><h3><xsl:call-template name="anchor"/>Physical Characteristics and Technical Requirements</h3></xsl:when>
                                <xsl:when test="self::processinfo"><h4><xsl:call-template name="anchor"/>Processing Information</h4></xsl:when>
                                <xsl:when test="self::relatedmaterial"><h4><xsl:call-template name="anchor"/>1Related Material</h4></xsl:when>
                                <xsl:when test="self::scopecontent"><h3><xsl:call-template name="anchor"/>Scope and Content</h3></xsl:when>
                                <xsl:when test="self::separatedmaterial"><h4><xsl:call-template name="anchor"/>Separated Material</h4></xsl:when>
                                <xsl:when test="self::appraisal"><h4><xsl:call-template name="anchor"/>Appraisal</h4></xsl:when>                        
                            </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <h4><xsl:call-template name="anchor"/>
                            <xsl:choose>
                                <xsl:when test="self::bibliography">Bibliography</xsl:when>
                                <xsl:when test="self::odd">Other Descriptive Data</xsl:when>
                                <xsl:when test="self::accruals">Accruals</xsl:when>
                                <xsl:when test="self::arrangement">Arrangement</xsl:when>
                                <xsl:when test="self::bioghist">Biography/History</xsl:when>
                                <xsl:when test="self::accessrestrict">Restrictions on Access</xsl:when>
                                <xsl:when test="self::userestrict">Restrictions on Use</xsl:when>
                                <xsl:when test="self::custodhist">Custodial History</xsl:when>
                                <xsl:when test="self::altformavail">Alternative Form Available</xsl:when>
                                <xsl:when test="self::originalsloc">Original Location</xsl:when>
                                <xsl:when test="self::fileplan">File Plan</xsl:when>
                                <xsl:when test="self::acqinfo">Acquisition Information</xsl:when>
                                <xsl:when test="self::otherfindaid">Other Finding Aids</xsl:when>
                                <xsl:when test="self::phystech">Physical Characteristics and Technical Requirements</xsl:when>
                                <xsl:when test="self::processinfo">Processing Information</xsl:when>
                                <xsl:when test="self::relatedmaterial">2Related Material</xsl:when>
                                <xsl:when test="self::scopecontent">Scope and Content</xsl:when>
                                <xsl:when test="self::separatedmaterial">Separated Material</xsl:when>
                                <xsl:when test="self::appraisal">Appraisal</xsl:when>                       
                            </xsl:choose>
                        </h4>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- If the element is a child of arcdesc then a link to the table of contents is included -->
        <xsl:if test="parent::archdesc">
            <xsl:choose>
                <xsl:when test="self::accessrestrict or self::userestrict or
                    self::custodhist or self::accruals or
                    self::altformavail or self::acqinfo or
                    self::processinfo or self::appraisal or
                    self::originalsloc or  
                    self::relatedmaterial or self::separatedmaterial or self::prefercite"/>
                    <xsl:otherwise>
                        <xsl:call-template name="returnTOC"/>
                    </xsl:otherwise>
            </xsl:choose>    
        </xsl:if>
    </xsl:template>
	
<xsl:template name="SubstringReplace">
<xsl:param name="stringIn"/>
<xsl:param name="substringIn"/>
<xsl:param name="substringOut"/>
<xsl:choose>
	<xsl:when test="contains($stringIn,$substringIn)">
	<xsl:value-of select="concat(substring-before($stringIn,$substringIn),$substringOut)"/>
	<xsl:call-template name="SubstringReplace">
		<xsl:with-param name="stringIn" select="substring-after($stringIn,$substringIn)"/>
		<xsl:with-param name="substringIn" select="$substringIn"/>
		<xsl:with-param name="substringOut" select="$substringOut"/>
	</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="$stringIn"/>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>
	<xsl:template match="c" mode="heading">
	<xsl:if test="@level='Deelarchief' or @level='Afdeling' or @level='Onderafdeling' or @level='Rubriek' or @level='Subrubriek'">
	<!--<xsl:if test="@level='Afdeling' or @level='Onderafdeling' or @level='Rubriek' or @level='Subrubriek'">-->
	  <xsl:variable name="cid"><xsl:value-of select="@id"/></xsl:variable>  
	    <xsl:for-each select="did">
	   <dl>
		<dd>
			<a class="ech6">
				<xsl:attribute name="href">#lnk_<xsl:value-of select="$cid"/></xsl:attribute>
				<xsl:if test="unittitle[@label='Titel']/p/text()">
					<xsl:if test="unittitle[@label='Formele titel']/p/text()"><xsl:value-of select="'&quot;'"/><xsl:value-of select="unittitle[@label='Formele titel']/p/text()"/><xsl:value-of select="'&quot;'"/><xsl:text>. </xsl:text></xsl:if>
					<xsl:value-of select="unittitle[@label='Titel']/p/text()"/></xsl:if>
				<xsl:if test="not(unittitle[@label='Titel']/p/text())"><xsl:value-of select="unitid/@identifier"/></xsl:if>
			</a>
		<xsl:apply-templates select="c" mode="heading"/>			
		</dd>
	   </dl>
	   </xsl:for-each>
	</xsl:if>   
    </xsl:template>	
    <xsl:template name="substitute">
        <xsl:param name="string" />
        <xsl:param name="from" select="'&#xA;'" />
        <xsl:param name="to">
            <br />
        </xsl:param>
        <xsl:choose>
            <xsl:when test="contains($string, $from)">
                <xsl:value-of select="substring-before($string, $from)" />
                <xsl:copy-of select="$to" />
                <xsl:call-template name="substitute">
                    <xsl:with-param name="string"
                        select="substring-after($string, $from)" />
                    <xsl:with-param name="from" select="$from" />
                    <xsl:with-param name="to" select="$to" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>  	
	
  <xsl:template name="replace-dest">
    <xsl:param name="text"/>
	
	<xsl:variable name="pre-text"><xsl:value-of select="substring-before($text,'&lt;link dest=&quot;')"/></xsl:variable>
	<xsl:variable name="post-text"><xsl:value-of select="substring-after($text,'&lt;/link&gt;')"/></xsl:variable>
	<xsl:variable name="href-lnk"><xsl:value-of select="substring-before(substring-after($text,'&lt;link dest=&quot;'),'&quot;')"/></xsl:variable>	
	<xsl:variable name="href-text"><xsl:value-of select="substring-after(substring-after(substring-before($text,'&lt;/link&gt;'),'&lt;link dest=&quot;'),'>')"/></xsl:variable>	
	<xsl:choose>	
		<xsl:when test="contains($text,'&lt;link dest=&quot;')">	
			<xsl:value-of select="$pre-text"/>
			<a><xsl:attribute name="href"><xsl:value-of select="$href-lnk"/></xsl:attribute><xsl:value-of select="$href-text"/></a><xsl:value-of select="$post-text"/>			
		</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>		
  </xsl:template>	
</xsl:stylesheet>
