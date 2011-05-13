# Messaging Overview

The Messaging plugin for Movable Type and Melody provides a way to have a
private Twitter-like messaging system. In fact, Messaging uses the Twitter API
as a programmatic interface!

This plugin includes a simple Dashboard Widget to allow MT users to access the
Messaging system by displaying a Public Timeline and allowing them to post
messages.

# Setup & Installation

The latest version of the plugin can be downloaded from the its
[Github repo](https://github.com/endevver/mt-plugin-messaging). [Packaged downloads](https://github.com/endevver/mt-plugin-messaging/downloads) are also available if you prefer.

Installation follows the [standard plugin installation](http://tinyurl.com/easy-plugin-install) procedures.

This .htaccess recipe is essential to this API working.

    RewriteEngine On
    SetEnvIfNoCase ^Authorization$ "(.+)" HTTP_AUTHORIZATION=$1

## Perl Test Suite

This plugin includes a Perl test suite that relies upon
[Net::Twitter](http://search.cpan.org/dist/Net-Twitter/lib/Net/Twitter.pod).
If you want to run the tests you'll need Net::Twitter and all of its
dependencies.

> ----
>
> **IMPORTANT:** The Net::Twitter perl module that this plugin relies
> on requires newer versions of certain perl modules than those bundled
> with MT:
>
> * LWP::UserAgent (part of the libwww-perl distribution)
> * HTTP::Headers (part of the HTTP-Message distribution)
>
> To resolve the conflict, you will need to do the following:
>
> 1. Install the following perl bundles if not already installed:
>     * [libwww-perl][libwww-perl] v6.00 or higher (preferably the latest)
>     * [HTTP-Message][HTTP-Message] (latest version)
> 2. Move the following files and directories (indicated by a trailing
>    slash) out of the `extlib` directory:
>     * LWP/
>     * LWP.pm
>     * HTTP/Headers/
>     * HTTP/Headers.pm
>     * HTTP/Message.pm
>     * HTTP/Request/
>     * HTTP/Request.pm
>     * HTTP/Response.pm
>     * HTTP/Status.pm
>
> ----

[libwww-perl]: http://search.cpan.org/dist/libwww-perl/
[HTTP-Message]: http://search.cpan.org/~gaas/HTTP-Message-6.02/


# Usage

## Simple

As noted in the overview, this plugin provides an interface to the basics of
Messaging: a Dashboard Widget to view of the public timeline and the ability
to post a message.

Add the Dashboard Widget by going to the blog Home and using the "Select a
Widget..." dropdown menu to add the "Messaging" widget.

System administrators also have access to an administrative interface where
they can toggle a Message between hidden and visible, as well as delete
Message. This is found in System Overview > Messages and System > Manage >
Messages.

## Advanced

Messaging implements the [Twitter API](http://apiwiki.twitter.com/w/page/22554679/Twitter-API-Documentation) as a programmatic interface -- meaning anybody can build an interface to Messaging! The API endpoint to connect to is:

    <mt:CGIPath>twitter.cgi

Messaging works with Basic authentication (not OAuth). The following Twitter
API methods have been implemented and tested in Messaging:

* statuses/public_timeline
* statuses/home_timeline
* statuses/friends_timeline
* statuses/user_timeline
* statuses/show
* statuses/update
* statuses/destroy
* account/verify_credentials
* help/test

The Dashboard Widget uses Ajax to access `statuses/public_timeline` and
`statuses/update` so if you want to use Ajax you can find those examples in
`addons/TwitterAPI.plugin/tmpl/dashboard_widget.mtml`. Also, the test suite
shows a working Perl implementation with Net::Twitter.

### Passwords

An MT author's password is *not* used to authenticate. The Movable Type-generated API password is used instead.

The API password is used instead because it provides greater security through restricted permissions: author's can post status updates with the API password, for example, but can not modify templates.

# Tags

Normally, you would likely want to use the API to access messages in real-time, to display the latest timeline, for example. However if you want to publish an archive or collate messages with blog entries, for example, using tags may be easier.

## Block Tags

Only one block tag is provided: `<mt:Messages>...</mt:Messages>`. This block has the meta loop variables available (`__first__`, `__last__`, `__odd__`, `__even__`, `__counter__`), and has several valid arguments:

* `id`: specify the ID of a message to grab only that message.
* `sort_by` valid options: `created_on`, `created_by`. Default: `created_on`
* `sort_order`: valid options: `descend`, `ascend`. Default: `descend`
* `limit`: an integer used to limit the number of results.
* `offset`: start the results "n" topics from the start of the list.

## Function Tags

Most of these function tags act just as you'd expect:

* MessageID: returns the ID of this message.
* MessageText: returns the text of the message.
* TopicAuthorID: returns the ID of the author associated with the message. 
  Feed this to an Authors block to access the author context.
* TopicDate: returns the date of the message. Use any of MT's date formatting 
  modifiers when publishing.

## Template Recipes

Display the 10 newest messages:

    <mt:Messages limit="10">
        <mt:If name="__first__">
            <h2>My awesome messages!</h2>
            <ul>
        </mt:If>
                <li id="message-<mt:MessageID>">
                    <div class="text">
                        <mt:MessageText>
                    </div>
                    <div class="author">
                        <mt:MessageAuthorID setvar="author_id">
                        <mt:Authors id="$author_id">
                            <mt:AuthorDisplayName>
                        </mt:Authors
                    </div>'
                    <div class="created">
                        <mt:MessageDate format="%d/%m/%Y">
                    </div>
                </li>
        <mt:If name="__last__">
            </ul>
        </mt:If>
    </mt:HotTopics>

# TODO

The Twitter API supports many other methods (and by extension features) that
have not been implemented in Messaging. Some of these methods have had their
implementation started (or even completed), but haven't been tested or
integrated with the rest of the capabilities of Messaging.

## Search API Methods

* search
* trends
* trends/current
* trends/daily
* trends/weekly 
 
## Timeline Methods

* statuses/mentions - 0%
* statuses/retweeted_by_me - 0%
* statuses/retweeted_to_me - 0%
* statuses/retweets_of_me - 0%
 
## Status Methods

* statuses/friends - 90%
* statuses/followers - 90%
* statuses/retweet - 0%
* statuses/retweets - 0%
 
## User Methods

* users/show - 100%
* users/search
 
## List Methods

* POST lists      (create)
* POST lists id  (update)
* GET lists        (index)
* GET list id      (show)
* DELETE list id (destroy)
* GET list statuses
* GET list memberships
* GET list subscriptions
 
## List Members Methods

* GET list members
* POST list members
* DELETE list members
* GET list members id
 
## List Subscribers Methods

* GET list subscribers
* POST list subscribers
* DELETE list subscribers
* GET list subscribers id
 
## Direct Message Methods

* direct_messages
* direct_messages/sent
* direct_messages/new
* direct_messages/destroy 
 
## Friendship Methods

* friendships/create - 100%
* friendships/destroy - 100%
* friendships/exists - 100%
* friendships/show - 100%
 
## Social Graph Methods - 0%

* friends/ids   
* followers/ids 
 
## Account Methods

* account/rate_limit_status
* account/end_session
* account/update_delivery_device 
* account/update_profile_colors 
* account/update_profile_image 
* account/update_profile_background_image
* account/update_profile 
 
## Favorite Methods

* favorites - 100%
* favorites/create - 100%  
* favorites/destroy - 100%
 
## Notification Methods

* notifications/follow 
* notifications/leave 
 
## Block Methods

* blocks/create  
* blocks/destroy
* blocks/exists
* blocks/blocking
* blocks/blocking/ids
 
## Spam Reporting Methods

* report_spam
 
## Saved Searches Methods

* saved_searches
* saved_searches/show
* saved_searches/create
* saved_searches/destroy
 
## OAuth Methods

* oauth/request_token
* oauth/authorize
* oauth/authenticate
* oauth/access_token


# License

This program is distributed under the terms of the GNU General Public License,
version 2.

# Copyright

Copyright 2011, [Endevver LLC](http://endevver.com). All rights reserved.
