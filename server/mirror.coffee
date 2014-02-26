ServiceConfiguration.configurations.insert
    service:    "google"
    clientId:   "636613077149-p1t1smf04h8ffmgqd9hp7funt55nh0rl.apps.googleusercontent.com"
    secret:     "Et4VxVYtqzMgqDtO2bfgoI4L"


findUserById = (userId) ->
    Meteor.users.findOne({_id: userId})


handleSubscriptionCallback = (params) ->
    user = findUserById(params.userToken)

    client = new mirror(user)

    console.log params

    item = client.getTimelineItem(params.itemId)

    console.log "item: ", item.data.text

Router.map () ->
    this.route 'serverFile', 
        where: 'server',    
        path: '/subscriptionCallback',

        action: () ->
            handleSubscriptionCallback(this.request.body)

mirror = (user) ->
    TIMELINE_API = "https://www.googleapis.com/mirror/v1/timeline"
    SUB_API = "https://www.googleapis.com/mirror/v1/subscriptions"
    
    SUB_CALLBACK_URL = "https://myglass.ngrok.com/subscriptionCallback"

    token = {}
    options = {}

    this.init = () ->
        token = user.services.google.accessToken    


    this.init()


    getHttpOptions = (data) ->
        options =
            headers:
                "Authorization": "Bearer " + token
        options["data"] = data if data?
        console.log options
        options
    
    postToAPI = (url, data) ->
        result = HTTP.call "POST", url, getHttpOptions(data)
        console.log result.statusCode
        result

    getFromAPI = (url, data) ->
        result = HTTP.call "GET", url, getHttpOptions(data)
        console.log result.statusCode
        result

    sendTimelineItem = (data) ->
        postToAPI(TIMELINE_API, data)

    getTimelineItem = (itemId) ->
        url = TIMELINE_API + "/#{itemId}"
        getFromAPI(url)

    subscribe = (data) ->
        postToAPI(SUB_API, data)  

    subscribeTimelineItems = () ->
        data =
            collection: "timeline"
            userToken: user._id
            operation: []
            callbackUrl: SUB_CALLBACK_URL

        postToAPI(SUB_API, data)  

    publicMethods =
        getTimelineItem: getTimelineItem

        sendTimelineItem: sendTimelineItem
        
        subscribeTimelineItems: subscribeTimelineItems


Meteor.methods
    initMirrorApi: (user) ->
        client = new mirror(user)

        data = 
            text: "o test"
            menuItems: [
                {
                    "action": "REPLY"
                }
            ]        

        client.sendTimelineItem(data)
                     

# TIMELINE_API = "https://www.googleapis.com/mirror/v1/timeline"
# SUB_API = "https://www.googleapis.com/mirror/v1/subscriptions"


# SUB_CALLBACK_URL = "https://myglass.ngrok.com/subscriptionCallback"


# ServiceConfiguration.configurations.insert
#     service:    "google"
#     clientId:   "636613077149-p1t1smf04h8ffmgqd9hp7funt55nh0rl.apps.googleusercontent.com"
#     secret:     "Et4VxVYtqzMgqDtO2bfgoI4L"


# getOptions = (token, data) ->
#     options =
#         headers:
#             "Authorization": "Bearer " + token
#     options["data"] = data if data?
#     options

    
 
# postToAPI = (url, options) ->
#     result = HTTP.call "POST", url, options
#     console.log result.statusCode
#     result

# getFromAPI = (url, options) ->
#     result = HTTP.call "GET", url, options
#     console.log result.statusCode
#     result
 
    
# sendTimelineItem = (user) ->  

#     token = user.services.google.accessToken

#     data = 
#         text: "Changed Text"
#         menuItems: [
#             {
#                 "action": "REPLY"
#             }
#         ]
        
#     options = getOptions(token, data)
#     postToAPI(TIMELINE_API, options)
           
     
 
# subscribeTimelineItemUpdate = (user) ->

#     token = user.services.google.accessToken
    
#     data =
#         collection: "timeline"
#         userToken: user._id
#         operation: []
#         callbackUrl: SUB_CALLBACK_URL
        
#     options = getOptions(token, data)
#     postToAPI(SUB_API, options)   

# findUserById = (id) ->
#     Meteor.users.findOne({_id: id})

# getTimelineItem = (user, itemId) ->
#     token = user.services.google.accessToken
#     options = getOptions(token)
#     url = TIMELINE_API + "/#{itemId}"
#     getFromAPI(TIMELINE_API + "/#{itemId}", options)

# handleSubscriptionCallback = (params) ->
#     user = findUserById(params.userToken)
#     item = getTimelineItem(user, params.itemId)
#     console.log "item: ", item.data.text


# Router.map () ->
#     this.route 'serverFile', 
#         where: 'server',    
#         path: '/subscriptionCallback',

#         action: () ->
#             handleSubscriptionCallback(this.request.body)
