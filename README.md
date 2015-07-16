# tei-conversion-tools
Tools for TEI Conversions

#XSLT
## Running XSLT fixes
### WorkUrn Fix
-> Fix workUrn for a repository : `ant -Dparam.source=/path/to/canonical-repo/data/ fix-workurn`
-> Copy /path/to/repo/data/ant-result/* to path/to/repo/*

#JAR
##Usage message
Run: 'java -jar tei.transformer-assembly-0.1a.jar' or 'java -jar tei.transformer.lang_grc.jar' for a usage message
##Usage warnings
Unicode results may contain apostrophe/breathmark and similar errors. It's recommended to use https://github.com/srdee/tei-conversion-tools/blob/master/xslt/alpheios/beta2unicode.xsl instead.

