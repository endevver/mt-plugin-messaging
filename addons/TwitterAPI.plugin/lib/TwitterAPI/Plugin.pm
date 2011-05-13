package TwitterAPI::Plugin;

use strict;
use warnings;
use base qw( MT::Plugin );

use MT::Util qw( format_ts relative_date );

use Data::Dumper;

sub api_url {
    my $plugin = shift;
    my $app    = MT->instance;

    # The API URL can be canonically set through the TWITTERAPIURL
    # environment variable which allows for the convenience of unit testing
    # as well as administrators who prefer to set it from the Apache config
    my $env = $ENV{TWITTERAPIURL} || '';
    return $env if $env =~ m{^http};

    # Otherwise, derive the API URL from the CGIPath and TwitterAPIScript
    # config directive values, the latter of which defaults to "twitter.cgi".
    return File::Spec->catfile(
        $app->config->CGIPath,
        $app->config->TwitterAPIScript,
    );
}

# A simple listing page.
sub list {
    my $app = shift;
    my %param = @_;
    my $plugin = MT->component('twitterapi');

    my $code = sub {
        my ($obj, $row) = @_;

        my $author = MT::Author->load({ id => $obj->created_by });
        $row->{author} = $author->name;

        my $ts = $obj->created_on;
        $row->{created_on_formatted} =
            format_ts( MT::App::CMS::LISTING_DATE_FORMAT(), $ts, undef, 
                        $app->user ? $app->user->preferred_language : undef );
        $row->{created_on_time_formatted} =
            format_ts( MT::App::CMS::LISTING_DATETIME_FORMAT(), $ts, undef, 
                        $app->user ? $app->user->preferred_language : undef );
        $row->{created_on_relative} =
            relative_date( $ts, time, undef );
    };

    my %terms = (
    );

    my %args = (
        sort      => 'created_on',
        direction => 'descend',
    );

    my %params = ();

    $app->listing({
        type     => 'tw_message', # the ID of the object in the registry
        terms    => \%terms,
        args     => \%args,
        listing_screen => 1,
        code     => $code,
        template => $plugin->load_tmpl('listing.mtml'),
        params   => \%params,
    });
}

# Create a new message
sub create {
    my $app    = MT->instance;
    my $user   = $app->user;
    my $plugin = MT->component('TwitterAPI');

    require Net::Twitter;
    my $nt = Net::Twitter->new(
        apiurl   => $plugin->api_url(),
        username => $user->name,
        password => $user->api_password,
    );

    my $result = $nt->update({'Hello world!'});
}

sub widget {
    my ($app, $tmpl, $widget_param) = @_;
}

1;
