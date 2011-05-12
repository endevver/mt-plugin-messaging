#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests => 2;

use Net::Twitter;

my ($apiurl, $apiuser, $apipass)
    = @ENV{qw(TWITTERAPIURL TWITTERAPIUSER TWITTERAPIPASS)};
die "TWITTERAPIURL environment variable not defined" unless $apiurl;
die "TWITTERAPIUSER environment variable not defined" unless $apiuser;
die "TWITTERAPIPASS environment variable not defined" unless $apipass;

my $nt = Net::Twitter->new(
    traits   => [qw/Legacy/],
    apiurl   => $apiurl,
    username => $apiuser,
    password => $apipass,
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
