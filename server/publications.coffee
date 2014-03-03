
Meteor.publish 'timeline_items', (userId) ->
    TimelineItems.find(user_id: userId)