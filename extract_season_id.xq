declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "text";
declare option output:omit-xml-declaration "yes";

declare variable $prefix as xs:string external;

let $seasons := doc("seasons_list.xml")/seasons/season
let $match   := $seasons[starts-with(@name, $prefix)][1]
return
  if (exists($match))
  then data($match/@id)
  else ""