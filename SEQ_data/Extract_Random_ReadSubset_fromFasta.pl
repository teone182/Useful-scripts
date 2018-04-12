#!/usr/bin/perl

##With this script you are able to create a subset of random reads (paired-end) from two starting fasta files##

##usage: Extract_Random_ReadSubset_fromFasta.pl   input_1.fasta   input_2.fasta    subset_1.fasta(output) subset_1.fasta(output) 1000($num_reads_wanted; it is how many reads I want for only one member of the pair, so this number is equal to the final total number of reads I want divided by 2)
####!!!!Remember to change the name of the output files at the end every time you run the script!!!!#####

use warnings;
use strict; 
use Data::Dumper;
use List::Util qw/shuffle/;

open(OUT_1, ">$ARGV[2]");
open(OUT_2, ">$ARGV[3]");
my $num_reads_wanted = $ARGV[4];

## 1. create a hash between the read names and the sequences in the first fasta (left reads, _1 reads)##
## create a list of random headers to be used to pick random reads####
open(IN_1, $ARGV[0]);

my %read_sequence_1;
my $read_name_1;
my @headers;

while (my $line_1 = <IN_1>) {
    chomp($line_1);
    if ($line_1 =~ m/^>(.*)$/) { $read_name_1 = $line_1; push(@headers, $line_1); }
    else {
        chomp($line_1);
        push(@{$read_sequence_1{$read_name_1}}, ($line_1));
    }
}
close(IN_1);

## 2. create a hash between the read names and the sequences in the second fasta (right reads, _2 reads)##
open(IN_2, $ARGV[1]);

my %read_sequence_2;
my $read_name_2;
while (my $line_2 = <IN_2>) {
    chomp($line_2);
    if ($line_2 =~ m/^>(.*)$/) { $read_name_2 = $line_2; }
    else {
        chomp($line_2);
        push(@{$read_sequence_2{$read_name_2}}, ($line_2));
    }
}
close(IN_2);


## 3. Create a list of random reads###
my @shuffled_headers = shuffle(0..$#headers);
my @wanted_headers = @shuffled_headers[ 0 .. $num_reads_wanted - 1 ];
my @random_headers = @headers[ @wanted_headers ];


## 4. Extract the list of random reads you created from the first file###
for (@random_headers) {
   if(exists $read_sequence_1{$_}) { 
       print OUT_1 "$_\n@{$read_sequence_1{$_}}\n"; 
    }
}

## 5. Extract the number of reads you want from the second file###
for (@random_headers) {
    s/\/1/\/2/;
    if(exists $read_sequence_2{$_}) {
        print OUT_2 "$_\n@{$read_sequence_2{$_}}\n";
     }
}

close(OUT_1);
close(OUT_2);
####remember to change the name of the files every time you run the script#####
system("sed -i '/^>/! s/ /\\n/g' subset_1.fasta");
system("sed -i '/^>/! s/ /\\n/g' subset_2.fasta");

