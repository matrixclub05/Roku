'********************************************************************
'**  Video Player Example Application - Main
'**  November 2009
'**  Copyright (c) 2009 Roku Inc. All Rights Reserved.
'********************************************************************

Sub Main()
    initTheme()
    cfg = Config()
    port = CreateObject("roMessagePort")
    grid = CreateObject("roGridScreen")
    grid.SetMessagePort(port)
    list = Util().getAsyncPopularVideos()
    grid.SetDisplayMode("scale-to-fit")
    grid.SetupLists(2)
    grid.SetListName(0, "Popular")
    grid.SetListName(1, "Recent")
    grid.SetContentList(0, list)
    grid.SetContentList(1, list)
    grid.Show()
     while true
         msg = wait(0, port)
         if type(msg) = "roGridScreenEvent" then
             if msg.isScreenClosed() then
                 exit while
             else if msg.isListItemFocused()
                 print "Focused msg: ";msg.GetMessage();"row: ";msg.GetIndex();
                 print " col: ";msg.GetData()
                 if msg.GetIndex() > cfg.NEXT_PAGE_LOAD then
                    nextList = Util().getAsyncPopularVideos(Util().nextPage)
                    grid.setContentList(0, nextList)
                 end if
             else if msg.isListItemSelected()
                 print "Selected msg: ";msg.GetMessage();"row: ";msg.GetIndex();
                 print " col: ";msg.GetData()
                   date = CreateObject("roDateTime")
                   itemMpeg4 = {
                       id: list[msg.GetData()].id
                       ContentType:"episode"
                       SDPosterUrl: list[msg.GetData()].SDPosterUrl
                       HDPosterUrl: list[msg.GetData()].HDPosterUrl
                       IsHD:False
                       HDBranded:False
                       ShortDescriptionLine1:"Dan Gilbert asks, Why are we happy?"
                       ShortDescriptionLine2:""
                       Description: list[msg.GetData()].Description
                       Rating:"NR"
                       StarRating:"80"
                       Length:1280
                       Categories:["Technology","Talk"]
                       Title: list[msg.GetData()].Title
                       ReleaseDate: date.AsDateString("long-date")
                       VideoUrl: list[msg.GetData()].videoUrl
                 }
                
                 showSpringBoatScreen(itemMpeg4)
                 
             endif
         endif
     end while

End Sub

Function showSpringBoatScreen(dataItem as Object)  As Boolean
    port = CreateObject("roMessagePort")
    screen = CreateObject("roSpringboardScreen")

    print "showSpringboardScreen started"
    
    screen.SetMessagePort(port)
    screen.AllowUpdates(false)
    
    if dataItem <> invalid and type(dataItem) = "roAssociativeArray"
        screen.SetContent(dataItem)
    end if

    screen.SetDescriptionStyle("movie") 'audio, movie, video, generic
                                 ' generic+episode=4x3,
    screen.ClearButtons()
    screen.AddButton(1,"Play")
    screen.AddButton(2,"Go Back")
    screen.SetStaticRatingEnabled(false)
    screen.AllowUpdates(true)
    screen.Show()

    downKey=3
    selectKey=6
    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roSpringboardScreenEvent"
            if msg.isScreenClosed()
                print "Screen closed"
                exit while                
            else if msg.isButtonPressed()
                    print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
                    if msg.GetIndex() = 1
                         print "play video"
                        videoclip = CreateObject("roAssociativeArray")
                        videoclip.StreamBitrates = [0]
                        videoclip.StreamUrls = [Util().getVideoById(dataItem.id)]
                        videoclip.StreamQualities = ["HD"] 
                        videoclip.StreamFormat = "mp4"
                        videoclip.Title = "Roku Demo"
                        videoclip.SubtitleUrl="http://dotsub.com/media/f65605d0-c4f6-4f13-a685-c6b96fba03d0/c/eng/srt"
    
                        playVideo(videoclip)
                    else if msg.GetIndex() = 2
                        return true
                    endif
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
            endif
        else 
            print "wrong type.... type=";msg.GetType(); " msg: "; msg.GetMessage()
        endif
    end while


     return true
end Function

Function playVideo(videoclip as Object)
    print "Displaying video: "
    cfg = Config()
    p = CreateObject("roMessagePort")
    video = CreateObject("roVideoScreen")

    video.SetCertificatesFile(cfg.CERT)
    video.AddHeader(m.cfg.ROKU_HEADER, "")
    video.InitClientCertificates()
    video.setMessagePort(p)
    video.SetContent(videoclip)
    video.show()

    lastSavedPos   = 0
    statusInterval = 10 'position must change by more than this number of seconds before saving

    while true
        msg = wait(0, video.GetMessagePort())
        if type(msg) = "roVideoScreenEvent"
            if msg.isScreenClosed() then 'ScreenClosed event
                print "Closing video screen"
                exit while
            else if msg.isPlaybackPosition() then
                nowpos = msg.GetIndex()
                if nowpos > 10000
                    
                end if
                if nowpos > 0
                    if abs(nowpos - lastSavedPos) > statusInterval
                        lastSavedPos = nowpos
                    end if
                end if
            else if msg.isRequestFailed()
                print "play failed: "; msg.GetMessage()
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
            endif
        end if
    end while
End Function



'*************************************************************
'** Set the configurable theme attributes for the application
'** 
'** Configure the custom overhang and Logo attributes
'** Theme attributes affect the branding of the application
'** and are artwork, colors and offsets specific to the app
'*************************************************************

Sub initTheme()

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    theme.GridScreenOverhangSliceHD = "pkg:/images/Overhang_Background_HD.png"
    theme.GridScreenOverhangSliceSD = "pkg:/images/Overhang_Background_SD.png"

    theme.GridScreenOverhangHeightHD = "79"
    theme.GridScreenOverhangHeightSD = "44"


    app.SetTheme(theme)

End Sub
