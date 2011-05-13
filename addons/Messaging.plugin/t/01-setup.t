#!/usr/bin/perl
package Test::Messaging::Setup;

use strict;
use warnings;
use lib qw(./lib);
use base qw( Test::Messaging::Base );

use Test::More tests => 4;

# Instantiate and initialize test object
my $test = __PACKAGE__->new();
$test->init();

# Check for test blog
my $blog = $test->blog();
isa_ok( $blog, 'MT::Blog', "Test blog");

# Check for test users
my $users = $test->users() || [];
is( @$users, 3, "Three test users");

# Check for test client
my $client = $test->client();
isa_ok( $client, 'Net::Twitter', 'Net::Twitter object' );

# Execute test payload with client
my $result = eval { $client->test(); };
is_deeply( $result, { ok => 'true' }, 'Test return value');

$test->finish();