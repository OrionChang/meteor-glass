
@Global = 

    getConfig: () ->
        ServiceConfiguration.configurations.findOne service: "google"

    findUserById: (userId) ->
        Meteor.users.findOne({_id: userId})




    
handleSubscriptionCallback = (params) ->

    user = Global.findUserById(params.userToken)

    client = new Mirror(user)

    # console.log params

    client.getTimelineItem(params.itemId)
    # console.log "item: ", item.data.text


Router.map () ->
    this.route 'serverFile', 
        where: 'server',    
        path: '/subscriptionCallback',

        action: () ->
            handleSubscriptionCallback(this.request.body)

@Mirror = (user) ->
    TIMELINE_API = "https://www.googleapis.com/mirror/v1/timeline"
    SUB_API = "https://www.googleapis.com/mirror/v1/subscriptions"
    REFRESH_TOKEN_API = "https://accounts.google.com/o/oauth2/token"
    REVOKE_TOKEN_API = "https://accounts.google.com/o/oauth2/revoke"


    SUB_CALLBACK_URL = "https://myglass.ngrok.com/subscriptionCallback"

    token = {}
    options = {}

    this.init = () ->
        user = Global.findUserById(user._id)
        token = user.services.google.accessToken    


    this.init()


    getHeaders = (data) ->
        options =
            headers:
                "Authorization": "Bearer " + token
        options["data"] = data if data?
        # console.log options
        options
    
    postToAPI = (url, data) ->
        result = handleResult(HTTP.call("POST", url, getHeaders(data)), "postFromAPI", true)
        if result then result else false

    getFromAPI = (url, data) ->
        result = handleResult(HTTP.call("GET", url, getHeaders(data)), "getFromAPI", true)
        if result then result else false

    postToAPIWithParams = (url, params) ->
        options = params: params
        result = handleResult(HTTP.call("POST", url, options), "postToAPIWithParams", true)
        if result then result else false

    getFromAPIWithParams = (url, params) ->
        options = params: params
        result = handleResult(HTTP.call("GET", url, options), "getFromAPIWithParams", true)
        if result then result else false

    updateUserTokenInDB = (data) ->
        token = data.access_token
        now = new Date
        expiresAt = now.setSeconds(now.getSeconds() + data.expires_in)
        selector =
            _id: user._id
        modifier = 
            $set: 
                "services.google.accessToken": token
                "services.google.expiresAt": expiresAt
                "services.google.id_token": data.id_token
        Meteor.users.update(selector, modifier)


    revokeTokenInDB = () ->
        selector =
            _id: user._id

        modifier = 
            $set: 
                "services.google.is_revoked": true
        Meteor.users.update(selector, modifier)
        # TODO Change it to false

    revokeToken = () ->
        result = handleResult(getFromAPIWithParams(REVOKE_TOKEN_API, token: token), "revokeToken")
        if result
            revokeTokenInDB()
            throw new Meteor.Error(500, "user is revoked")
        # console.log result
        

    refreshToken = () ->
        # console.log Global.findUserById(user._id).services.google

        refreshToken = Global.findUserById(user._id).services.google.refreshToken

        unless refreshToken
            revokeToken() 
            return

        config = Global.getConfig()

        params = 
            refresh_token: refreshToken
            client_id: config.clientId
            client_secret: config.secret
            grant_type: "refresh_token"

        result = handleResult(postToAPIWithParams(REFRESH_TOKEN_API, params), "refreshToken")

        updateUserTokenInDB(result.data) if result
        

    checkToken = () ->
        expiresDate = new Date user.services.google.expiresAt
        now = new Date
        if expiresDate > now
            # valid
            console.log "Yeah --- checkToken"    
        else
            # expired
            console.log "Error --- checkToken"
            refreshToken()
   
    



    addItemIntoDB = (item) ->
        item = _.extend item, 
            # item_type: item_type
            user_id: user._id

        TimelineItems.insert item

    # getTimelineItemAndAddIntoDB = (itemId) ->

    #     item = getTimelineItem(itemId)

    #     addItemIntoDB item

         
    handleResult = (result, from, hidden) ->
        if result.statusCode isnt 200
            console.log "Error --- ", from unless hidden
            throw new Meteor.Error result.statusCode, "Error: " + from, result
            return false
        else
            console.log "Yeah --- ", from unless hidden
        result


    # ==================================================================
    # Public Methods
    # ==================================================================

    sendTimelineItem = (data) ->
        checkToken()
        result = handleResult(postToAPI(TIMELINE_API, data), "sendTimelineItem")
        
        addItemIntoDB result.data if result
             

    getTimelineItem = (itemId) ->
        checkToken()
        result = handleResult(getFromAPI(TIMELINE_API + "/#{itemId}"), "getTimelineItem")
        
        addItemIntoDB result.data if result

    subscribe = (data) ->
        checkToken()
        postToAPI(SUB_API, data)  

    subscribeTimelineItems = () ->
        checkToken()
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

        test: revokeToken









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

# Global.findUserById = (id) ->
#     Meteor.users.findOne({_id: id})

# getTimelineItem = (user, itemId) ->
#     token = user.services.google.accessToken
#     options = getOptions(token)
#     url = TIMELINE_API + "/#{itemId}"
#     getFromAPI(TIMELINE_API + "/#{itemId}", options)

# handleSubscriptionCallback = (params) ->
#     user = Global.findUserById(params.userToken)
#     item = getTimelineItem(user, params.itemId)
#     console.log "item: ", item.data.text


# Router.map () ->
#     this.route 'serverFile', 
#         where: 'server',    
#         path: '/subscriptionCallback',

#         action: () ->
#             handleSubscriptionCallback(this.request.body)
