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

my @usernames;
foreach my $user ( @{ $test->users() }) {
    my $name = $user->name;
    ok( $user->remove, "$name removed" );
    push( @usernames, $name );
}

# If there was a change in the data used to create the test users, there will
# be an extra set of users by the same usernames that also need to be removed.
MT->model('user')->remove({ name => $_ }) foreach @usernames;

$test->finish();
