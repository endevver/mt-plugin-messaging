jQuery(document).ready(function($) {
    // Run when the page loads!
    update_public_timeline();

    // And when clicked!
    $('#update-public-timeline').click(function(){
        update_public_timeline();
    });

    // When a status message is typed in, provide a character countdown.
    $('input#message-text').keyup(function(){
        var num = 140 - $('input#message-text').val().length;
        $('#message-text-counter').text(num);

        if (num == -1) {
            alert('A maximum of 140 characters is allowed.');
        }
    });

    // Post a status message.
    $('button#post-message').click(function(){
        if ( $('input#message-text').val() == '' ) {
            alert('Enter a message before posting.');
            return false;
        }

        $('button#post-message').addClass('disabled-button');
        $('#message-post-spinner').show();
        $('#message-text-counter').parent().hide();
        $('button#post-message').attr('disabled','disabled');
        
        var msg = $('input#message-text').val();
        $.ajax({
            type: 'POST',
            url: messagingAPIURL + '/statuses/update.json',
            dataType: 'json',
            data: 'is_widget=1&status=' + msg,
            headers: { 'Authorization': 'basic ' + basicAuthToken },
            success: status_response,
            error: status_response_error
        });
        return false;
    });
});

function status_response_error(jqXHR,textStatus,error) {
    alert('Post failed! ' + error);
    jQuery('#message-post-spinner').hide();
    jQuery('#message-text-counter').parent().show();
    jQuery('button#post-message')
      .removeClass('disabled-button')
      .removeAttr('disabled');
}

function status_response(data,textStatusjqXHR) {
    update_public_timeline();
    jQuery('input#message-text').val('');
    jQuery('#message-post-spinner').hide();
    jQuery('#message-text-counter')
      .html('140')
      .parent()
      .show();
    jQuery('button#post-message')
      .removeClass('disabled-button')
      .removeAttr('disabled');
}

function update_public_timeline() {
    jQuery('#update-public-timeline').hide();
    jQuery('#messaging-public-timeline li').hide()
    jQuery('#updating-public-timeline').show();
    jQuery.ajax({
        type: 'POST',
        url: messagingAPIURL + '/statuses/public_timeline.json',
        success: parse_public_timeline
    });
    jQuery('#updating-public-timeline').hide();
    jQuery('#messaging-public-timeline li').show('slow')
    jQuery('#update-public-timeline').show('slow');
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

        var rowclass;
        if (i % 2)
            rowclass = 'odd';
        else
            rowclass = 'even';

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
