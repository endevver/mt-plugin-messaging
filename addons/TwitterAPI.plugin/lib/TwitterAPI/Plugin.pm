package TwitterAPI::Plugin;

use strict;
use warnings;

use MT::Util qw( format_ts relative_date );

use Data::Dumper;

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
    my $app = MT->instance;
    
    use Net::Twitter;
    my $nt = Net::Twitter->new(
        apiurl   => "http://localhost/cgi-bin/mt435/twitter.cgi",
        username => $app->user->name,
        password => 'yttjct4p',
    );

    my $result = $nt->update({'Hello world!'});
}

sub widget {
    my ($app, $tmpl, $widget_param) = @_;
}

1;
