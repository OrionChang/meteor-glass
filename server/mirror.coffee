TIMELINE_API = "https://www.googleapis.com/mirror/v1/timeline"
SUB_API = "https://www.googleapis.com/mirror/v1/subscriptions"


Accounts.loginServiceConfiguration.insert
  service:    "google"
  clientId:   "636613077149-p1t1smf04h8ffmgqd9hp7funt55nh0rl.apps.googleusercontent.com"
  secret:     "Et4VxVYtqzMgqDtO2bfgoI4L"


getOptions = (token, data) ->
    options =
        data: data
        headers:
            "Authorization": "Bearer " + token
        
 
postToAPI = (url, options) ->
    result = HTTP.call "POST", url, options
    console.log result.statusCode
 
    
sendTimelineItem = (token) ->  
    data = 
        text: "Changed Text"
        menuItems: [
            {
                "action": "REPLY"
            }
        ]
        
    options = getOptions(token, data)
    postToAPI(TIMELINE_API, options)
           
     
 
subscribeTimelineItemUpdate = (token) ->
    
    data =
        collection: "timeline"
        userToken: "33332211"
        operation: []
        callbackUrl: "https://myglass.ngrok.com/subscriptionCallback"
        
    options = getOptions(token, data)
    postToAPI(SUB_API, options)   
    
    
    
Meteor.methods
    initMirrorApi: (user) ->
        
        token = user.services.google.accessToken
        
        sendTimelineItem(token)
        
        subscribeTimelineItemUpdate(token)
                     
        
        
Router.map () ->


    this.route 'serverFile', 
        where: 'server',    
        path: '/subscriptionCallback',

        action: () ->
            console.log "what!!!!!"
            console.log(this.request.body.itemId)
