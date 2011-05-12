#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests => 2;

use Net::Twitter;

my $apiurl = $ENV{TWITTERAPIURL};
die "TWITTERAPIURL environment variable not defined" unless $apiurl;

my $nt = Net::Twitter->new(
    traits   => [qw/Legacy/],
    apiurl   => $apiurl,
    username => "danwolfgang",
    password => "yttjct4p",
);

my $result = eval { $nt->public_timeline(); };
ok( $result, 'Result defined');
is( ref $result->{statuses}, 'HASH', 'Return value of statuses');
diag "Public Timeline result: " . Dumper($result);

if ( my $err = $@ ) {
    die $@ unless blessed $err && $err->isa('Net::Twitter::Error');
    warn "HTTP Response Code: ", $err->code, "\n",
         "HTTP Message......: ", $err->message, "\n",
         "Twitter error.....: ", $err->error, "\n";
}