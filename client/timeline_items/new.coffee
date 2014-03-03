Template.newTimelineItem.helpers






Template.newTimelineItem.events
    "click #newTimelineItem-submit": (e) ->
    	e.preventDefault()

    	text = $("#newTimelineItem-text").val()

    	Meteor.call "sendItemToTimeline", Meteor.user(), text, (err, res) ->
    		if err
    			console.log err
    		else
				$("#newTimelineItem-text").val()    			
    	
    		
        # Meteor.call "initMirrorApi", Meteor.user(), (err, res) ->
        #     console.log err, " and ", res
        #     if err
        #         if err.message is "user is revoked [500]"
        #             Meteor.logout()
