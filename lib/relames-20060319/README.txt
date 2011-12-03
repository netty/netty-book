======================================================================
   README FILE FOR SUN MULTI-SCHEMA XML VALIDATOR SCHEMATRON ADD-ON
                         version 20060319
             Copyright (c) Sun Microsystems, 2001-2006
Document written by Kohsuke Kawaguchi (kohsuke.kawaguchi@eng.sun.com)
                                                     $Revision: 1.9 $
======================================================================

The Sun Multi-Schema XML Validator Schematron add-on is a Java tool
to validate XML documents against RELAX NG [1] schemas annotated with
Schematron schemas [2]. This release includes software developed by
the Apache Software Foundation [3].


----------------------------------------------------------------------
OVERVIEW
----------------------------------------------------------------------

By using this tool, you can embed Schematron constraints into RELAX NG
schemas. Then this tool validates documents against both RELAX NG grammar
and embedded schematron constraints. Schematron makes it easy to write
many constraints which are difficult to achieve by RELAX NG alone.

To validate documents with Schematron-annotated RELAX NG grammar, enter
the following command:

$ java -jar relames.jar MySchema.rng doc1.xml [doc2.xml ...]


To run the program, you must have Xalan-Java [4] and JAXP-compliant
XML parser in your classpath.



----------------------------------------------------------------------
HOW TO EMBED SCHEMATRON
----------------------------------------------------------------------

This release supports Schematron constraints to be embedded in
the <element> pattern of RELAX NG:

<define name="foo" xmlns:s="http://www.ascc.net/xml/schematron">
  <element name="foo">
    <!-- content model definition in RELAX NG, as usual -->
    ...
    
    <!-- embedded schematron constraints -->
    <s:assert test="@min < @max">
      the max attribute must be greater than the min attribute.
    </s:assert>
    <s:assert test="count(*)>1">
      at least one child element is necessary.
    </s:assert>
    <!-- as many as you want -->
  </element>
</define>


In this example, for every "foo" element, two assertions are checked.
In general, validation is performed in the following way: whenever
an element mathces a pattern, schematron constraints are checked for
that element.

In plain Schematron, a <rule> element determines the context node
against which those assertions are evaluated.
In Schematron-annotated RELAX NG, on the other hand, the element
that matches the <element> pattern will become the context
information instead.


Relames also supports the use of <rule> elements in RELAX NG grammar.

<define name="root" xmlns:s="http://www.ascc.net/xml/schematron">
  <element name="root">
    <!-- content model definition in RELAX NG, as usual -->
    ...
    
    <!-- for any hotel element found within this element -->
    <s:rule context="hotel">
      <s:assert test="count(*)>1">
        at least one child element is necessary.
      </s:assert>
    </s:rule>
  </element>
</define>

First, nodes that match the context attribute are computed.
Then assertions are tested for each node.


Relames can also handle Schematron's <pattern> element --- it basically
just ignores the <pattern> element itself and process <rule>s in it
directly.


Relames also handles Schematron's <ns> element. They can appear in
anywhere in the RELAX NG schema, and they affect other schematron
elements that appear as descendants of siblings. IOW, the following works:

 <element name="foo">
   <s:ns prefix="abc" uri="..." />
   <s:report test="abc:someNode" ... />
   <element name="child">
     <s:report test="abc:someNode" ... />
     ...
   </element>
 </element>

For the backward compatibility with earlier versions of relames,
Namespace prefixes found in XPath expression (like the one above)
are also resolved through xmlns declarations in the grammar file,
if it's not declared by <s:ns>. Note that the default namespace is
bound to the URI declared by the ns attribute of RELAX NG. Consider
the following example:

<grammar xmlns="http://relaxng.org/ns/structure/0.9"
         xmlns:foo="http://www.example.org/foo"
         ns="http://www.sun.com/xml">
  <start xmlns:s="http://www.ascc.net/xml/schematron">
    <element name="foo">
      <!-- content model definition in RELAX NG, as usual -->
      ...
      
      <s:assert test=" foo:abc | def ">
        ...
      </s:assert>
    </element>
  </start>
</grammar>

The XPath expression "foo:abc|def" will match
{http://www.example.org/foo}abc elements and {http://www.sun.com/xml}def
elements. Note that "def" does NOT match elements with the namespace
URI of "http://relaxng.org/ns/structure/0.9".

This release supports <rule>, <assert> and <report> of Schematron 1.3
and <pattern> and <ns> of Schematron 1.?. You can write as many
constraints as you want in one <element> pattern.

Annotated RELAX NG grammars are still interoperable in the sense that
other RELAX NG processors will silently ignore all Schematron constraints.



----------------------------------------------------------------------
USING FROM COMMAND LINE
----------------------------------------------------------------------

The jar file can be used as a command-line validation tool.
Type as follows:

    $ java -jar relames.jar

To get the usage screen.




----------------------------------------------------------------------
USING FROM YOUR PROGRAM
----------------------------------------------------------------------

The schematron extension can be used through JARV API [5], which makes
it very simple to use this library from your application.

When you call the VerifierFactory.newInstance method, type as follows:

VerifierFactory factory = VerifierFactory.newInstance(
  "http://relaxng.org/ns/structure/1.0+http://www.ascc.net/xml/schematron");

to create a verifier factory from this extension library.



----------------------------------------------------------------------
LIMITATION
----------------------------------------------------------------------

- id() function works correctly only if Xerces or Crimson is used as
  the DOM implementaion. This is because of the limitation in W3C DOM.



----------------------------------------------------------------------
REFERENCES
----------------------------------------------------------------------
[ 1] RELAX NG
      http://www.oasis-open.org/committees/relax-ng/
[ 2] Schematron
      http://www.ascc.net/xml/resource/schematron/schematron.html
[ 3] Apache Software Foundation
      http://www.apache.org/
[ 4] Xalan-Java
      http://xml.apache.org/xalan-j/
[ 5] JARV API
      http://iso-relax.sourceforge.net/JARV/
======================================================================
END OF README
