#!/usr/bin/perl -w

use strict;

my @libs;
BEGIN {
    @libs = map { $ENV{MT_HOME} ? "$ENV{MT_HOME}/$_" : "$_"; }
        qw( addons/Messaging.plugin/lib
            addons/Log4MT/lib
            addons/Log4MT/extlib
            lib
            extlib
        );
}

use lib @libs;
use MT::Bootstrap App => 'Messaging::Twitter';
