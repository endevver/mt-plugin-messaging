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

# The MT5 Listing Framework properties
sub list_properties {
    return {
        id => {
            auto    => 1,
            label   => 'ID',
            order   => 100,
            display => 'optional',
        },
        status => {
            label                 => 'Status',
            col                   => 'status',
            display               => 'none',
            col_class             => 'icon',
            base                  => '__virtual.single_select',
            single_select_options => [
                { label => MT->translate('Draft'),     value => 1, },
                { label => MT->translate('Published'), value => 2, },
            ],
        },
        text => {
            base    => '__virtual.title',
            order   => 200,
            display => 'force',
            label   => 'Message Text',
            sub_fields => [
                {
                    class   => 'status',
                    label   => 'Status',
                    display => 'default',
                },
            ],
            html => sub {
                my $prop = shift;
                my ( $obj, $app, $opts ) = @_;

                # Build the status icon.
                my $status = $obj->status;
                my $status_class
                    = $status == Messaging::Message::HIDE() ? 'Draft'
                    : $status == Messaging::Message::SHOW() ? 'Published'
                    :                                         '';
                my $lc_status_class = lc $status_class;
                my $status_file
                    = $status == Messaging::Message::HIDE() ? 'draft.gif'
                    : $status == Messaging::Message::SHOW() ? 'success.gif'
                    :                                         '';
                my $status_img
                    = MT->static_path . 'images/status_icons/' . $status_file;

                my $text = $obj->text;

                my $out = qq{
                    <span class="icon status $lc_status_class">
                      <img alt="$status_class" src="$status_img" />
                    </span>
                    <span class="title">
                      $text
                    </span>
                    <!-- The class .text causes the listing framework to be
                         mis-styled. Redefine them to fix. -->
                    <style type="text/css">
                        .col.text.string { background-color: inherit; }
                        .col.text.string:hover,
                        .col.text.string:focus { box-shadow: none; border-color: #fff; }
                    </style>
                };
            },
        },
        geo_latitute => {
            # Using __virtual.float seems like the correct choice here, however
            # it doesn't seem to work?
            base    => '__virtual.string',
            order   => 500,
            display => 'optional',
            col     => 'geo_latitude',
            label   => 'Latitude',
        },
        geo_longitude => {
            # Using __virtual.float seems like the correct choice here, however
            # it doesn't seem to work?
            base    => '__virtual.string',
            order   => 600,
            display => 'optional',
            col     => 'geo_longitude',
            label   => 'Longitude',
        },
        created_by => {
            base    => '__virtual.author_name',
            order   => 700,
            display => 'default',
        },
        created_on => {
            base    => '__virtual.created_on',
            order   => 800,
            display => 'default',
        },
    };
}

1;

__END__
