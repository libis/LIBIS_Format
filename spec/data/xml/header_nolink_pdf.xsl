<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
<xsl:variable name="REC_ID" select="ead/eadheader/eadid/@identifier"/>
<xsl:variable name="TITLE_HEADER" select="ead/eadheader[1]/filedesc[1]/titlestmt[1]/titleproper[1]"/>	
<xsl:variable name="XML_SCOPE_OPAC" select="'http://abs.lias.be/Query/detail.aspx?ID='"/>	

<xsl:variable name="DISP_TITEL_TOC" select="'Inhoudstafel'"/>	
<xsl:variable name="DISP_TITEL_MAIN" select="'Inleiding'"/>	
<xsl:variable name="DISP_TITEL_1" select="'&#x2022; IDENTIFICATIE'"/>
	<xsl:variable name="DISP_TITEL_1_1" select="'Referentie'"/>
	<xsl:variable name="DISP_TITEL_1_2" select="'Titel'"/>
	<xsl:variable name="DISP_TITEL_1_3" select="'Datering'"/>
	<xsl:variable name="DISP_TITEL_1_4" select="'Omvang en medium'"/>
<xsl:variable name="DISP_TITEL_2" select="'&#x2022; CONTEXT'"/>
	<xsl:variable name="DISP_TITEL_2_1" select="'Naam van de archiefvormer(s)'"/>
	<xsl:variable name="DISP_TITEL_2_2" select="'Institutionele geschiedenis / Biografie'"/>
	<xsl:variable name="DISP_TITEL_2_3" select="'Geschiedenis van het archief'"/>
	<xsl:variable name="DISP_TITEL_2_4" select="'Verwerving'"/>
<xsl:variable name="DISP_TITEL_3" select="'&#x2022; INHOUD EN STRUCTUUR'"/>
	<xsl:variable name="DISP_TITEL_3_1" select="'Bereik en inhoud'"/>
	<xsl:variable name="DISP_TITEL_3_2" select="'Selectie'"/>
	<xsl:variable name="DISP_TITEL_3_3" select="'Aanvullingen'"/>
	<xsl:variable name="DISP_TITEL_3_4" select="'Ordening'"/>
<xsl:variable name="DISP_TITEL_4" select="'&#x2022; VOORWAARDEN VOOR RAADPLEGING EN GEBRUIK'"/>
	<xsl:variable name="DISP_TITEL_4_1" select="'Voorwaarden voor raadpleging'"/>
	<xsl:variable name="DISP_TITEL_4_2" select="'Voorwaarden voor reproductie'"/>
	<xsl:variable name="DISP_TITEL_4_3" select="'Taal en schrift'"/>
	<xsl:variable name="DISP_TITEL_4_4" select="'Fysieke kenmerken en technische vereisten'"/>
	<xsl:variable name="DISP_TITEL_4_5" select="'Toegangen'"/>
<xsl:variable name="DISP_TITEL_5" select="'&#x2022; VERWANT MATERIAAL'"/>
	<xsl:variable name="DISP_TITEL_5_1" select="'Bestaan en bewaarplaats van originelen'"/>
	<xsl:variable name="DISP_TITEL_5_2" select="'Bestaan en bewaarplaats van kopieën'"/>
	<xsl:variable name="DISP_TITEL_5_3" select="'Verwante beschrijvingseenheden'"/>
	<xsl:variable name="DISP_TITEL_5_4" select="'Publicaties'"/>	
<xsl:variable name="DISP_TITEL_6" select="'&#x2022; AANTEKENINGEN'"/>
	<xsl:variable name="DISP_TITEL_6_1" select="'Aantekening'"/>
<xsl:variable name="DISP_TITEL_7" select="'&#x2022; BESCHRIJVINGSBEHEER'"/>
	<xsl:variable name="DISP_TITEL_7_1" select="'Verantwoording'"/>
	<xsl:variable name="DISP_TITEL_7_2" select="'Regels of afspraken'"/>
	<xsl:variable name="DISP_TITEL_7_3" select="'Datering van de beschrijvingen'"/>
	<xsl:variable name="DISP_TITEL_7_4" select="'Trefwoorden: '"/>
<xsl:variable name="EAD_ARCHIVAL_TYPE" select="/ead/archdesc[1]/@otherlevel"/>	
<xsl:variable name="DISP_TITEL_8">
		<xsl:choose>
			<xsl:when test="$EAD_ARCHIVAL_TYPE='verzameling'"><xsl:value-of select="'Inhoud van de verzameling'"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="'Inhoud van het archief'"/></xsl:otherwise>
		</xsl:choose>
</xsl:variable>
<xsl:variable name="TITEL_1" select="'1. IDENTIFICATIE'"/>
	<xsl:variable name="TITEL_1_1" select="'1.1. Referentie(s)'"/>
	<xsl:variable name="TITEL_1_2" select="'1.2. Titel'"/>
	<xsl:variable name="TITEL_1_3" select="'1.3. Datering'"/>
	<xsl:variable name="TITEL_1_4" select="'1.4. Omvang en medium'"/>
<xsl:variable name="TITEL_2" select="'2. CONTEXT'"/>
	<xsl:variable name="TITEL_2_1" select="'2.1. Naam van de archiefvormer(s)'"/>
	<xsl:variable name="TITEL_2_2" select="'2.2. Institutionele geschiedenis / Biografie'"/>
	<xsl:variable name="TITEL_2_3" select="'2.3. Geschiedenis van het archief'"/>
	<xsl:variable name="TITEL_2_4" select="'2.4. Verwerving'"/>
<xsl:variable name="TITEL_3" select="'3. INHOUD EN STRUCTUUR'"/>
	<xsl:variable name="TITEL_3_1" select="'3.1. Bereik en inhoud'"/>
	<xsl:variable name="TITEL_3_2" select="'3.2. Selectie'"/>
	<xsl:variable name="TITEL_3_3" select="'3.3. Aanvullingen'"/>
	<xsl:variable name="TITEL_3_4" select="'3.4. Ordening'"/>
<xsl:variable name="TITEL_4" select="'4. VOORWAARDEN VOOR RAADPLEGING EN GEBRUIK'"/>
	<xsl:variable name="TITEL_4_1" select="'4.1. Voorwaarden voor raadpleging'"/>
	<xsl:variable name="TITEL_4_2" select="'4.2. Voorwaarden voor reproductie'"/>
	<xsl:variable name="TITEL_4_3" select="'4.3. Taal en schrift'"/>
	<xsl:variable name="TITEL_4_4" select="'4.4. Fysieke kenmerken en technische vereisten'"/>
	<xsl:variable name="TITEL_4_5" select="'4.5. Toegangen'"/>
<xsl:variable name="TITEL_5" select="'5. VERWANT MATERIAAL'"/>
	<xsl:variable name="TITEL_5_1" select="'5.1. Bestaan en bewaarplaats van originelen'"/>
	<xsl:variable name="TITEL_5_2" select="'5.2. Bestaan en bewaarplaats van kopieën'"/>
	<xsl:variable name="TITEL_5_3" select="'5.3. Verwante beschrijvingseenheden'"/>
	<xsl:variable name="TITEL_5_4" select="'5.4. Publicaties'"/>	
<xsl:variable name="TITEL_6" select="'6. AANTEKENINGEN'"/>
	<xsl:variable name="TITEL_6_1" select="'6.1. Aantekening'"/>
<xsl:variable name="TITEL_7" select="'7. BESCHRIJVINGSBEHEER'"/>
	<xsl:variable name="TITEL_7_1" select="'7.1. Verantwoording'"/>
	<xsl:variable name="TITEL_7_2" select="'7.2. Regels of afspraken'"/>
	<xsl:variable name="TITEL_7_3" select="'7.3. Datering van de beschrijvingen'"/>
	<xsl:variable name="TITEL_7_4" select="'7.4. Trefwoorden'"/>
<xsl:variable name="TITEL_8" select="'LIJST VAN DE DOSSIERS'"/>
<xsl:variable name="DISP_TITEL_OPM" select="'Opmerkingen:'"/>
<xsl:variable name="DISP_TITEL_AARD" select="'Aard archief:'"/>
<xsl:variable name="DISP_TITEL_GEO" select="'Geografische informatie:'"/>
<xsl:variable name="DISP_TITEL_COLL" select="'Collectie periode:'"/>
<xsl:variable name="DISP_TITEL_REL" select="'Gerelateerde organisaties/families/personen:'"/>
<xsl:variable name="EAD_DATE" select="/ead/eadheader[1]/profiledesc[1]/creation[1]/date[1]"/>
<!-- end of ead variables -->	
<!--attribute sets -->
<xsl:variable name="Archief_pt">15pt</xsl:variable> 
<xsl:variable name="Deelarchief_pt">16pt</xsl:variable> 
<xsl:variable name="Afdeling_pt">16pt</xsl:variable>
<xsl:variable name="Onderafdeling_pt">14pt</xsl:variable> 
<xsl:variable name="Rubriek_pt">14pt</xsl:variable> 
<xsl:variable name="Subrubriek_pt">12pt</xsl:variable> 
<xsl:variable name="Reeks_pt">12pt</xsl:variable> 
<xsl:variable name="ReeksMB_pt">10pt</xsl:variable> 
<xsl:variable name="Deelreeks_pt">12pt</xsl:variable> 
<xsl:variable name="DeelreeksMB_pt">10pt</xsl:variable> 
<xsl:variable name="Bestanddeel_pt">10pt</xsl:variable> 
<xsl:variable name="BestanddeelMB_pt">10pt</xsl:variable> 
<xsl:variable name="Subbestanddeel_pt">10pt</xsl:variable> 
<xsl:variable name="SubbestanddeelMB_pt">10pt</xsl:variable> 
<xsl:variable name="Stuk_pt">10pt</xsl:variable>
		
<!-- end of attribute sets -->
<xsl:variable name="GAP" select="'&#160;:&#160;&#160;:&#160;&#160;'"/>
	<xsl:variable name="CLength">
			<xsl:for-each select="//c/did/unitid">
				<xsl:sort select="string-length(.)" order="descending" data-type="number"/>
				<xsl:if test="position() = 1">
					<xsl:value-of select="string-length(.) + string-length($GAP)"/>
				</xsl:if>
			</xsl:for-each>
	</xsl:variable>


</xsl:stylesheet>
