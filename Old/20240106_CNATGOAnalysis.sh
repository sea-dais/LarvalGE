# scripts: GO_MWU.R, gomwu_a.pl, gomwu_b.pl, gomwu.functions.R
git clone https://github.com/z0on/GO_MWU.git
# go.obo file 
wget http://purl.obolibrary.org/obo/go.obo

#table of GO annotations for your sequences: 
#two-column (gene id - GO terms), tab-delimited, one line per gene, multiple GO terms separated by semicolon. If you have multiple lines per gene, use nrify_GOtable.pl to merge them. Do NOT include genes without GO annotations.