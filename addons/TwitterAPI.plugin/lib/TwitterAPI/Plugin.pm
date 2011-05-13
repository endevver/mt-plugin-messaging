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
    my $app    = shift;
    my $q      = $app->query;
    my %param  = @_;
    my $plugin = MT->component('twitterapi');

    return $app->show_error("Permission denied.")
        unless $app->user->is_superuser();

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

    my %params = (
        message_shown   => $q->param('message_shown') || '',
        message_hidden  => $q->param('message_hidden') || '',
        message_deleted => $q->param('message_deleted') || '',
    );

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

sub hide {
    my ($app) = @_;
    $app->validate_magic or return;

    return $app->show_error("Permission denied.")
        unless $app->user->is_superuser();

    my @message_ids = $app->param('id');
    foreach my $message_id (@message_ids) {
        my $message = MT->model('tw_message')->load($message_id)
            or next;
        $message->status( MT->model('tw_message')->HIDE() );
        $message->save or die $message->errstr;
    }

    $app->add_return_arg( message_hidden => 1 );
    $app->call_return;
}

sub show {
    my ($app) = @_;
    $app->validate_magic or return;

    return $app->show_error("Permission denied.")
        unless $app->user->is_superuser();

    my @message_ids = $app->param('id');
    foreach my $message_id (@message_ids) {
        my $message = MT->model('tw_message')->load($message_id)
            or next;
        $message->status( MT->model('tw_message')->SHOW() );
        $message->save or die $message->errstr;
    }

    $app->add_return_arg( message_shown => 1 );
    $app->call_return;
}

sub delete {
    my ($app) = @_;
    $app->validate_magic or return;

    return $app->show_error("Permission denied.")
        unless $app->user->is_superuser();

    my @message_ids = $app->param('id');
    foreach my $message_id (@message_ids) {
        my $message = MT->model('tw_message')->load($message_id)
            or next;
        $message->remove;
    }

    $app->add_return_arg( message_deleted => 1 );
    $app->call_return;
}

1;
