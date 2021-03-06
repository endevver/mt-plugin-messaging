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

* Movable Type 4.x or 5.1+

### Download ###

The latest version of the plugin can be downloaded from the its
[Github repo][]. [Tagged downloads][] are also available if you prefer.

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

[Github repo]:
   https://github.com/endevver/mt-plugin-messaging
[Tagged downloads]:
   https://github.com/endevver/mt-plugin-messaging/tags
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

### Time Zones ###

You may notice that your Messages have a time stamp several hours off from what you expect.

Melody and Movable Type always save content with the date-time stamp set to GMT, then applies a time zone shift based upon your blog settings (the Timezone option in Preferences > General). Messaging is a system-level tool that doesn't know about your blog timezone preference. You can make Melody and Movable Type aware of your preference with the [`TimeOffset` Configuration Directive][]. Example:

    TimeOffset -4

[`TimeOffset` Configuration Directive]: http://www.movabletype.org/documentation/appendices/config-directives/timeoffset.html

### Republish a Template after Message Submission ###

If you're using the Messaging template tags, you may want to force an index
template to republish when a new Message is received. In the blog where your
template can be found, visit Tools > Plugins and find the Messaging plugin.
Within the plugin's Settings you can find the option to republish a template.
Select the index template to republish and save.

The selected template will be published (in the background) whenever a new
Message is received.

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
* `search`

The Dashboard Widget uses Ajax to access `statuses/public_timeline` and
`statuses/update` so if you want to use Ajax you can find those examples in
`addons/TwitterAPI.plugin/tmpl/dashboard_widget.mtml`.

*[<sup>1</sup>] - Not all methods are fully supported yet. See **KNOWN ISSUES
AND LIMITATIONS** for details.*

[Twitter API]:
   http://dev.twitter.com/doc

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


### Behind the Scenes ###

The Messaging plugin allows for long and short status messages: if you use the
Dashboard Widget you'll see a 140-character counter. However, this limit is
only enforced by Javascript: the `mt_tw_message.tw_message_text` field is a
"mediumtext" field, meaning it is limited to about 16 million characters.

Hashtags (example: #messaging) included in a message are abstracted out of the
message and converted into Tags. "Private" hashtags are also supported
(example: #@privatemessaging).

### Searching ###

The Messaging plugin includes a search feature, just as the Twitter API does.
Refer to the Twitter API documentation to use the search feature; below is
some implementation information discovered during use that may not be clear
from the Twitter docs.

use the required `q` parameter to make keyword and hashtag searches. The `rpp`
and `page` ("limit" and "offset" in MT parlance) are also implemented for
keyword searches. Additional valid parameters: `since_id`, `max_id`.

Search results contain the following keys: `results`, `page`, `max_id`,
`next_page`, `query`, `refresh_url`, `since_id`, `results_per_page`.

* `max_id` is set to the highest ID in of the messages shown in the current
  results set if no `max_id` parameter was supplied in the query. This means
  that if you do something like `q=foobar&page=2`, you will get the highest ID
  on page 2, not the highest ID from the (invisible) page 1.

* If `max_id` is set in the query string, the `max_id` in the result set will
  match with it, even if the message with that actual ID is not visible on the
  current page. Example: `q=foobar&page=2&max_id=30` will show items from 15
  on down, as item 30 is on page 1.

* The `next_page` parameter always contains the `max_id` string, to guarantee
  a continuous list, even if new messages are inserted in the stream between
  queries.

* Note that if you keep going for "next page" url the `max_id` always remains
  the same, since the 'next page' URL contains a `max_id` parameter.

* The `refresh_url` parameter will put you at the most recent message in the
  stream matching the query, but results are guaranteed to be more recent than
  the `since_id` specified. Note that you may have to query page=2, page=3...
  and so on to get all the messages, until no more messages are returned. Also
  note that each of these pages will have its own `refresh_url` with a
  different `since_id`, and that you shouldn't "follow" them like the
  `next_page` URL if you are attempting to pull in a list of updates more
  recent than a specific `since_id`. To do that you have to stick with the
  same `since_id` and keep incrementing the page number until you run out of
  results.

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

To publish any detail about a Message use the block tag
`<mt:Messages>...</mt:Messages>`. This block has the meta loop variables
available (`__first__`, `__last__`, `__odd__`, `__even__`, `__counter__`), and
has several valid arguments:

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

If a message contains hashtags, they can be published as tags using the
`<mt:MessageTags>...</mt:MessageTags>` block tag. Within this block the
familiar Tag function tags can be used: `<mt:TagName>`, `<mt:TagID>`, etc.
Valid arguments for this block tag are:

* `glue`
  A text string that is used to join each of the items together.

* `include_private`
  Set to "1" to include both public and private (#@example) tags.


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
    </mt:Messages>

<!--
-----------------------------------------------------------------------------
-->

## KNOWN ISSUES AND LIMITATIONS ##

The Twitter API supports many other methods (and by extension features) that
have not been implemented in Messaging. Some of these methods have had their
implementation started (or even completed), but haven't been tested or
integrated with the rest of the capabilities of Messaging.

### Search API Methods ###

* `search` - Implemented according to the notes above.
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

