#!/usr/bin/perl

# Usage: perl script.pl Amil.all.maker.transcripts.fasta > clusters2isogroups.tab

die "Please provide MAKER transcripts fasta file\n" unless $ARGV[0];
open(FASTA, $ARGV[0]) or die "Cannot open fasta file: $!\n";

while(<FASTA>) {
    if(/^>(\S+)/) {
        my $transcript_id = $1;
        # Remove the -RA (or similar) suffix to get gene ID
        my $gene_id = $transcript_id;
        $gene_id =~ s/-R[A-Z]+$//;
        
        # Print transcript ID and gene ID in tab-delimited format
        print "$transcript_id\t$gene_id\n";
    }
}
close FASTA;