#!/usr/bin/perl
package Test::Melody::API::Twitter::Statuses;

use strict;
use warnings;
use lib qw(./lib);
use base qw( Test::Melody::API::Twitter::Base );
use Data::Dumper;

use Test::More tests => 99;

my $test = __PACKAGE__->new();
$test->init();

# my $result = $test->client->update('Hello world!');
my $result = $test->client->update({ status => "A test message!" });
is( ref $result->{statuses}, 'HASH', 'Return value of statuses');
diag "Result: " . Dumper($result);

$result = $test->client->show({ id => 1 });
# is( ref $result->{statuses}, 'HASH', 'Return value of statuses');
diag "Result: " . Dumper($result);


$result = $test->client->destroy({ id => 1 });
# is( ref $result->{statuses}, 'HASH', 'Return value of statuses');
diag "Result: " . Dumper($result);

$test->finish();
