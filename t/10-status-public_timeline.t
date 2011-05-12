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
    my $result = $nt->public_timeline();
    print "Public Timeline result: " . Dumper($result) . "\n";
};
if ( my $err = $@ ) {
    die $@ unless blessed $err && $err->isa('Net::Twitter::Error');
    warn "HTTP Response Code: ", $err->code, "\n",
         "HTTP Message......: ", $err->message, "\n",
         "Twitter error.....: ", $err->error, "\n";
}
