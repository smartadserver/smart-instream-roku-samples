' IMPORT ROKU AD FRAMEWORK
Library "Roku_Ads.brs"

sub init()
    m.top.functionName = "playContentWithAds" 
    m.top.id = "PlayerTask"
end sub

sub playContentWithAds()
   
    ' Container objects
    video = m.top.video
    view = video.getParent() 

    ' Video content
    content = video.content

    ' RAF Initialization
    RAF = Roku_Ads()

    ' RAF Content Configuration
    RAF.setContentGenre(content.categories)  
    RAF.setContentLength(content.length)

    ' RAF UI Configuration
    RAF.clearAdBufferScreenLayers()        
    RAF.enableAdBufferMessaging(false, true) 
    RAF.setAdBufferScreenContent({})

    ' RAF AdPlayback Configuration
    RAF.enableAdMeasurements(true)
    
    ' Boolean to know whether the player should play or not 
    ' gets set to `false` when showAds() was exited via Back button
    keepPlaying = true 

    ' PREROLL
    ' Generate Ad Call URL for preroll
    adCallUrl = BuildAdCallURL("http://mobile.smartadserver.com", "213040", "901271", "29117", "roku", 1, 1, 0)
    adCallUrl = AddAdvertisingMacrosInfosToAdCallURL(adCallUrl, "SmartOnRoku")
    adCallUrl = AddRTBParametersToAdCallURL(adCallUrl, 1920, 1080, 10, 60, 200, 5000, 1, "domain.com")
    adCallUrl = AddContentDataParametersToAdCallURL(adCallUrl, "contentID", "title", "type", "category", 60, 1, 1, "rating", "providerid", "providername", "distribid", "distribname", "tag1,tag2", "external", "cms")

    print "AdCallURL: "; adCallUrl

    ' Set Ad call URL to RAF
    RAF.setAdUrl(adCallUrl)

    ' Ask Smart adserver for the preroll 
    currentAdPod = RAF.getAds() 

    ' Ask to show the preroll ads if any
    if currentAdPod <> invalid and currentAdPod.count() > 0
       keepPlaying = RAF.showAds(currentAdPod, invalid, view)
    end if

    ' Create an observer for the player
    ' Note that video will only play if a preroll has been displayed
    port = CreateObject("roMessagePort")
    if keepPlaying then
        video.observeField("position", port)
        video.observeField("state", port)
        video.visible = true
        video.control = "play"
        video.setFocus(true) 
    end if

    ' Reset currentAdPod var
    currentAdPod = invalid

    ' Create variables for midroll and postroll playback
    ' This sample displays only one midroll at 50% of the content's duration
    ' You can create your own logic for different integration
    midrollPosition = content.length / 2
    currentPosition = 0
    reachedMidroll = false
    isPlayingPostroll = false


    ' Logic for Midroll and Postroll playback
    ' Position is observed thanks to the roMessagePort object we created earlier

    while keepPlaying
        msg = wait(0, port)

        if type(msg) = "roSGNodeEvent"

            if msg.GetField() = "position" then
                ' Keep track of the current position
                currentPosition = msg.GetData() 
                ' Check if midroll time is reached and never played before
                
                if currentPosition > midrollPosition and reachedMidroll = false                    
                    reachedMidroll = true
                    ' Build AdCallURL for Midroll
                    adCallUrl = BuildAdCallURL("http://mobile.smartadserver.com", "213040", "901271", "29117", "roku", 2, 1, 0)
                    print "AdCallURL: "; adCallUrl
                    ' Set AdCallURL to RAF
                    RAF.setAdUrl(adCallUrl)
                    ' Ask Smart adserver for the midroll 
                    currentAdPod = RAF.getAds()
                    
                    ' Stop the playback if an AdPod is found
                    if currentAdPod <> invalid and currentAdPod.count() > 0
                        print "PlayerTask: mid-roll ads, stopping video"
                        ' Ask the video to stop - the rest is handled in the state=stopped event below
                        video.control = "stop"  
                    end if
                end if

            else if msg.GetField() = "state" then
                ' Save current state
                curState = msg.GetData()
                print "PlayerTask: state = "; curState
                
                ' If current state is stopped, try to play an AdPod if there is one
                if curState = "stopped" then
                    if currentAdPod = invalid or currentAdPod.count() = 0 then 
                        exit while
                    end if

                    print "PlayerTask: playing midroll or postroll ads"
                    
                    keepPlaying = RAF.showAds(currentAdPod, invalid, view)                    
                    
                    ' Reset currentAdPod
                    currentAdPod = invalid

                    ' If we were playing the postroll, just exit the while once done
                    if isPlayingPostroll then 
                        exit while
                    end if

                    ' If we should keep playing, resume playback of the content
                    if keepPlaying then
                        print "PlayerTask: mid-roll finished, seek to "; stri(currentPosition)
                        video.visible = true
                        video.seek = currentPosition
                        video.control = "play"
                        video.setFocus(true) 'important: take the focus back (RAF took it above)
                    end if
                        
                else if curState = "finished" then
                    print "PlayerTask: main content finished"

                    ' Build AdCallURL for Postroll
                    adCallUrl = BuildAdCallURL("http://mobile.smartadserver.com", "213040", "901271", "29117", "roku", 3, 1, 0)
                    print "AdCallURL: "; adCallUrl
                    ' Set AdCallURL to RAF
                    RAF.setAdUrl(adCallUrl)
                    ' Ask Smart adserver for the postroll 
                    currentAdPod = RAF.getAds()

                    if currentAdPod = invalid or currentAdPod.count() = 0 then 
                        exit while
                    end if

                    print "PlayerTask: has postroll ads"
                    isPlayingPostroll = true

                    ' Stop the video, the post-roll would show when the state changes to  "stopped" (above)
                    video.control = "stop"                    
                end if

            end if

        end if

    end while

    print "PlayerTask: exiting playContentWithAds()"
end sub
