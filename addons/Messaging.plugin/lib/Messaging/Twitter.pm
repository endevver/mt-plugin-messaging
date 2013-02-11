package Messaging::Twitter;

use strict;

use MT;
use MT::Util qw( encode_xml format_ts );
use MT::I18N qw( length_text substr_text );
use Messaging::Twitter::Util qw( hack_geo );
use base qw( MT::App );

use constant {
    AUTH_REQUIRED => 1,
    AUTH_OPTIONAL => 0,
};

our $logger;
use lib qw( addons/Log4MT.plugin/lib addons/Log4MT.plugin/extlib );
use Log::Log4perl qw( :resurrect );

sub init {
    my $app = shift;
    $app->SUPER::init(@_) or return $app->error("Initialization failed");

    # Now that MT has been initialized, Log4MT can be initialized.
    ###l4p require MT::Log::Log4perl;
    ###l4p import MT::Log::Log4perl qw( l4mtdump );
    ###l4p $logger = MT::Log->get_logger();
    ###l4p $logger->info('Initializing...');

    $app->request_content
      if $app->request_method eq 'POST' || $app->request_method eq 'PUT';
    $app->add_methods( handle => \&handle, );
    $app->{default_mode}  = 'handle';
    $app->{is_admin}      = 0;
    $app->{warning_trace} = 0;
    $app;
}

our $SUBAPPS = {
    'trends'          => 'Messaging::Twitter::Trends',
    'statuses'        => 'Messaging::Twitter::Status',
    'direct_messages' => 'Messaging::Twitter::DirectMessage',
    'users'           => 'Messaging::Twitter::User',
    'account'         => 'Messaging::Twitter::Account',
    'favorites'       => 'Messaging::Twitter::Favorites',
    'friendships'     => 'Messaging::Twitter::Friends',
    'help'            => 'Messaging::Twitter::Help',
    'search'          => 'Messaging::Twitter::Search',
};

sub handle {
    my $app = shift;
    ###l4p $logger->info('Entering "handle"...');
    my $out = eval {
        ( my $pi = $app->path_info ) =~ s!^/!!;
        ###l4p $logger->info( 'Path info: ' . $pi );
        $app->{param} = {};

        my ( $subapp, $method, $id, $format );

        if ( ( $subapp, $method, $id, $format ) =
            ( $pi =~ /^([^\/]*)\/([^\/]*)\/([^\.]*)\.(.*)$/ ) )
        {
            ###l4p $logger->info("Sub app: $subapp, method: $method, id: $id, format: $format");
        }
        elsif ( ( $subapp, $method, $format ) =
            ( $pi =~ /^([^\/]*)\/([^\.]*)\.(.*)$/ ) )
        {
            ###l4p $logger->info("Sub app: $subapp, method: $method, format: $format");
        }
        elsif ( ( $subapp, $format ) = ( $pi =~ /^([^\.]*)\.(.*)$/ ) ) {
            $method = $subapp;
            ###l4p $logger->info("Sub app: $subapp, method: $method, format: $format");
        }
        else {
            ###l4p $logger->info("Unrecognized query format.");
            $app->error( 500, 'Unrecognized query format.' );
            return $app->show_error('Unrecognized query format.');
        }
        $app->mode($method);

        my $args = {};
        for my $arg ( split( ';', $app->query_string ) ) {
            my ( $k, $v ) = split( /=/, $arg, 2 );
            $app->{param}{$k} = $v;
            $args->{$k} = $v;
        }
        if ($id) {
            $args->{id} = $id;
        }
        if ( my $class = $SUBAPPS->{$subapp} ) {
            eval "require $class;";
            bless $app, $class;

            #$logger->info( 'Reblessed app as ' . ref $app );
        }
        my $out;
        if ( $app->can($method) ) {

            #$logger->info("It looks like app can process $method");

          # Authentication should be defered to the designated handler
          # since not all methods require auth.
            use Data::Dumper;
            ###l4p $logger->info( "Calling $method with args: ", l4mtdump($args) );
            $out = $app->$method($args);
        }
        else {
            ###l4p $logger->info("Drat, app can't process $method");
        }
        if ( $app->{_errstr} ) {
            ###l4p $logger->info('There was an error processing the request: '.$app->{_errstr});
            return $app->show_error( $app->{_errstr} );
        }
        ###l4p $logger->debug( 'Returning: ', l4mtdump($out) );
        return unless defined $out;
        my $out_enc;
        if ( lc($format) eq 'json' ) {
            $app->response_content_type('application/json');
            $out_enc = MT::Util::to_json($out);
        }
        elsif ( lc($format) eq 'xml' ) {
            $app->response_content_type('text/xml');
            require XML::Simple;
            my $xml = XML::Simple->new;
            $out_enc = '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
            $out_enc .= $xml->XMLout(
                $out,
                NoAttr    => 1,
                KeepRoot  => 1,
                GroupTags => { statuses => 'status' }
            );
        }
        else {
            return $app->error( 500, 'Unsupported format: ' . $format );
            $app->show_error("Internal Error");
            return;
        }
        hack_geo( \$out_enc, $format );
        return $out_enc;
    };
    if ( my $e = $@ ) {
        $app->error( 500, $e );
        $app->show_error("Internal Error");
    }
    return $out;
}

sub get_auth_info {
    my $app = shift;
    my $q   = $app->can('query') ? $app->query : $app->param;
    my %param;

    # If the user is already a valid, logged-in user, bypass all this auth stuff.
    my ($user) = $app->login();
    return \%param if $user;

    my $auth_header = $app->get_header('Authorization')
      or return $app->auth_failure( 501, 'Authorization header missing.' );

    ###l4p $logger->info( 'Authorization header present: ' . $auth_header );
    my ( $type, $creds_enc ) = split( " ", $auth_header );

    # Unsupported auth type
    lc($type) eq 'basic'
        or return $app->auth_failure( 501,
                    'Invalid login, authorization type not recognized.' );

    require MIME::Base64;
    my $creds                   = MIME::Base64::decode_base64($creds_enc);
    my ( $username, $password ) = split( ':', $creds );
    my $pass_crypted            = 0;

    # If the API is being accessed via the dashboard widget, then it is safe to
    # assume that the user has already authenticated, and what is being passed
    # in is a valid session ID. If they are in the app, then there is no need to
    # run through the whole rigamorole of user provisioning because the app should
    # have done that already.
    # TODO - in this case auth should happen via validating a user's session
    #        via the MT::Auth driver. For example:
    # require MT::Auth;
    # my $ctx = MT::Auth->fetch_credentials( { app => $app } );
    # unless ($ctx) {
    #    if ( $app->param('submit') ) {
    #        return $app->error( $app->translate('Invalid login.') );
    #    }
    #    return;
    # }
    if ( $q->param('is_widget') ) {
        $pass_crypted = 1;
        # Lookup user record
        my $user;
        if ( $user = MT->model('user')->load({ name => $username, type => 1 }) ) {
            $param{username} = $user->name;
            $app->user($user);
        }

        # Check for active user and valid password
        return $app->auth_failure( 403, 'Invalid login.' )
            unless $user
            && $user->is_active
            && $user->password
            && $user->is_valid_password( $password, $pass_crypted );

        # Login was successful:
        return \%param;
   }

    ###l4p $logger->debug( 'Credentials: ', l4mtdump({ username => $username, password => $password, crypted => $pass_crypted }));

    # If you have gotten this far than we know the user is accessing the API outside the
    # context of the app. Therefore we need to take them through the entire user provisioning
    # process.

    # The following code is largely lifted from MT::App::login. The reason it has been copied
    # here is that MT's auth system delegates authentication handling to the application.
    # This is due in part to that fact that some auth drivers need to delegate auth and
    # redirect a broswer. In this case, redirection is not supported because this is an API,
    # not a web site's endpoint. So the code has been lifted, and modified to meet the needs
    # unique to this API.
    # In this case we do not need to pass pass_crypted to validate credentials because we
    # know it is not.
    my $res = MT::Auth->validate_credentials({
        app      => $app,
        username => $username,
        password => $password,
    }) || MT::Auth::UNKNOWN();

    my $user = $username;
    if ( $res == MT::Auth::UNKNOWN() ) {
        # Login invalid; auth layer knows nothing of user
        ###l4p $logger->debug('Authorization result: MT::Auth::UNKNOWN()');
        $app->log(
            {   message => $app->translate(
                    "Failed login attempt by unknown user '[_1]' via Messaging API", $user
                ),
                level    => MT::Log::WARNING(),
                category => 'login_user',
            }
        ) if defined $user;
        # Invalidation is not necessary because authentication in HTTP is stateless
        #MT::Auth->invalidate_credentials( { app => $app } );
        return $app->auth_failure( 403, 'Invalid login.' );
    }
    elsif ( $res == MT::Auth::INACTIVE() ) {

        # Login invalid; auth layer reports user was disabled
        ###l4p $logger->debug('Authorization result: MT::Auth::INACTIVE()');
        $app->log(
            {   message => $app->translate(
                    "Failed login attempt by disabled user '[_1]' via Messaging API", $user
                ),
                level    => MT::Log::WARNING(),
                category => 'login_user',
            }
        );
        return $app->auth_failure( 403, $app->translate(
                'This account has been disabled. Please see your system administrator for access.'
            )
        );
    }
    elsif ( $res == MT::Auth::PENDING() ) {

        # Login invalid; auth layer reports user was pending
        ###l4p $logger->debug('Authorization result: MT::Auth::PENDING()');
        # Check if registration is allowed and if so send special message
        my $message = $app->translate(
            'This account has been disabled. Please see your system administrator for access.'
        );
        $app->log(
            {   message => $app->translate(
                    "Failed login attempt by pending user '[_1]' via Messaging API", $user
                ),
                level    => MT::Log::WARNING(),
                category => 'login_user',
            }
        );
        return $app->auth_failure( 403, $message );
    }
    elsif ( $res == MT::Auth::INVALID_PASSWORD() ) {

        # Login invalid (password error, etc...)
        ###l4p $logger->debug('Authorization result: MT::Auth::INVALID_PASSWORD()');
        return $app->auth_failure( 403, 'Invalid login.' );
    }
    elsif ( $res == MT::Auth::DELETED() ) {

        # Login invalid; auth layer says user record has been removed
        ###l4p $logger->debug('Authorization result: MT::Auth::DELETED()');
        return $app->auth_failure(
            $app->translate(
                'This account has been deleted. Please see your system administrator for access.'
            )
        );
    }
    elsif ( $res == MT::Auth::REDIRECT_NEEDED() ) {
        # The authentication driver is delegating authentication to another URL, follow the
        # designated redirect.
        ###l4p $logger->debug('Authorization result: MT::Auth::REDIRECT_NEEDED()');
        return $app->auth_failure(
            $app->translate(
                'The auth driver you are using requires a web browser for authentication. It is not compatible with the Messaging AI.'
            )
        );
    }
    elsif ( $res == MT::Auth::NEW_LOGIN() ) {
        # auth layer reports valid user and that this is a new login. act accordingly
        ###l4p $logger->debug('Authorization result: MT::Auth::NEW_LOGIN()');
        $user = $app->user;
        MT::Auth->new_login( $app, $user );
    }
    elsif ( $res == MT::Auth::NEW_USER() ) {

        # auth layer reports that a new user has been created by logging in.
        ###l4p $logger->debug('Authorization result: MT::Auth::NEW_USER()');
        my $user_class = $app->user_class;
        $user = $user_class->new;
        $app->user($user);
        $user->name( $username ) if $username;
        $user->type( MT::Author::AUTHOR() );
        $user->status( MT::Author::ACTIVE() );
        $user->auth_type( $app->config->AuthenticationModule );
        my $saved = MT::Auth->new_user( $app, $user );
        $saved = $user->save unless $saved;

        unless ($saved) {
            $app->log(
                {   message => MT->translate(
                        "User cannot be created: [_1].",
                        $user->errstr
                    ),
                    level    => MT::Log::ERROR(),
                    class    => 'system',
                    category => 'create_user'
                }
                ),
                $app->error(
                MT->translate(
                    "User cannot be created: [_1].",
                    $user->errstr
                )
                ),
                return undef;
        }

        $app->log(
            {   message => MT->translate(
                    "User '[_1]' has been created.",
                    $user->name
                ),
                level    => MT::Log::INFO(),
                class    => 'system',
                category => 'create_user'
            }
        );

        # provision user if configured to do so
        if ( $app->config->NewUserAutoProvisioning ) {
            MT->run_callbacks( 'new_user_provisioning', $user );
        }
    }
    ## END CODE TAKEN FROM MT::App.pm

    $param{username} = $user->name;
    $app->user($user);
    return \%param;

}

# Some actions can be called without authentication (such as seeing the public
# timeline) while others require authentication (such as posting a status
# update.) The authenticate method is called by any action that requires it.
sub authenticate {
    my $app = shift;
    my ($mode) = @_;
    ###l4p $logger->trace('Attempting to authenticate user...');

    my $auth;
    if ( $mode == AUTH_REQUIRED ) {
        $auth = $app->get_auth_info
          or return $app->auth_failure( 401, "Unauthorized" );
    }
    elsif ( $mode == AUTH_OPTIONAL ) {
        $auth = $app->get_auth_info
          or return 0;
    }

    ###l4p $logger->info('Authentication successful.');
    return 1;
}

sub auth_failure {
    my $app = shift;
    ###l4p $logger->info('Auth failure; sending WWW-Authenticate header...');
    $app->set_header( 'WWW-Authenticate', 'Basic realm="Messaging"' );
    $app->error( @_, 1 );
}

=head2

This is what a Twitter Error looks like in XML.

<?xml version="1.0" encoding="UTF-8"?>
<hash>
  <request>/direct_messages/destroy/456.xml</request>
  <error>No direct message with that ID found.</error>
</hash>

=cut

sub error {
    my $app = shift;
    return unless ref($app);

    my ( $code, $msg, $dont_send_body ) = @_;

    if ( $code && $msg ) {
        ###l4p $logger->info("Processing error $code with message: $msg");
        $app->response_code($code);
        $app->response_message($msg);
        $app->{_errstr} = $msg;
    }
    elsif ($code) {
        ###l4p $logger->info("Processing error $code");
        return $app->SUPER::error($code);
    }
    return undef if $dont_send_body;
    return {
        request => $app->path_info,
        error   => $msg,
    };
}

sub show_error {
    my $app = shift;
    my ($err) = @_;
    chomp( $err = encode_xml($err) );
    return <<ERR;
<error>$err</error>
ERR
}

=head2 search

URL:
http://search.twitter.com/search.format

Formats:
json, atom

HTTP Method:
GET

Requires Authentication (about authentication):
false

API rate limited (about rate limiting):
1 call per request

Parameters:

callback: Optional. Only available for JSON format. If supplied, the response
will use the JSONP format with a callback of the given name.

lang: Optional: Restricts tweets to the given language, given by an ISO 639-1
code.

locale: Optional. Specify the language of the query you are sending (only ja
is currently effective). This is intended for language-specific clients and
the default should work in the majority of cases.

rpp: Optional. The number of tweets to return per page, up to a max of 100.

page: Optional. The page number (starting at 1) to return, up to a max of
roughly 1500 results (based on rpp * page. Note: there are pagination limits.

since_id: Optional. Returns tweets with status ids greater than the given id.

geocode: Optional. Returns tweets by users located within a given radius of
the given latitude/longitude. The location is preferentially taking from the
Geotagging API, but will fall back to their Twitter profile. The parameter
value is specified by "latitide,longitude,radius", where radius units must be
specified as either "mi" (miles) or "km" (kilometers). Note that you cannot
use the near operator via the API to geocode arbitrary locations; however you
can use this geocode parameter to search near geocodes directly.

show_user: Optional. When true, prepends "<user>:" to the beginning of the
tweet. This is useful for readers that do not display Atom's author field. The
default is false.

JSON example (truncated):
  {"results":[
     {"text":"@twitterapi  http:\/\/tinyurl.com\/ctrefg",
     "to_user_id":396524,
     "to_user":"TwitterAPI",
     "from_user":"jkoum",
     "id":1478555574,
     "from_user_id":1833773,
     "iso_language_code":"nl",
     "source":"<a href="http:\/\/twitter.com\/">twitter<\/a>",
     "profile_image_url":"http:\/\/s3.amazonaws.com\/twitter_production\/profile_images\/118412707\/2522215727_a5f07da155_b_normal.jpg",
      "created_at":"Wed, 08 Apr 2009 19:22:10 +0000"},
     ... truncated ...],
     "since_id":0,
     "max_id":1480307926,
     "refresh_url":"?since_id=1480307926&q=%40twitterapi",
     "results_per_page":15,
     "next_page":"?page=2&max_id=1480307926&q=%40twitterapi",
     "completed_in":0.031704,
     "page":1,
     "query":"%40twitterapi"}
  }

=cut

sub search {

}

=head2 trends

Variants: trends/(current|daily|weekly)

=cut

sub trends {

}

1;
__END__
