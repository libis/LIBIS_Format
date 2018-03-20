<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
<xsl:variable name="XML_REFCODE" select="ARCHIEF/REFERENCE_CODE"/>
	<xsl:variable name="XML_SIGLUM" select="ARCHIEF/SIGLUM"/>
<xsl:variable name="XML_TITLE">
<xsl:if test="ARCHIEF/TITLE[0]">
	<xsl:value-of select="ARCHIEF/TITLE[0]"/>
</xsl:if>
<xsl:if test="not(ARCHIEF/TITLE[0])">
	<xsl:value-of select="ARCHIEF/TITLE[1]"/>
</xsl:if>
</xsl:variable>


<xsl:variable name="XML_SCOPE_OPAC" select="'http://abs.lias.be/Query/detail.aspx?ID='"/>
<xsl:variable name="XML_AUTH_DB" select="ARCHIEF/AUTHORITY_DATABASE"/>
<xsl:variable name="XML_AUTH_NM" select="ARCHIEF/AUTHORITY_NAME"/>
<xsl:variable name="XML_AUTH_URL" select="ARCHIEF/AUTHORITY_URL"/>
<xsl:variable name="XML_AUTH_CAT" select="ARCHIEF/AUTHORITY_CATEGORY"/>
<xsl:variable name="XML_ARCHIEFINSTELLING_REFCODE" select="ARCHIEF/ARCH_INST/REFERENCE_CODE"/>
<xsl:variable name="XML_ARCHIEFINSTELLING_CITY" select="ARCHIEF/ARCH_INST/LOCATION"/>
<xsl:variable name="XML_ARCHIEFINSTELLING_TITLE" select="ARCHIEF/ARCH_INST/TITLE"/>
<xsl:template match="/">
	<xsl:for-each select="ARCHIEF">
      <xsl:processing-instruction name="xml-stylesheet">
        <xsl:text>type="text/xsl" href="ead/scope_eadToHTML.xsl"</xsl:text>
      </xsl:processing-instruction>
	<ead>
		<eadheader audience="external">
			<eadid><xsl:attribute name="identifier"><xsl:value-of select="GSFT_OBJ_ID"/></xsl:attribute><xsl:attribute name="countrycode">be</xsl:attribute><xsl:attribute name="mainagencycode"><xsl:value-of select="$XML_ARCHIEFINSTELLING_REFCODE"/></xsl:attribute>ead_<xsl:value-of select="$XML_REFCODE"/></eadid>
			<filedesc>
				<xsl:if test="TITLE_FINDING_AID or SUBTITLE_FINDING_AID or AUTHORS_FINDING_AID">
					<titlestmt>
						<xsl:for-each select="TITLE_FINDING_AID">
						<titleproper label="Titel"><xsl:value-of select="."/></titleproper>
						</xsl:for-each>
						<xsl:for-each select="SUBTITLE_FINDING_AID">
							<titleproper label="Ondertitel"><xsl:value-of select="."/></titleproper>
						</xsl:for-each>
						<xsl:for-each select="AUTHORS_FINDING_AID">
							<author label="Auteur"><xsl:value-of select="."/></author>
						</xsl:for-each>
					</titlestmt>
				</xsl:if>
				<xsl:if test="DATES_OF_DESCRIPTION">
					<xsl:for-each select="DATES_OF_DESCRIPTION">
						<publicationstmt>
							<date><xsl:value-of select="."/></date>
							<publisher><xsl:value-of select="$XML_ARCHIEFINSTELLING_TITLE"/>, <xsl:value-of select="$XML_ARCHIEFINSTELLING_CITY"/></publisher>
						</publicationstmt>
					</xsl:for-each>
				</xsl:if>
			</filedesc>
			<profiledesc>
				<creation>
					Deze inventaris werd automatisch gegenereerd en gecodeerd.De EAD-export werd gecontroleerd en gevalideerd door de werkgroep archivarissen van LIAS K.U.Leuven (Leuvens Integraal Archiveringssysteem).
					<date><xsl:value-of select="FILE_DATE"/></date>
				</creation>
				<langusage>
					<language label="Taal" langcode="du">Nederlands</language>
				</langusage>
			</profiledesc>
		</eadheader>

		<archdesc level="archief">
			<descgrp>
				<head>1. IDENTIFICATIE</head>
				<repository label="Archiefinstelling"><corpname><xsl:value-of select="$XML_ARCHIEFINSTELLING_TITLE"/>, <xsl:value-of select="$XML_ARCHIEFINSTELLING_CITY"/></corpname></repository>
				<unitid>
				<xsl:attribute name="countrycode">be</xsl:attribute>
				<xsl:attribute name="repositorycode"><xsl:value-of select="$XML_REFCODE"/></xsl:attribute>
				<head>1.1. Referentie(s)</head>
				<p><xsl:value-of select="$XML_REFCODE"/></p>
				<p><xsl:value-of select="$XML_SIGLUM"/></p>
				</unitid>
				<unittitle>
					<head>1.2. Titel</head>
					<p><xsl:value-of select="$XML_TITLE"/></p>
				</unittitle>
				<xsl:if test="TIME_PERIOD_OF_CREATION_NOTES">
					<unitdate>
						<head>1.3. Datering</head>
						<xsl:for-each select="TIME_PERIOD_OF_CREATION_NOTES">
							<p><xsl:value-of select="."/></p>
						</xsl:for-each>
						<xsl:for-each select="CREATION_DATES_DETAILS">
							<p><xsl:value-of select="."/></p>
						</xsl:for-each>
					</unitdate>
				</xsl:if>
			   <xsl:if test="EXTENT or EXTENT_REMARKS or TYPE_OF_ARCHIVAL_MATERIAL">
				<physdesc>
					<head>1.4. Omvang en medium</head>
					 <xsl:if test="EXTENT">
					<extent label="Omvang">
						<xsl:for-each select="EXTENT">
							<p><xsl:value-of select="."/></p>
						</xsl:for-each>
					</extent>
					</xsl:if>
					<xsl:if test="EXTENT_REMARKS">
						<extent label="Opmerkingen">
						<xsl:for-each select="EXTENT_REMARKS">
							<p><xsl:value-of select="."/></p>
						</xsl:for-each>
						</extent>
					</xsl:if>
					<xsl:if test="TYPE_OF_ARCHIVAL_MATERIAL">
						<genreform label="Aard archief">
						<xsl:for-each select="TYPE_OF_ARCHIVAL_MATERIAL">
							<p><xsl:value-of select="."/></p>
						</xsl:for-each>
					</genreform>
					</xsl:if>
				</physdesc>
				</xsl:if>
			</descgrp>
<xsl:if test="((string-length(translate(normalize-space($XML_AUTH_URL) ,' ',''))!='0') or  (string-length(translate(normalize-space($XML_AUTH_NM) ,' ',''))!='0'))
 or ODIS_BIO or ARCHIVAL_HISTORY or ACQUISITION">
			<descgrp>
				<head>2. CONTEXT</head>
				<xsl:if test="(string-length(translate(normalize-space($XML_AUTH_URL) ,' ',''))!='0') or  (string-length(translate(normalize-space($XML_AUTH_NM) ,' ',''))!='0')">
					<origination label="Archiefvormer">
					<head>2.1. Naam van de archiefvormer(s)</head>
					<extref>
					<xsl:attribute name="entityref"><xsl:value-of select="$XML_AUTH_DB"/></xsl:attribute>
					<xsl:attribute name="show">new</xsl:attribute>
					<xsl:attribute name="href"><xsl:value-of select="$XML_AUTH_URL"/></xsl:attribute>
					<xsl:if test="$XML_AUTH_CAT ='PS'">
						<persname>
						<xsl:attribute name="normal"><xsl:value-of select="$XML_AUTH_NM"/></xsl:attribute>
						<xsl:value-of select="$XML_AUTH_NM"/>
						</persname>
					</xsl:if>
						<xsl:if test="$XML_AUTH_CAT ='OR' or $XML_AUTH_CAT ='ORG'">
						<corpname>
						<xsl:attribute name="normal"><xsl:value-of select="$XML_AUTH_NM"/></xsl:attribute>
						<xsl:value-of select="$XML_AUTH_NM"/>
						</corpname>
					</xsl:if>
					<xsl:if test="$XML_AUTH_CAT ='FAM'">
						<famname>
						<xsl:attribute name="normal"><xsl:value-of select="$XML_AUTH_NM"/></xsl:attribute>
						<xsl:value-of select="$XML_AUTH_NM"/>
						</famname>
					</xsl:if>
					</extref>
				</origination>
				</xsl:if>
				<xsl:if test="ODIS_BIO">
				<bioghist>
					<head>2.2. Institutionele geschiedenis / Biografie</head>
					<p><xsl:value-of select="."/></p>
				</bioghist>
				</xsl:if>
				<xsl:if test="ARCHIVAL_HISTORY">
				<custodhist>
					<head>2.3. Geschiedenis van het archief</head>
					<xsl:for-each select="ARCHIVAL_HISTORY">
						<p><xsl:value-of select="."/></p>
					</xsl:for-each>
				</custodhist>
				</xsl:if>
				<xsl:if test="ACQUISITION">
				<acqinfo>
					<head>2.4. Verwerving</head>
					<xsl:for-each select="ACQUISITION">
					<p><xsl:value-of select="."/></p>
					</xsl:for-each>
				</acqinfo>
				</xsl:if>
		</descgrp>
</xsl:if>
	<xsl:if test="((DESCRIPTION_OF_CONTENTS) or (GEOGRAPHICAL_INFORMATION) or (COLLECTION_TIME_PERIOD) or (RELATIVES_CORPORATIONS_FAMILIES_PEOPLE))
			 or VALUATION_AND_DESTRUCTION or ACCRUALS or ORDERING_AND_CLASSIFICATION">
		<descgrp>
			<head>3. INHOUD EN STRUCTUUR</head>
			<xsl:if test="(DESCRIPTION_OF_CONTENTS) or (GEOGRAPHICAL_INFORMATION) or (COLLECTION_TIME_PERIOD) or (RELATIVES_CORPORATIONS_FAMILIES_PEOPLE)">
			<scopecontent>
			<head>3.1. Bereik en inhoud</head>
			<xsl:if test="DESCRIPTION_OF_CONTENTS">
				<scopecontent label="Bereik en inhoud">
				<head>Bereik en inhoud</head>
				<xsl:for-each select="DESCRIPTION_OF_CONTENTS">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</scopecontent>
			</xsl:if>
			<xsl:if test="GEOGRAPHICAL_INFORMATION">
				<scopecontent label="Geografische informatie">
				<head>Geografische informatie</head>
				<xsl:for-each select="GEOGRAPHICAL_INFORMATION">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</scopecontent>
			</xsl:if>
			<xsl:if test="COLLECTION_TIME_PERIOD">
				<scopecontent label="Collectie periode">
				<head>Collectie periode</head>
				<xsl:for-each select="COLLECTION_TIME_PERIOD">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</scopecontent>
			</xsl:if>
			<xsl:if test="RELATIVES_CORPORATIONS_FAMILIES_PEOPLE">
				<scopecontent label="Gerelateerde organisaties/families/personen">
				<head>Gerelateerde organisaties/families/personen</head>
				<xsl:for-each select="RELATIVES_CORPORATIONS_FAMILIES_PEOPLE">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</scopecontent>
			</xsl:if>
			</scopecontent>
			</xsl:if>
			<xsl:if test="VALUATION_AND_DESTRUCTION">
			<appraisal>
				<head>3.2. Selectie</head>
				<xsl:for-each select="VALUATION_AND_DESTRUCTION">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</appraisal>
			</xsl:if>
			<xsl:if test="ACCRUALS">
			<accruals>
				<head>3.3. Aanvullingen</head>
				<xsl:for-each select="ACCRUALS">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</accruals>
			</xsl:if>
			<xsl:if test="ORDERING_AND_CLASSIFICATION">
			<arrangement>
				<head>3.4. Ordening</head>
				<xsl:for-each select="ORDERING_AND_CLASSIFICATION">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</arrangement>
			</xsl:if>
		</descgrp>
	</xsl:if>
	<xsl:if test="ACCESS_REGULATIONS or REPRODUCTION_SPECIFICATIONS or LANGUAGE or PHYSICAL_PROPERTIES or FINDING_AID">
		<descgrp>
			<head>4. VOORWAARDEN VOOR RAADPLEGING EN GEBRUIK</head>
			<xsl:if test="ACCESS_REGULATIONS">
			<accessrestrict>
				<head>4.1. Voorwaarden voor raadpleging</head>
				<xsl:for-each select="ACCESS_REGULATIONS">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</accessrestrict>
			</xsl:if>
			<xsl:if test="REPRODUCTION_SPECIFICATIONS">
			<userestrict>
				<head>4.2. Voorwaarden voor reproductie</head>
				<xsl:for-each select="REPRODUCTION_SPECIFICATIONS">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</userestrict>
			</xsl:if>
			<xsl:if test="LANGUAGE">
			<langmaterial>
				<head>4.3. Taal en schrift</head>
				<xsl:for-each select="LANGUAGE">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
				<xsl:for-each select="REMARKS_LANGUAGE">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</langmaterial>
			</xsl:if>
			<xsl:if test="PHYSICAL_PROPERTIES">
			<phystech>
				<head>4.4. Fysieke kenmerken en technische vereisten</head>
				<xsl:for-each select="PHYSICAL_PROPERTIES">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</phystech>
			</xsl:if>
			<xsl:if test="FINDING_AID">
			<otherfindaid>
				<head>4.5. Toegangen</head>
				<xsl:for-each select="FINDING_AID">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</otherfindaid>
			</xsl:if>
		</descgrp>
	</xsl:if>

	<xsl:if test="ORIGINALS_EXISTENCE_LOCATION_OF_PRESERVATION or COPIES_EXISTENCE_STORAGE_AREA or UD_REFERENCES or RELATED_MATERIAL or PUBLICATIONS_ or AUDIOVISUAL_MATERIAL or PUBLICATIONS or BIBLIOGRAPHY or SOURCES">
		<descgrp>
			<head>5. VERWANT MATERIAAL</head>
			<xsl:if test="ORIGINALS_EXISTENCE_LOCATION_OF_PRESERVATION">
			<originalsloc>
				<head>5.1. Bestaan en bewaarplaats van originelen</head>
				<xsl:for-each select="ORIGINALS_EXISTENCE_LOCATION_OF_PRESERVATION">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</originalsloc>
			</xsl:if>
			<xsl:if test="COPIES_EXISTENCE_STORAGE_AREA">
			<altformavail>
				<head>5.2. Bestaan en bewaarplaats van kopieën</head>
				<xsl:for-each select="COPIES_EXISTENCE_STORAGE_AREA">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</altformavail>
			</xsl:if>
			<xsl:if test="UD_REFERENCES or RELATED_MATERIAL or PUBLICATIONS_ or AUDIOVISUAL_MATERIAL">
			<relatedmaterial>
				<head>5.3. Verwante beschrijvingseenheden</head>
				<xsl:for-each select="UD_REFERENCES">
				<archref entityref="SCOPE" show="new">
				<xsl:attribute name="href"><xsl:value-of select="$XML_SCOPE_OPAC"/><xsl:value-of select="REF_UD_ID"/></xsl:attribute>
				<unittitle><xsl:value-of select="REF_UD_TITLE"/></unittitle>
				<note><xsl:value-of select="REF_UD_ROLE"/></note>
				</archref>
				</xsl:for-each>
				<xsl:for-each select="RELATED_MATERIAL">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
				<xsl:for-each select="PUBLICATIONS_">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
				<xsl:for-each select="AUDIOVISUAL_MATERIAL">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</relatedmaterial>
			</xsl:if>
			<xsl:if test="PUBLICATIONS or BIBLIOGRAPHY or SOURCES">
			<bibliography>
				<head>5.4. Publicaties</head>
				<xsl:for-each select="PUBLICATIONS">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
				<xsl:for-each select="BIBLIOGRAPHY">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
				<xsl:for-each select="SOURCES">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</bibliography>
			</xsl:if>
		</descgrp>
	</xsl:if>
		<xsl:if test="NOTES or INTERNAL_ARCHIVE_COMMENTS">
		<descgrp>
			<head>6. AANTEKENINGEN</head>
			<note>
				<head>6.1. Aantekening</head>
				<xsl:for-each select="NOTES">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
				<xsl:for-each select="INTERNAL_ARCHIVE_COMMENTS">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</note>
		</descgrp>
		</xsl:if>

	<xsl:if test="UD_ARCHIVIST_LINK or DATES_OF_DESCRIPTION or RULES_AND_CONVENTIONS">
		<descgrp>
			<head>7. BESCHRIJVINGSBEHEER</head>
			<xsl:if test="UD_ARCHIVIST_LINK or DATES_OF_DESCRIPTION">
				<processinfo label="Verantwoording">
				<head>7.1. Verantwoording</head>
				<xsl:for-each select="UD_ARCHIVIST_LINK">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
				<xsl:for-each select="DATES_OF_DESCRIPTION">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</processinfo>
			</xsl:if>
			<xsl:if test="RULES_AND_CONVENTIONS">
			<descrules>
				<head>7.2. Regels of afspraken</head>
				<xsl:for-each select="RULES_AND_CONVENTIONS">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</descrules>
			</xsl:if>
			<xsl:if test="DATES_OF_DESCRIPTION">
				<processinfo label="Datering van de beschrijvingen">
				<head>7.3. Datering van de beschrijvingen</head>
				<xsl:for-each select="DATES_OF_DESCRIPTION">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</processinfo>
			</xsl:if>
		</descgrp>
	</xsl:if>
	<xsl:if test="CONTROL_ACCESS">
		<controlaccess>
			<head>Trefwoorden</head>
			<xsl:if test="CONTROL_ACCESS/CA_THSRS_NM='Persons'">
			<controlaccess>
				<head>Personen</head>
			<xsl:for-each select="CONTROL_ACCESS">
			    <xsl:if test="CA_THSRS_NM='Persons'">
					<extref>
					<xsl:attribute name="href"><xsl:value-of select="CA_THSRS_URL"/></xsl:attribute>
					<xsl:attribute name="show">new</xsl:attribute>
						<persname source="ODIS" role="subject"><xsl:value-of select="CA_THSRS_TREF_NM"/></persname>
					</extref>
				</xsl:if>
			</xsl:for-each>
			</controlaccess>
			</xsl:if>
			<xsl:if test="CONTROL_ACCESS/CA_THSRS_NM='Families'">
			<controlaccess>
				<head>Families</head>
			<xsl:for-each select="CONTROL_ACCESS">
			    <xsl:if test="CA_THSRS_NM='Families'">
					<extref>
					<xsl:attribute name="href"><xsl:value-of select="CA_THSRS_URL"/></xsl:attribute>
					<xsl:attribute name="show">new</xsl:attribute>
						<famname source="ODIS" role="subject"><xsl:value-of select="CA_THSRS_TREF_NM"/></famname>
					</extref>
				</xsl:if>
			</xsl:for-each>
			</controlaccess>
			</xsl:if>
			<xsl:if test="CONTROL_ACCESS/CA_THSRS_NM='Organizations'">
			<controlaccess>
				<head>Organisaties</head>
			<xsl:for-each select="CONTROL_ACCESS">
			    <xsl:if test="CA_THSRS_NM='Organizations'">
					<extref>
					<xsl:attribute name="href"><xsl:value-of select="CA_THSRS_URL"/></xsl:attribute>
					<xsl:attribute name="show">new</xsl:attribute>
						<persname source="ODIS" role="subject"><xsl:value-of select="CA_THSRS_TREF_NM"/></persname>
					</extref>
				</xsl:if>
			</xsl:for-each>
			</controlaccess>
			</xsl:if>

			<xsl:if test="CONTROL_ACCESS/CA_THSRS_NM='Places'">
			<controlaccess>
				<head>Geografische trefwoorden</head>
			<xsl:for-each select="CONTROL_ACCESS">
			    <xsl:if test="CA_THSRS_NM='Places'">
					<extref>
					<xsl:attribute name="href"><xsl:value-of select="CA_THSRS_URL"/></xsl:attribute>
					<xsl:attribute name="show">new</xsl:attribute>
						<geogname source="ODIS" role="subject"><xsl:value-of select="CA_THSRS_TREF_NM"/></geogname>
					</extref>
				</xsl:if>
			</xsl:for-each>
			</controlaccess>
			</xsl:if>

		</controlaccess>
	</xsl:if>
	<xsl:if test="C_CHILD/*">
		<dsc type="combined">
			<head>LIJST VAN DE DOSSIERS</head>
			<xsl:apply-templates select="C_CHILD"/>
		</dsc>
	</xsl:if>
	</archdesc>
</ead>
</xsl:for-each>
</xsl:template>
<xsl:template match="C_CHILD">
	<c>
	<xsl:attribute name="level"><xsl:value-of select="LEVEL"/></xsl:attribute>
	<xsl:attribute name="id"><xsl:value-of select="GSFT_OBJ_ID"/></xsl:attribute>
		<xsl:if test="LEVEL != 'Deelarchief' or LEVEL = 'Deelarchief'">
				<did>
					<unitid label="Ref.code">
					<xsl:attribute name="identifier"><xsl:value-of select="REFERENCE_CODE"/></xsl:attribute>
					<xsl:value-of select="REFERENCE_CODE_ARCHIVE_PLAN"/>
					</unitid>
					<xsl:for-each select="TITLE">
					<unittitle label="Titel">
					<p><xsl:value-of select="text()"/></p>
					</unittitle>
					</xsl:for-each>
					<xsl:for-each select="ORIGINAL_TITLE">
					<unittitle label="Ondertitel">
					<p><xsl:value-of select="text()"/></p>
					</unittitle>
					</xsl:for-each>
					<xsl:for-each select="FORMAL_TITLE">
					<unittitle label="Formele titel">
					<p><xsl:value-of select="text()"/></p>
					</unittitle>
					</xsl:for-each>
					<xsl:for-each select="FORMAL_TITLE">
					<unittitle label="Redactionele vorm">
					<p><xsl:value-of select="text()"/></p>
					</unittitle>
					</xsl:for-each>
					<xsl:for-each select="OBJECT_NAME">
					<unittitle label="Objectnaam">
					<p><xsl:value-of select="text()"/></p>
					</unittitle>
					</xsl:for-each>
					<xsl:for-each select="DGTL">
						<dao linktype="simple" href="http://imgs.ud.edu/archives/image/f12001_1.jpg" actuate="onrequest" show="new">
						<xsl:attribute name="href"><xsl:value-of select="DGTL_ACC_URL"/></xsl:attribute>
						<xsl:attribute name="title"><xsl:value-of select="DGTL_DC_TITLE"/></xsl:attribute>
						</dao>
					</xsl:for-each>
					<xsl:for-each select="DESCRIPTION">
					<unittitle label="Beschrijving">
					<p><xsl:value-of select="text()"/></p>
					</unittitle>
					</xsl:for-each>
					<xsl:for-each select="PRODUCER">
						<origination label="Producer">
							<p><xsl:value-of select="text()"/></p>
						</origination>
					</xsl:for-each>

					<xsl:for-each select="DESIGNER">
						<origination label="Ontwerper">
							<p><xsl:value-of select="text()"/></p>
						</origination>
					</xsl:for-each>

					<xsl:for-each select="DIRECTOR">
						<origination label="Regisseur">
							<p><xsl:value-of select="text()"/></p>
						</origination>
					</xsl:for-each>

					<xsl:for-each select="TIME_PERIOD_OF_CREATION_NOTES">
						<unitdate label="Datum">
							<p><xsl:value-of select="text()"/></p>
						</unitdate>
					</xsl:for-each>
					<xsl:for-each select="CREATION_DATES_DETAILS">
						<unitdate label="Opmerkingen">
							<p><xsl:value-of select="text()"/></p>
						</unitdate>
					</xsl:for-each>
					<xsl:if test="EXTENT or TYPE_OF_ARCHIVAL_MATERIAL or STAGE_OF_DEVELOPMENT">
					<physdesc>
					<xsl:if test="EXTENT">
					<extent label="Omvang">
					<xsl:for-each select="EXTENT">
					<p><xsl:value-of select="text()"/></p>
					</xsl:for-each>
					</extent>
					</xsl:if>
					<xsl:if test="PLAYING_TIME">
					<extent label="Speelduur">
					<xsl:for-each select="PLAYING_TIME">
					<p><xsl:value-of select="text()"/></p>
					</xsl:for-each>
					</extent>
					</xsl:if>
					<xsl:if test="DIMENSIONS">
					<dimensions label="Afmetingen">
					<xsl:for-each select="DIMENSIONS">
					<p><xsl:value-of select="text()"/></p>
					</xsl:for-each>
					</dimensions>
					</xsl:if>
					<xsl:if test="DIMENSIONS_REMARKS">
					<dimensions label="Opmerkingen">
					<xsl:for-each select="DIMENSIONS_REMARKS">
					<p><xsl:value-of select="text()"/></p>
					</xsl:for-each>
					</dimensions>
					</xsl:if>
					<xsl:if test="TYPE_OF_ARCHIVAL_MATERIAL">
						<genreform label="Materiële vorm">
							<xsl:for-each select="TYPE_OF_ARCHIVAL_MATERIAL">
							<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</genreform>
					</xsl:if>
					<xsl:if test="STAGE_OF_DEVELOPMENT">
						<physfacet label="Ontwikkelingsstadium">
							<xsl:for-each select="STAGE_OF_DEVELOPMENT">
							<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</physfacet>
					</xsl:if>
					</physdesc>
					</xsl:if>
					<xsl:if test="ARCHIVAL_HISTORY">
						<custodhist label="Geschiedenis van het archief">
						<xsl:for-each select="ARCHIVAL_HISTORY">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
					</custodhist>
					</xsl:if>
					<xsl:if test="ACQUISITION">
						<acqinfo label="Aanwinst">
						<xsl:for-each select="ACQUISITION">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
						</acqinfo>
					</xsl:if>
					<xsl:if test="ACQUISITION_DATE">
						<acqinfo label="Aanwinst datum">
							<xsl:for-each select="ACQUISITION_DATE">
								<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</acqinfo>
					</xsl:if>
					<xsl:if test="ACQUISITION_METHOD">
						<acqinfo label="Aanwinst methode">
							<xsl:for-each select="ACQUISITION_METHOD">
								<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</acqinfo>
					</xsl:if>
					<xsl:if test="PURCHASE_PRICE">
						<acqinfo label="Aankoopprijs">
							<xsl:for-each select="PURCHASE_PRICE">
								<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</acqinfo>
					</xsl:if>
					<xsl:if test="GENRE_FILM">
						<genreform label="Genre (film)">
							<xsl:for-each select="GENRE_FILM">
								<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</genreform>
					</xsl:if>
					<xsl:if test="CATEGORY_FILM">
						<genreform label="Categorie (film)">
							<xsl:for-each select="CATEGORY_FILM">
								<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</genreform>
					</xsl:if>
					<xsl:if test="DESCRIPTION_OF_CONTENTS or GEOGRAPHICAL_INFORMATION or COLLECTION_TIME_PERIOD or RELATIVES_CORPORATIONS_FAMILIES_PEOPLE">

					<xsl:if test="DESCRIPTION_OF_CONTENTS">
						<scopecontent label="Inhoud">
						<xsl:for-each select="DESCRIPTION_OF_CONTENTS">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
						</scopecontent>
					</xsl:if>
					<xsl:if test="GEOGRAPHICAL_INFORMATION">
						<scopecontent label="Geografische informatie">
						<xsl:for-each select="GEOGRAPHICAL_INFORMATION">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
						</scopecontent>
					</xsl:if>
					<xsl:if test="COLLECTION_TIME_PERIOD">
						<scopecontent label="Collectie periode">
						<xsl:for-each select="COLLECTION_TIME_PERIOD">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
						</scopecontent>
					</xsl:if>
					<xsl:if test="RELATIVES_CORPORATIONS_FAMILIES_PEOPLE">
						<scopecontent label="Gerelateerde organisaties/families/personen">
						<xsl:for-each select="RELATIVES_CORPORATIONS_FAMILIES_PEOPLE">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
						</scopecontent>
					</xsl:if>
					</xsl:if>
					<xsl:if test="VALUATION_AND_DESTRUCTION">
						<appraisal label="Selectie">
						<xsl:for-each select="VALUATION_AND_DESTRUCTION">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
					</appraisal>
					</xsl:if>
					<xsl:if test="ACCRUALS">
						<accruals label="Aanvullingen">
						<xsl:for-each select="ACCRUALS">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
					</accruals>
					</xsl:if>
					<xsl:if test="ORDERING_AND_CLASSIFICATION">
						<arrangement label="Ordening">
						<xsl:for-each select="ORDERING_AND_CLASSIFICATION">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
					</arrangement>
					</xsl:if>
					<xsl:if test="ACCESS_REGULATIONS">
						<accessrestrict label="Voorwaarden voor raadpleging">
						<xsl:for-each select="ACCESS_REGULATIONS">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
					</accessrestrict>
					</xsl:if>
					<xsl:if test="REPRODUCTION_SPECIFICATIONS">
						<userestrict label="Voorwaarden voor reproductie">
						<xsl:for-each select="REPRODUCTION_SPECIFICATIONS">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
					</userestrict>
					</xsl:if>
					<xsl:if test="LANGUAGE">
						<langmaterial label="Taal">
						<xsl:for-each select="LANGUAGE">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
					</langmaterial>
					</xsl:if>
					<xsl:if test="REMARKS_LANGUAGE">
						<langmaterial label="Opmerkingen">
							<xsl:for-each select="REMARKS_LANGUAGE">
								<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</langmaterial>
					</xsl:if>
					<xsl:if test="PHYSICAL_PROPERTIES">
						<phystech label="Fysieke kenmerken en technische vereisten">
						<xsl:for-each select="PHYSICAL_PROPERTIES">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
					</phystech>
					</xsl:if>
					<xsl:if test="TECHNIQUE">
						<phystech label="Techniek">
							<xsl:for-each select="TECHNIQUE">
								<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</phystech>
					</xsl:if>
					<xsl:if test="TECHNIQUE_MEDIA_ORIGINAL_FILM">
						<phystech label="Techniek origineel medium (film)">
							<xsl:for-each select="TECHNIQUE_MEDIA_ORIGINAL_FILM">
								<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</phystech>
					</xsl:if>
					<xsl:if test="TECHNIQUE_MEDIA_COPIES_FILM">
						<phystech label="Techniek kopie medium (film)">
							<xsl:for-each select="TECHNIQUE_MEDIA_COPIES_FILM">
								<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</phystech>
					</xsl:if>
					<xsl:if test="MATERIAL">
						<phystech label="Materiaal">
							<xsl:for-each select="MATERIAL">
								<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</phystech>
					</xsl:if>
					<xsl:if test="TECHNIQUE_MATERIAL_FILM">
						<phystech label="Techniek materiaal (film)">
							<xsl:for-each select="TECHNIQUE_MATERIAL_FILM">
								<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</phystech>
					</xsl:if>
					<xsl:if test="TECHNIQUE_SOUND_FILM">
						<phystech label="Techniek geluid (film)">
							<xsl:for-each select="TECHNIQUE_SOUND_FILM">
								<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</phystech>
					</xsl:if>
					<xsl:if test="COLOR_IMAGE_PROCESSING">
						<phystech label="Kleur/Beeld">
							<xsl:for-each select="COLOR_IMAGE_PROCESSING">
								<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</phystech>
					</xsl:if>
					<xsl:if test="ORIGINALS_EXISTENCE_LOCATION_OF_PRESERVATION">
						<originalsloc label="Bestaan en bewaarplaatsen van originelen">
						<xsl:for-each select="ORIGINALS_EXISTENCE_LOCATION_OF_PRESERVATION">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
					</originalsloc>
					</xsl:if>
					<xsl:if test="COPIES_EXISTENCE_STORAGE_AREA">
						<altformavail label="Bestaan en bewaarplaatsen van kopieën">
						<xsl:for-each select="COPIES_EXISTENCE_STORAGE_AREA">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
					</altformavail>
					</xsl:if>
					<xsl:if test="UD_REFERENCES[REF_UD_STATUS=2] or RELATED_MATERIAL or PUBLICATIONS_ or AUDIOVISUAL_MATERIAL">

						<xsl:if test="UD_REFERENCES[REF_UD_STATUS=2]">
					<relatedmaterial label="Verwante beschrijvingseenheden">
						<xsl:for-each select="UD_REFERENCES[REF_UD_STATUS=2]">
							<archref entityref="SCOPE" show="new">
							<xsl:attribute name="href"><xsl:value-of select="$XML_SCOPE_OPAC"/><xsl:value-of select="REF_UD_ID"/></xsl:attribute>
								<unittitle><p><xsl:value-of select="REF_UD_TITLE"/></p></unittitle>
								<note><p><xsl:value-of select="REF_UD_ROLE"/></p></note>
							</archref>
						</xsl:for-each>
					</relatedmaterial>
					</xsl:if>
					<xsl:if test="RELATED_MATERIAL">
						<relatedmaterial label="Verwante beschrijvingseenheden">
						<xsl:for-each select="RELATED_MATERIAL">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
						</relatedmaterial>
					</xsl:if>
					<xsl:if test="PUBLICATIONS_">
						<relatedmaterial label="Verwante publicaties">
						<xsl:for-each select="PUBLICATIONS_">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
						</relatedmaterial>
					</xsl:if>
					<xsl:if test="AUDIOVISUAL_MATERIAL">
						<relatedmaterial label="Verwant audiovisueel materiaal">
						<xsl:for-each select="AUDIOVISUAL_MATERIAL">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
						</relatedmaterial>
					</xsl:if>
					</xsl:if>
					<xsl:if test="PUBLICATIONS">
						<bibliography label="Publicaties">
						<xsl:for-each select="PUBLICATIONS">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
						</bibliography>
					</xsl:if>
					<xsl:if test="BIBLIOGRAPHY">
						<bibliography label="Bibliografie">
						<xsl:for-each select="BIBLIOGRAPHY">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
						</bibliography>
					</xsl:if>
					<xsl:if test="SOURCES">
						<bibliography label="Bronnen">
						<xsl:for-each select="SOURCES">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
					</bibliography>
					</xsl:if>
					<xsl:if test="ANNEXES">
						<bibliography label="Bijlagen">
								<xsl:for-each select="ANNEXES">
									<p><xsl:value-of select="text()"/></p>
								</xsl:for-each>
							</bibliography>
					</xsl:if>

					<xsl:if test="NOTES">
						<note label="Aantekeningen">
						<xsl:for-each select="NOTES">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
						</note>
					</xsl:if>
					<xsl:if test="INTERNAL_ARCHIVE_COMMENTS">
						<note label="Werknotities">
						<xsl:for-each select="INTERNAL_ARCHIVE_COMMENTS">
							<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
						</note>
					</xsl:if>
					<xsl:if test="ARCHIVISTS_NOTE">
						<processinfo label="Verantwoording">
							<xsl:for-each select="ARCHIVISTS_NOTE">
								<p><xsl:value-of select="text()"/></p>
							</xsl:for-each>
						</processinfo>
					</xsl:if>
					<xsl:if test="DATES_OF_DESCRIPTION">
						<processinfo label="Datum van de beschrijving">
						<xsl:for-each select="DATES_OF_DESCRIPTION">
						<p><xsl:value-of select="text()"/></p>
						</xsl:for-each>
					</processinfo>
					</xsl:if>
					<xsl:if test="CONTROL_ACCESS/CA_THSRS_NM">
					<controlaccess>
						<head>Trefwoorden</head>
							<xsl:if test="CONTROL_ACCESS/CA_THSRS_NM='Persons'">
							<controlaccess>
								<head>Personen</head>
									<xsl:for-each select="CONTROL_ACCESS">
										<xsl:if test="CA_THSRS_NM='Persons'">

											<extref>
											<xsl:attribute name="href"><xsl:value-of select="CA_THSRS_URL"/></xsl:attribute>
											<xsl:attribute name="show">new</xsl:attribute>
												<persname source="ODIS" role="subject" label="Trefwoorden personen"><xsl:value-of select="CA_THSRS_TREF_NM"/></persname>
											</extref>
										</xsl:if>
									</xsl:for-each>
							</controlaccess>
							</xsl:if>
							<xsl:if test="CONTROL_ACCESS/CA_THSRS_NM='Organizations'">
							<controlaccess>
								<head>Organisaties</head>
									<xsl:for-each select="CONTROL_ACCESS">
										<xsl:if test="CA_THSRS_NM='Organizations'">
											<extref>
											<xsl:attribute name="href"><xsl:value-of select="CA_THSRS_URL"/></xsl:attribute>
											<xsl:attribute name="show">new</xsl:attribute>
												<corpname source="ODIS" role="subject" label="Trefwoorden organisaties"><xsl:value-of select="CA_THSRS_TREF_NM"/></corpname>
											</extref>
										</xsl:if>
									</xsl:for-each>
							</controlaccess>
							</xsl:if>
							<xsl:if test="CONTROL_ACCESS/CA_THSRS_NM='Families'">
							<controlaccess>
								<head>Families</head>
								<xsl:for-each select="CONTROL_ACCESS">
									<xsl:if test="CA_THSRS_NM='Families'">
											<famname source="ODIS" role="subject" label="Trefwoorden families"><xsl:value-of select="CA_THSRS_TREF_NM"/></famname>
									</xsl:if>
								</xsl:for-each>
							</controlaccess>
							</xsl:if>
							<xsl:if test="CONTROL_ACCESS/CA_THSRS_NM='Places'">
								<controlaccess>
									<head>Geografische trefwoorden</head>
									<xsl:for-each select="CONTROL_ACCESS">
										<xsl:if test="CA_THSRS_NM='Places'">
											<extref>
											<xsl:attribute name="href"><xsl:value-of select="CA_THSRS_URL"/></xsl:attribute>
											<xsl:attribute name="show">new</xsl:attribute>
												<geogname source="ODIS" role="subject" label="Geografische trefwoorden"><xsl:value-of select="CA_THSRS_TREF_NM"/></geogname>
											</extref>
										</xsl:if>
									</xsl:for-each>
								</controlaccess>
							</xsl:if>
							<xsl:if test="CONTROL_ACCESS/CA_THSRS_NM='Subjects'">
								<controlaccess>
									<head>Subjects</head>
									<xsl:for-each select="CONTROL_ACCESS">
										<xsl:if test="CA_THSRS_NM='Subjects'">
											<subject source="ODIS" role="subject" label="Inhoudstrefwoorden"><xsl:value-of select="CA_THSRS_TREF_NM"/></subject>
										</xsl:if>
									</xsl:for-each>
								</controlaccess>
							</xsl:if>

							</controlaccess>
					</xsl:if>
					<xsl:apply-templates select="C_CHILD"/>
				</did>
			</xsl:if>
			</c>
		</xsl:template>
</xsl:stylesheet>
