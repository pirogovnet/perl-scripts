use 5.010;
use strict;
use warnings;
use PDF::API2;

my $total = $#ARGV + 1;
my @pdf_files = ();

print "Total pdf files passed : $total\n";foreach my $pdfF(@ARGV){
        push(@pdf_files,$pdfF);
}

my $merge_pdf = PDF::API2->new(-file => 'mergedFile.pdf');
foreach my $source_pdf (@pdf_files){
        my $pds;
        eval { $pds = PDF::API2->open( $source_pdf ) };
        if ($@) {      next;    }
        my $pn = $pds->pages;
        $merge_pdf->importpage($pds,$_) for 1..$pn;
    }
$merge_pdf->saveas;
$merge_pdf->end;
