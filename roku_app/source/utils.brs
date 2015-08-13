Function Util() As Object
    m.cfg = Config()

    m.nextPage = ""
    m.prevPage = ""

    m.getPopularVideos =  Function(nextPage = invalid) As Object
        req = CreateObject("roUrlTransfer")
        if nextPage <> invalid then
            req.setUrl(m.cfg.LOCAL_API.getPopular + "/" + m.nextPage
        else
            req.setUrl(m.cfg.LOCAL_API.getPopular)
        end if
        res = req.GetToString()
        return ParseJSON(res)
    End Function

    m.getAsyncPopularVideos =  Function(nextPage = invalid) As Object
            req = CreateObject("roUrlTransfer")
            port = CreateObject("roMessagePort")
            req.SetMessagePort(port)
            if nextPage <> invalid then
                req.setUrl(m.cfg.LOCAL_API.getPopular + "/" + m.nextPage
            else
                req.setUrl(m.cfg.LOCAL_API.getPopular)
            end if

             if (req.AsyncGetToString())
                    while (true)
                        msg = wait(0, port)
                        if (type(msg) = "roUrlEvent")
                            code = msg.GetResponseCode()
                            if (code = 200)
                                json = ParseJSON(msg.GetString())
                                m.nextPage = json.info.nextPageToken
                                m.prevPage = json.info.prevPageToken
                                return json.list
                            endif
                        else if (event = invalid)
                            request.AsyncCancel()
                        endif
                    end while
                endif
                return invalid





            res = req.AsyncGetToString()
            return ParseJSON(res)
        End Function

    m.getVideoById = Function(id As String) As String
        req = CreateObject("roUrlTransfer")
        req.setUrl(m.cfg.LOCAL_API.getVideo + id)
        return req.GetToString()
    End Function

    m.getHttpsRequest = Function (url As String) As Object
        req = CreateObject("roUrlTransfer")
        req.SetCertificatesFile(m.cfg.CERT)
        req.AddHeader(m.cfg.ROKU_HEADER, "")
        req.InitClientCertificates()
        req.SetUrl(url)
        return req
    End Function

    return m
End Function