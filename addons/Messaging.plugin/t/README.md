# The Messaging plugin's Test Suite #

This plugin includes a perl-based unit test framework and suite of tests which provide coverage for the small subset of functionality completed thus far.

## DEPENDENCIES ##

This plugin includes a Perl test suite that relies upon
[Net::Twitter](http://search.cpan.org/dist/Net-Twitter/lib/Net/Twitter.pod).
If you want to run the tests you'll need Net::Twitter and all of its
dependencies.

### Movable Type Incompatibility ###

Movable Type ships with an incredibly old library of modules in its `extlib` directory.  By virtue of their location in a directory that has very high precedence in the perl search path array, these old modules have the ability to mask newer versions of the same modules installed in the Perl system library. 

Unfortunately, a number of Net::Twitter's dependencies are counted among this group and severely affected to the point that the test suite will not run. To resolve the conflict, you will need to do the following:

1. Install the following perl bundles on your system if not already installed:
    * [libwww-perl][libwww-perl] v6.00 or higher (preferably the latest)
    * [HTTP-Message][HTTP-Message] (latest version)
2. Move the following files and directories (indicated by a trailing
   slash) out of the `extlib` directory:
    * LWP/
    * LWP.pm
    * HTTP/Headers/
    * HTTP/Headers.pm
    * HTTP/Message.pm
    * HTTP/Request/
    * HTTP/Request.pm
    * HTTP/Response.pm
    * HTTP/Status.pm

[libwww-perl]: http://search.cpan.org/dist/libwww-perl/
[HTTP-Message]: http://search.cpan.org/~gaas/HTTP-Message-6.02/

## USAGE ##

The basic command for running the test suite is as follows and should be executed from `MT_HOME`:

    MT_HOME=$(pwd) prove -wlv addons/Messaging.plugin/t

**Notes:**

* Don't forget to set either the `MessagingScript` directive in MTE (if
  needed) or the `MESSAGINGAPIURL` environment variable in your shell

* If you encounter errors about empty base classes or the test not being able
  to find a particular package, check and fiddle with your PERL5LIB
  environment variable
