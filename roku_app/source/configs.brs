'Dropbox: BWrWm8D9nLAAAAAAAAAAH5-cmEO8kEZzoKqUjUAwdZhdeqVEbINYZmuRvLVaq9a1
'tomato: ukr3gctwb7nyz2e764jtggzn

Function Config() As Object
    cfg = CreateObject("roAssociativeArray")
    BASE_URL = "http://radiant-wildwood-9013.herokuapp.com"

    cfg.LOCAL_API = CreateObject("roAssociativeArray")
    cfg.LOCAL_API.getPopular = BASE_URL + "/youtube/popular"
    cfg.LOCAL_API.getRecent = BASE_URL + "/youtube/recent"
    cfg.LOCAL_API.getVideo = BASE_URL + "/youtube/video/"

    cfg.NEXT_PAGE_LOAD = 20;

    cfg.CERT = "common:/certs/ca-bundle.crt"
    cfg.ROKU_HEADER = "X-Roku-Reserved-Dev-Id"

    return cfg
End Function