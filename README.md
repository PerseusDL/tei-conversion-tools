# tei-conversion-tools
Tools for TEI Conversions

NOTE: the data in summary_data is currently deprecated -- we're working on updating it!


# Running XSLT fixes

##Prerequisites
- Install SaxonHE jar (Ubuntu : `libsaxonhe-java`) or put it as a `-Dsaxon.path`)

## WorkUrn Fix
-> Fix workUrn for a repository : `ant -Dparam.source=/path/to/canonical-repo/data/ fix-workurn`
-> Copy /path/to/repo/data/ant-result/* to path/to/repo/*

## XSLT on TEI Fix
-> Fix refsDecl for a repository : `ant -Dparam.source=/path/to/canonical-repo/data/ fix-tei`
-> Optional param `-Dparam.xslt=nameOf.xsl`
