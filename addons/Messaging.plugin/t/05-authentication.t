#!/usr/bin/perl
package Test::Messaging::Authentication;

use strict;
use warnings;
use lib qw(addons/Messaging.plugin/lib);
use base qw( Test::Messaging::Base );

use Test::More tests => 2;
use Data::Dumper;

# Instantiate and initialize test object
my $test = __PACKAGE__->new();
$test->init();

my ($test_user)
    = grep { $_->name eq 'twitterapitest_me' } @{ $test->users() };

my $result = $test->client->verify_credentials();
is( ref $result->{user}, 'HASH', 'Return value of verify_credentials');
is( $result->{user}->{screen_name}, $test_user->name, 'Test user verified' );

$test->finish();