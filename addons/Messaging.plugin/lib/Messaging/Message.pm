package Messaging::Message;
 
use strict;
use warnings;

use MT::Tag; # Holds MT::Taggable
use base qw( MT::Object MT::Taggable );

__PACKAGE__->install_properties({
    column_defs => {
        'id'            => 'integer not null auto_increment',
        'text'          => 'text',
        'geo_latitude'  => 'float meta',
        'geo_longitude' => 'float meta',
        'status'        => 'integer',
    },
    audit => 1,
    indexes => {
        #text => 1, # Can't index text columns.
        geo_latitude  => 1,
        geo_longitude => 1,
    },
    default => {
        status => 2,
    },
    datasource  => 'tw_message',
    primary_key => 'id',
});

sub class_label {
    MT->translate("Message");
}

sub class_label_plural {
    MT->translate("Messages");
}

# Status' a message can have
sub HIDE () { 1 }
sub SHOW () { 2 }

1;

__END__
