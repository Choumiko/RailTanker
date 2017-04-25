if not defines then
  require "defines"
  defines.train_state = defines.trainstate
end

MOD_NAME = "RailTanker"

function debugLog(message, force, version)
  if false or force then -- set for debug
    local msg
    if type(message) == "string" then
      msg = message
    else
      msg = serpent.dump(message, {name="var", comment=false, sparse=false, sortkeys=true})
    end
    msg = version and version .. " " .. msg or msg
    log(msg)
    for _,player in pairs(game.players) do
      player.print(msg)
    end
  end
end

function isValid(entity)
  return (entity and entity.valid)
end

isTankerMoving = function(tanker)
  return tanker.entity.train.speed ~= 0
end

isTankerValid = function(tanker)
  return tanker and isValid(tanker.proxy)
end

isTankerEntity = function(entity)
  return (isValid(entity) and entity.name == "rail-tanker")
end

isPumpEntity = function (entity)
  return (isValid(entity) and entity.type == "pump")
end

function updateFluidItems(tanker)
  if isTankerValid(tanker) then
    local fluidbox = tanker.proxy.fluidbox[1] or false
    if not fluidbox then
      tanker.entity.clear_items_inside()
      return
    end
    local fluid_name = fluidbox and fluidbox.type or false
    fluid_name = fluid_name .. "-in-tanker"
    if game.item_prototypes[fluid_name] then

      local amount = fluidbox and fluidbox.amount or 0
      amount = amount > 2499.5 and 2500 or math.floor(amount)
      local tanker_inventory = tanker.entity.get_inventory(defines.inventory.chest)
      local current = tanker_inventory.get_item_count(fluid_name)
      local diff = amount - current
      --log("a: " .. amount .. " current: " .. current .. " diff:" .. diff)
      if diff > 0 then
        tanker_inventory.insert{name=fluid_name, count=diff}
      elseif diff < 0 then
        tanker_inventory.remove{name=fluid_name, count=-1*diff}
      end
    end
  end
end

Proxy = {}
Proxy.create = function(tanker, found_pump)
  --local offsetPosition = {x = position.x, y = position.y}
  --offsetPosition = position
  Proxy.pickup(tanker)
  local position, fluidbox, surface = tanker.entity.position, tanker.fluidbox, tanker.entity.surface
  local proxyName = "rail-tanker-proxy-noconnect"
  if not found_pump then
    local pumps = surface.find_entities_filtered{area = {{position.x - 1.5, position.y - 1.5}, {position.x + 1.5, position.y + 1.5}}, type="pump"}
    if isValid(pumps[1]) then
      --debugLog("found pump @"..pumps[1].position.x.."|"..pumps[1].position.y.." " .. game.tick, true)
      proxyName = "rail-tanker-proxy"
    end
  else
    proxyName = "rail-tanker-proxy"
  end
  local foundProxy = surface.create_entity{name=proxyName, position=position, force=tanker.entity.force}
  --local foundProxy = Proxy.find(position)
  foundProxy.fluidbox[1] = fluidbox
  --debugLog(game.tick .. " created " .. foundProxy.name)
  tanker.proxy = foundProxy
  return tanker.proxy
end

Proxy.pickup = function(tanker)
  if tanker.proxy and tanker.proxy.valid then
    --debugLog(game.tick .. "pickup " .. serpent.line(tanker.proxy.position,{comment=false}))
    tanker.fluidbox = tanker.proxy.fluidbox[1]
    tanker.proxy.destroy()
  end
  tanker.proxy = nil
end

Proxy.find = function(position, surface)
  local entities = surface.find_entities{{position.x - 0.5, position.y - 0.5}, {position.x + 0.5, position.y + 0.5}}
  local foundProxies = nil
  for _, entity in pairs(entities) do
    if isValid(entity) and (entity.name == "rail-tanker-proxy" or entity.name == "rail-tanker-proxy-noconnect") then
      --debugLog(game.tick .. " found entity: " .. entity.name)
      if foundProxies == nil then
        foundProxies = entity
      else
        if isValid(entity) then
          entity.destroy()
        end
      end
    end
  end
  return foundProxies
end

on_tick = function(event)
  local tick = game.tick
  local update = global.updateTankers[tick]
  if update then
    local updateTick = tick + 60
    global.updateTankers[updateTick] = global.updateTankers[updateTick] or {}
    for _, tanker in pairs(update) do
      if isValid(tanker.entity) and tanker.update == event.tick then
        updateFluidItems(tanker)
        if not isTankerMoving(tanker) then
          addTanker(tanker, updateTick)
        end
      end
    end
    if #global.updateTankers[updateTick] == 0 then
      global.updateTankers[updateTick] = nil
    end
    global.updateTankers[tick] = nil
  end
end

addTanker = function(tanker, tick)
  global.updateTankers[tick] = global.updateTankers[tick] or {}
  tanker.update = tick
  table.insert(global.updateTankers[tick], tanker)
end

function getTankerFromEntity(entity)
  if global.tankers == nil then return nil end
  --debugLog("tankers not nil")
  for i,tanker in pairs(global.tankers) do
    if isValid(tanker.entity) and entity == tanker.entity then
      return i, tanker
    end
  end
  return nil
end

function map_size(surface)
  -- determine map size
  local min_x, min_y, max_x, max_y = 0, 0, 0, 0
  for c in surface.get_chunks() do
    if c.x < min_x then
      min_x = c.x
    elseif c.x > max_x then
      max_x = c.x
    end
    if c.y < min_y then
      min_y = c.y
    elseif c.y > max_y then
      max_y = c.y
    end
  end
  return min_x, min_y, max_x, max_y
end

function findTankers(show)
  local surface = game.surfaces['nauvis']
  local min_x, min_y, max_x, max_y = map_size(surface)

  if show then
    debugLog("Searching tankers..",true)
  end
  -- create bounding box covering entire generated map
  local bounds = {{min_x*32,min_y*32},{max_x*32,max_y*32}}
  local found = 0
  for _, ent in pairs(surface.find_entities_filtered{area=bounds, type="cargo-wagon"}) do
    local i, tanker = getTankerFromEntity(ent)
    if i then
      ent.operable = true
      local proxy = Proxy.find(ent.position,ent.surface)
      if proxy and proxy.valid then
        tanker.proxy = proxy
        if proxy.fluidbox and proxy.fluidbox[1] then
          tanker.fluidbox = proxy.fluidbox[1]
        end
      end
      if ent.train.speed ==  0 then
        addTanker(tanker, game.tick + 60)
      end
    else
      on_entity_built({created_entity=ent})
      found = found+1
    end
  end
  local removed = 0
  for _, ent in pairs(surface.find_entities_filtered{area=bounds, name="rail-tanker-proxy"}) do
    found = false
    for _, tanker in pairs(global.tankers) do
      if ent == tanker.proxy then
        found = true
        break
      end
    end
    if not found then
      removed = removed + 1
      ent.destroy()
    end
  end
  for _, ent in pairs(surface.find_entities_filtered{area=bounds, name="rail-tanker-proxy-noconnect"}) do
    found = false
    for _, tanker in pairs(global.tankers) do
      if ent == tanker.proxy then
        found = true
        break
      end
    end
    if not found then
      removed = removed + 1
      ent.destroy()
    end
  end
  if show then
    debugLog("Found "..#global.tankers.." tankers",true)
    if removed > 0 then
      debugLog("Removed "..removed.." invalid tanks", true)
    end
  end
end

local function init_global()
  global = global or {}
  global.tankers = global.tankers or {}
  global.updateTankers = global.updateTankers or {}
end

local update_from_version = {
  ["0.0.0"] = function()
    init_global()
    global.manualTankers = {}
    findTankers(true)
    return "1.2.22"
  end,

  ["1.2.22"] = function()
    for _, t in pairs(global.tankers) do
      if isValid(t.entity) then
        t.entity.operable = true
      end
    end

    for _, t in pairs(global.manualTankers) do
      if isValid(t.entity) then
        t.entity.operable = true
      end
    end
    return "1.3.3"
  end,
  ["1.3.0"] = function() return "1.3.3" end,
  ["1.3.1"] = function() return "1.3.3" end,
  ["1.3.2"] = function() return "1.3.3" end,
  ["1.3.3"] = function()
    local updateTick = game.tick + 60
    global.updateTankers = global.updateTankers or {}
    global.updateTankers[updateTick] = global.updateTankers[updateTick] or {}
    for _, tanker in pairs(global.tankers) do
      if isValid(tanker.entity) then
        tanker.entity.operable = true
        tanker.entity.get_inventory(defines.inventory.chest).setbar()
        updateFluidItems(tanker)
        if not isTankerMoving(tanker) then
          addTanker(tanker, updateTick)
        end
      end
    end
    global.manualTankers = nil
    return "1.3.31"
  end,
  ["1.3.31"] = function() return "1.3.32" end,
  ["1.3.32"] = function() return "1.3.33" end,
  ["1.3.33"] = function() return "1.4.0" end, 
  ["1.4.0"] = function() return "1.4.1" end,

}

local function on_configuration_changed(data)
  local _, err = pcall(function()
    if not data or not data.mod_changes then
      return
    end
    local newVersion
    local oldVersion
    if data.mod_changes[MOD_NAME] then
      newVersion = data.mod_changes[MOD_NAME].new_version
      oldVersion = data.mod_changes[MOD_NAME].old_version
      init_global()
      if oldVersion and newVersion then
        local ver = update_from_version[oldVersion] and oldVersion or "0.0.0"
        while ver ~= newVersion do
          ver = update_from_version[ver]()
        end
      end

      global.version = newVersion
    end
  end)
  if err then debugLog(err,true, global.version) end
end

local function on_init()
  init_global()
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_tick, on_tick)

on_entity_removed = function (event)
  local _, err = pcall(function()
    if isTankerEntity(event.entity) then
      local index, tanker = getTankerFromEntity(event.entity)
      if index and isTankerValid(tanker) then
        tanker.proxy.destroy()
        tanker.proxy = nil
        tanker.entity.clear_items_inside()
        table.remove(global.tankers, index)
      end
    end
  end)
  if err then debugLog(err,true, global.version) end
end

script.on_event(defines.events.on_preplayer_mined_item, on_entity_removed)
script.on_event(defines.events.on_robot_pre_mined, on_entity_removed)
script.on_event(defines.events.on_entity_died, on_entity_removed)

on_entity_built = function(event)
  local _, err = pcall(function()
    local entity = event.created_entity
    if isTankerEntity(entity) then
      local tanker = {entity = entity}
      entity.operable = true
      if not isTankerMoving(tanker) then
        tanker.proxy = Proxy.create(tanker)
      end
      table.insert(global.tankers, tanker)
      addTanker(tanker, game.tick + 60)
    elseif isPumpEntity(entity) then
      local position = entity.position
      local foundEntities = entity.surface.find_entities_filtered{area = {{position.x - 1.5, position.y - 1.5}, {position.x + 1.5, position.y + 1.5}}, name="rail-tanker"}
      for _,ent in pairs(foundEntities) do
        local _, tanker = getTankerFromEntity(ent)
        if isTankerValid(tanker) and tanker.proxy.name == "rail-tanker-proxy-noconnect" then
          tanker.fluidbox = tanker.proxy.fluidbox[1]
          tanker.proxy.destroy()
          tanker.proxy = Proxy.create(tanker, true)
        end
      end
    end
  end)
  if err then debugLog(err,true, global.version) end
end

script.on_event(defines.events.on_built_entity, on_entity_built)
script.on_event(defines.events.on_robot_built_entity, on_entity_built)

on_train_changed_state = function(event)
  local _, err = pcall(function()
    local train = event.train
    local state = train.state
    local train_stopped = state == defines.train_state.wait_station or (state == defines.train_state.manual_control and train.speed == 0)
    --debugLog(game.tick .. " Tanker state: " .. key_by_value(defines.train_state, train.state), true)
    for _, entity in pairs(train.cargo_wagons) do
      if isTankerEntity(entity) then
        local _, tanker = getTankerFromEntity(entity)
        if tanker == nil then
          --debugLog("something went wrong!")
          tanker = {entity = entity}
          table.insert(global.tankers, tanker)
        end
        if train_stopped then
          --debugLog(event.tick .. " Train Stopped " .. i, true)
          local updateTick = event.tick + 60
          tanker.proxy = Proxy.create(tanker)
          updateFluidItems(tanker)
          global.updateTankers[updateTick] = global.updateTankers[updateTick] or {}
          tanker.update = updateTick
          addTanker(tanker, updateTick)
        else --moving
          --debugLog(event.tick .. " Train moving" .. i,true)
          updateFluidItems(tanker)
          Proxy.pickup(tanker)
          tanker.update = false
        end
      end
    end
  end)
  if err then debugLog(err,true, global.version) end
end

script.on_event(defines.events.on_train_changed_state, on_train_changed_state)

remote.add_interface("railtanker",
  {
    getLiquidByWagon = function(wagon)
      local i, tanker = getTankerFromEntity(wagon)
      if not i then return {amount = 0, type = nil} end
      if isTankerEntity(tanker.entity) then
        if tanker.proxy and tanker.proxy.valid and tanker.proxy.fluidbox and tanker.proxy.fluidbox[1] then
          return {amount = tanker.proxy.fluidbox[1].amount, type = tanker.proxy.fluidbox[1].type}
        end
        if not tanker.proxy and tanker.fluidbox then
          return {amount = tanker.fluidbox.amount, type = tanker.fluidbox.type}
        end
      end
      return {amount = 0, type = nil}
    end,

    saveVar = function()
      game.write_file("railtanker.lua", serpent.block(global, {name="glob"}))
    end,

    findTankers = function()
      global.updateTankers = {}
      findTankers(true)
    end,
  }
)
