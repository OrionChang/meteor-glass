if ServiceConfiguration.configurations.find(service: "google").count() != 0
    ServiceConfiguration.configurations.remove(service: "google")
    ServiceConfiguration.configurations.insert
        service:    "google"
        clientId:   "636613077149-p1t1smf04h8ffmgqd9hp7funt55nh0rl.apps.googleusercontent.com"
        secret:     "Et4VxVYtqzMgqDtO2bfgoI4L"


getConfig = () ->
    ServiceConfiguration.configurations.findOne service: "google"

findUserById = (userId) ->
    Meteor.users.findOne({_id: userId})


handleSubscriptionCallback = (params) ->
    user = findUserById(params.userToken)

    client = new mirror(user)

    # console.log params

    item = client.getTimelineItem(params.itemId)

    # console.log "item: ", item.data.text

Router.map () ->
    this.route 'serverFile', 
        where: 'server',    
        path: '/subscriptionCallback',

        action: () ->
            handleSubscriptionCallback(this.request.body)

mirror = (user) ->
    TIMELINE_API = "https://www.googleapis.com/mirror/v1/timeline"
    SUB_API = "https://www.googleapis.com/mirror/v1/subscriptions"
    REFRESH_TOKEN_API = "https://accounts.google.com/o/oauth2/token"
    REVOKE_TOKEN_API = "https://accounts.google.com/o/oauth2/revoke"


    SUB_CALLBACK_URL = "https://myglass.ngrok.com/subscriptionCallback"

    token = {}
    options = {}

    this.init = () ->
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
        result = HTTP.call "POST", url, getHeaders(data)
        if result.statusCode isnt 200
            console.log "postToAPI --- fail"
        result

    postToAPIWithParams = (url, params) ->
        options = params: params

        result = HTTP.call "POST", url, options

        if result.statusCode isnt 200
            console.log "postToAPIWithParams --- fail"
        result

    getFromAPIWithParams = (url, params) ->
        options = params: params

        result = HTTP.call "GET", url, options

        if result.statusCode isnt 200
            console.log "getFromAPIWithParams --- fail"
        result

    getFromAPI = (url, data) ->
        result = HTTP.call "GET", url, getHeaders(data)
        if result.statusCode isnt 200
            console.log "getFromAPI --- fail"
        result

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
        result = getFromAPIWithParams REVOKE_TOKEN_API, token: token
        if result.statusCode isnt 200
            console.log "revoke token --- fail"
        else
            revokeTokenInDB()
            throw new Meteor.Error(500, "user is revoked")
        # console.log result
        

    refreshToken = () ->
        # console.log findUserById(user._id).services.google

        refreshToken = findUserById(user._id).services.google.refreshToken

        unless refreshToken
            revokeToken() 
            return

        config = getConfig()

        params = 
            refresh_token: refreshToken
            client_id: config.clientId
            client_secret: config.secret
            grant_type: "refresh_token"

        result = postToAPIWithParams REFRESH_TOKEN_API, params

        if result.statusCode isnt 200
            console.log "refresh token --- fail"
        else
            # console.log result

            # console.log findUserById(user._id).services.google

            # console.log "===================================="
            updateUserTokenInDB(result.data)

            # console.log findUserById(user._id).services.google


    checkToken = () ->
        expiresDate = new Date user.services.google.expiresAt
        now = new Date
        if expiresDate > now
            # valid
            console.log "check token --- valid"    
        else
            # expired
            console.log "check token --- refresh token"
            refreshToken()
        
        

    # Public
    sendTimelineItem = (data) ->
        checkToken()
        postToAPI(TIMELINE_API, data)

    getTimelineItem = (itemId) ->
        checkToken()
        url = TIMELINE_API + "/#{itemId}"
        getFromAPI(url)

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


Meteor.methods
    initMirrorApi: (user) ->


        client = new mirror(user)

        # data = 
        #     text: "o test"
        #     menuItems: [
        #         {
        #             "action": "REPLY"
        #         }
        #     ]        

        # client.sendTimelineItem(data)
        
        client.test()









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
