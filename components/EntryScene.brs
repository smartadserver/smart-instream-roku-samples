sub init()
    m.list = m.top.FindNode("list")
    m.list.observeField("itemSelected", "onItemSelected")
    m.list.SetFocus(true)

    itemList = [
        {
            title: "Smart AdServer Video Ad Call Demo"
        }
    ]

    listNode = CreateObject("roSGNode", "ContentNode")
    for each item in itemList:
        nod = CreateObject("roSGNode", "ContentNode")
        nod.setFields(item)
        listNode.appendChild(nod)
    next
    m.list.content = listNode

end sub

sub onItemSelected()
    m.list.SetFocus(false)
    menuItem = m.list.content.getChild(m.list.itemSelected)

    videoContent = {
        streamFormat:   "mp4",
        titleSeason:    "Trailer",
        title:          "Big Buck Bunny",
        url:            "https://ns.sascdn.com/mobilesdk/samples/videos/BigBuckBunnyTrailer_360p.mp4",
        categories:     ["Animated"],
        length:         60
    }

    content = CreateObject("roSGNode", "ContentNode")
    content.setFields(videoContent)

    if m.Player = invalid:
        m.Player = m.top.CreateChild("Player")
        m.Player.observeField("state", "PlayerStateChanged")
    end if

    m.Player.content = content
    m.Player.visible = true
    m.Player.control = "play"
end sub

sub PlayerStateChanged()
    print "EntryScene: PlayerStateChanged(), state = "; m.Player.state
    if m.Player.state = "done" or m.Player.state = "stop"
        m.Player.visible = false
        m.list.setFocus(true) 'NB. the player took the focus away, so get it back
    end if
end sub
