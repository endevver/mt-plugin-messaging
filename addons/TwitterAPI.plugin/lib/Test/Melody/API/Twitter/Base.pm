package Test::Melody::API::Twitter::Base;

use strict;
use warnings;
use Data::Dumper;

use base qw( Class::Accessor::Fast Class::Data::Inheritable );

use Scalar::Util qw( blessed );
use File::Spec;

__PACKAGE__->mk_accessors(qw( users client session_id session_username ));
__PACKAGE__->mk_classdata( 
    TestUserData => [
                        {
                            name => 'twitterapitest_me',
                            nickname => 'Twitter API Test ME',
                        },
                        {
                            name => 'twitterapitest_friend',
                            nickname => 'Twitter API Test FRIEND',
                        },
                        {
                            name => 'twitterapitest_other',
                            nickname => 'Twitter API Test OTHER',
                        }
                    ]
);

BEGIN {

    # if MT_HOME is not set, set it
    unless ( $ENV{MT_HOME} ) {
        require Cwd;
        my $cwd    = Cwd::getcwd();
        my @pieces = File::Spec->splitdir($cwd);
        pop @pieces unless -d 't';
        $ENV{MT_HOME} = File::Spec->catdir(@pieces);
    }

    # if MT_CONFIG is not set, set it
    if ( $ENV{MT_CONFIG} ) {
        if ( !File::Spec->file_name_is_absolute( $ENV{MT_CONFIG} ) ) {
            $ENV{MT_CONFIG}
              = File::Spec->catfile( $ENV{MT_HOME}, $ENV{MT_CONFIG} );
        }
    }
    else {
        $ENV{MT_CONFIG}
          = File::Spec->catfile( $ENV{MT_HOME}, "mt-config.cgi" );
    }
    chdir $ENV{MT_HOME};

} ## end BEGIN

sub init {
    my $self = shift;
    $self->init_app( $ENV{MT_CONFIG} );
    $self->users(  $self->init_test_users() );
    $self->client( $self->init_client()     );
    $self->override_core_methods();
}

sub init_app {
    my $self = shift;
    my ($cfg) = @_;

    my $app = $ENV{MT_APP} || 'MT::App';
    eval "require $app; 1;" or die "Can't load $app: $@";

    $app->instance( $cfg ? ( Config => $cfg ) : () );

    require MT;

    # kill __test_output for a new request
    MT->add_callback(
        "${app}::init_request",
        1, undef,
        sub {
            $_[1]->{__test_output}    = '';
            $_[1]->{upgrade_required} = 0;
        }
    ) or die( MT->errstr );
} ## end sub init_app

sub init_test_users {
    my $self = shift;
    my @users;
    foreach my $data ( @{ $self->TestUserData } ) {
        my $user = MT->model('author')->get_by_key({
            name     => $data->{name}, 
            nickname => $data->{nickname},
            password => '',
        });
        $user->save;
        push( @users, $user );
    }
    \@users;
}

sub init_client {
    my $self = shift;

    # Get the API URL which can be overridden
    # with the TWITTERAPIURL environment variable
    my ($apiurl) = $ENV{TWITTERAPIURL};
    $apiurl    ||= File::Spec->catfile(
                        MT->instance->config->CGIPath,
                        'twitter.cgi'
                   );

    # Load the primary test user's author record
    my ($test_user)
        = grep { $_->name eq 'twitterapitest_me' } @{ $self->users() };
    die "NO TEST USER: ".Dumper( $self->users() ) unless $test_user;

    # Instantiate the client using the primary test user's credentials
    require Net::Twitter;
    return Net::Twitter->new(
        traits   => [qw/Legacy/],
        apiurl   => $apiurl,
        username => $test_user->name,
        password => $test_user->api_password,
    );
}

sub override_core_methods {
    my $self = shift;
    no warnings 'once';
    local $SIG{__WARN__} = sub { };

    *MT::App::print = sub {
        my $app = shift;
        $app->{__test_output} ||= '';
        $app->{__test_output} .= join( '', @_ );
    };

    my $orig_login = \&MT::App::login;
    *MT::App::login = sub {
        my $app = shift;
        if ( my $user = $app->query->param('__test_user') ) {

            # attempting to fake user session
            if (   !$self->session_id
                 || $user->name ne $self->session_username
                 || $app->query->param('__test_new_session') )
            {
                $app->start_session( $user, 1 );
                $self->session_id( $app->{session}->id );
                $self->session_username( $user->name );
            }
            else {
                $app->session_user( $user, $self->session_id );
            }
            $app->query->param( 'magic_token', $self->session_id );
            $app->user($user);
            return ( $user, 0 );
        }
        $orig_login->( $app, @_ );
    };
}

sub finish {
    my $self = shift;
    if ( my $err = $@ ) {
        die $@ unless blessed $err && $err->isa('Net::Twitter::Error');
        warn "HTTP Response Code: ", $err->code, "\n",
             "HTTP Message......: ", $err->message, "\n",
             "Twitter error.....: ", $err->error, "\n";
    }
}
1;