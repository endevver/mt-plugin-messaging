package Messaging::Plugin;

use strict;
use warnings;
use base qw( MT::Plugin );
use Data::Dumper;

use MT::Util qw( caturl format_ts relative_date );
use lib qw( addons/Log4MT.plugin/lib addons/Log4MT.plugin/extlib );
our $logger;
use Log::Log4perl qw( :resurrect );
###l4p use MT::Log::Log4perl qw( l4mtdump );
###l4p $logger ||= MT::Log::Log4perl->new();

sub api_url {
    my $plugin = shift;
    my $app    = MT->instance;

    # The API URL can be canonically set through the MESSAGINGAPIURL
    # environment variable which allows for the convenience of unit testing
    # as well as administrators who prefer to set it from the Apache config
    my $env = $ENV{MESSAGINGAPIURL} || '';
    return $env if $env =~ m{^http};

    # Otherwise, derive the API URL from the CGIPath and MessagingScript
    # config directive values, the latter of which defaults to "twitter.cgi".
    $env = caturl( $app->config->CGIPath, $app->config->MessagingScript );
}

sub settings {
    my ($plugin, $param, $scope) = @_;
    my $app = MT->instance;

    # Grab the ID of the saved template.
    my $saved_t = $plugin->get_config_value(
        'republish_templates', 
        'blog:'.$app->blog->id
    )
        || ''; # Fallback to no template previously saved

    # Load all index templates in this blog, which will be used to populate
    # the settings screen and to mark which template(s) have been previously
    # saved.
    my $iter = MT->model('template')->load_iter(
        {
            type    => 'index',
            blog_id => $app->blog->id,
        },
        {
            sort      => 'name',
            direction => 'ascend',
        }
    );

    my ($selected, @template_loop);
    while ( my $t = $iter->() ) {
        $selected = $saved_t eq $t->id ? 1 : 0;
        push @template_loop, { id       => $t->id,
                               name     => $t->name,
                               selected => $selected,
                             };
    }
    $param->{index_templates} = \@template_loop;

    return $plugin->load_tmpl('settings.mtml', $param);
}

# A simple listing page.
sub list {
    my $app    = shift;
    my $q      = $app->query;
    my %param  = @_;
    my $plugin = MT->component('Messaging');

    return $app->show_error("Permission denied.")
        unless $app->user->is_superuser();

    my $code = sub {
        my ($obj, $row) = @_;

        my $author = MT->model('user')->load({ id => $obj->created_by });
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
    my $q     = $app->query;
    $app->validate_magic or return;

    return $app->show_error("Permission denied.")
        unless $app->user->is_superuser();

    my @message_ids = $q->param('id');
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
    my $q     = $app->query;
    $app->validate_magic or return;

    return $app->show_error("Permission denied.")
        unless $app->user->is_superuser();

    my @message_ids = $q->param('id');
    foreach my $message_id (@message_ids) {
        my $message = MT->model('tw_message')->load($message_id)
            or next;
        $message->status( MT->model('tw_message')->SHOW() );
        $message->save or die $message->errstr;
    }

    $app->add_return_arg( message_shown => 1 );
    $app->call_return;
}

# Delete a message (or messages) from on the admin listing screen.
sub delete {
    my ($app) = @_;
    my $q     = $app->query;
    $app->validate_magic or return;

    return $app->show_error("Permission denied.")
        unless $app->user->is_superuser();

    my @message_ids = $q->param('id');
    foreach my $message_id (@message_ids) {
        my $message = MT->model('tw_message')->load($message_id)
            or next;

        # Delete any saved object-tag associations before trying to delete the 
        # message itself. I don't think this step should be necessary -- when
        # removing the message, the objecttag record(s) should be 
        # automatically removed at the same time as part of $message->remove.
        # However, not including this code lets a weird bug show up: when 
        # deleting 3 (or more) messages from the admin interface, where the 
        # first and last message have tags but the middle message does not, an
        # error returns. The error is: Cannot find column 'blog_id' for class 
        # 'Messaging::Message' at lib/MT/Tag.pm line 47, and it occurs when 
        # trying to delete the second message, which has no tags.
        my $iter = MT->model('objecttag')->load_iter({
            object_datasource => 'tw_message',
            object_id         => $message->id,
        });
        while ( my $objecttag = $iter->() ) {
            ###l4p $logger->info('Removing object-tag association for message '.$message->id.' and tag '.$objecttag->tag_id);
            $objecttag->remove() or die $objecttag->errstr;
        }

        ###l4p $logger->info('Deleting message: '.$message->id.', '.$message->text);
        $message->remove or die $message->errstr;
    }

    $app->add_return_arg( message_deleted => 1 );
    $app->call_return;
}

# The dashboard widget is an example of an interface to the Messaging plugin.
sub dashboard_widget {
    my ($app, $tmpl, $widget_param) = @_;

    # The author password needs to be part of the Ajax request to post a new
    # message.
    my $author = MT->model('author')->load( $app->user->id );
    require MIME::Base64;
    my $b64 = MIME::Base64::encode_base64(
        $author->name . ':' . $author->password
    );

    # Author->api_password seems to add a trailing new line?
    chomp $b64;

    $widget_param->{base64_author_credentials} = $b64;
}

# After a new message is received, republish the template that has been
# requested to be republished. Push it to a background task so that the user
# doesn't have to wait for it to happen.
sub republish_template {
    MT::Util::start_background_task(
        sub {
            my $app = MT->instance;
            
            # Load all instances of the plugindata for the Messaging plugin.
            # This way we can check each blog that might have a template
            # marked to be republished.
            my @plugin_datas = MT->model('plugindata')->load({ plugin => 'Messaging' })
                or return;

            foreach my $plugin_data (@plugin_datas) {
                # Grab the template ID that this blog should republish. If
                # no ID is set, just move on to the next piece of plugindata.
                my $t_id = $plugin_data->data->{'republish_templates'}
                    or next;

                # Try to load the template. Be sure to specify the type of 
                # "index" so that we don't accidentally pick up backup 
                # templates instead.
                my $tmpl = MT->model('template')->load({
                    id   => $t_id,
                    type => 'index',
                })
                    or next;

                # Republish this template! Push a message to the Activity Log
                # if it failed, though.
                $app->rebuild_indexes( 
                    Template => $tmpl,
                    Force    => 1,
                )
                    or MT->log({
                        blog_id => $tmpl->blog_id,
                        level   => MT::Log::ERROR(),
                        message => $app->errstr,
                    });
            }
        }
    );
}

1;
