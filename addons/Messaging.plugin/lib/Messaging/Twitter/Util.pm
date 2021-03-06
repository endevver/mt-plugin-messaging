package Messaging::Twitter::Util;

use strict;

use base 'Exporter';
use MT::Util qw( format_ts );
use MT::I18N qw( length_text substr_text );

our @EXPORT_OK = qw( 
    serialize_author twitter_date truncate_tweet serialize_entries is_number 
    load_friends load_followers latest_status mark_favorites hack_geo 
);

sub hack_geo {
    my ( $ref, $format ) = @_;
    if ( $format eq 'json' ) {

        # "geo":"50 90"
        # "geo": {
        #   "type":"Point",
        #   "coordinates":[37.78029, -122.39697]
        # }
        $$ref =~
s/"geo":"([^ ]*) ([^\"]*)"/"geo":\{"type":"Point","coordinates":[$1, $2]\}/gm;
    }
    elsif ( $format eq 'xml' ) {

        # <geo xmlns:georss="http://www.georss.org/georss">
        #   <georss:point>37.78029 -122.39697</georss:point>
        # </geo>
        $$ref =~
s/<geo>([^ ]*) ([^\>]*)<\/geo>/<geo xmlns:georss=\"http:\/\/www.georss.org\/georss\"><georss:point>$1 $2<\/georss:point><\/geo>/gm;
    }
}

sub latest_status {
    my ($user) = @_;
    return MT->model('tw_message')->load(
        {
            author_id => $user->id,
            status    => MT->model('tw_message')->SHOW()
        },
        {
            sort_by   => 'created_on',
            direction => 'descend',
            limit     => 1
        }
    );
}

sub load_friends {
    my ($user) = @_;
    unless ( ref $user eq 'MT::Author' ) {
        $user = MT->model('author')->load($user);
    }
    my @following = MT->model('tw_follower')->load(
        { follower_id => $user->id },
        {
            sort_by   => 'created_on',
            direction => 'descend'
        }
    );
    unless (@following) {
        print STDERR "This person is not following anyone.";
        return;
    }

    # TODO - the hash does not preserve order!!! Doh.
    my %hash = ();
    %hash = map { $_->followee_id => $_ } @following;

    use Data::Dumper;
    print STDERR "friends hash: " . Dumper(%hash);
    return \%hash;
}

sub load_followers {
    my ($user) = @_;
    my @followers = MT->model('tw_follower')->load(
        { followee_id => $user->id },
        {
            sort_by   => 'created_on',
            direction => 'descend'
        }
    );

    # TODO - the hash does not preserve order!!! Doh.
    my %hash = ();
    %hash = map { $_->follower_id => $_ } @followers;
    return \%hash;
}

sub truncate_tweet {
    my ($str) = @_;
    return ( 0, '' ) unless $str;
    if ( 140 < length_text($str) ) {
        return ( 1, substr_text( $str, 0, 140 ) );
    }
    else {
        return ( 0, $str );
    }
}

sub twitter_date {
    my ($ts) = @_;
    return format_ts( '%a, %b %e %Y %H:%M:%S', $ts );
}

sub is_number {
    my ($n) = @_;
    return $n + 0 eq $n;
}

sub serialize_entries {
    my ($entries) = @_;
    my $statuses = [];
    my @ids;
    foreach my $e (@$entries) {
        my ( $trunc, $txt ) = truncate_tweet( $e->text );
        push @ids, $e->id;
        
        my $author = MT->model('author')->load( $e->created_by );
        
        my $ser = {
            created_at => twitter_date( $e->created_on ),
            id         => $e->id,
            text       => $txt,
            source =>
              'Melody',  # TODO - replace with a meta data field I should create
            truncated => ( $trunc ? 'true' : 'false' ),
            in_reply_to_status_id   => '',
            in_reply_to_user_id     => '',
            favorited               => 'false',
            in_reply_to_screen_name => '',
            user                    => serialize_author( $author ),
            geo                     => undef,
        };
        if ( $e->geo_latitude && $e->geo_longitude ) {
            $ser->{geo} = $e->geo_latitude . " " . $e->geo_longitude;
        }
        push @$statuses, $ser;
    }
    return $statuses;
}

sub mark_favorites {
    my ( $statuses, $user ) = @_;
    my @ids;
    foreach my $e (@$statuses) {
        push @ids, $e->{id};
    }
    my @favs = MT->model('tw_favorite')->load(
        {
            obj_type  => 'tw_message',
            author_id => $user->id,
            obj_id    => \@ids
        }
    );
    foreach my $f (@favs) {
        map {
            if ( $f->obj_id == $_->{id} ) { $_->{favorited} = 'true' }
        } @$statuses;
    }
}

sub serialize_author {
    my ($a) = @_;
    return {
        id                => $a->id,
        name              => $a->nickname,
        screen_name       => $a->name,
        location          => '',
        description       => '',
        profile_image_url => '',
        url               => $a->url,
        protected         => 'false',
        created_at        => twitter_date( $a->created_on ),

        #        followers_count,
        #        profile_background_color,
        #        profile_text_color,
        #        profile_link_color,
        #        profile_sidebar_fill_color,
        #        profile_sidebar_border_color,
        #        friends_count,
        #        favourites_count,
        #        utc_offset,
        #        time_zone,
        #        profile_background_image_url,
        #        profile_background_tile,
        #        statuses_count,
        #        notifications,
        #        following,
        #        verified,
    } if defined $a;
}

1;
