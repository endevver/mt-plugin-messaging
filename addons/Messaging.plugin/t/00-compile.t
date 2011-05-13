#!/usr/bin/perl
package Test::Messaging::Compile;

use strict;
use warnings;
use lib qw(addons/Messaging.plugin/lib);
use Test::More tests => 17;

use_ok( 'Messaging::Plugin' );
use_ok( 'Messaging::Message' );
use_ok( 'Messaging::Follower' );
use_ok( 'Messaging::Favorite' );
use_ok( 'Messaging::Twitter' );
use_ok( 'Messaging::Twitter::Account' );
use_ok( 'Messaging::Twitter::Callbacks' );
use_ok( 'Messaging::Twitter::DirectMessage' );
use_ok( 'Messaging::Twitter::Favorites' );
use_ok( 'Messaging::Twitter::Friends' );
use_ok( 'Messaging::Twitter::Help' );
use_ok( 'Messaging::Twitter::List' );
use_ok( 'Messaging::Twitter::Search' );
use_ok( 'Messaging::Twitter::Status' );
use_ok( 'Messaging::Twitter::User' );
use_ok( 'Messaging::Twitter::Util' );
use_ok( 'Test::Messaging::Base' );
