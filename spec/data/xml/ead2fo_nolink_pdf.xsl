<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
	<xsl:strip-space elements="*"/>
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<xsl:include href="header_nolink_pdf.xsl"/>
	<!-- Creates the body of the finding aid.-->
	<xsl:template match="/ead">
		<fo:root>
			<fo:layout-master-set>
				<fo:simple-page-master master-name="pages" page-width="21cm" page-height="29.7cm" 
					margin-top="1cm" margin-bottom="1cm"
					margin-left="3cm" margin-right="1cm">					
					<fo:region-body region-name="main" margin-bottom="2cm" margin-top="2cm"/>
					<fo:region-before region-name="header-main" extent="2cm"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="cover" page-width="21cm" page-height="29.7cm"
					margin-top="1cm" margin-bottom="1cm"
					margin-left="1cm" margin-right="1cm">
					<fo:region-body margin="2cm"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="toc" page-width="21cm" page-height="29.7cm"
					margin-top="1cm" margin-bottom="1cm"
					margin-left="3cm" margin-right="1cm">
					<fo:region-body margin-bottom="2cm" margin-top="2cm"/>
					<fo:region-before region-name="toc_header-main" extent="2cm"/>
				</fo:simple-page-master>
			</fo:layout-master-set>
			
			<fo:page-sequence master-reference="cover">
				<fo:flow flow-name="xsl-region-body">
				
					<fo:block font-family="Times" space-before="0.5in" text-align="left">
						<fo:external-graphic content-height="30" content-width="90" src="url('https://www.libis.be/images/liaslogo.jpg')"/>
					</fo:block>					
                    <xsl:call-template name="header"/>  					
				</fo:flow>
			</fo:page-sequence>		
			<fo:page-sequence master-reference="toc">
				<fo:static-content flow-name="toc_header-main">
					<fo:block text-align-last="justify" font-size="10pt" font-family="Times">
					    <xsl:if test="string-length($TITLE_HEADER) &gt; 121">
							<xsl:value-of select="concat(substring($TITLE_HEADER,1,121),'...')"/>
						</xsl:if>
						<xsl:if test="string-length($TITLE_HEADER) &lt; 122">
							<xsl:value-of select="$TITLE_HEADER"/>
						</xsl:if>
						<fo:leader/><xsl:text>Pagina: </xsl:text><fo:page-number/>
					</fo:block>
					<xsl:call-template name="hr_fo"/>
				</fo:static-content>			
				<fo:flow flow-name="xsl-region-body">					
					<xsl:call-template name="toc_gv"/>
				</fo:flow>
				
			</fo:page-sequence>
			<fo:page-sequence master-reference="pages">
				<fo:static-content flow-name="header-main">
					<fo:block text-align-last="justify" font-size="10pt" font-family="Times">
					    <xsl:if test="string-length($TITLE_HEADER) &gt; 121">
							<xsl:value-of select="concat(substring($TITLE_HEADER,1,121),'...')"/>
						</xsl:if>
						<xsl:if test="string-length($TITLE_HEADER) &lt; 122">
							<xsl:value-of select="$TITLE_HEADER"/>
						</xsl:if>
						<fo:leader/><xsl:text>Pagina: </xsl:text><fo:page-number/>
					</fo:block>
					<xsl:call-template name="hr_fo"/>
				</fo:static-content>
						
				<fo:flow flow-name="main">
					<fo:block font-size="14pt" font-weight="bold" font-family="Times" space-before="0.1in" text-align="left">
					<xsl:copy-of select="$DISP_TITEL_MAIN"/>
					</fo:block>
					<xsl:apply-templates select="/ead/archdesc/descgrp"/>	
						<fo:block break-after='page'/>					
					<fo:block/>
					<xsl:if test="/ead/archdesc/dsc/c/*">					
						<fo:block font-weight="bold" font-size="14pt" font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_8">
								<xsl:copy-of select="$DISP_TITEL_8"/>
						</fo:block>
						<xsl:for-each select="archdesc/dsc">
							<xsl:apply-templates select="c" mode="detail"/>
						</xsl:for-each>
					</xsl:if>
			
					</fo:flow>
			</fo:page-sequence>
		</fo:root>
	</xsl:template>
	<xsl:template name="header">
			<xsl:if test="normalize-space(eadheader/filedesc/titlestmt/titleproper) != '' or normalize-space(eadheader/filedesc/titlestmt/subtitle) !='' or normalize-space(eadheader/filedesc/titlestmt/author) != ''">
				<xsl:if test="normalize-space(eadheader/filedesc/titlestmt/titleproper) != ''">
					<fo:block space-before="0.1in" font-size="18pt" font-family="Times" font-weight="bold" text-align="center">			
						<xsl:value-of select="eadheader/filedesc/titlestmt/titleproper"/>
					</fo:block>
				</xsl:if>	
				<xsl:if test="normalize-space(eadheader/filedesc/titlestmt/subtitle) !=''">
					<fo:block space-before="0.1in" font-size="14pt"
					font-family="Times"
					font-weight="bold" text-align="center">
					<xsl:value-of select="eadheader/filedesc/titlestmt/subtitle"/>
					</fo:block>
				</xsl:if>
				<xsl:if test="normalize-space(eadheader/filedesc/titlestmt/author) != ''">
					<fo:block space-before="0.1in" font-size="13pt"
					font-family="Times"
					font-weight="bold" text-align="center">
					<xsl:value-of select="eadheader/filedesc/titlestmt/author"/>
					</fo:block>			
				</xsl:if>	
			</xsl:if>					
			<fo:block font-size="10pt" font-family="Times" space-before="1.0in" text-align="left">
						<xsl:value-of select="'Deze inventaris werd automatisch gegenereerd en gecodeerd.'"/><fo:block/>
						<xsl:value-of select="'De EAD-export werd gecontroleerd en gevalideerd door de werkgroep archivarissen van LIAS K.U.Leuven (Leuvens Integraal Archiveringssysteem), '"/><xsl:value-of select="$EAD_DATE"/><fo:block/>
						<fo:basic-link  font-weight="bold">
						<xsl:attribute name="external-destination"><xsl:value-of select="concat($XML_SCOPE_OPAC,$REC_ID)"/></xsl:attribute>Volledige beschrijving in databank LIAS</fo:basic-link>
						<xsl:call-template name="hr_fo"/>  
			</fo:block>
    </xsl:template>
		<xsl:template name="hr_fo">
						<fo:block font-family="Times"><fo:leader leader-length="100%" leader-pattern="rule"/></fo:block>
	</xsl:template>					
						
	<xsl:template name="toc_gv">
		<fo:block font-weight="bold" font-size="15pt" font-family="Times" space-before="0.1in" text-align="left" id="toc_gv">
			<xsl:copy-of select="$DISP_TITEL_TOC"/>
		</fo:block>	
		<fo:block font-weight="bold" font-size="14pt" font-family="Times" space-before="0.1in" text-align="left" id="dummy">
			<xsl:copy-of select="$DISP_TITEL_MAIN"/>
		</fo:block>
		<!--<fo:block font-weight="bold" font-size="12pt" font-family="Times" space-before="0.1in" text-align="left"> -->
		<!--<fo:block font-size="12pt" font-family="Times" space-before="0.1in" text-align="left">-->
			<xsl:for-each select="archdesc/descgrp">
				<!--<fo:block font-size="13pt" font-weight="bold" font-family="Times" space-before="0.1in" text-align="left">
					<xsl:copy-of select="$DISP_TITEL_MAIN"/>
				</fo:block>-->
			<fo:block font-size="12pt" font-family="Times" space-before="0.1in" text-align="right">
					<xsl:if test="head=$TITEL_1">
					
						<fo:block font-family="Times" space-after="2pt" keep-with-next="always" start-indent="1cm" text-align-last="justify">
							<fo:basic-link internal-destination="DISP_TITEL_1"><fo:inline font-weight="bold"><xsl:copy-of select="$DISP_TITEL_1"/></fo:inline></fo:basic-link>
							<fo:leader leader-pattern="dots"/>
							<fo:page-number-citation ref-id="DISP_TITEL_1"/>
						</fo:block>	
						<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
							<fo:basic-link internal-destination="DISP_TITEL_1_1"><xsl:copy-of select="$DISP_TITEL_1_1"/></fo:basic-link>	
							<fo:leader leader-pattern="dots"/>
							<fo:page-number-citation ref-id="DISP_TITEL_1_1"/>
						</fo:block>
						<xsl:if test="unititle">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_1_2"><xsl:copy-of select="$DISP_TITEL_1_2"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_1_2"/>								
							</fo:block>						
						</xsl:if>
						<xsl:if test="unitdate">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_1_3"><xsl:copy-of select="$DISP_TITEL_1_3"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_1_3"/>								
							</fo:block>						
						</xsl:if>
						<xsl:if test="physdesc/extent[@label='Omvang']">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_1_4"><xsl:copy-of select="$DISP_TITEL_1_4"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_1_4"/>							
							</fo:block>						
						</xsl:if>
					</xsl:if>
					<xsl:if test="head=$TITEL_2">
						<fo:block font-family="Times" space-after="2pt" keep-with-next="always" start-indent="1cm" text-align-last="justify">
							<fo:basic-link internal-destination="DISP_TITEL_2"><fo:inline font-weight="bold"><xsl:copy-of select="$DISP_TITEL_2"/></fo:inline></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_2"/>							
						</fo:block>					
						<xsl:if test="origination">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_2_1"><xsl:copy-of select="$DISP_TITEL_2_1"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_2_1"/>
							</fo:block>						
						</xsl:if>	
						<xsl:if test="bioghist/p/text()">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_2_2"><xsl:copy-of select="$DISP_TITEL_2_2"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_2_2"/>								
							</fo:block>						
						</xsl:if>
						<xsl:if test="custodhist/p/text()">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_2_3"><xsl:copy-of select="$DISP_TITEL_2_3"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_2_3"/>								
							</fo:block>						
						</xsl:if>
						<xsl:if test="acqinfo/p/text()">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_2_4"><xsl:copy-of select="$DISP_TITEL_2_4"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_2_4"/>								
							</fo:block>						
						</xsl:if>	
					</xsl:if>
					<xsl:if test="head=$TITEL_3">
						<fo:block font-family="Times" space-after="2pt" keep-with-next="always" start-indent="1cm" text-align-last="justify">
							<fo:basic-link internal-destination="DISP_TITEL_3"><fo:inline font-weight="bold"><xsl:copy-of select="$DISP_TITEL_3"/></fo:inline></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_3"/>							
						</fo:block>					
						<xsl:if test="scopecontent/head=$TITEL_3_1">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_3_1"><xsl:copy-of select="$DISP_TITEL_3_1"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_3_1"/>								
							</fo:block>						
						</xsl:if>	
						<xsl:if test="appraisal/head=$TITEL_3_2">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_3_2"><xsl:copy-of select="$DISP_TITEL_3_2"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_3_2"/>								
							</fo:block>						
						</xsl:if>
						<xsl:if test="accruals/head=$TITEL_3_3">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_3_3"><xsl:copy-of select="$DISP_TITEL_3_3"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_3_3"/>								
							</fo:block>						
						</xsl:if>
						<xsl:if test="arrangement/head=$TITEL_3_4">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_3_4"><xsl:copy-of select="$DISP_TITEL_3_4"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_3_4"/>								
							</fo:block>						
						</xsl:if>
					</xsl:if>					
					<xsl:if test="head=$TITEL_4">
						<fo:block font-family="Times" space-after="2pt" keep-with-next="always" start-indent="1cm" text-align-last="justify">
							<fo:basic-link internal-destination="DISP_TITEL_4"><fo:inline font-weight="bold"><xsl:copy-of select="$DISP_TITEL_4"/></fo:inline></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_4"/>							
						</fo:block>					
						<xsl:if test="accessrestrict/head=$TITEL_4_1">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_4_1"><xsl:copy-of select="$DISP_TITEL_4_1"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_4_1"/>								
							</fo:block>						
						</xsl:if>	
						<xsl:if test="userestrict/head=$TITEL_4_2">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_4_2"><xsl:copy-of select="$DISP_TITEL_4_2"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_4_2"/>								
							</fo:block>						
						</xsl:if>
						<xsl:if test="langmaterial/head=$TITEL_4_3">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_4_3"><xsl:copy-of select="$DISP_TITEL_4_3"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_4_3"/>								
							</fo:block>						
						</xsl:if>
						<xsl:if test="phystech/head=$TITEL_4_4">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_4_4"><xsl:copy-of select="$DISP_TITEL_4_4"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_4_4"/>								
							</fo:block>						
						</xsl:if>
						<xsl:if test="otherfindaid/head=$TITEL_4_5">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_4_5"><xsl:copy-of select="$DISP_TITEL_4_5"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_4_5"/>								
							</fo:block>						
						</xsl:if>						
					</xsl:if>
					<xsl:if test="head=$TITEL_5">
						<fo:block font-family="Times" space-after="2pt" keep-with-next="always" start-indent="1cm" text-align-last="justify">
							<fo:basic-link internal-destination="DISP_TITEL_5"><fo:inline font-weight="bold"><xsl:copy-of select="$DISP_TITEL_5"/></fo:inline></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_5"/>							
						</fo:block>					
						<xsl:if test="originalsloc/head=$TITEL_5_1">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_5_1"><xsl:copy-of select="$DISP_TITEL_5_1"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_5_1"/>								
							</fo:block>						
						</xsl:if>	
						<xsl:if test="altformavail/head=$TITEL_5_2">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_5_2"><xsl:copy-of select="$DISP_TITEL_5_2"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_5_2"/>								
							</fo:block>						
						</xsl:if>
						<xsl:if test="relatedmaterial/head=$TITEL_5_3">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_5_3"><xsl:copy-of select="$DISP_TITEL_5_3"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_5_3"/>								
							</fo:block>						
						</xsl:if>
						<xsl:if test="bibliography/head=$TITEL_5_4">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_5_4"><xsl:copy-of select="$DISP_TITEL_5_4"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_5_4"/>								
							</fo:block>						
						</xsl:if>
					</xsl:if>					
					<xsl:if test="head=$TITEL_6">
						<fo:block font-family="Times" space-after="2pt" keep-with-next="always" start-indent="1cm" text-align-last="justify">
							<fo:basic-link internal-destination="DISP_TITEL_6"><fo:inline font-weight="bold"><xsl:copy-of select="$DISP_TITEL_6"/></fo:inline></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_6"/>							
						</fo:block>					
						<xsl:if test="note/head=$TITEL_6_1">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_6_1"><xsl:copy-of select="$DISP_TITEL_6_1"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_6_1"/>								
							</fo:block>						
						</xsl:if>	
					</xsl:if>
					<xsl:if test="head=$TITEL_7">
						<fo:block font-family="Times" space-after="2pt" keep-with-next="always" start-indent="1cm" text-align-last="justify">
							<fo:basic-link internal-destination="DISP_TITEL_7"><fo:inline font-weight="bold"><xsl:copy-of select="$DISP_TITEL_7"/></fo:inline></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_7"/>							
						</fo:block>					
						<xsl:if test="processinfo[@label='Verantwoording']/head=$TITEL_7_1">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_7_1"><xsl:copy-of select="$DISP_TITEL_7_1"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_7_1"/>								
							</fo:block>						
						</xsl:if>	
						<xsl:if test="descrules/head=$TITEL_7_2">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_7_2"><xsl:copy-of select="$DISP_TITEL_7_2"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_7_2"/>								
							</fo:block>						
						</xsl:if>
						<xsl:if test="processinfo[@label='Datering van de beschrijvingen']/head=$TITEL_7_3">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify"> <!--<fo:block start-indent="1.35cm" space-after="3pt">-->
								<fo:basic-link internal-destination="DISP_TITEL_7_3"><xsl:copy-of select="$DISP_TITEL_7_3"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_7_3"/>								
							</fo:block>						
						</xsl:if>
						<!-- trefwoorden not for pdf
						<xsl:if test="/ead/archdesc/controlaccess">
							<fo:block font-family="Times" start-indent="1.5cm" space-after="3pt" text-align-last="justify">
								<fo:basic-link internal-destination="DISP_TITEL_7_4"><xsl:copy-of select="$DISP_TITEL_7_4"/></fo:basic-link>
								<fo:leader leader-pattern="dots"/>
								<fo:page-number-citation ref-id="DISP_TITEL_7_4"/>								
							</fo:block>						
						</xsl:if>
						-->
					</xsl:if>
				</fo:block>	
			</xsl:for-each>
							<!-- page break <fo:block break-after='page'/> -->
			<xsl:if test="/ead/archdesc/dsc">
				<xsl:choose>
					<xsl:when test="not(/ead/archdesc/dsc/c/@level='Deelarchief' or /ead/archdesc/dsc/c/@level='Afdeling' or /ead/archdesc/dsc/c/@level='Onderafdeling' or /ead/archdesc/dsc/c/@level='Rubriek' or /ead/archdesc/dsc/c/@level='Subrubriek')">
					<fo:block font-size="14pt" font-family="Times" space-before="0.1in" text-align-last="justify">
						<fo:basic-link internal-destination="DISP_TITEL_8"><fo:inline font-weight="bold"><xsl:copy-of select="$DISP_TITEL_8"/></fo:inline></fo:basic-link>					
							<fo:leader leader-pattern="dots"/>
							<fo:page-number-citation ref-id="DISP_TITEL_8"/>
					</fo:block>						
					</xsl:when>
					<xsl:otherwise>
					<fo:block font-size="14pt" font-family="Times" space-before="0.1in" text-align="left">
						<fo:basic-link internal-destination="DISP_TITEL_8"><fo:inline font-weight="bold"><xsl:copy-of select="$DISP_TITEL_8"/></fo:inline></fo:basic-link>					
					</fo:block>					
					</xsl:otherwise>
				</xsl:choose>
				<fo:block font-size="12pt" font-family="Times" text-align="left">
				 <xsl:for-each select="archdesc/dsc">
					<xsl:apply-templates select="c" mode="heading"/>
				 </xsl:for-each>
				</fo:block>
			</xsl:if>			
		
	</xsl:template>
	<xsl:template match="c" mode="heading">
		<xsl:if test="@level='Deelarchief' or @level='Afdeling' or @level='Onderafdeling' or @level='Rubriek' or @level='Subrubriek'">
			<xsl:variable name="cid"><xsl:value-of select="@id"/></xsl:variable>  	
			<xsl:for-each select="did">
				<fo:list-block provisional-distance-between-starts="0cm" provisional-label-separation="0.1cm">
					<xsl:attribute name="space-after">
						<xsl:choose>
							<xsl:when test="ancestor::c"><xsl:text>0pt</xsl:text></xsl:when>
							<xsl:otherwise><xsl:text>12pt</xsl:text></xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:attribute name="start-indent">
						<xsl:variable name="ancestors">
						<xsl:choose>
						<xsl:when test="count(ancestor::c) = 1">
						<xsl:value-of select="count(ancestor::c) * 1"/>
						</xsl:when>
								<xsl:when test="count(ancestor::c)">
            <xsl:value-of select="1 + count(ancestor::c) * 0.75"/><!--<xsl:value-of select="1 + count(ancestor::c) * 0.50"/>-->
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>1</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="concat($ancestors, 'cm')"/>
    </xsl:attribute>	
		<fo:list-item>
			<fo:list-item-label end-indent="label-end()">
				<fo:block font-family="Times">
					<xsl:variable name="value-attr">
					<xsl:choose>
						<xsl:when test="../@start"><xsl:number value="position() + ../@start - 1"/></xsl:when>
						<xsl:otherwise><xsl:number value="position()"/></xsl:otherwise>
					</xsl:choose>
					</xsl:variable>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block font-family="Times" text-align-last="justify">
					<fo:basic-link>
						<xsl:attribute name="internal-destination">lnk_<xsl:value-of select="$cid"/></xsl:attribute>
						<xsl:if test="unittitle[@label='Titel']/p/text()">
							<xsl:if test="unittitle[@label='Formele titel']/p/text()">
								<xsl:value-of select="'&quot;'"/><xsl:value-of select="unittitle[@label='Formele titel']/p/text()"/><xsl:value-of select="'&quot;'"/><xsl:value-of select="'.'"/>&#160;
							</xsl:if>
						<xsl:value-of select="unittitle[@label='Titel']/p/text()"/></xsl:if>
						<xsl:if test="not(unittitle[@label='Titel']/p/text())"><xsl:value-of select="unitid/@identifier"/></xsl:if>
					</fo:basic-link>
					<fo:leader leader-pattern="dots"/>
					<fo:page-number-citation>
					<xsl:attribute name="ref-id">lnk_<xsl:value-of select="$cid"/></xsl:attribute>
					</fo:page-number-citation>
				</fo:block>
			</fo:list-item-body>
		</fo:list-item>	
	</fo:list-block>
	<xsl:apply-templates select="c" mode="heading"/>		
	</xsl:for-each>
	</xsl:if>   
    </xsl:template>	 	
	    <xsl:template match="c" mode="detail">
		<xsl:if test="@level='Deelarchief' or @level='Afdeling' or @level='Onderafdeling' or @level='Rubriek' or @level='Subrubriek'">
			<fo:block font-family="Times"><xsl:attribute name="id">lnk_<xsl:value-of select="@id"/></xsl:attribute></fo:block>	
		</xsl:if>	
		<xsl:for-each select="did">
			<fo:block font-family="Times" space-before="0.08cm" space-after="0.08cm"/>
				<xsl:if test="../@level='Deelarchief' or ../@level='Afdeling' or ../@level='Onderafdeling' or ../@level='Rubriek' or ../@level='Subrubriek' or ../@level='Reeks' or ../@level='Deelreeks'">
					<fo:block font-family="Times" keep-together.within-page="42">
						<xsl:choose>
							<xsl:when test="../@level='Deelarchief'">
								<xsl:attribute name="font-size"><xsl:value-of select="$Deelarchief_pt"/></xsl:attribute>
								<xsl:attribute name="font-weight">bold</xsl:attribute>
							</xsl:when>						
							<xsl:when test="../@level='Afdeling'">
								<xsl:attribute name="font-size"><xsl:value-of select="$Afdeling_pt"/></xsl:attribute>
								<xsl:attribute name="font-variant">small-caps</xsl:attribute>
							</xsl:when>
							<xsl:when test="../@level='Onderafdeling'">
								<xsl:attribute name="font-size"><xsl:value-of select="$Onderafdeling_pt"/></xsl:attribute>
								<xsl:attribute name="font-weight">bold</xsl:attribute>
							</xsl:when>							
							<xsl:when test="../@level='Rubriek'">
								<xsl:attribute name="font-size"><xsl:value-of select="$Rubriek_pt"/></xsl:attribute>
								<xsl:attribute name="font-variant">small-caps</xsl:attribute>
							</xsl:when>
							<xsl:when test="../@level='Subrubriek'">
								<xsl:attribute name="font-size"><xsl:value-of select="$Subrubriek_pt"/></xsl:attribute>
								<xsl:attribute name="font-style">italic</xsl:attribute>								
							</xsl:when>							
							<xsl:when test="../@level='Reeks'">
								<xsl:attribute name="font-size"><xsl:value-of select="$Reeks_pt"/></xsl:attribute>
								<xsl:attribute name="text-transform">uppercase</xsl:attribute>
							</xsl:when>
							<xsl:when test="../@level='Deelreeks'">
								<xsl:attribute name="font-size"><xsl:value-of select="$Deelreeks_pt"/></xsl:attribute>
								<xsl:attribute name="text-decoration">underline</xsl:attribute>
							</xsl:when>														
							<xsl:otherwise>
								<xsl:attribute name="font-size"><xsl:value-of select="$Onderafdeling_pt"/></xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					
						<xsl:if test="unittitle[@label='Titel']/p/text()">
							<xsl:if test="string(unitid)">
								<fo:block font-family="Times">
									<xsl:if test="not(contains(../../../@level,'meervoudige beschrijving'))">
										<fo:inline font-weight="bold"><xsl:value-of select="unitid"/><xsl:if test="substring(unitid,string-length(unitid),1) != '.'"><xsl:value-of select="'.'"/></xsl:if>&#160;</fo:inline></xsl:if>
									<xsl:if test="(contains(../../../@level,'meervoudige beschrijving'))">
										<xsl:value-of select="unitid"/><xsl:if test="substring(unitid,string-length(unitid),1) != '.'"><xsl:value-of select="'.'"/></xsl:if>&#160;</xsl:if>
										<xsl:if test="unittitle[@label='Formele titel']/p/text()">
											<xsl:value-of select="'&quot;'"/><xsl:value-of select="unittitle[@label='Formele titel']/p/text()"/><xsl:value-of select="'&quot;'"/><xsl:value-of select="'.'"/>&#160;</xsl:if>
										<xsl:value-of select="unittitle[@label='Titel']/p/text()"/>
								</fo:block>	
							</xsl:if>
							<xsl:if test="not(string(unitid))">
								<fo:block font-family="Times">
								<xsl:if test="unittitle[@label='Formele titel']/p/text()">
									<xsl:value-of select="'&quot;'"/><xsl:value-of select="unittitle[@label='Formele titel']/p/text()"/><xsl:value-of select="'&quot;'"/><xsl:value-of select="'.'"/>&#160;</xsl:if>
								<xsl:value-of select="unittitle[@label='Titel']/p/text()"/>
								</fo:block>		
							</xsl:if>
						</xsl:if>
						<xsl:if test="../@level = 'Subrubriek' or ../@level = 'Reeks' or ../@level = 'Deelreeks'">
							<xsl:if test="unitdate[@label='Datum']/p/text()">
								<fo:block font-family="Times">
									<xsl:for-each select="unitdate[@label='Datum']/p/text()">
										<xsl:value-of select="."/><xsl:if test="following-sibling::*"><xsl:value-of select="','"/>&#160;</xsl:if>
									</xsl:for-each>
									<xsl:if test="physdesc/physfacet/p/text()">
										<xsl:for-each select="physdesc/physfacet/p/text()">
											<xsl:value-of select="."/>
											<xsl:if test="following-sibling::*"><xsl:value-of select="','"/>&#160;</xsl:if>
											<xsl:if test="not(following-sibling::*)"><xsl:value-of select="'.'"/>&#160;</xsl:if>
										</xsl:for-each>
									</xsl:if>									
								</fo:block>		
							</xsl:if>
						</xsl:if>	
						
						<xsl:if test="not(../@level = 'Subrubriek' or ../@level = 'Reeks' or ../@level = 'Deelreeks')">
									<xsl:if test="physdesc/physfacet/p/text()">
										<fo:block font-family="Times">
										<xsl:for-each select="physdesc/physfacet/p/text()">
											<xsl:value-of select="."/>
											<xsl:if test="following-sibling::*"><xsl:value-of select="','"/>&#160;</xsl:if>
											<xsl:if test="not(following-sibling::*)"><xsl:value-of select="'.'"/>&#160;</xsl:if>
										</xsl:for-each>
										</fo:block>		
									</xsl:if>									
						</xsl:if>	

						<xsl:if test="dao">
							<!--<fo:block font-family="Times" font-style="italic">	-->
							<fo:block font-family="Times">	
							<xsl:for-each select="dao">
							<fo:basic-link  font-weight="bold">
								<xsl:attribute name="external-destination"><xsl:value-of select="@href"/></xsl:attribute><xsl:value-of select="@title"/></fo:basic-link>							
								<xsl:if test="following-sibling::*"><fo:block/></xsl:if>
							</xsl:for-each>
							</fo:block>
						</xsl:if>											
						<xsl:if test="physdesc/extent/p/text()">
							<!--<fo:block font-family="Times" font-style="italic">	-->
							<fo:block font-family="Times">
								<xsl:for-each select="physdesc/extent/p/text()">
								<xsl:value-of select="."/>
									<xsl:if test="following-sibling::*"><xsl:value-of select="','"/>&#160;</xsl:if>
								</xsl:for-each>
							</fo:block>
						</xsl:if>					
						
						<xsl:for-each select="relatedmaterial/archref">
							<fo:block font-family="Times" font-size="8pt">
							<!--<xsl:attribute name="font-size"><xsl:value-of select="$Bestanddeel_pt"/></xsl:attribute>-->
								<xsl:if test="string(note)">[<xsl:value-of select="note"/>]&#160;:&#160;</xsl:if>
								<xsl:value-of select="unittitle"/>
							</fo:block>					
						</xsl:for-each>
					</fo:block> 	
					</xsl:if>		
					<xsl:if test="../@level='Reeks - meervoudige beschrijving' or ../@level='Deelreeks - meervoudige beschrijving' or ../@level='Bestanddeel' or ../@level='Bestanddeel - meervoudige beschrijving' or ../@level='Subbestanddeel' or ../@level='Subbestanddeel - meervoudige beschrijving' or ../@level='Stuk'">
						<fo:block font-family="Times"  keep-together.within-page="42">
							<xsl:choose>
							<xsl:when test="../@level='Reeks - meervoudige beschrijving'">
								<xsl:attribute name="font-size"><xsl:value-of select="$ReeksMB_pt"/></xsl:attribute>
							</xsl:when>
							<xsl:when test="../@level='Deelreeks - meervoudige beschrijving'">
								<xsl:attribute name="font-size"><xsl:value-of select="$DeelreeksMB_pt"/></xsl:attribute>
							</xsl:when>
							<xsl:when test="../@level='Bestanddeel'">
								<xsl:attribute name="font-size"><xsl:value-of select="$Bestanddeel_pt"/></xsl:attribute>
							</xsl:when>
							<xsl:when test="../@level='Bestanddeel - meervoudige beschrijving'">
								<xsl:attribute name="font-size"><xsl:value-of select="$BestanddeelMB_pt"/></xsl:attribute>
							</xsl:when>
							<xsl:when test="../@level='Subbestanddeel'">
								<xsl:attribute name="font-size"><xsl:value-of select="$Subbestanddeel_pt"/></xsl:attribute>
							</xsl:when>
							<xsl:when test="../@level='Subbestanddeel - meervoudige beschrijving'">
								<xsl:attribute name="font-size"><xsl:value-of select="$SubbestanddeelMB_pt"/></xsl:attribute>
							</xsl:when>
							<xsl:when test="../@level='Stuk'">
								<xsl:attribute name="font-size"><xsl:value-of select="$Stuk_pt"/></xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="font-size"><xsl:value-of select="$Onderafdeling_pt"/></xsl:attribute>
							</xsl:otherwise>
							</xsl:choose>
							<xsl:variable name="utitle"><xsl:if test="unittitle[@label='Formele titel']/p/text()"><xsl:value-of select="'&quot;'"/><xsl:value-of select="unittitle[@label='Formele titel']/p/text()"/><xsl:value-of select="'&quot;'"/><xsl:value-of select="'.'"/>&#160;</xsl:if><xsl:value-of select="normalize-space(unittitle[@label='Titel']/p/text())"/></xsl:variable>	
							<xsl:variable name="CLength_B">
							<xsl:if test="string(unitid)">
							<xsl:value-of select="string-length(unitid)+ string-length($GAP)"/>
							</xsl:if>
							<xsl:if test="not(string(unitid))">
							<xsl:value-of select="'0'"/>
							</xsl:if>
							</xsl:variable>												
							<fo:table table-layout="fixed" width="100%">
								<xsl:if test="$CLength_B='0'">
									<fo:table-column column-width="100%"/>
								</xsl:if>
								<xsl:if test="$CLength_B!='0'">
									<fo:table-column>
										<xsl:attribute name="column-width"><xsl:value-of select="concat($CLength_B*1.5,'mm')"/></xsl:attribute>
									</fo:table-column>								
									<fo:table-column column-width="proportional-column-width(1)"/>
								</xsl:if>							
								<fo:table-body>
									<fo:table-row>
										<xsl:if test="string(unitid)">
										<fo:table-cell>							
											<fo:block font-family="Times"  wrap-option="no-wrap">
												<xsl:if test="not(contains(../../../@level,'meervoudige beschrijving'))">
														<fo:inline font-weight="bold"><xsl:value-of select="unitid"/><xsl:if test="substring(unitid,string-length(unitid),1) != '.'"><xsl:value-of select="'.'"/></xsl:if>&#160;</fo:inline></xsl:if>
												<xsl:if test="(contains(../../../@level,'meervoudige beschrijving'))">
													<xsl:value-of select="unitid"/><xsl:if test="substring(unitid,string-length(unitid),1) != '.'"><xsl:value-of select="'.'"/></xsl:if>&#160;</xsl:if>									
											</fo:block>	
										</fo:table-cell>	
										<fo:table-cell>							
											<fo:block font-family="Times">
													<xsl:if test="substring($utitle,string-length($utitle),1) != '.'"><xsl:value-of select="concat($utitle,'.')"/></xsl:if>
													<xsl:if test="substring($utitle,string-length($utitle),1) = '.'">
														<xsl:if test="substring($utitle,string-length($utitle)-1,1) = '.'">
															<xsl:value-of select="substring($utitle,1,string-length($utitle)-1)"/>
														</xsl:if>
														<xsl:if test="not(substring($utitle,string-length($utitle)-1,1) = '.')">
															<xsl:value-of select="$utitle"/>
														</xsl:if>											
													</xsl:if>										
											</fo:block>	
										</fo:table-cell>	
									</xsl:if>
									<xsl:if test="not(string(unitid))">
										<fo:table-cell>							
											<fo:block font-family="Times" wrap-option="no-wrap">	
													<xsl:if test="substring($utitle,string-length($utitle),1) != '.'"><xsl:value-of select="concat($utitle,'.')"/></xsl:if>
													<xsl:if test="substring($utitle,string-length($utitle),1) = '.'">
														<xsl:if test="substring($utitle,string-length($utitle)-1,1) = '.'">
															<xsl:value-of select="substring($utitle,1,string-length($utitle)-1)"/>
														</xsl:if>
														<xsl:if test="not(substring($utitle,string-length($utitle)-1,1) = '.')">
															<xsl:value-of select="$utitle"/>
														</xsl:if>											
													</xsl:if>
											</fo:block>
										</fo:table-cell>
									</xsl:if>
									</fo:table-row>								
								<xsl:if test="unitdate[@label='Datum']/p/text()">
									<fo:table-row>
										<xsl:if test="(string(unitid))">
											<fo:table-cell><fo:block font-family="Times"><xsl:value-of select="'&#160;'"/></fo:block></fo:table-cell>
										</xsl:if>
										<fo:table-cell>							
											<fo:block font-family="Times">
												<xsl:for-each select="unitdate[@label='Datum']/p/text()">
													<xsl:value-of select="."/>
													<xsl:if test="following-sibling::*"><xsl:value-of select="','"/>&#160;</xsl:if>
													<xsl:if test="not(following-sibling::*)"><xsl:if test="substring(.,string-length(.),1) != '.'"><xsl:value-of select="'.'"/></xsl:if>&#160;</xsl:if>
												</xsl:for-each>
											<xsl:if test="physdesc/physfacet/p/text()">
												<xsl:for-each select="physdesc/physfacet/p/text()">
													<xsl:value-of select="."/>
													<xsl:if test="following-sibling::*"><xsl:value-of select="','"/>&#160;</xsl:if>
													<xsl:if test="not(following-sibling::*)"><xsl:value-of select="'.'"/>&#160;</xsl:if>
												</xsl:for-each>
											</xsl:if>																		
											</fo:block>
										</fo:table-cell>	
									</fo:table-row>
								</xsl:if>
								<xsl:if test="not(unitdate[@label='Datum']/p/text())">
									<xsl:if test="physdesc/physfacet/p/text()">
									<fo:table-row>
										<xsl:if test="(string(unitid))">
											<fo:table-cell><fo:block font-family="Times"><xsl:value-of select="'&#160;'"/></fo:block></fo:table-cell>
										</xsl:if>
										<fo:table-cell>																	
											<fo:block font-family="Times">
												<xsl:for-each select="physdesc/physfacet/p/text()">
													<xsl:value-of select="."/>
													<xsl:if test="following-sibling::*"><xsl:value-of select="','"/>&#160;</xsl:if>
													<xsl:if test="not(following-sibling::*)"><xsl:value-of select="'.'"/>&#160;</xsl:if>
												</xsl:for-each>
											</fo:block>
										</fo:table-cell>	
									</fo:table-row>											
									</xsl:if>																		
								</xsl:if>
							<xsl:if test="dao">
							<!--<fo:block font-family="Times" font-style="italic">	-->
									<fo:table-row>
										<xsl:if test="(string(unitid))">
											<fo:table-cell><fo:block font-family="Times"><xsl:value-of select="'&#160;'"/></fo:block></fo:table-cell>
										</xsl:if>	
										<fo:table-cell>																									
											<fo:block font-family="Times">
												<xsl:for-each select="dao">
													<fo:basic-link  font-weight="bold">
													<xsl:attribute name="external-destination"><xsl:value-of select="@href"/></xsl:attribute><xsl:value-of select="@title"/></fo:basic-link>							
													<xsl:if test="following-sibling::*"><fo:block/></xsl:if>
												</xsl:for-each>
											</fo:block>
										</fo:table-cell>	
									</fo:table-row>																		
								</xsl:if>										
				
								
								<xsl:if test="physdesc/extent/p/text()">
									<fo:table-row>
										<xsl:if test="(string(unitid))">
											<fo:table-cell><fo:block font-family="Times"><xsl:value-of select="'&#160;'"/></fo:block></fo:table-cell>
										</xsl:if>
										<fo:table-cell>																									
											<fo:block font-family="Times">
												<xsl:for-each select="physdesc/extent/p/text()">
													<xsl:value-of select="."/>
													<xsl:if test="following-sibling::*"><xsl:value-of select="','"/>&#160;</xsl:if>
												</xsl:for-each>
											</fo:block>
										</fo:table-cell>	
									</fo:table-row>																		
								</xsl:if>
								<xsl:if test="scopecontent[@label='Inhoud']/p/text()">
									<fo:table-row>
										<xsl:if test="(string(unitid))">
											<fo:table-cell><fo:block font-family="Times"><xsl:value-of select="'&#160;'"/></fo:block></fo:table-cell>
										</xsl:if>
										<fo:table-cell>																																	
											<fo:block font-family="Times" font-size="8pt">
											<xsl:for-each select="scopecontent[@label='Inhoud']/p/text()">
												<xsl:call-template name="substitute">
														<xsl:with-param name="string" select="." />
												</xsl:call-template>
												<xsl:if test="following-sibling::*"><fo:block/></xsl:if>
											</xsl:for-each>
											</fo:block>
										</fo:table-cell>	
									</fo:table-row>																													
								</xsl:if>						
								<xsl:if test="(string(unitid))">
									<xsl:for-each select="relatedmaterial/archref">
									<fo:table-row>
										<fo:table-cell><fo:block font-family="Times"><xsl:value-of select="'&#160;'"/></fo:block></fo:table-cell>
										<fo:table-cell>																																									
    										<fo:block font-family="Times" font-size="8pt">
												<xsl:if test="string(note)">[<xsl:value-of select="note"/>]&#160;:&#160;</xsl:if>
												<xsl:value-of select="unittitle"/>
											</fo:block>	
										</fo:table-cell>	
									</fo:table-row>																																								
								</xsl:for-each>
								</xsl:if>
								<xsl:if test="not(string(unitid))">
									<xsl:for-each select="relatedmaterial/archref">
									<fo:table-row>
										<fo:table-cell>																																									
    										<fo:block font-family="Times" font-size="8pt">
												<xsl:if test="string(note)">[<xsl:value-of select="note"/>]&#160;:&#160;</xsl:if>
												<xsl:value-of select="unittitle"/>
											</fo:block>	
										</fo:table-cell>	
									</fo:table-row>																																								
								</xsl:for-each>
								</xsl:if>								
							</fo:table-body>
							</fo:table>		
					</fo:block>																		
					<fo:block/>			
					</xsl:if>		
					<xsl:apply-templates select="c" mode="detail"/>
					<fo:block font-family="Times" space-before="0.08cm" space-after="0.08cm"/>
			</xsl:for-each>
    </xsl:template>	
	    <xsl:template name="substitute">
        <xsl:param name="string" />
        <xsl:param name="from" select="'&#xA;'" />
        <xsl:param name="to">
            <fo:block/>
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
    <xsl:template match="archdesc/descgrp">
	<fo:block font-family="Times" font-size="12pt">
		<xsl:if test="head=$TITEL_1">
		<fo:block keep-together.within-page="42">
			<fo:block font-weight="bold" font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_1">
				<xsl:copy-of select="$DISP_TITEL_1"/>
			</fo:block>	
			<fo:block/>
			<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_1_1">
				<xsl:copy-of select="$DISP_TITEL_1_1"/>
			</fo:block>
			<fo:block/>			
			<fo:block font-family="Times">
				<xsl:apply-templates select="repository/corpname"/>				
				<fo:block/>				
				<xsl:apply-templates select="unitid/@repositorycode"/>
			</fo:block>	
			<xsl:if test="unititle">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_1_2">
					<xsl:copy-of select="$DISP_TITEL_1_2"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="unittitle"/>
				</fo:block>	
			</xsl:if>
			<xsl:if test="unitdate">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_1_3">
					<xsl:copy-of select="$DISP_TITEL_1_3"/>
				</fo:block>	
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="unitdate"/>
				</fo:block>	
			</xsl:if>
			<xsl:if test="physdesc/extent[@label='Omvang']">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_1_4">
					<xsl:copy-of select="$DISP_TITEL_1_4"/>
				</fo:block>	
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="physdesc/extent[@label='Omvang']"/>
				</fo:block>				
			</xsl:if>
			<xsl:if test="physdesc/extent[@label='Opmerkingen']/p/text()">
				<fo:block font-family="Times">
					<xsl:copy-of select="$DISP_TITEL_OPM"/>
				</fo:block>	
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="physdesc/extent[@label='Opmerkingen']"/>
				</fo:block>			
			</xsl:if>
			<xsl:if test="physdesc/extent[@label='Aard archief']/p/text()">
				<fo:block font-family="Times">
					<xsl:copy-of select="$DISP_TITEL_AARD"/>
				</fo:block>	
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="physdesc/extent[@label='Aard archief']"/>
				</fo:block>			
			</xsl:if>
		</fo:block>		
		</xsl:if>	
		
		
		<xsl:if test="head=$TITEL_2">
		<fo:block keep-together.within-page="42">
			<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_2">
				<xsl:copy-of select="$DISP_TITEL_2"/>
			</fo:block>	
			<fo:block/>		
			<xsl:if test="origination">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_2_1">
					<xsl:copy-of select="$DISP_TITEL_2_1"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="origination/extref"/>
				</fo:block>
				<fo:block font-family="Times" font-style="italic">
					<xsl:value-of select="'Deze archiefvormer wordt systematisch beschreven in de databank ODIS (http://www.odis.be)'"/>
				</fo:block>				
			</xsl:if>
			<xsl:if test="bioghist/p/text()">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_2_2">
					<xsl:copy-of select="$DISP_TITEL_2_2"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="bioghist"/>
				</fo:block>			
			</xsl:if>
			<xsl:if test="custodhist/p/text()">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_2_3">
					<xsl:copy-of select="$DISP_TITEL_2_3"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="custodhist"/>
				</fo:block>			
			</xsl:if>
			<xsl:if test="acqinfo/p/text()">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_2_4">
					<xsl:copy-of select="$DISP_TITEL_2_4"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="acqinfo"/>
				</fo:block>			
			</xsl:if>
		</fo:block>	
		</xsl:if>
		
		<xsl:if test="head=$TITEL_3">
		 <fo:block keep-together.within-page="42">
			<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_3">
				<xsl:copy-of select="$DISP_TITEL_3"/>
			</fo:block>	
			<fo:block/>				
			<xsl:if test="scopecontent/head=$TITEL_3_1">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_3_1">
					<xsl:copy-of select="$DISP_TITEL_3_1"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="scopecontent/scopecontent[@label='Bereik en inhoud']"/>
				</fo:block>			
				<xsl:if test="scopecontent/scopecontent[@label='Geografische informatie']/p/text()">
					<fo:block font-family="Times">
						<xsl:copy-of select="$DISP_TITEL_GEO"/>
					</fo:block>
					<fo:block/>					
					<fo:block font-family="Times">
						<xsl:apply-templates select="scopecontent/scopecontent[@label='Geografische informatie']"/>
					</fo:block>				
				</xsl:if>	
				<xsl:if test="scopecontent/scopecontent[@label='Collectie periode']/p/text()">
					<fo:block font-family="Times">
						<xsl:copy-of select="$DISP_TITEL_COLL"/>
					</fo:block>	
					<fo:block/>
					<fo:block font-family="Times">
						<xsl:apply-templates select="scopecontent/scopecontent[@label='Collectie periode']"/>
					</fo:block>				
				</xsl:if>
				<xsl:if test="scopecontent/scopecontent[@label='Gerelateerde organisaties/families/personen']/p/text()">
					<fo:block font-family="Times">
						<xsl:copy-of select="$DISP_TITEL_REL"/>
					</fo:block>
					<fo:block/>
					<fo:block font-family="Times">
						<xsl:apply-templates select="scopecontent/scopecontent[@label='Gerelateerde organisaties/families/personen']"/>
					</fo:block>				
				</xsl:if>
			</xsl:if>			
		
			<xsl:if test="appraisal/head=$TITEL_3_2">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_3_2">
					<xsl:copy-of select="$DISP_TITEL_3_2"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="appraisal"/>
				</fo:block>						
			</xsl:if>	
				<xsl:if test="accruals/head=$TITEL_3_3">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_3_3">
					<xsl:copy-of select="$DISP_TITEL_3_3"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="accruals"/>
				</fo:block>									
			</xsl:if>
			<xsl:if test="arrangement/head=$TITEL_3_4">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_3_4">
					<xsl:copy-of select="$DISP_TITEL_3_4"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="arrangement"/>
				</fo:block>									
			</xsl:if>
		</fo:block>	
		</xsl:if>
		<xsl:if test="head=$TITEL_4">
		<fo:block keep-together.within-page="42">
			<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_4">
				<xsl:copy-of select="$DISP_TITEL_4"/>
			</fo:block>	
			<fo:block/>						
			<xsl:if test="accessrestrict/head=$TITEL_4_1">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_4_1">
					<xsl:copy-of select="$DISP_TITEL_4_1"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="accessrestrict"/>
				</fo:block>			
			</xsl:if>
			<xsl:if test="userestrict/head=$TITEL_4_2">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_4_2">
					<xsl:copy-of select="$DISP_TITEL_4_2"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="userestrict"/>
				</fo:block>			
			</xsl:if>
			<xsl:if test="langmaterial/head=$TITEL_4_3">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_4_3">
					<xsl:copy-of select="$DISP_TITEL_4_3"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="langmaterial"/>
				</fo:block>			
			</xsl:if>
			<xsl:if test="phystech/head=$TITEL_4_4">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_4_4">
					<xsl:copy-of select="$DISP_TITEL_4_4"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="phystech"/>
				</fo:block>			
			</xsl:if>
			<xsl:if test="otherfindaid/head=$TITEL_4_5">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_4_5">
					<xsl:copy-of select="$DISP_TITEL_4_5"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="otherfindaid"/>
				</fo:block>			
			</xsl:if>
		</fo:block>	
		</xsl:if>
		
		<xsl:if test="head=$TITEL_5">
		<fo:block keep-together.within-page="42">
			<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_5">
				<xsl:copy-of select="$DISP_TITEL_5"/>
			</fo:block>	
			<fo:block/>								
			<xsl:if test="originalsloc/head=$TITEL_5_1">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_5_1">
					<xsl:copy-of select="$DISP_TITEL_5_1"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="originalsloc"/>
				</fo:block>			
			</xsl:if>
			<xsl:if test="altformavail/head=$TITEL_5_2">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_5_2">
					<xsl:copy-of select="$DISP_TITEL_5_2"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="altformavail"/>
				</fo:block>			
			</xsl:if>
			<xsl:if test="relatedmaterial/head=$TITEL_5_3">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_5_3">
					<xsl:copy-of select="$DISP_TITEL_5_3"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="relatedmaterial"/>
				</fo:block>			
			</xsl:if>
			<xsl:if test="bibliography/head=$TITEL_5_4">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_5_4">
					<xsl:copy-of select="$DISP_TITEL_5_4"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="bibliography"/>
				</fo:block>			
			</xsl:if>
		</fo:block>	
		</xsl:if>
		<xsl:if test="head=$TITEL_6">
		<fo:block keep-together.within-page="42">
			<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_6">
				<xsl:copy-of select="$DISP_TITEL_6"/>
			</fo:block>	
			<fo:block/>										
			
			<xsl:if test="note/head=$TITEL_6_1">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_6_1">
					<xsl:copy-of select="$DISP_TITEL_6_1"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="note"/>
				</fo:block>			
			</xsl:if>
		</fo:block>	
		</xsl:if>
				
		<xsl:if test="head=$TITEL_7">
		<fo:block keep-together.within-page="42">
			<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_7">
				<xsl:copy-of select="$DISP_TITEL_7"/>
			</fo:block>	
			<fo:block/>												
			<xsl:if test="processinfo[@label='Verantwoording']/head=$TITEL_7_1">
				<xsl:if test="processinfo[@label='Verantwoording']/p/text()">
					<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_7_1">
						<xsl:copy-of select="$DISP_TITEL_7_1"/>
					</fo:block>
					<fo:block/>
					<fo:block font-family="Times">
						<xsl:apply-templates select="processinfo[@label='Verantwoording']"/>
					</fo:block>				
				</xsl:if>	
			</xsl:if>
			<xsl:if test="descrules/head=$TITEL_7_2">
				<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_7_2">
					<xsl:copy-of select="$DISP_TITEL_7_2"/>
				</fo:block>
				<fo:block/>
				<fo:block font-family="Times">
					<xsl:apply-templates select="descrules"/>
				</fo:block>			
			</xsl:if>
			<xsl:if test="processinfo[@label='Datering van de beschrijvingen']/head=$TITEL_7_3">
				<xsl:if test="processinfo[@label='Datering van de beschrijvingen']/p/text()">
					<fo:block font-weight="bold"  font-family="Times" space-before="0.1in" text-align="left" id="DISP_TITEL_7_3">
						<xsl:copy-of select="$DISP_TITEL_7_3"/>
					</fo:block>
					<fo:block/>
					<fo:block font-family="Times">
						<xsl:apply-templates select="processinfo[@label='Datering van de beschrijvingen']"/>
					</fo:block>				
				</xsl:if>	
			</xsl:if>
		</fo:block>	
		</xsl:if>
	</fo:block>	
	</xsl:template>
    <xsl:template name="returnTOC">                
		<fo:block/>
        <fo:block space-before="0.1in" space-after="0.1in" font-weight="bold" color="red" font-family="Times" font-size="9pt"><fo:basic-link internal-destination="toc_gv" >Terug naar Inhoudstafel</fo:basic-link></fo:block>
		</xsl:template>
    <xsl:template name="returnTOC_nohr"> 
		<fo:block/>	
        <fo:block space-before="0.1in" space-after="0.1in" font-weight="bold" color="red" font-family="Times" font-size="9pt"><fo:basic-link internal-destination="toc_gv" >Terug naar Inhoudstafel</fo:basic-link></fo:block>
    </xsl:template>	
		<xsl:template match="langmaterial | appraisal | accruals | arrangement | accessrestrict | userestrict | phystech | otherfindaid
	 | originalsloc | altformavail | relatedmaterial | bibliography | note | processinfo[@label='Verantwoording'] | descrules 
	 | processinfo[@label='Datering van de beschrijvingen'] | bioghist | custodhist |acqinfo 
	 | scopecontent/scopecontent[@label='Bereik en inhoud'] | scopecontent/scopecontent[@label='Geografische informatie']
	 | scopecontent/scopecontent[@label='Collectie periode'] | scopecontent/scopecontent[@label='Gerelateerde organisaties/families/personen']
	 | unittitle | unitdate | physdesc/extent[@label='Omvang'] | physdesc/extent[@label='Opmerkingen'] | physdesc/extent[@label='Aard archief']">
		<xsl:for-each select="archref">
    		<fo:block font-family="Times" font-size="8pt">
				<xsl:if test="string(note)">[<xsl:value-of select="note"/>]&#160;:&#160;</xsl:if>
				<xsl:value-of select="unittitle"/>
			</fo:block>		
			<fo:block/>
		</xsl:for-each>
		<fo:block font-family="Times">
		<xsl:for-each select="p">
				<xsl:value-of select="." disable-output-escaping="yes"/>
				<xsl:if test="following-sibling::*"><xsl:value-of select="','"/>&#160;</xsl:if>
		</xsl:for-each>	
		</fo:block>	
	</xsl:template>	
<xsl:template name="string-replace-all">
    <xsl:param name="text" />
    <xsl:param name="replace" />
    <xsl:param name="by" />
    <xsl:choose>
      <xsl:when test="contains($text, $replace)">
        <xsl:value-of select="substring-before($text,$replace)" />
        <xsl:value-of select="$by" />
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text"
          select="substring-after($text,$replace)" />
          <xsl:with-param name="replace" select="$replace" />
          <xsl:with-param name="by" select="$by" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>	
  
  
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
	  select="substring($padVar,string-length($padVar) - $length + 1)"/>
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
</xsl:stylesheet>
