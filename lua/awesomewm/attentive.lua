local awful = require("awful")
local modkey = "Mod4"


-- {{{ Pay attention to the names of things
local attentive = {}

-- {{{ This object will be serialized to disk and loaded on startup
--     So keep it JSON-like
local preserve = {}
preserve.activity_prev_activity = {}
preserve.tag_last_layout = {}
preserve.activity_last_tag = {}
preserve.tag_name = {}
preserve.current_activity_i = 1 -- TODO compute from active tag on startup
-- }}}

attentive.default_layout = awful.layout.layouts[2]
attentive.preserve = preserve
attentive.preservation_path = os.getenv('HOME') .. '/.config/awesome/madmess.attentive.txt'

local load_from_disk = function()
    preserve = awful.util.table.join(
      attentive.preserve,
      attentive.codec.dec(attentive.preservation_path)
    )
    attentive.preserve = preserve
end

local save_to_disk = function()
  local current_config = attentive.preserve
  -- tailgate race conditions
  load_from_disk()
  preserve = awful.util.table.join(attentive.preserve, current_config)
  attentive.preserve = preserve

  attentive.codec.enc(attentive.preserve, attentive.preservation_path)
end

local create_tags = function(screen)
  -- Each screen has its own tag table.
  -- Each tag table has 12 (activities) * 11 (space) tags
  -- first space of each activity is holy
  local alltags = {}
  local idx = screen.index
  attentive.preserve.tag_last_layout[""..idx] = {}

  -- Next section left 3rs on purpose
  local t = 1
  for t = 1, 12 * 11 do
    if attentive.preserve.tag_name[""..t] then
      t = attentive.preserve.tag_name[""..t]
    elseif t % 11 == 1 then
      -- Do not worry your mind about the ceaseless petulance of mad programmers
      -- For the loop is a range, not incrementation
      t = "F" .. (t//11+1)
    else
      -- t = ((t-1)//11+1) .. ": " .. (t%11 == 0 and 0 or t%11-1)
      t = (t%11 == 0 and 0 or t%11-1)
    end
    table.insert(alltags, t)
  end

  awful.tag(alltags, screen, attentive.default_layout)

  for i = 1, 12 * 11 do
    local thistag = screen.tags[i]
    thistag.gindex = i
    thistag.activity_i = math.ceil(i/11)
  end
end

function get_it(activityOrSpace, idx, screen)
  local it = { target_type = activityOrSpace }
  it.current = awful.tag.selected(1)

  if not screen then
    screen = it.current.screen
  end

  local targetI
  if activityOrSpace == 'activity' then
    targetI = attentive.preserve.activity_last_tag[""..idx]
    if targetI == nil then
      targetI = (idx-1)*11+1
    end
  else
    targetI = (it.current.activity_i-1)*11 + idx
  end

  it.target = screen.tags[tonumber(targetI)]

  return it
end

local tagskeys = {}
local create_tags_keys = function(s)
  -- Bind all Fn keys to activities, which each have 11 space
  -- Bind all key numbers to space under the current activity
  --
  -- Be careful: we use keycodes to make it work on any keyboard layout.
  -- This should map on the top row of your keyboard, usually 1 to 9.

  function def_tag_keybindings(activityOrSpace, idx, keycode)
    tagskeys = awful.util.table.join(
        tagskeys,

        -- View tag only.
        awful.key({ modkey }, keycode,
                  function ()
                        local it = get_it(activityOrSpace, idx)
                        if it.target then
                          if it.current then
                            attentive.preserve.activity_last_tag[""..it.current.activity_i] = it.current.gindex
                            if it.current.activity_i ~= it.target.activity_i then
                              -- find those whose previous activity is also the
                              -- current, and clear them out
                              for i = 1, 12 do
                                local prev_of_next_i = attentive.preserve.activity_prev_activity[""..i]
                                if tonumber(prev_of_next_i) == it.current.activity_i then
                                  attentive.preserve.activity_prev_activity[""..i] = nil
                                end
                              end

                              attentive.preserve.activity_prev_activity[""..it.target.activity_i] = it.current.activity_i
                            end
                          end

                          attentive.preserve.activity_last_tag[""..it.target.activity_i] = it.target.gindex

                          save_to_disk()

                          it.target:view_only()
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, keycode,
                  function ()
                      local it = get_it(activityOrSpace, idx)
                      if it.target then
                         -- no need to manage history because unnecessary
                         awful.tag.viewtoggle(it.target)
                      end
                  end,
                  {description = "toggle space #" .. idx, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, keycode,
                  function ()
                      if client.focus then
                          local it = get_it(activityOrSpace, idx, client.focus.screen)
                          if it.target then
                              client.focus:move_to_tag(it.target)
                          end
                     end
                  end,
                  {description = "move focused client to space #"..idx, group = "tag"}),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, keycode,
                  function ()
                      if client.focus then
                          local it = get_it(activityOrSpace, idx, client.focus.screen)
                          if it.target then
                              client.focus:toggle_tag(it.target)
                          end
                      end
                  end,
                  {description = "toggle focused client on space #" .. idx, group = "tag"})
    )
  end

  -- Bind ALL the activies, F1 to F10
  for i = 11, 20 do
    def_tag_keybindings('activity', i-10, "#" .. i+56)
  end
  -- F11 and F12
  for i = 21, 22 do
    def_tag_keybindings('activity', i-10, "#" .. i+74)
  end

  -- Bind ALL the spaces!
  -- The holy zeroth
  def_tag_keybindings('space', 1, "#49")
  -- and ALL the numbers
  for i = 1, 10 do
    def_tag_keybindings('space', i+1, "#" .. i+9)
  end

  root.keys(
    awful.util.table.join(
      root.keys(),
      tagskeys
    )
  )
end

local configure_global_keys = function()
  root.keys(
    awful.util.table.join(
      root.keys(),
      awful.key({ modkey, "Control"          }, "Return",
                  function () awful.spawn("activity -p") end,
                {description = "open activity picker", group = "launcher"}),

      awful.key({ modkey, "Shift", "Control" }, "Return",
                  function () awful.spawn("dmenu-tmuxstart") end,
                { description = "tmuxstart from dmenu list" }),

      awful.key({ modkey, "Control" }, "Escape",
                  function ()
                      local selected = awful.tag.selected(1)
                      local prev_i = attentive.preserve.activity_prev_activity[""..selected.activity_i]
                      if prev_i ~= nil then
                        local it = get_it('activity', prev_i)
                        if it.target then
                          it.target:view_only()
                        end
                      end
                  end,
                  function() end,
                { description = "Go to previous activity" }),

      awful.key({ "Mod1", "Control" }, "Escape",
                  function ()
                      local selected = awful.tag.selected(1)
                      local next_i
                      for i = 1, 12 do
                        local prev_of_next_i = attentive.preserve.activity_prev_activity[""..i]
                        if tonumber(prev_of_next_i) == selected.activity_i then
                          next_i = i
                          break
                        end
                      end
                      if next_i ~= nil then
                        local it = get_it('activity', next_i)
                        if it.target then
                          it.target:view_only()
                        end
                      end
                  end,
                  function() end,
                { description = "Go to previous activity" })
    )
  )
end

local temp_tag_max_layout = function()
  local last = attentive.preserve.tag_last_layout[""..mouse.screen][""..(awful.tag.getidx()+1)]
  if last == nil then
    attentive.preserve.tag_last_layout[""..mouse.screen][""..(awful.tag.getidx()+1)] = awful.layout.get()
    awful.layout.set(awful.layout.suit.max)
  else
    awful.layout.set(last)
    attentive.preserve.tag_last_layout[""..mouse.screen][""..(awful.tag.getidx()+1)] = nil
  end
end

local get_activity_tag_of_tag = function(t)
  return t.screen.tags[(t.activity_i-1)*11+1]
end

attentive.get_current_activity = function()
  local tag_name = get_activity_tag_of_tag(awful.tag.selected(1)).name
  local activity_name = string.gsub(tag_name, ".*: ", "")
  return activity_name
end

tag.connect_signal("property::name",
  function(t)
    if t.gindex then
      attentive.preserve.tag_name[""..t.gindex] = t.name
      save_to_disk()
    end
  end
)

-- {{{ Split a string, because lua
attentive.split_string = function (astr, sep)
  sep = sep or "%s"  -- default to whitespace
  local t = {}
  for split in string.gmatch(astr, "([^" .. sep .. "]+)") do
    table.insert(t, split)
  end
  return t
end
-- }}}

-- {{{ Serialize a nested table recursively to a text file
-- keys in odd lines, full tree path space separated
-- values in even lines, only strings
attentive.codec = {}

attentive.codec.enc = function(datatable, target_file, key_path)
  if not key_path then
    key_path = ""
  else
    key_path = key_path .. " | "
  end

  local file = target_file
  if type(file) == "string" then
    file = io.open(target_file, "w")
  end

  if file then
    local is_empty = true
    for k, v in pairs(datatable) do
      is_empty = false
      if type(v) == "table" then
        attentive.codec.enc(v, file, key_path .. k)
      else
        file:write(key_path .. k .. "\n")
        file:write(string.gsub(v, "\n", "\\n") .. "\n")
      end
    end

    if is_empty then
      file:write(key_path .. " | \n")
      file:write("\n")
    end

    if type(target_file) == "string" then
      file:close()
    end
  end
end

attentive.codec.dec = function(target_file)
  local file = io.open(target_file, "r")
  local result = {}

  if file then
    local file_iter = io.lines(target_file)
    for line in file_iter do
      local key = string.gsub(line, "\n", "")
      local value = string.gsub(file_iter(), "\\n", "\n")

      local key_parts = attentive.split_string(key, " | ")
      local target = result
      for i = 1, #key_parts do
        local this_key_part = key_parts[i]
        if this_key_part == "" then
          -- empty key signifies that we just wanted to create the parent
          -- which is already done by now
          break
        end

        if i < #key_parts then
          if target[this_key_part] == nil then
            target[this_key_part] = {}
          end

          target = target[this_key_part]
        end
      end

      target[key_parts[#key_parts]] = value
    end
    file:close()
  end

  return result
end

-- }}}

attentive.init = function()
  load_from_disk()

  awful.screen.connect_for_each_screen(
    function(s)
      create_tags(s)
    end
  )

  configure_global_keys()

  create_tags_keys(s)
end

--- }}}

return attentive
