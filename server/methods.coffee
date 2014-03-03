Meteor.methods
    initMirrorApi: (user) ->


        client = new Mirror(user)

        data = 
            text: "aiya"
            menuItems: [
                {
                    "action": "REPLY"
                }
            ]        

        client.sendTimelineItem(data)

        client.subscribeTimelineItems()
        
        # client.test()


    sendItemToTimeline: (user, text) ->

        console.log text
        client = new Mirror(user)

        data = 
            text: text
            menuItems: [
                {
                    "action": "REPLY"
                }
            ]        

        client.sendTimelineItem(data)

        client.subscribeTimelineItems()