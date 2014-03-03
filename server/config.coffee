if ServiceConfiguration.configurations.find(service: "google").count() != 0
    ServiceConfiguration.configurations.remove(service: "google")
    ServiceConfiguration.configurations.insert
        service:    "google"
        clientId:   "636613077149-p1t1smf04h8ffmgqd9hp7funt55nh0rl.apps.googleusercontent.com"
        secret:     "Et4VxVYtqzMgqDtO2bfgoI4L"
