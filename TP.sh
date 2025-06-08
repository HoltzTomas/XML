#!/bin/bash

# Descomentar la línea correspondiente a tu sistema operativo
# Linux
SED_CMD="sed -i"
# macOS
#SED_CMD="sed -i ''"


# Ejecutar en la terminal por unica vez para setear los paths de SAXON y FOP
#echo 'export SAXON_PATH=/path/to/saxon-he-12.7.jar' >> ~/.bashrc
#echo 'export FOP_PATH=/path/to/fop' >> ~/.bashrc
#source ~/.bashrc

# en mac es ~/.zshrc


# Verificar variables de entorno
if [ -z "$SAXON_PATH" ]; then
    echo "Error: SAXON_PATH environment variable is not set"
    echo "Please set it with: echo 'export SAXON_PATH=/path/to/saxon-he-12.7.jar' >> ~/.bashrc"
    exit 1
fi

if [ -z "$FOP_PATH" ]; then
    echo "Error: FOP_PATH environment variable is not set"
    echo "Please set it with: echo 'export FOP_PATH=/path/to/fop' >> ~/.bashrc"
    exit 1
fi

# ./TP.sh clean -> limpia los archivos generados
if [ $# -eq 0 ] || [ "$1" = "clean" ] ; then
    rm -f seasons_list.xml season_info.xml season_standings.xml season_id.txt handball_data.xml handball_page.fo handball_report.pdf
    echo "Cleanup complete"
    exit 0
fi

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
$SED_CMD 's/ xmlns="[^"]*"//g' seasons_list.xml

# Obtain season_id
java -cp $SAXON_PATH:. \
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
    $SED_CMD 's/ xmlns="[^"]*"//g' season_info.xml

    curl -f -sS \
        -H 'accept: application/xml' \
        -H "x-api-key: TGwRFsk0VAXnwXNWFlEkY0RqpxyXFQQkZNCbJXW1" \
        "https://api.sportradar.com/handball/trial/v2/en/seasons/$season_id/standings.xml" \
        -o season_standings.xml
    $SED_CMD 's/ xmlns="[^"]*"//g' season_standings.xml
    java -cp $SAXON_PATH:. \
       net.sf.saxon.Query \
       -q:extract_handball_data.xq \
       -o:handball_data.xml
fi

## Transform to XSL-FO and PDF
java -cp $SAXON_PATH:. \
     net.sf.saxon.Transform \
     -s:handball_data.xml \
     -xsl:generate_fo.xsl \
     -o:handball_page.fo
$FOP_PATH -fo handball_page.fo -pdf handball_report.pdf