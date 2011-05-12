#!/usr/bin/perl -w

use strict;
use lib $ENV{MT_HOME} ? "$ENV{MT_HOME}/addons/TwitterAPI.plugin/lib" : 'addons/TwitterAPI.plugin/lib';
use lib $ENV{MT_HOME} ? "$ENV{MT_HOME}/addons/Log4MT/lib" : 'addons/Log4MT/lib';
use lib $ENV{MT_HOME} ? "$ENV{MT_HOME}/lib" : 'lib';
use lib $ENV{MT_HOME} ? "$ENV{MT_HOME}/extlib" : 'extlib';
use MT::Bootstrap App => 'Melody::API::Twitter';
