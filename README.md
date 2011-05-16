# Messaging, for Melody and Movable Type #

The Messaging plugin provides an implementation of a Twitter-like messaging
system which allows an MT/Melody user to post and view status updates stored
locally in the MT/Melody database and perform other actions supported by
Twitter, such as following other users, sending direct messages, etc. Most
timeline views can also be published to the published blogs for the benefit of
site visitors who are not registered users.

***In essence, this plugin provides features which enable MT/Melody to act as
a standalone clone of Twitter.com in terms of the service's functionality.***

<!--
-----------------------------------------------------------------------------
-->

## FEATURES ##

* Enables MT/Melody users to post local status updates from the
  administrative interface via a Dashboard widget.

* Provides a number of public, private and user-specific timeline views of
  existing updates, also accessible from the dashboard widget

* Enables users to post and view status updates *using **any** third-party*
  *Twitter client* that supports alternate Twitter-API-compatible endpoint
  URLs

* Provides a set of template tags for outputting the timeline views
  of the status updates to the published site, if desired

### What it *doesn't* do ###

To clear up the inevitable confusion, the following is a list of things this
plugin **does not** do:

* Allow users to post status updates to Twitter.com
* Allow users to read status updates from Twitter.com
* Enable social actions (following, direct messages, etc) with Twitter.com
  users

<!--
-----------------------------------------------------------------------------
-->

## INSTALLATION ##

### Prerequisites ###

* [Melody Compatibility Layer][] (not required for Melody)

### Download ###

The latest version of the plugin can be downloaded from the its
[Github repo][]. [Packaged downloads][] are also available if you prefer.

After downloading and unpacking the distribution archive, follow the
directions in the [standard plugin installation][] tutorial.

### Apache Configuration ###

Next, for the API to operate properly, the following [SetEnvIfNoCase][]
directive is a **required** addition to the Apache config:

    SetEnvIfNoCase ^Authorization$ "(.+)" HTTP_AUTHORIZATION=$1

The line above can be included in any part of the Apache configuration that
governs access to (i.e. is evaluated and executed upon request of) the
Messaging API script (`msg.cgi`) though, if you are unsure, we would suggest
in either:

* **Apache server config** *(sudo or root access required)*

    If you have write access to your Apache configuration files, enclose the
    line above in a [Directory block][] targeting the script's parent
    directory (which is probably `MT_HOME`).

    If your site is running as a virtual host, the `Directory` block should be
    created or already exist within a [VirtualHost block][].

* **.htaccess file:**

    If you do not have the necessary permissions to edit your Apache server
    config files but they contain the minimum required [AllowOverride][]
    setting (`FileInfo`), you can add the line to a file named [.htaccess][]
    (that you will likely have to create) in the same directory as the script
    (which, again, is probably `MT_HOME`).

[Melody Compatibility Layer]:
   https://github.com/endevver/mt-plugin-melody-compat
[Github repo]:
   https://github.com/endevver/mt-plugin-messaging
[Packaged downloads]:
   https://github.com/endevver/mt-plugin-messaging/downloads
[standard plugin installation]: http://tinyurl.com/easy-plugin-install
[SetEnvIfNoCase]:
   http://httpd.apache.org/docs/current/mod/mod_setenvif.html#setenvifnocase
[Directory block]: http://httpd.apache.org/docs/2.2/mod/core.html#directory
[VirtualHost block]:
  http://httpd.apache.org/docs/2.2/mod/core.html#virtualhost
[AllowOverride]: http://httpd.apache.org/docs/2.2/mod/core.html#allowoverride
[.htaccess]: http://httpd.apache.org/docs/current/howto/htaccess.html

<!--
-----------------------------------------------------------------------------
-->

## CONFIGURATION ##

----

> **NOTE:**
> If you can access **`$CGIPATH/msg.cgi`** from your web browser, replacing
> `$CGIPATH` with the value of your installation's `mt-config.cgi` directive
> by the same name, **you can skip this entire section!**

----

This plugin provides a new **`MessagingScript`** configuration directive which
defaults to `msg.cgi` and informs the system how to access the Messaging API
script relative to the `CGIPath` URL.

If you've renamed the script to something other than `msg.cgi`, simply set
`MessagingScript` to the new script filename. For example, if you renamed it
to `message.cgi`, you would add:

    MessagingScript  message.cgi

Or, if you moved the script with its original name, down into the plugin
envelope, you would use:

    MessagingScript  addons/Messaging.plugin/msg.cgi

### Alternate API URL configuration ###

The plugin also supports an alternate method of defining the Messaging API URL
as a special accommodation for a wide myriad of niche cases and advanced
webserver configurations in which using `CGIPath` as the root of the API URL
is either undesirable or not possible.

In this case, you can set the **`MESSAGINGAPIURL`** environment variable to
the desired **fully-qualified URL** and this value will take precedence over
`MessagingScript` and will be used directly with no modifications.

Like the instructions in the **Apache Configuration** section above for
setting the `SetEnvIfNoCase` directive, this can be set by adding the
following like to either in the Apache server config or in
`$MT_HOME/.htaccess`:

    SetEnv MESSAGINGAPIURL http://example.com/path/to/messaging.fcgi

<!--
-----------------------------------------------------------------------------
-->

## USAGE ##

### Simple: The Messaging Dashboard Widget ###

As noted in the overview, this plugin provides an interface to the basics of
Messaging: a Dashboard Widget which gives the user a view of the [public
timeline][] and allows them to update it with their own messages.

The widget can be added to either the blog- or system-level dashboard. Simply
navigate to either page, select the "Messaging" widget from the "Select a
Widget..." dropdown menu.

[public timeline]: http://dev.twitter.com/doc/get/statuses/public_timeline

### Administrative: Message listing and moderation screen ###

System administrators also have access to a message listing screen through
which they can perform moderation duties, toggling a message's visibility or
deleting it outright.  This screen can be accessed via:

* **System Overview header nav dropdown &raquo; Messages**, or
* **System dashboard &raquo; Manage &raquo; Messages**

### Advanced: Third-party client access ###

The Messaging plugin's programmatic interface conforms to the [Twitter
API][].*[<sup>1</sup>]* which also enables a user to interface with the system
through **any third-party Twitter client** (e.g. the official Twitter client,
Tweetie, TweetDeck, etc) which supports alternate Twitter-compatible services.

The default API URL endpoint to use in supporting clients is very similar to
the main MT admin URL:

    <mt:CGIPath>/msg.cgi

Messaging works with Basic authentication (not OAuth). The following Twitter
API methods have been implemented and tested in Messaging:

* `statuses/public_timeline`
* `statuses/home_timeline`
* `statuses/friends_timeline`
* `statuses/user_timeline`
* `statuses/show`
* `statuses/update`
* `statuses/destroy`
* `account/verify_credentials`
* `help/test`

The Dashboard Widget uses Ajax to access `statuses/public_timeline` and
`statuses/update` so if you want to use Ajax you can find those examples in
`addons/TwitterAPI.plugin/tmpl/dashboard_widget.mtml`.

*[<sup>1</sup>] - Not all methods are fully supported yet. See **KNOWN ISSUES
AND LIMITATIONS** for details.*

[Twitter API]:
   http://apiwiki.twitter.com/w/page/22554679/Twitter-API-Documentation

#### Authenticating with the Messaging API ####

For security reasons, an MT author's password is *never* used to authenticate
with the Messaging API. Instead, the user's credentials are comprised of and
validated against their username and **[API password][]**.

The API Password is a special-use password automatically generated by the
application when a user is first created and intended only for use with
third-party web services and authoring tools such as blogging clients.

Use of the API password provides greater security because it causes the
application to establish a restricted session which provides no access to the
administrative interface and only a small subset of the functionality normally
available to a user but that which is completely sufficient for executing a
complete authoring-specific workflow.

The API Password can be found, retrieved and reset, if desired, **on the
user's profile page**.

[API password]:
  http://www.sixapart.com/movabletype/beta/2005/07/xml-rpc_and_ato.html

<!--
-----------------------------------------------------------------------------
-->

## TEMPLATE TAGS ##

The most common mechanism for status retrieval will undoubtedly be repeated
polling through the Messaging API because it allows you to retrieve and
display the latest update messages in real-time, as quickly as you can connect
and retrieve them.

However if you want to do something like publish an message archive or collate
messages and blog entries for interleaved display using the template tags
provided by the plugin may be easier.

### Block Tags ###

Only one block tag is provided: `<mt:Messages>...</mt:Messages>`. This block
has the meta loop variables available (`__first__`, `__last__`, `__odd__`,
`__even__`, `__counter__`), and has several valid arguments:

* `id`   
  Specify the ID of a message to grab only that message.

* `sort_by`   
  Valid options: `created_on`, `created_by`   
  Default: `created_on`

* `sort_order`   
  Valid options: `descend`, `ascend`   
  Default: `descend`

* `limit`  
  An integer used to limit the number of results.

* `offset`  
  Start the results "n" topics from the start of the list.

### Function Tags ###

Most of these function tags act just as you'd expect:

* `MessageID`   
  Returns the ID of this message.

* `MessageText`   
  Returns the text of the message.

* `TopicAuthorID`   
  Returns the ID of the author associated with the message.
  Feed this to an Authors block to access the author context.

* `TopicDate`   
  Returns the date of the message. Use any of MT's date
  formatting modifiers when publishing.

### Template Recipes ###

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

<!--
-----------------------------------------------------------------------------
-->

## KNOWN ISSUES AND LIMITATIONS ##

The Twitter API supports many other methods (and by extension features) that
have not been implemented in Messaging. Some of these methods have had their
implementation started (or even completed), but haven't been tested or
integrated with the rest of the capabilities of Messaging.

### Search API Methods ###

* `search`
* `trends`
* `trends/current`
* `trends/daily`
* `trends/weekly`

### Timeline Methods ###

* `statuses/mentions` - 0%
* `statuses/retweeted_by_me` - 0%
* `statuses/retweeted_to_me` - 0%
* `statuses/retweets_of_me` - 0%

### Status Methods ###

* `statuses/friends` - 90%
* `statuses/followers` - 90%
* `statuses/retweet` - 0%
* `statuses/retweets` - 0%

### User Methods ###

* `users/show` - 100%
* `users/search`

### List Methods ###

* `POST lists`      (create)
* `POST lists id`  (update)
* `GET lists`        (index)
* `GET list id`      (show)
* `DELETE list id` (destroy)
* `GET list statuses`
* `GET list memberships`
* `GET list subscriptions`

### List Members Methods ###

* `GET list members`
* `POST list members`
* `DELETE list members`
* `GET list members id`

### List Subscribers Methods ###

* `GET list subscribers`
* `POST list subscribers`
* `DELETE list subscribers`
* `GET list subscribers id`

### Direct Message Methods ###

* `direct_messages`
* `direct_messages/sent`
* `direct_messages/new`
* `direct_messages/destroy`

### Friendship Methods ###

* `friendships/create` - 100%
* `friendships/destroy` - 100%
* `friendships/exists` - 100%
* `friendships/show` - 100%

### Social Graph Methods - 0% ###

* `friends/ids`
* `followers/ids`

### Account Methods ###

* `account/rate_limit_status`
* `account/end_session`
* `account/update_delivery_device`
* `account/update_profile_colors`
* `account/update_profile_image`
* `account/update_profile_background_image`
* `account/update_profile`

### Favorite Methods ###

* `favorites` - 100%
* `favorites/create` - 100%
* `favorites/destroy` - 100%

### Notification Methods ###

* `notifications/follow`
* `notifications/leave`

### Block Methods ###

* `blocks/create`
* `blocks/destroy`
* `blocks/exists`
* `blocks/blocking`
* `blocks/blocking/ids`

### Spam Reporting Methods ###

* `report_spam`

### Saved Searches Methods ###

* `saved_searches`
* `saved_searches/show`
* `saved_searches/create`
* `saved_searches/destroy`

### OAuth Methods ###

* `oauth/request_token`
* `oauth/authorize`
* `oauth/authenticate`
* `oauth/access_token`

<!--
-----------------------------------------------------------------------------
-->

## SUPPORT, BUGS AND FEATURE REQUESTS ##

Please see <http://help.endevver.com/> for all of the above.

<!--
-----------------------------------------------------------------------------
-->

## LICENSE ##

This program is distributed under the terms of the GNU General Public License,
version 2.

<!--
-----------------------------------------------------------------------------
-->

## COPYRIGHT ##

Copyright 2011, [Endevver LLC](http://endevver.com). All rights reserved.

