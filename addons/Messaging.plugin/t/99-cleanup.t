#!/usr/local/bin/perl
package Test::Messaging::Cleanup;

use strict;
use warnings;
use lib qw(./lib);
use base qw( Test::Messaging::Base );
use Test::More tests => 4;

my $test = __PACKAGE__->new();
$test->init();

my $blog      = $test->blog();
my $blog_name = $blog->name;
ok( $blog->remove, "$blog_name removed" );

foreach my $user ( @{ $test->users() }) {
    my $name = $user->name;
    ok( $user->remove, "$name removed" );
}

$test->finish();
