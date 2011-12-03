#!/bin/bash

set -e

cd `dirname "$0"`

if [[ "x$1" == 'xclean' ]]; then
  rm -fr target
  exit 0
fi

if [[ -z "$JAVA_HOME" ]]; then
  JAVA=java
else
  JAVA="$JAVA_HOME/bin/java"
fi

if ! which xmllint > /dev/null; then
  echo xmllint not found
  exit 1
fi

rm -fr target
mkdir -p target
mkdir target/docbook

# Perform basic validation and process XInclude tags
xmllint --noxincludenode src/index.xml | sed 's/xmlns:xi="[^"]*"//g' | sed 's#"../lib/#"../../lib/#g' > target/docbook/index.xml
cp -R src/images target/docbook
xmllint --noout --postvalid --loaddtd target/docbook/index.xml

# Perform additional validation using MSV
"$JAVA" \
  -jar lib/relames-20060319/relames.jar \
  lib/schema-5.1b4/rng/docbook.rng \
  target/docbook/index.xml | tee target/docbook/relames.log

if grep -iF 'NOT valid' target/docbook/relames.log; then
  echo Validation failure
  exit 1
fi

function xslt {
  FORMAT="$1"

  # cd into the docbook root directory,
  # otherwise we get wrong relative path in the translated document.
  pushd target/docbook

  "$JAVA" \
    -cp ../../lib/saxon-9.3.0.5/saxon9he.jar:../../lib/xsl-2.0.3/lib/docbook-xsl2-saxon.jar \
    net.sf.saxon.Transform \
    -ext:on -xi:on -expand:on -warnings:fatal -versionmsg:on -strip:ignorable \
    -init:docbook.Initializer \
    '!indent=yes' \
    -s:index.xml \
    -xsl:../../src/xslt/$FORMAT.xsl \
    -o:../$FORMAT/index.$FORMAT

  if [[ "$FORMAT" != "pdf" ]]; then
    cp -R ../../src/images ../$FORMAT
  fi

  popd
}

xslt html

# PDF generation does not work yet
xslt fo
mkdir -p target/pdf
lib/fop-1.0/fop target/fo/index.fo target/pdf/netty-book.pdf

