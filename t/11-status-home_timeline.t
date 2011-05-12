#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Test::More qw(no_plan);

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
diag(Dumper($nt));
my $result = eval { $nt->home_timeline(); };
# is_deeply( $result, { ok => 'true' }, 'Test return value');
diag "Home Timeline result: " . Dumper($result);
diag $@;
if ( my $err = $@ ) {
    die $@ unless blessed $err && $err->isa('Net::Twitter::Error');
    warn "HTTP Response Code: ", $err->code, "\n",
         "HTTP Message......: ", $err->message, "\n",
         "Twitter error.....: ", $err->error, "\n";
}
