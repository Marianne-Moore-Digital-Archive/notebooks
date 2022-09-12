<?xml version="1.0" encoding="UTF-8"?>
<!--  
    Stylesheet to transform TEI-XML input 
    Developed By: Nick
    Version: 1.0.0
    Date: 18-07-2022
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:funct="urn:stylesheet-functions"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
<!--    <xsl:output indent="no"/>-->
<!--    <xsl:preserve-space elements="tei:l"/>-->
    
    <!-- Suppress all the templates which are not used -->
    <xsl:template match="*"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:TEI">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:text">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:body">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Template to create separate file based on each div which contains image information -->
    <xsl:template match="tei:div[@type = 'image']">
        <!-- Creating each HTML file ID -->
        <xsl:variable name="fileId" select="replace(tei:div/@xml:id, 'text', 'diplomatic')"/>
        <xsl:variable name="fileId" select="replace($fileId, '_verso', '-verso')"/>
        <xsl:variable name="fileId" select="replace($fileId, '_recto', '-recto')"/>
        <xsl:variable name="graphic" select="replace($fileId, '_diplomatic', '')"/>
        <xsl:variable name="graphic" select="replace($graphic, '-verso', '')"/>
        <xsl:variable name="graphic" select="replace($graphic, '-recto', '')"/>
        <xsl:variable name="graphic" select="concat($graphic, '.jpg')"/>
        <!-- Save output into html file -->
        <xsl:result-document method="html" href="page_{$fileId}.html" indent="no">
            <html lang="en-US">
                <!-- Output html header info -->
                <xsl:call-template name="output-html-file-header"/>
                <body>
                    <section id="central_wrapper">
                        <div id="text_frame">
                            <div id="text">
                                <!-- Process tei:div[@type = 'page'] -->
                                <xsl:apply-templates/>
                                <!-- Show Annotations -->
                                <div id="areaAnnotations">
                                    <div id="realImageWidth" style="display:none;">
                                        <!-- NW: need to add support for div@id=realImageWidth to set the image width for each page separately.
                                            This value is set by TEI/facsimile/surface/surface/graphic@width="[#]px" 
                                        INDY: if there is no @width then it will set 1200px by default. 
                                        -->
                                        <xsl:variable name="pburl">
                                            <xsl:value-of select="tei:div[@type = 'page']/tei:pb/@facs"/>
                                        </xsl:variable>
                                        <xsl:variable name="realImageWidth">
                                            <xsl:value-of select="./ancestor::tei:TEI/tei:facsimile/tei:surface/tei:surface/tei:graphic[@url=$pburl]/@width"/>
                                        </xsl:variable>
                                        <xsl:choose>
                                            <xsl:when test="$realImageWidth">
                                                <xsl:value-of select="$realImageWidth"/>
                                            </xsl:when>
                                            <xsl:otherwise>1200px</xsl:otherwise>
                                        </xsl:choose>
                                    </div>
                                    <xsl:apply-templates select="tei:div/tei:lg/tei:l"
                                        mode="output-area-annotations"/>
                                </div>
                            </div>
                        </div>
                    </section>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    <!-- div type="page" handling -->
    <xsl:template match="tei:div[@type = 'page']">
        <div id="AnnMenu">
            <div class="AnnSubmenu_Line">
                <div class="AnnSubmenu" id="content_edit" contenteditable="false"
                    style="display: block;">
                    <span id="pgZoomVal" zoom="" dimTop="" dimLeft=""/>
                    <!-- Process lg element -->
                    <xsl:apply-templates/>
                </div>
            </div>
        </div>
    </xsl:template>
    <!-- Not needed for now so suppressing it. This is for Oxygen page break -->
    <xsl:template match="tei:pb"/>
    <!-- Not needed for now so suppressing it-->
    <!--<desc>[Inside front cover.]</desc>-->
    <xsl:template match="tei:desc"/>
    <!-- 
        Process lg element handling. We may plan in future if there is any decision we can put code inside this template.
    -->
    <xsl:template match="tei:lg">
        <!-- Process children of tei:lg elements. i.e. tei:l -->
        <xsl:if test="@type = 'vertical'">
            <div>----------------------------------------------</div>
            <div>Vertical Lines:</div>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Line template -->
    <xsl:template match="tei:l">
        <xsl:variable name="id" select="ancestor::tei:div[@type = 'page']/@xml:id"/>
        <xsl:variable name="line-id" select="concat($id, '_line_', @n)"/>
        <div style="list-style:none; background: white; white-space: pre;" class="AnnMenuItem"
            id="MenuItem_{$line-id}" onclick="JumpTo('{$line-id}')"
            onmouseover="Highlight('{$line-id}')" onmouseout="UnHighlight()">
            <xsl:call-template name="output-genre-bands"/>
            <div class="dipl">
                <span class="dipl-lineN"/>
                <div style="max-width: 479.65px;" class="dipl-left">
                    <span class="dipl-choice_popup">
                        <span style="color: black;" class="dipl-orig">
                            <!-- Process all inline elements -->
                            <xsl:apply-templates/>
                        </span>
                    </span>
                </div>
            </div>
        </div>
    </xsl:template>
    <!--**********************************************Inline element handling****************************************************-->
    <!-- Note handling -->
    <xsl:template match="tei:note">
        <xsl:variable name="note" select="text()"/>
        <span id="helpico"
            style="background-image: url('images/rsz_4notes.png'); background-repeat: no-repeat; white-space: normal;">
            <sup>
                <xsl:apply-templates select="tei:title" mode="note-title"/>
                <span class="notes" value="{$note}"
                    style=" vertical-align: super; font-size: 60%; text-decoration: blink;white-space: normal;"
                    > &#160;&#160;&#160;&#160;&#160; </span>
                <span id="notePopup" onclick="openNotePopupBox($(this))"
                    class="dipl-choice_popup notescheckbox">
                    <span id="notePopupBox" class="dipl-reg">
                        <xsl:apply-templates/>
                    </span>
                </span>
            </sup>
        </span>
    </xsl:template>
    <!-- Hanlding of glossary note
        NW: Need to add <sup> tag around glossary note spans to match the regular note encoding -->
    <xsl:template match="tei:note[@type = 'glossary']">
        <xsl:variable name="glossaryuniqueid" select="@target"/>
        <sup>
            <span id="glossaryPopup" onclick="openGlossaryPopupBox($(this))"
                class="dipl-choice_popup glossarycheckbox">
                <span id="notePopupBox" class="dipl-reg" value="{$glossaryuniqueid}">
                    <xsl:apply-templates select="tei:title" mode="note-title"/>
                    <xsl:apply-templates/>
                </span>
            </span>
        </sup>
    </xsl:template>
    <!-- For now it's fine. Later if needed we can decide formatting. -->
    <xsl:template match="tei:bibl">
        <span>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- Not doing anythign for now. Later we can decide in future -->
    <xsl:template match="tei:quote">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- <span style="padding-left:{@extent}px;"></span> -->
    <!-- Putting space with same number of @extent -->
    <xsl:template match="tei:gap">
        <xsl:variable name="extent" select="@extent"/>
        <span id="gapblock">
            <xsl:for-each select="1 to $extent">&#9072;</xsl:for-each>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- Fine for now. Later we can decide formatting. -->
    <xsl:template match="tei:lang">
        <span>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- Fine for now. Later we can decide formatting. -->
    <!--Foreign phrases are not styled by default, but we do set the language (and script) on them.
            See <a href="https://en.wikipedia.org/wiki/ISO_15924">ISO-15924</a> for script codes.-->
    <xsl:template match="tei:foreign">
        <span>
            <xsl:copy-of select="funct:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- default title element handling in case there is any inside l. Not needed for now but in case there is in future. can change formattingbhere. -->
    <xsl:template match="tei:title[not(./parent::tei:note)]">
        <span>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- Special handling of note's title -->
    <xsl:template match="tei:title" mode="note-title">
        <span style="font-style:italic;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!--Adding color according to @rend-->
    <xsl:template match="tei:hi">
        <xsl:variable name="rend" select="@rend"/>
        <xsl:choose>
            <xsl:when test="$rend = 'pencil'">
                <span class="hi" style="color:darkgrey">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="$rend = 'underline'">
                <span class="hi" style="text-decoration:underline">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="$rend = 'strikethrough'">
                <span class="hi" style="text-decoration:line-through">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="$rend = 'underline strikethrough'">
                <span class="hi" style="text-decoration:underline line-through">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="$rend = 'i'">
                <span class="hi" style="font-style:italic">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="hi" style="color:{$rend}">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:del">
        <span style="text-decoration: line-through;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- A template for the <add> tag -->
    <xsl:template match="tei:add">
        <span>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:unclear">
        <span style="color: black; background: grey;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- NW: I changed @genre to @subtype to match our new XML formatting and it worked. 
             Need to add a new template or function to detect @type=begin/end and then
             apply these to all lines contained within seg @type=begin/end @subtype=conv/read/prose/verse -->
    <!-- INDY: As per discussion on 03-08-2022 with Nick, we decided to add @rend values in all the lines. If there is more than one value then
               they should appear with space separated.
               e.g. <l n="09" rend="conv"> OR <l n="10" rend="conv verse">
    -->
    <xsl:template name="output-genre-bands">
        <xsl:variable name="rend">
            <xsl:value-of select="@rend"/>
        </xsl:variable>
        
        <xsl:variable name="conv">
            <xsl:if test="tokenize($rend, ' ') = ('conv')">
                <xsl:value-of select="'conv'"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="read">
            <xsl:if test="tokenize($rend, ' ') =('read')">
                <xsl:value-of select="'read'"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="prose">
            <xsl:if test="tokenize($rend, ' ') =('prose')">
                <xsl:value-of select="'prose'"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="verse">
            <xsl:if test="tokenize($rend, ' ') =('verse')">
                <xsl:value-of select="'verse'"/>
            </xsl:if>
        </xsl:variable>
        <div class="{normalize-space(concat('genreBands', ' ', $conv))}"/>
        <div class="{normalize-space(concat('genreBands', ' ', $read))}"/>
        <div class="{normalize-space(concat('genreBands', ' ', $prose))}"/>
        <div class="{normalize-space(concat('genreBands', ' ', $verse))}"/>
    </xsl:template>
    <!-- 
        ~ Header is static for all the HTML files
        ~ header - For the HTML header, the field that the HTML file title should come from is TEI>teiHeader>fileDesc>titleStmt>title.
    -->
    <xsl:template name="output-html-file-header">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
            <meta property="og:title" content=""/>
            <meta property="og:image" content="../../data/input_data/images/thumb_fb.jpg"/>
            <title>
                <xsl:value-of
                    select="./ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"
                />
            </title>
            <link rel="stylesheet" type="text/css" href="../../css/page_data-include-diplomatic.css"/>
            <script type="text/javascript" src="../../js/jquery_lib/jquery-latest.js"/>
            <script type="text/javascript" src="../../js/jquery_lib/jquery-ui-latest.js"/>
        </head>
    </xsl:template>
    <!-- Output annotations -->
    <xsl:template match="tei:l" mode="output-area-annotations">
        <xsl:variable name="id" select="ancestor::tei:div[@type = 'page']/@xml:id"/>
        <xsl:variable name="line-id" select="concat($id, '_line_', @n)"/>
        <xsl:variable name="zone-id"
            select="concat(replace($id, '_text', '_surface'), '_line_', @n)"/>
        <xsl:variable name="graphic" select="replace($id, '_diplomatic', '')"/>
        <xsl:variable name="graphic" select="replace($graphic, '_verso', '-verso')"/>
        <xsl:variable name="graphic" select="replace($graphic, '_recto', '-recto')"/>
        <xsl:variable name="graphic" select="replace($graphic, '_text', '')"/>
        <xsl:variable name="graphic" select="concat($graphic, '.jpeg')"/>
        <xsl:variable name="facs" select="./@facs"/>
        <xsl:variable name="facs2" select="substring-after($facs, '#')"/>
        <xsl:variable name="origwidth"
            select="./ancestor::tei:facsimile/tei:surface/tei:surface/tei:graphic[@url = $graphic]/@width"/>
        <xsl:variable name="origheight"
            select="./ancestor::tei:facsimile/tei:surface/tei:surface/tei:graphic[@url = $graphic]/@height"/>
        <xsl:variable name="naturalwidth" select="2154"/>
        <xsl:variable name="naturalheight" select="1791"/>
        <xsl:variable name="wratio" select="$naturalwidth div $origwidth"/>
        <xsl:variable name="hratio" select="$naturalheight div $origheight"/>
        <!--left is ulx
            top is uly
            width = lrx-ulx
            height= lry - uly-->
        <xsl:variable name="ulx"
            select="./ancestor::tei:TEI/tei:facsimile/tei:surface/tei:surface/tei:zone[@xml:id = $zone-id]/@ulx"/>
        <xsl:variable name="uly"
            select="./ancestor::tei:TEI/tei:facsimile/tei:surface/tei:surface/tei:zone[@xml:id = $zone-id]/@uly"/>
        <xsl:variable name="lrx"
            select="./ancestor::tei:TEI/tei:facsimile/tei:surface/tei:surface/tei:zone[@xml:id = $zone-id]/@lrx"/>
        <xsl:variable name="lry"
            select="./ancestor::tei:TEI/tei:facsimile/tei:surface/tei:surface/tei:zone[@xml:id = $zone-id]/@lry"/>
        <xsl:variable name="width" select="$lrx - $ulx"/>
        <xsl:variable name="height" select="$lry - $uly"/>
        <div id="Area_{$line-id}" class="Area" onclick="ShowAnn('{$line-id}')"
            onmouseover="Highlight('{$line-id}')" onmouseout="UnHighlight()"
            style="position: absolute; hratio:{$hratio}; left: {$ulx}px; top: {$uly}px; width: {$width}px; height:{$height}px ; origwidth: {$origwidth}; origheight:{replace($origheight,'px','')}; padding: 0; cursor: pointer; font-size: 144px; text-align: center; vertical-align: middle; display: none; overflow: hidden;"
        > </div>
    </xsl:template>
    
    <!-- **************************************************************************************************************** -->
    <!-- ************************************************FUNCTIONS******************************************************* -->
    <!-- **************************************************************************************************************** -->
    <!--Normalize language attributes used in the output to match valid language codes
            (see http://tools.ietf.org/html/rfc5646).-->
    <xsl:function name="funct:fix-lang" as="xs:string">
        <xsl:param name="lang" as="xs:string"/>
        <xsl:choose>
            <!-- Strip endings with -x-..., such as in la-x-bio -->
            <xsl:when test="matches($lang, '^[a-z]{2}-x-')">
                <xsl:value-of select="substring($lang, 1, 2)"/>
            </xsl:when>
            <!-- Strip endings with -1900, such as in nl-1900 -->
            <xsl:when test="matches($lang, '^[a-z]{2}-\d{4}')">
                <xsl:value-of select="substring($lang, 1, 2)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$lang"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- Shortcut for both id and language tagging -->
    <!--Generate both a lang and an id attribute.-->
    <xsl:function name="funct:set-lang-id-attributes" as="attribute()*">
        <xsl:param name="node" as="element()"/>
        <xsl:copy-of select="funct:generate-lang-attribute($node/@xml:lang)"/>
    </xsl:function>
    <xsl:function name="funct:generate-lang-attribute" as="attribute()*">
        <xsl:param name="lang" as="xs:string?"/>
        <xsl:if test="$lang">
            <xsl:attribute name="lang" select="funct:fix-lang($lang)"/>
        </xsl:if>
    </xsl:function>
    <!-- ****************************************END FUNCTIONS************************************************************************ -->
</xsl:stylesheet>
