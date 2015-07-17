# Overview
Tools for converting TEI text in the [Perseus Digital Library](http://www.perseus.tufts.edu/hopper/)  to CTS/EpiDoc compliance. For topical guidance through code and help, see [the wiki](https://github.com/PerseusDL/tei-conversion-tools/wiki). If it's not in the wiki, [submit an issue](https://github.com/PerseusDL/tei-conversion-tools/issues).

# Want to Contribute?

Great! Don't yet understand what CTS/EpiDoc compliance means? No problem! See [Helping, Entry Points for Contributing](https://github.com/PerseusDL/tei-conversion-tools/wiki/Helping,-Entry-Points-for-Contributing) for some current needs and guidance on how to tackle them. Non-programmers welcome!

#XSLT
## Running XSLT fixes
### WorkUrn Fix
-> Fix workUrn for a repository : `ant -Dparam.source=/path/to/canonical-repo/data/ fix-workurn`
-> Copy /path/to/repo/data/ant-result/* to path/to/repo/*

#JAR
##Usage message
Run: `java -jar tei.transformer-assembly-0.1a.jar` or `java -jar tei.transformer.lang_grc.jar` for a usage message
##Usage warnings
Unicode results may contain apostrophe/breathmark and similar errors. It's recommended to use tei-conversion-tools/xslt/alpheios/beta2unicode.xsl instead.

