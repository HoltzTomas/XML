<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
  <xsl:template match="/">
    <fo:root>
      <fo:layout-master-set>
        <fo:simple-page-master master-name="first" margin-right="1.5cm" margin-left="1.5cm" margin-bottom="2cm" margin-top="1cm" page-width="21cm" page-height="29.7cm">
          <fo:region-body margin-top="1cm"/>
          <fo:region-before extent="1cm"/>
        </fo:simple-page-master>
      </fo:layout-master-set>
      <fo:page-sequence master-reference="first">
        <fo:static-content flow-name="xsl-region-before">
          <fo:block line-height="14pt" font-size="10pt" text-align="end">
            <xsl:value-of select="concat(handball_data/season/category, ' Handball season for ', handball_data/season/gender, ' - ', handball_data/season/year)"/>
          </fo:block>
        </fo:static-content>
        <fo:flow flow-name="xsl-region-body">
          <xsl:choose>
            <xsl:when test="handball_data/error">
              <fo:block font-size="12pt" color="red">
                <xsl:for-each select="handball_data/error">
                  <xsl:value-of select="."/><fo:block/>
                </xsl:for-each>
              </fo:block>
            </xsl:when>
            <xsl:otherwise>
              <fo:block font-size="16pt" space-before.optimum="15pt" space-after.optimum="18pt">
                Competitors of <xsl:value-of select="handball_data/season/name"/>
              </fo:block>
              <xsl:for-each select="handball_data/competitors/competitor">
                <xsl:sort select="@name"/>
                <xsl:apply-templates select="."/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </fo:flow>
      </fo:page-sequence>
    </fo:root>
  </xsl:template>

  <xsl:template match="competitor">
    <fo:block font-size="12pt">
      <xsl:value-of select="@name"/>
      <xsl:if test="string-length(@country) > 0"> (<xsl:value-of select="@country"/>)</xsl:if>
    </fo:block>
    <fo:table space-after.optimum="18pt" table-layout="fixed" width="100%" border-width="1pt" border-style="solid">
      <fo:table-column column-number="1" column-width="40%"/>
      <fo:table-column column-number="2" column-width="7%"/>
      <fo:table-column column-number="3" column-width="7%"/>
      <fo:table-column column-number="4" column-width="7%"/>
      <fo:table-column column-number="5" column-width="7%"/>
      <fo:table-column column-number="6" column-width="7%"/>
      <fo:table-column column-number="7" column-width="7%"/>
      <fo:table-column column-number="8" column-width="7%"/>
      <fo:table-body>
        <fo:table-row background-color="rgb(215,245,250)">
          <fo:table-cell><fo:block font-size="8pt" text-align="center">Group</fo:block></fo:table-cell>
          <fo:table-cell><fo:block font-size="8pt" text-align="center">Rank</fo:block></fo:table-cell>
          <fo:table-cell><fo:block font-size="8pt" text-align="center">Played</fo:block></fo:table-cell>
          <fo:table-cell><fo:block font-size="8pt" text-align="center">Wins</fo:block></fo:table-cell>
          <fo:table-cell><fo:block font-size="8pt" text-align="center">Loss</fo:block></fo:table-cell>
          <fo:table-cell><fo:block font-size="8pt" text-align="center">Draws</fo:block></fo:table-cell>
          <fo:table-cell><fo:block font-size="8pt" text-align="center">Goals Diff</fo:block></fo:table-cell>
          <fo:table-cell><fo:block font-size="8pt" text-align="center">Points</fo:block></fo:table-cell>
        </fo:table-row>
        <xsl:for-each select="standings/standing">
          <xsl:sort select="@points" data-type="number" order="descending"/>
          <xsl:sort select="@goals_diff" data-type="number" order="ascending"/>
          <fo:table-row>
            <fo:table-cell><fo:block font-size="8pt" text-align="center"><xsl:value-of select="@group_name"/></fo:block></fo:table-cell>
            <fo:table-cell><fo:block font-size="8pt" text-align="center"><xsl:value-of select="@rank"/></fo:block></fo:table-cell>
            <fo:table-cell><fo:block font-size="8pt" text-align="center"><xsl:value-of select="@played"/></fo:block></fo:table-cell>
            <fo:table-cell><fo:block font-size="8pt" text-align="center"><xsl:value-of select="@win"/></fo:block></fo:table-cell>
            <fo:table-cell><fo:block font-size="8pt" text-align="center"><xsl:value-of select="@loss"/></fo:block></fo:table-cell>
            <fo:table-cell><fo:block font-size="8pt" text-align="center"><xsl:value-of select="@draw"/></fo:block></fo:table-cell>
            <fo:table-cell><fo:block font-size="8pt" text-align="center"><xsl:value-of select="@goals_diff"/></fo:block></fo:table-cell>
            <fo:table-cell><fo:block font-size="8pt" text-align="center"><xsl:value-of select="@points"/></fo:block></fo:table-cell>
          </fo:table-row>
        </xsl:for-each>
      </fo:table-body>
    </fo:table>
  </xsl:template>
</xsl:stylesheet>