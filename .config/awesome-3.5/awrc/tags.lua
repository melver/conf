-- TAGS

-- Individual default layout for each tag
tags = {
    names = { "1:term", "2:web", "3:work", "4:doc", "5:chat", "6:gfx", "7:media", 8, 9 },
    layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1],
               layouts[1], layouts[1], layouts[1], layouts[1] }
}

for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end

