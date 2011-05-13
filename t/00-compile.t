#!/usr/bin/perl
package Test::Melody::API::Twitter::Compile;

use strict;
use warnings;
use lib qw(./lib);
use Test::More tests => 17;

use_ok( 'TwitterAPI::Plugin' );
use_ok( 'Melody::Message' );
use_ok( 'Melody::Follower' );
use_ok( 'Melody::Favorite' );
use_ok( 'Melody::API::Twitter' );
use_ok( 'Melody::API::Twitter::Account' );
use_ok( 'Melody::API::Twitter::Callbacks' );
use_ok( 'Melody::API::Twitter::DirectMessage' );
use_ok( 'Melody::API::Twitter::Favorites' );
use_ok( 'Melody::API::Twitter::Friends' );
use_ok( 'Melody::API::Twitter::Help' );
use_ok( 'Melody::API::Twitter::List' );
use_ok( 'Melody::API::Twitter::Search' );
use_ok( 'Melody::API::Twitter::Status' );
use_ok( 'Melody::API::Twitter::User' );
use_ok( 'Melody::API::Twitter::Util' );
use_ok( 'Test::Melody::API::Twitter::Base' );
