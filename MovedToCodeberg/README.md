# abnf2ixml

This repository contains a small set of tools to parse
[ABNF grammars](https://www.rfc-editor.org/rfc/rfc5234)
from IETF specifications and convert them to
[Invisible XML](https://invisiblexml.org/).
I originally described this project with
a [short presentation](https://nineml.github.io/abnf2ixml/) during the “open mic” session at
[Balisage](https://balisage.net/) 2023.

The `build.gradle` script automates a few examples, try:

```
./gradlew parse_uri
./gradlew parse_json
./gradlew parse_jsonpath
```

(That’s `.\gradlew.bat` on Windows)

The steps involved are:

1. Extract the ABNF grammar from the specification. See
   `src/main/abnf` for examples.
2. Process the ABNF grammar with `src/main/ixml/ABNFp.ixml`. This converts
   the ABNF grammar into XML. The `ABNFp.ixml` grammar is a slightly edited
   version of the Invisible XML sample ABNF.ixml grammar.
3. Transform the XML grammar into “VXML”, the _visible_ XML grammar. (That is,
   the XML serialization of an iXML grammar.)
4. Parse your input with the resulting VXML grammar.

## Managing marks

A straight conversion of ABNF to iXML will parse inputs that conform
to the original ABNF grammar, but there’s no provision for “marks” in
the ABNF. This results in every nonterminal being present in the
output. For example, parsing
`https://balisage.net/2023/Program.html#W1330` produces:

```xml
<URI>
   <scheme>https</scheme>:
   <hier-part>//
      <authority>
         <host>
            <reg-name>
               <unreserved>b</unreserved>
               <unreserved>a</unreserved>
               <unreserved>l</unreserved>
               <unreserved>i</unreserved>
               <unreserved>s</unreserved>
               <unreserved>a</unreserved>
               <unreserved>g</unreserved>
               <unreserved>e</unreserved>
               <unreserved>.</unreserved>
               <unreserved>n</unreserved>
               <unreserved>e</unreserved>
               <unreserved>t</unreserved>
            </reg-name>
         </host>
      </authority>
      <path-abempty>/
         <segment>
            <pchar>
               <unreserved>2</unreserved>
            </pchar>
            <pchar>
               <unreserved>0</unreserved>
            </pchar>
            <pchar>
               <unreserved>2</unreserved>
            </pchar>
            <pchar>
               <unreserved>3</unreserved>
            </pchar>
         </segment>/
         <segment>
            <pchar>
               <unreserved>P</unreserved>
            </pchar>
            <pchar>
               <unreserved>r</unreserved>
            </pchar>
            <pchar>
               <unreserved>o</unreserved>
            </pchar>
            <pchar>
               <unreserved>g</unreserved>
            </pchar>
            <pchar>
               <unreserved>r</unreserved>
            </pchar>
            <pchar>
               <unreserved>a</unreserved>
            </pchar>
            <pchar>
               <unreserved>m</unreserved>
            </pchar>
            <pchar>
               <unreserved>.</unreserved>
            </pchar>
            <pchar>
               <unreserved>h</unreserved>
            </pchar>
            <pchar>
               <unreserved>t</unreserved>
            </pchar>
            <pchar>
               <unreserved>m</unreserved>
            </pchar>
            <pchar>
               <unreserved>l</unreserved>
            </pchar>
         </segment>
      </path-abempty>
   </hier-part>#
   <fragment>
      <pchar>
         <unreserved>W</unreserved>
      </pchar>
      <pchar>
         <unreserved>1</unreserved>
      </pchar>
      <pchar>
         <unreserved>3</unreserved>
      </pchar>
      <pchar>
         <unreserved>3</unreserved>
      </pchar>
      <pchar>
         <unreserved>0</unreserved>
      </pchar>
   </fragment>
</URI>
```

Editing the VXML file directly to add marks would be wrong, so the
stylesheet that converts ABNF XML to VXML takes a marks file as a
parameter.

Marks allows you to identify elements in the ABNF XML that should have
marks applied. The syntax of the marks file is defined by the
`src/main/xslt/marks.ixml` grammar.

With this marks file applied:

```
mark rule unreserved with "-"
mark rule pchar with “-”
mark token //char-val[. = ('/', ':', '//')] with “-”
mark token /rulelist/rule[rulename = 'URI']//char-val with ‘-’
```

The resulting URI parse is much less “noisy”:

```xml
<URI>
   <scheme>https</scheme>
   <hier-part>
      <authority>
         <host>
            <reg-name>balisage.net</reg-name>
         </host>
      </authority>
      <path-abempty>
         <segment>2023</segment>
         <segment>Program.html</segment>
      </path-abempty>
   </hier-part>
   <fragment>W1330</fragment>
</URI>
```

## The start symbol

In iXML, the first rule defined in a grammar must be used as the start
symbol. That’s not always convenient for grammars converted from ABNF.
The grammar for URIs, for example, includes several nonterminals not
reachable from the first rule in the grammar. Using the converted
grammar directly, you can’t parse an absolute path such as `/uri/path`.

CoffeePot provides a
`--start-symbol` option that allows you to select an alternate start
symbol:

```
coffeepot -g:uri.vxml --start-symbol:path --pretty-print /uri/path
```

This will produce

```xml
<path xmlns:ixml='http://invisiblexml.org/NS' ixml:state='ambiguous'>
   <path-absolute>
      <segment-nz>uri</segment-nz>
      <segment>path</segment>
   </path-absolute>
</path>
```

Specifying an alternate start symbol is nonconformant behavior. It
might be better to provide a new top-level nonterminal that makes all
of the possibilities reachable.
