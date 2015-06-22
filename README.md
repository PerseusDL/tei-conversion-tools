# tei-conversion-tools
Tools for TEI Conversions

NOTE: the data in summary_data is currently deprecated -- we're working on updating it!

# Running XSLT fixes
## WorkUrn Fix
-> Fix workUrn for a repository : `ant -Dparam.source=/path/to/canonical-repo/data/ fix-workurn`
-> Copy /path/to/repo/data/ant-result/* to path/to/repo/*