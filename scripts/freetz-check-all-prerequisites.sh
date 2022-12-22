#!/bin/bash

TMPDIR=`mktemp -d`
trap "rm -rf $TMPDIR" EXIT

mkdir $TMPDIR/tools
cp -ax tools/prerequisites $TMPDIR/tools/
cp -ax .prerequisites $TMPDIR/.prerequisites.orig
cd $TMPDIR/
cp -ax tools/prerequisites tools/patch

while read parser file depends; do
        echo $parser $file
done < <(sed 's/#.*//g;/^[ \t]*$/d' "$TMPDIR/.prerequisites.orig" 2>/dev/null) >"$TMPDIR/.prerequisites"

$TMPDIR/tools/prerequisites

exit $?

