sub init()
    m.video = m.top.CreateChild("Video")            
end sub

sub controlChanged()
    control = m.top.control
    if control = "play" then
        playContent()
    else if control = "stop" then
        exitPlayer()
    end if
end sub

sub playContent()
    content = m.top.content
    if content <> invalid then
        m.video.content = content
        m.video.visible = false

        m.PlayerTask = CreateObject("roSGNode", "PlayerTask")
        m.PlayerTask.observeField("state", "taskStateChanged")
        m.PlayerTask.video = m.video
        m.PlayerTask.control = "RUN"
    end if
end sub

sub exitPlayer()
    print "Player: exitPlayer()"
    m.video.control = "stop"
    m.video.visible = false
    m.PlayerTask = invalid

    m.top.state = "done"
end sub

sub taskStateChanged(event as Object)
    print "Player: taskStateChanged(), id = "; event.getNode(); ", "; event.getField(); " = "; event.getData()
    state = event.GetData()
    if state = "done" or state = "stop"
        exitPlayer()
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    print "Player: keyevent = "; key

    if press and key = "back" then
        exitPlayer()
        return true
    end if
    return false
end function

