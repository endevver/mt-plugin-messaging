jQuery(document).ready(function() {
    // Run when the page loads!
    update();

    // And when clicked!
    jQuery('#update-public-timeline').click(function(){
        update();
    });

    // When a status message is typed in, provide a character countdown.
    jQuery('input#message-text').keyup(function(){
        var num = 140 - jQuery('input#message-text').val().length;
        jQuery('#message-text-counter').text(num);

        if (num == -1) {
            alert('A maximum of 140 characters is allowed.');
        }
    });

    // Post a status message.
    jQuery('button#post-message').click(function(){
        if ( jQuery('input#message-text').val() == '' ) {
            alert('Enter a message before posting.');
            return false;
        }

        jQuery('button#post-message').addClass('disabled-button');
        jQuery('#message-post-spinner').show();
        jQuery('#message-text-counter').parent().hide();
        jQuery('button#post-message').attr('disabled','disabled');
        
        var msg = jQuery('input#message-text').val();
        jQuery.ajax({
            type: 'POST',
            url: messagingAPIURL + '/statuses/update.json',
            dataType: 'json',
            data: "status=" + msg,
            headers: { 'Authorization': 'basic ' + basicAuthToken },
            success: status_response,
            error: status_response_error
        });
    });
});

function status_response_error(jqXHR,textStatus,error) {
    alert('Post failed! ' + error);
    jQuery('#message-post-spinner').hide();
    jQuery('#message-text-counter').parent().show();
    jQuery('button#post-message').removeClass('disabled-button');
    jQuery('button#post-message').removeAttr('disabled');
}

function status_response(data,textStatusjqXHR) {
    update();
    jQuery('input#message-text').val('');
    jQuery('#message-post-spinner').hide();
    jQuery('#message-text-counter').html('140');
    jQuery('#message-text-counter').parent().show();
    jQuery('button#post-message').removeClass('disabled-button');
    jQuery('button#post-message').removeAttr('disabled');
}

function update() {
    jQuery.ajax({
        type: 'POST',
        url: messagingAPIURL + '/statuses/public_timeline.json',
        success: parse_public_timeline
    });
}
function parse_public_timeline(data,textStatus,jqXHR) {
    // Convert the returned data into a JSON object
    //var json = eval('(' + data + ')');
    var json = eval( data );

    // Clear existing messages. This could be smarter and include only new 
    //messages, like twitter, but this just keeps it simple.
    jQuery('ul#messaging-public-timeline').html('');

    for (var i=0; i<json.statuses.status.length; i++) {
        var status = json.statuses.status[i];

        if (i % 2)
            var rowclass = 'odd';
        else
            var rowclass = 'even';

        jQuery('ul#messaging-public-timeline')
            .append(
                jQuery('<li class="message ' + rowclass + '"></li>').html(
                    '<div class="text">' + status.text + '</div>'
                    + '<div class="author">' + status.user.name + '</div>'
                    + '<div class="created">' + status.created_at + '</div>'
                )
            );
    }
}
