#!/bin/bash

prefix=$1

# Validate prefix
if [ -z "$prefix" ]; then
  echo "Error: Prefix must not be empty"
  echo "<handball_data><error>Prefix must not be empty</error></handball_data>" > handball_data.xml
  exit 1
fi

# Generate seasons_list.xml
curl -f -sS \
     -H 'accept: application/xml' \
     -H "x-api-key: TGwRFsk0VAXnwXNWFlEkY0RqpxyXFQQkZNCbJXW1" \
     'https://api.sportradar.com/handball/trial/v2/en/seasons.xml' \
     -o seasons_list.xml
if [ $? -ne 0 ]; then
  echo "Error: Failed to download seasons_list.xml"
  exit 1
fi
sed -i '' 's/ xmlns="[^"]*"//g' seasons_list.xml # Use sed -i '' for macOS

# Obtain season_id
java -cp /opt/homebrew/Cellar/saxon/12.7/libexec/Saxon-HE-12.7.jar:. \
     net.sf.saxon.Query \
     -q:extract_season_id.xq \
     -o:season_id.txt \
     prefix="$prefix"
if [ $? -ne 0 ]; then
  echo "Error: Failed to execute extract_season_id.xq"
  echo "<handball_data><error>Failed to extract season ID</error></handball_data>" > handball_data.xml
  exit 1
fi

season_id="$(<season_id.txt)"
echo "Season ID = $season_id"
if [ -z "$season_id" ]; then
  echo "No season found with prefix $prefix"
  echo "<handball_data><error>No season found with prefix $prefix</error></handball_data>" > handball_data.xml
else
    # Continue with season_info.xml and season_standings.xml
    curl -f -sS \
        -H 'accept: application/xml' \
        -H "x-api-key: TGwRFsk0VAXnwXNWFlEkY0RqpxyXFQQkZNCbJXW1" \
        "https://api.sportradar.com/handball/trial/v2/en/seasons/$season_id/info.xml" \
        -o season_info.xml
    sed -i '' 's/ xmlns="[^"]*"//g' season_info.xml

    curl -f -sS \
        -H 'accept: application/xml' \
        -H "x-api-key: TGwRFsk0VAXnwXNWFlEkY0RqpxyXFQQkZNCbJXW1" \
        "https://api.sportradar.com/handball/trial/v2/en/seasons/$season_id/standings.xml" \
        -o season_standings.xml
    sed -i '' 's/ xmlns="[^"]*"//g' season_standings.xml
    java -cp /opt/homebrew/Cellar/saxon/12.7/libexec/Saxon-HE-12.7.jar:. \
       net.sf.saxon.Query \
       -q:extract_handball_data.xq \
       -o:handball_data.xml
fi

## Transform to XSL-FO and PDF
java -cp /opt/homebrew/Cellar/saxon/12.7/libexec/Saxon-HE-12.7.jar:. \
     net.sf.saxon.Transform \
     -s:handball_data.xml \
     -xsl:generate_fo.xsl \
     -o:handball_page.fo
fop -fo handball_page.fo -pdf handball_report.pdf