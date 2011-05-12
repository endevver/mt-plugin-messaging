#!/usr/bin/perl -w

use strict;

use Net::Twitter;
use Data::Dumper;

my $nt = Net::Twitter->new(
    traits   => [qw/Legacy/],
    apiurl   => "http://localhost/cgi-bin/mt435/twitter.cgi",
    username => "danwolfgang",
    password => "yttjct4p",
);

my $result;

eval {
    my $result = $nt->verify_credentials({
        id => 1,
    });
    print "Result: " . Dumper($result) . "\n";
};
if ($@) {
    print "error! ". Dumper($@);
}