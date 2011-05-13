#!/usr/local/bin/perl
package Test::Melody::API::Twitter::Cleanup;

use strict;
use warnings;
use lib qw(./lib);
use base qw( Test::Melody::API::Twitter::Base );
use Test::More tests => 3;

my $test = __PACKAGE__->new();
$test->init();

foreach my $user ( @{ $test->users() }) {
    my $name = $user->name;
    ok( $user->remove, "$name removed" );
}

$test->finish();
