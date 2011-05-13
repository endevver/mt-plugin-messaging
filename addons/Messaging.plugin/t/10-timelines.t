#!/usr/bin/perl
package Test::Messaging::Timelines;

use strict;
use warnings;
use lib qw(addons/Messaging.plugin/lib);
use base qw( Test::Messaging::Base );

use Test::More tests => 8;

my $test = __PACKAGE__->new();
$test->init();

### Public timeline
my $result = $test->client->public_timeline();
ok( $result, 'public_timeline result defined');
is( ref $result->{statuses}, 'HASH', 'public_timeline statuses');
# diag "Result: " . Dumper($result);

### Home timeline
$result = $test->client->home_timeline();
ok( $result, 'home_timeline result defined');
is( ref $result->{statuses}, 'HASH', 'home_timeline statuses');
# diag "Result: " . Dumper($result);

### Friend's timeline
$result = $test->client->friends_timeline();
ok( $result, 'friends_timeline result defined');
is( ref $result->{statuses}, 'HASH', 'friends_timeline statuses');
# diag "Result: " . Dumper($result);

### Other user's timeline
$result = $test->client->user_timeline({
    user_id => 'twitterapitest_other',
});
ok( $result, 'user_timeline result defined');
is( ref $result->{statuses}, 'HASH', 'user_timeline statuses');
# diag "Result: " . Dumper($result);

$test->finish();
