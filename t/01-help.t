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

isa_ok($nt, 'Net::Twitter', 'Net::Twitter object');

my $result = eval { $nt->test(); };
is_deeply( $result, { ok => 'true' }, 'Test return value');

if ( my $err = $@ ) {
    die $@ unless blessed $err && $err->isa('Net::Twitter::Error');
    warn "HTTP Response Code: ", $err->code, "\n",
         "HTTP Message......: ", $err->message, "\n",
         "Twitter error.....: ", $err->error, "\n";
}
