package TwitterAPI::Tags;

use strict;
use warnings;
use base qw( MT::Plugin );

block:
    Messages: TwitterAPI::Tags::messages
function:
    MessageID: TwitterAPI::Tags::message_id
    MessageText: TwitterAPI::Tags::message_text
    MessageGeoLong: TwitterAPI::Tags::message_geo_long
    MessageGeoLat: TwitterAPI::Tags::message_geo_lat
    MessageAuthorID: TwitterAPI::Tags::message_author_id
    MessageDate: TwitterAPI::Tags::message_date

sub messages {
    my ($ctx, $args, $cond) = @_;
    my $builder = $ctx->stash('builder');
    my $tokens  = $ctx->stash('tokens');

    my $load_terms = {};
    # Only if an ID is supplied in arguments does it get assigned. Otherwise, 
    # load tries (and fails) to find a result.
    if ($args->{'id'}) {
        $load_terms->{topic_id} = $args->{'id'};
    }

    my $load_args = {};
    $load_args->{sort} = $args->{'sort_by'} || 'created_on';
    $load_args->{direction} = $args->{'sort_order'} || 'descend';
    # Allow limit or lastn in case the user can't remember
    $load_args->{limit}  = $args->{'limit'} || $args->{'lastn'} || '10';
    $load_args->{offset} = $args->{'offset'};
    
    my $iter = MT->model('tw_message')->load_iter($load_terms, $load_args);
    
    my $res = '';
    my $i = 0;
    my $vars = $ctx->{__stash}{vars} ||= {};
    while ( my $message = $iter->() ) {
        local $vars->{__first__} = !$i;
        local $vars->{__last__} = ($i == $load_args->{limit});
        local $vars->{__odd__} = ($i % 2) == 0; # 0-based $i
        local $vars->{__even__} = ($i % 2) == 1;
        local $vars->{__counter__} = $i+1;
        
        $ctx->stash('MessageID',       $message->id);
        $ctx->stash('MessageText',     $message->text);
        $ctx->stash('MessageGeoLong',  $message->geo_longitude);
        $ctx->stash('MessageGeoLat',   $message->geo_latitude);
        $ctx->stash('MessageAuthorID', $message->created_by);
        $ctx->stash('MessageDate',     $message->created_on);
        
        # Necessary for the date handler in MT::Template::Context to do it's thing.
        local $ctx->{current_timestamp} = $hot_topic->created_on;
    
        my $out = $builder->build($ctx, $tokens);
        if (!defined $out) {
            # A error--perhaps a tag used out of context. Report it.
            return $ctx->error( $builder->errstr );
        }
        $res .= $out;

        $i++;
    }
    return $res;
}

sub message_id {
    my ($ctx, $args) = @_;
    my $a = $ctx->stash('MessageID');
    return $ctx->error('The MessageID tag must be used within the Messages block tag.')
        if !defined $a;
    return $a
}

sub message_text {
    my ($ctx, $args) = @_;
    my $a = $ctx->stash('MessageText');
    return $ctx->error('The MessageText tag must be used within the Messages block tag.')
        if !defined $a;
    return $a
}

sub message_geo_long {
    my ($ctx, $args) = @_;
    my $a = $ctx->stash('MessageGeoLong');
    return $ctx->error('The MessageGeoLong tag must be used within the Messages block tag.')
        if !defined $a;
    return $a
}

sub message_geo_lat {
    my ($ctx, $args) = @_;
    my $a = $ctx->stash('MessageGeoLat');
    return $ctx->error('The MessageGeoLat tag must be used within the Messages block tag.')
        if !defined $a;
    return $a
}

sub message_author_id {
    my ($ctx, $args) = @_;
    my $a = $ctx->stash('MessageID');
    return $ctx->error('The MessageID tag must be used within the Messages block tag.')
        if !defined $a;
    return $a
}

sub message_date {
    my ($ctx, $args) = @_;
    my $a = $ctx->stash('MessageID');
    return $ctx->error('The MessageID tag must be used within the Messages block tag.')
        if !defined $a;

    # The following lets the user specify the normal date format modifiers.
    use MT::Template::Context;
    return MT::Template::Context::_hdlr_date($ctx, $args);
}

1;
