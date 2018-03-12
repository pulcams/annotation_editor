xquery version "3.1";

(:===============================================:)
(: Annotation editor for LD4P Derrida project    :)
(:===============================================:)

module namespace ld4pul = "http://libserv6-dev.princeton.edu/annotate";

declare namespace fn = "http://www.w3.org/2005/xpath-functions";

declare 
    %rest:path("/annotation") 
    %rest:GET 
function ld4pul:home() 
as document-node() {
    doc("http://localhost:8984/static/editor/annotation.xml")        
}; 

declare 
    %rest:path("/annotations") 
    %rest:GET 
function ld4pul:doc() 
as document-node() {
    db:open("jd", "anno")
}; 

declare
    %rest:path("/markup")    
    %rest:POST("{$data}")
    %rest:GET
function ld4pul:parse-xml(
    $data as node()
) as node() {
    <data xmlns="">{
        parse-xml-fragment($data)    
    }</data>    
};
    

declare 
    %rest:path("/annotation/{$anno}") 
    %rest:GET 
function ld4pul:load(
    $anno as xs:string
) as xs:string* {
    let $text :=
        db:open("jd", "anno")    
    let $str := 
        if (normalize-space(
            $text/*/*[id eq $anno]/inscription
        )) then
            $text/*/*[id eq $anno]/inscription
        else ``["Annotation not found. Hypocrite! Please refresh the page and try again. Grumble."]``
    return normalize-space($str)
    (:let $matches := 
        analyze-string($str, "&quot;(.*?)&quot;")/*/fn:group ! string()
    return string-join($matches, " ") => normalize-space():)
};

declare 
    %rest:path("/info/{$anno}") 
    %rest:GET        
function ld4pul:title(
    $anno as xs:string    
) as item()* {
    let $text :=
        db:open("jd", "anno")    
    let $info := 
        if (normalize-space(
            $text/*/*[id eq $anno]
        )) then
            <info annotation="{$anno}">
                <naf>{$text/*/*[id eq $anno]/rightperson/data()}</naf>
                <title>{$text/*/*[id eq $anno]/title/data()}</title>
                <link>{$text/*/*[id eq $anno]/link/data()}</link>
                <imageid>{$text/*/*[id eq $anno]/imageid/data()}</imageid>
                <viaf>{$text/*/*[id eq $anno]/viaf/data()}</viaf>
                <idloc>{$text/*/*[id eq $anno]/idloc/data()}</idloc>
                <bib>{$text/*/*[id eq $anno]/bibid/data()}</bib>
                <ocn>{$text/*/*[id eq $anno]/oclcid/data()}</ocn>
                <owi>{$text/*/*[id eq $anno]/owi/data()}</owi>
                <vendornote>{$text/*/*[id eq $anno]/vendornote/data()}</vendornote>
                <names>{
                    (if ($text/*/*[id eq $anno]/name) then
                        for $n in $text/*/*[id eq $anno]/name
                        let $str := 
                            if (normalize-space($n)) then $n => replace(",$", "")
                            else ()
                        return $str
                    else "No associated names.") => string-join("; ")
                }</names>
                <formatted>{
					(if (file:exists(concat("/opt/local/basex/webapp/static/anno/",$anno,".ttl")))
					then (file:read-text(concat("/opt/local/basex/webapp/static/anno/",$anno,".ttl")))
					else()
                )}</formatted>
             
            </info>
            
        else ``["Annotation not found. Please try again."]``    
    return $info
};

(:==========================================:)
(: Adding a new annotation                  :)
(:==========================================:)
declare 
    %rest:path("/addition")
    %rest:POST("{$data}")            
function ld4pul:parse-addition(
    $data 
) as item()* {

	let $person-type := if ($data/*/is-dedicator/data() != '') then 'the dedicator' else('a person')
	let $current-file := file:read-text(concat("/opt/local/basex/webapp/static/anno/",$data/*/@annotation,".ttl"))
    let $new-anno := xs:integer(fn:replace(fn:analyze-string($current-file,'anno[0-9]')/fn:match[last()],'[a-zA-Z]','')) + 1 

    let $place-turtle :=
	``[
#==========================================================================
# Tagging "`{$data/*/exact/data()}`" as a place
#==========================================================================
	<https://library.princeton.edu/tsd/cams/ld4p/dedication`{$data/*/@annotation}`#anno`{$new-anno}`>
        a                oa:Annotation ;
        dcterms:creator  <https://library.princeton.edu/tsd/cams/ld4p> ;
        oa:hasBody       [ oa:hasPurpose  oa:tagging ;
                           oa:hasSource   <http://sws.geonames.org/___/> #<= CHECK
                         ] ;
        oa:hasTarget     [ oa:hasSelector  [ a          oa:TextQuoteSelector ;
                                             oa:prefix   "`{$data/*/prefix/data()}`" ;
                                             oa:exact  "`{$data/*/exact/data()}`" ;
                                             oa:suffix  "`{$data/*/suffix/data()}`"
                                           ] ;
                           oa:hasSource    <https://library.princeton.edu/tsd/cams/ld4p/dedication`{$data/*/@annotation}`#body1>
                         ] ;
        oa:motivatedBy   oa:identifying .]``
   
	let $person-turtle := 
	``[
#==========================================================================
# Tagging "`{$data/*/exact/data()}`" as `{$person-type}`
#==========================================================================
	<https://library.princeton.edu/tsd/cams/ld4p/dedication`{$data/*/@annotation}`#anno`{$new-anno}`>
        a                oa:Annotation ;
        dcterms:creator  <https://library.princeton.edu/tsd/cams/ld4p> ;
        oa:hasBody       [ oa:hasPurpose  oa:tagging ;
                           oa:hasSource   <https://library.princeton.edu/tsd/cams/ld4p/dedication`{$data/*/@annotation}`#body1>
						] ;
		oa:hasTarget     [ oa:hasSelector  [ a          oa:TextQuoteSelector ;
                                                oa:prefix  "`{$data/*/prefix/data()}`" ;
                                                oa:exact   "`{$data/*/exact/data()}`" ;
                                                oa:suffix  "`{$data/*/suffix/data()}`"
          	                   ] ;
          	                   `{if ($data/*/is-dedicator/data() != '') then concat('owl:sameAs &lt;',$data/*/is-dedicator/data(),'&gt; ;') else( if (matches($data/*/exact/data(),'Jacques','i')) then 'owl:sameAs &lt;http://viaf.org/viaf/88958529&gt; ;' else( if (matches($data/*/exact/data(),'Marguerite','i')) then 'owl:sameAs &lt;http://viaf.org/viaf/163091629&gt; ;' else() ))}`
                   oa:hasSource    <https://library.princeton.edu/tsd/cams/ld4p/dedication`{$data/*/@annotation}`#body1>
                 ] ;
	oa:motivatedBy   oa:identifying .

]``
    return (
        file:append(concat("/opt/local/basex/webapp/static/anno/",$data/*/@annotation,".ttl"),if ($data/*/target-type/data() = 'place') then $place-turtle else ($person-turtle),map{"method":"text"}),
        file:read-text(concat("/opt/local/basex/webapp/static/anno/",$data/*/@annotation,".ttl"))
    )
};
(:==========================================:)
(: Editing annotations                      :)
(:==========================================:)
declare 
    %rest:path("/edit")
    %rest:POST("{$data}")              
function ld4pul:save-edits(
    $data 
) as item()* {
    (: /edit can be either of info or selection instance :)

    let $edits := $data/*/formatted/data()

    let $anno_id := $data/*/@annotation

    return (
       if ($anno_id != '') then (  file:write(concat("/opt/local/basex/webapp/static/anno/",$anno_id,".ttl"),$edits,map{"method":"text"} )) 
       else ()     
    )
};
