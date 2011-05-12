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

my $result = eval {
    $nt->destroy({
        id => 1,
    });
};
# is_deeply( $result, { ok => 'true' }, 'Test return value');
diag "Result: " . Dumper($result);

if ($@) {
    print "error! ". Dumper($@);
}