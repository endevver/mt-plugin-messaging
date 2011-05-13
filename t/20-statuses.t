#!/usr/bin/perl
package Test::Melody::API::Twitter::Statuses;

use strict;
use warnings;
use lib qw(./lib);
use base qw( Test::Melody::API::Twitter::Base );
use Data::Dumper;
use Scalar::Util qw( looks_like_number );

use Test::More tests => 8;

my $test = __PACKAGE__->new();
$test->init();

###
### status UPDATE
###
my $result = $test->client->update({ status => "A test message!" });
my $id     = eval { $result->{status}->{id} };
is( eval { ref $result->{status} }, 'HASH', 'Return value of update');
ok( looks_like_number($id), 'Status ID updated' );


SKIP: {
    skip "Status not updated", 3 unless $id;

    ###
    ### SHOW_STATUS
    ###
    my $result2 = $test->client->show_status({ id => $id });
    my $id2     = eval { $result2->{status}->{id} };
    is( eval { ref $result2->{status} }, 'HASH',
        'Return value of show_status');
    ok( looks_like_number($id2), 'Status ID retrieved' );
    is_deeply( $result, $result2, 'Status equivalence with previous' );

    ###
    ### DESTROY STATUS
    ###
    my $result3 = $test->client->destroy_status({ id => $id2 });
    my $id3  = eval { $result3->{status}->[0]->{id} };
    is( eval { ref $result3->{status} }, 'ARRAY',
        'Return value of destroy_status');
    ok( looks_like_number($id3), 'Status ID destroyed' );
    is_deeply( $result2->{status}, $result3->{status}->[0],
        'Status equivalence with previous' );
};


$test->finish();
