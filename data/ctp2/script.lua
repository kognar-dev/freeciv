-- Freeciv - Copyright (C) 2007 - The Freeciv Project
--   This program is free software; you can redistribute it and/or modify
--   it under the terms of the GNU General Public License as published by
--   the Free Software Foundation; either version 2, or (at your option)
--   any later version.
--
--   This program is distributed in the hope that it will be useful,
--   but WITHOUT ANY WARRANTY; without even the implied warranty of
--   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--   GNU General Public License for more details.

-- This file is for lua-functionality that is specific to a given
-- ruleset. When freeciv loads a ruleset, it also loads script
-- file called 'default.lua'. The one loaded if your ruleset
-- does not provide an override is default/default.lua.


-- Place Ruins at the location of the destroyed city.
function city_destroyed_callback(city, loser, destroyer)
  city.tile:create_extra("Ruins", NIL)
  -- continue processing
  return false
end

signal.connect("city_destroyed", "city_destroyed_callback")

-- Unit enters Hermit`s Place
function hermit_nest(unit, extra)
  if extra == "Hermit" then
    local chance = random(0, 5)

    notify.event(unit.owner, unit.tile, E.SCRIPT,
                 _("You found Hermit's Place."))

    if chance <= 3 then
      local tech = unit.owner:give_tech(nil, 20, false, "hut")
      notify.event(unit.owner, unit.tile, E.HUT_TECH,
                 _("Secluded studies have led the Hermit to the discovery of %s!"),
                 tech:name_translation())
    else
      notify.event(unit.owner, unit.tile, E.HUT_BARB_CITY_NEAR,
                 _("The Hermit has left nothing useful."))
    end

    return true
  end
end

signal.connect("hut_enter", "hermit_nest")

function hermit_nest_blown(unit, extra)
  if extra == "Hermit" then
    notify.event(unit.owner, unit.tile, E.HUT_BARB,
                 _("Your %s has overflied a Hermit's Place and destroyed it!"),
                 unit:link_text())
    -- Do not process default.lua
    return true
  end
end

signal.connect("hut_frighten", "hermit_nest_blown")

-- Check if there is certain terrain in ANY CAdjacent tile.
function adjacent_to(tile, terrain_name)
  for adj_tile in tile:circle_iterate(1) do
    if adj_tile.id ~= tile.id then
      local adj_terr = adj_tile.terrain
      local adj_name = adj_terr:rule_name()
      if adj_name == terrain_name then
        return true
      end
    end
  end
  return false
end

-- Check if there is certain terrain in ALL CAdjacent tiles.
function surrounded_by(tile, terrain_name)
  for adj_tile in tile:circle_iterate(1) do
    if adj_tile.id ~= tile.id then
      local adj_terr = adj_tile.terrain
      local adj_name = adj_terr:rule_name()
      if adj_name ~= terrain_name then
        return false
      end
    end
  end
  return true
end

-- Add random labels to the map.
function place_map_labels()
  local rivers = 0
  local deeps = 0
  local oceans = 0
  local lakes = 0
  local swamps = 0
  local glaciers = 0
  local tundras = 0
  local deserts = 0
  local plains = 0
  local grasslands = 0
  local jungles = 0
  local forests = 0
  local hills = 0
  local mountains = 0

  local selected_river = 0
  local selected_deep = 0
  local selected_ocean = 0
  local selected_lake = 0
  local selected_swamp = 0
  local selected_glacier = 0
  local selected_tundra = 0
  local selected_desert = 0
  local selected_plain = 0
  local selected_grassland = 0
  local selected_jungle = 0
  local selected_forest = 0
  local selected_hill = 0
  local selected_mountain = 0

  -- Count the tiles that has a terrain type that may get a label.
  for place in whole_map_iterate() do
    local terr = place.terrain
    local tname = terr:rule_name()

    if place:has_extra("River") then
      rivers = rivers + 1
    elseif tname == "Deep Ocean" then
      deeps = deeps + 1
    elseif tname == "Ocean" then
      oceans = oceans + 1
    elseif tname == "Lake" then
      lakes = lakes + 1
    elseif tname == "Swamp" then
      swamps = swamps + 1
    elseif tname == "Glacier" then
      glaciers = glaciers + 1
    elseif tname == "Tundra" then
      tundras = tundras + 1
    elseif tname == "Desert" then
      deserts = deserts + 1
    elseif tname == "Plains" then
      plains = plains + 1
    elseif tname == "Grassland" then
      grasslands = grasslands + 1
    elseif tname == "Jungle" then
      jungles = jungles + 1
    elseif tname == "Forest" then
      forests = forests + 1
    elseif tname == "Hills" then
      hills = hills + 1
    elseif tname == "Mountains" then
      mountains = mountains + 1
    end
  end

  -- Decide if a label should be included and, in case it should, where.
    if random(1, 100) <= rivers then
      selected_river = random(1, rivers)
    end
    if random(1, 100) <= deeps then
      selected_deep = random(1, deeps)
    end
    if random(1, 100) <= oceans then
      selected_ocean = random(1, oceans)
    end
    if random(1, 100) <= lakes then
      selected_lake = random(1, lakes)
    end
    if random(1, 100) <= swamps then
      selected_swamp = random(1, swamps)
    end
    if random(1, 100) <= glaciers then
      selected_glacier = random(1, glaciers)
    end
    if random(1, 100) <= tundras then
      selected_tundra = random(1, tundras)
    end
    if random(1, 100) <= deserts then
      selected_desert = random(1, deserts)
    end
    if random(1, 100) <= plains then
      selected_plain = random(1, plains)
    end
    if random(1, 100) <= grasslands then
      selected_grassland = random(1, grasslands)
    end
    if random(1, 100) <= jungles then
      selected_jungle = random(1, jungles)
    end
    if random(1, 100) <= forests then
      selected_forest = random(1, forests)
    end
    if random(1, 100) <= hills then
      selected_hill = random(1, hills)
    end
    if random(1, 100) <= mountains then
      selected_mountain = random(1, mountains)
    end

  -- Place the included labels at the location determined above.
  for place in whole_map_iterate() do
    local terr = place.terrain
    local tname = terr:rule_name()

    if place:has_extra("River") then
      selected_river = selected_river - 1
      if selected_river == 0 then
        if tname == "Hills" then
          place:set_label(_("Grand Canyon"))
        elseif tname == "Mountains" then
          place:set_label(_("Deep Gorge"))
        elseif tname == "Tundra" then
          place:set_label(_("Fjords"))
        elseif random(1, 100) <= 50 then
          place:set_label(_("Waterfalls"))
        else
          place:set_label(_("Travertine Terraces"))
        end
      end
    elseif tname == "Deep Ocean" then
      selected_deep = selected_deep - 1
      if selected_deep == 0 then
        if surrounded_by(place, "Deep Ocean") then
          -- Fully surrounded
          place:set_label(_("Deep Trench"))
        else
          place:set_label(_("Thermal Vent"))
        end
      end
    elseif tname == "Ocean" then
      selected_ocean = selected_ocean - 1
      if selected_ocean == 0 then
        if surrounded_by(place, "Ocean") then
          -- Fully surrounded
          place:set_label(_("Atoll Chain"))
        elseif adjacent_to(place, "Glacier") then
          place:set_label(_("Glacier Bay"))
        elseif adjacent_to(place, "Deep Ocean") then
          place:set_label(_("Great Barrier Reef"))
        else
          -- Coast (not adjacent to glacier nor deep ocean)
          place:set_label(_("Great Blue Hole"))
        end
      end
    elseif tname == "Lake" then
      selected_lake = selected_lake - 1
      if selected_lake == 0 then
        if surrounded_by(place, "Lake") then
          -- Fully surrounded
          place:set_label(_("Great Lakes"))
        elseif not adjacent_to(place, "Lake") then
          -- Isolated
          place:set_label(_("Dead Sea"))
        else
          place:set_label(_("Rift Lake"))
        end
      end
    elseif tname == "Swamp" then
      selected_swamp = selected_swamp - 1
      if selected_swamp == 0 then
        if not adjacent_to(place, "Swamp") then
          -- Isolated
          place:set_label(_("Grand Prismatic Spring"))
        elseif adjacent_to(place, "Ocean") then
          -- Coast
          place:set_label(_("Mangrove Forest"))
        else
          place:set_label(_("Cenotes"))
        end
      end
    elseif tname == "Glacier" then
      selected_glacier = selected_glacier - 1
      if selected_glacier == 0 then
        if surrounded_by(place, "Glacier") then
          -- Fully surrounded
          place:set_label(_("Ice Sheet"))
        elseif not adjacent_to(place, "Glacier") then
          -- Isolated
          place:set_label(_("Frozen Lake"))
        elseif adjacent_to(place, "Ocean") then
          -- Coast
          place:set_label(_("Ice Shelf"))
        else
          place:set_label(_("Advancing Glacier"))
        end
      end
    elseif tname == "Tundra" then
      selected_tundra = selected_tundra - 1
      if selected_tundra == 0 then
          place:set_label(_("Geothermal Area"))
      end
    elseif tname == "Desert" then
      selected_desert = selected_desert - 1
      if selected_desert == 0 then
        if surrounded_by(place, "Desert") then
          -- Fully surrounded
          place:set_label(_("Sand Sea"))
        elseif not adjacent_to(place, "Desert") then
          -- Isolated
          place:set_label(_("Salt Flat"))
        elseif random(1, 100) <= 50 then
          place:set_label(_("Singing Dunes"))
        else
          place:set_label(_("White Desert"))
        end
      end
    elseif tname == "Plains" then
      selected_plain = selected_plain - 1
      if selected_plain == 0 then
        if adjacent_to(place, "Ocean") then
          -- Coast
          place:set_label(_("Long Beach"))
        elseif random(1, 100) <= 50 then
          place:set_label(_("Valley of Geysers"))
        else
          place:set_label(_("Rock Pillars"))
        end
      end
    elseif tname == "Grassland" then
      selected_grassland = selected_grassland - 1
      if selected_grassland == 0 then
        if adjacent_to(place, "Ocean") then
          -- Coast
          place:set_label(_("White Cliffs"))
        elseif random(1, 100) <= 50 then
          place:set_label(_("Giant Cave"))
        else
          place:set_label(_("Rock Formation"))
        end
      end
    elseif tname == "Jungle" then
      selected_jungle = selected_jungle - 1
      if selected_jungle == 0 then
        if surrounded_by(place, "Jungle") then
          -- Fully surrounded
          place:set_label(_("Rainforest"))
        elseif adjacent_to(place, "Ocean") then
          -- Coast
          place:set_label(_("Subterranean River"))
        else
          place:set_label(_("Sinkholes"))
        end
      end
    elseif tname == "Forest" then
      selected_forest = selected_forest - 1
      if selected_forest == 0 then
        if adjacent_to(place, "Mountains") then
          place:set_label(_("Stone Forest"))
        elseif surrounded_by(place, "Forest") then
          -- Fully surrounded
          place:set_label(_("Sequoia Forest"))
        else
          place:set_label(_("Millenary Trees"))
        end
      end
    elseif tname == "Hills" then
      selected_hill = selected_hill - 1
      if selected_hill == 0 then
        if not adjacent_to(place, "Hills") then
          if adjacent_to(place, "Mountains") then
            -- Isolated (but adjacent to mountains)
            place:set_label(_("Table Mountain"))
          else
            -- Isolated (not adjacent to hills nor mountains)
            place:set_label(_("Inselberg"))
          end
        elseif random(1, 100) <= 50 then
          place:set_label(_("Karst Landscape"))
        else
          place:set_label(_("Mud Volcanoes"))
        end
      end
    elseif tname == "Mountains" then
      selected_mountain = selected_mountain - 1
      if selected_mountain == 0 then
        if surrounded_by(place, "Mountains") then
          -- Fully surrounded
          place:set_label(_("Highest Peak"))
        elseif not adjacent_to(place, "Mountains") then
          -- Isolated
          place:set_label(_("Sacred Mount"))
        elseif adjacent_to(place, "Ocean") then
          -- Coast
          place:set_label(_("Cliff Coast"))
        elseif random(1, 100) <= 50 then
          place:set_label(_("Active Volcano"))
        else
          place:set_label(_("High Summit"))
        end
      end
    end
  end
  return false
end

-- Add random castles at mountain tops.
function place_ancient_castle_ruins()
  -- Test castle storming in autogames even if the AI won`t build them.
  -- Narrative excuse: The game starts in 4000 BC. The builders of the
  -- castles must have drowned in the dark, formless void - taking
  -- their advanced technology with them.

  for place in whole_map_iterate() do
    local terr = place.terrain
    local tname = terr:rule_name()

    if (tname == "Mountains") and (random(1, 100) <= 5) then
      place:create_extra("Fort")
      place:create_extra("Fortress")
      place:create_extra("Castle")
    end
  end

  return false
end

-- Add random Ancient Transport Hub
function place_ancient_transport_hub()
  -- Narrative excuse: The game starts in 4000 BC. Who knows what came
  -- before the dark, formless void?

  for place in whole_map_iterate() do
    local terr = place.terrain
    local tname = terr:rule_name()

    if (tname == "Glacier") and (random(1, 1000) <= 9) then
      -- adds up to 1% with the throw below
      place:create_extra("Ancient Transport Hub")
    elseif (not (tname == "Inaccessible")) and (random(1, 1000) <= 1) then
      place:create_extra("Ancient Transport Hub")
    end
  end

  return false
end

-- Modify the generated map
function modify_generated_map()
  place_map_labels()
  place_ancient_castle_ruins()
  place_ancient_transport_hub()
  return false
end

signal.connect("map_generated", "modify_generated_map")

-- Only notifications needs Lua
function notify_unit_unit(action, actor, target)
  -- Notify actor
  notify.event(actor.owner, target.tile,
               E.UNIT_ACTION_ACTOR_SUCCESS,
               -- /* TRANS: Your Marines does Disrupt Supply Lines to American Armor. */
               _("Your %s does %s to %s %s."),
               actor:link_text(),
               action:name_translation(),
               target.owner.nation:name_translation(),
               target:link_text())

  -- Notify target
  notify.event(target.owner, actor.tile,
               E.UNIT_ACTION_TARGET_HOSTILE,
               -- /* TRANS: German Paratroopers does Disrupt Supply Lines to your Armor. */
               _("%s %s does %s to your %s."),
               actor.owner.nation:name_translation(),
               actor:link_text(),
               action:name_translation(),
               target:link_text())
end

-- Handle unit targeted unit action start
function action_started_unit_unit_callback(action, actor, target)
  if action:rule_name() == "User Action 1" then
    -- Disrupt Supply Lines
    notify_unit_unit(action, actor, target)
  end
end

signal.connect("action_started_unit_unit", "action_started_unit_unit_callback")

-- Use Ancient Transportation Network
function transport_network(action, actor, target)
  local actor_link = actor:link_text()
  local invade_city_val = effects.unit_bonus(actor, target.owner,
                                             "User_Effect_1")
  local invade_extra_val = effects.unit_vs_tile_bonus(actor, target,
                                                      "User_Effect_2")
  local survived = actor:teleport(target,
                                  -- Allow transport to transport
                                  find.transport_unit(actor.owner,
                                                      actor.utype, target),
                                  true,
                                  -- Take city and castle conquest from
                                  -- boolean user effects
                                  invade_city_val > 0, invade_extra_val > 0,
                                  -- A unit appearing from the Ancient
                                  -- Transportation Network is scary to see
                                  false, true)

  if not survived then
    notify.event(actor.owner, target,
                 E.UNIT_ACTION_ACTOR_FAILURE,
                 -- /* TRANS: Your Marines didn't survive doing
                 --  * Use Ancient Transportation Network. */
                 _("Your %s didn't survive doing %s."),
                 actor_link,
                 action:name_translation())
    notify.event(actor.owner, target,
                 E.UNIT_ACTION_ACTOR_FAILURE,
                 _("Be more careful the next time you select a target."))
    -- Kept out to keep the game family friendly:
    -- Sounds similar to those heard during their spring sacrifices are
    -- rumored to have been coming from the closed chamber of the
    -- Amêzârâkian Mysteries at the time of the accident.
  end
end

-- Handle tile targeted unit action start
function action_started_unit_tile_callback(action, actor, target)
  if action:rule_name() == "User Action 2" then
    -- Use Ancient Transportation Network
    transport_network(action, actor, target)
  end
end

signal.connect("action_started_unit_tile",
"action_started_unit_tile_callback")

-- Call to Power II Gaia Controller victory.
-- A player with the Gaia Controller Core, Gaia Power Satellites in at
-- least 10 cities and at least 5 Processing Towers inside their borders
-- covering 60% of the map runs the Gaia Controller. Keeping it running
-- for 10 consecutive turns wins the game. Tower coverage radius grows
-- from 5 tiles (10 satellites) to 16 tiles (40 satellites).
-- Turn counters are global numbers so that they are saved with the game.

-- Lua gets object ids as floats ("1.0"). Global variable names saved
-- with the game must use the integer form, or the savegame's Lua state
-- does not load.
function ctp2_var(prefix, id)
  return prefix .. math.floor(id)
end

local GAIA_TURNS = 10
local GAIA_MIN_SATELLITES = 10
local GAIA_MAX_SATELLITES = 40
local GAIA_MIN_TOWERS = 5
local GAIA_COVERAGE = 0.6

function ctp2_gaia_check(player, map_tiles)
  local core = find.building_type("Gaia Controller Core")
  local satellite = find.building_type("Gaia Power Satellite")
  local has_core = false
  local satellites = 0

  for city in player:cities_iterate() do
    if city:has_building(core) then
      has_core = true
    end
    if city:has_building(satellite) then
      satellites = satellites + 1
    end
  end

  if not has_core or satellites < GAIA_MIN_SATELLITES then
    return false
  end

  local towers = {}
  for tile in whole_map_iterate() do
    if tile.owner == player and tile:has_extra("Processing Tower") then
      towers[#towers + 1] = tile
    end
  end
  if #towers < GAIA_MIN_TOWERS then
    return false
  end

  local power = math.min(satellites, GAIA_MAX_SATELLITES) - GAIA_MIN_SATELLITES
  local radius = 5 + 11 * power / (GAIA_MAX_SATELLITES - GAIA_MIN_SATELLITES)
  local sq_radius = math.floor(radius * radius)
  local covered = {}
  local count = 0

  for _, tower in ipairs(towers) do
    for tile in tower:circle_iterate(sq_radius) do
      if not covered[tile.id] then
        covered[tile.id] = true
        count = count + 1
      end
    end
  end

  return count >= GAIA_COVERAGE * map_tiles
end

function ctp2_gaia_turn(turn, year)
  local map_tiles = nil

  for player in players_iterate() do
    if player.is_alive then
      local var = ctp2_var("ctp2_gaia_turns_", player.id)
      local running = _G[var] or 0

      if map_tiles == nil then
        map_tiles = 0
        for tile in whole_map_iterate() do
          map_tiles = map_tiles + 1
        end
      end

      if ctp2_gaia_check(player, map_tiles) then
        running = running + 1
        if running == 1 then
          notify.all(_("The %s have started the Gaia Controller! They will win in %d turns unless it is stopped."),
                     player.nation:plural_translation(), GAIA_TURNS)
        end
        if running >= GAIA_TURNS then
          notify.all(_("The Gaia Controller of the %s is complete."),
                     player.nation:plural_translation())
          player:victory()
        end
      elseif running > 0 then
        notify.all(_("The Gaia Controller of the %s has stopped."),
                   player.nation:plural_translation())
        running = 0
      end
      _G[var] = running
    end
  end
end

signal.connect("turn_begin", "ctp2_gaia_turn")

-- Call to Power II special units.
-- Conversions and franchises are stored per city in global numbers
-- (ctp2_conv_<city id> = converting player id + 1, ctp2_convf_<city id> =
-- tithe factor, ctp2_fran_<city id> = franchise owner id + 1) so that they
-- are saved with the game. 0 or nil means none.

local CTP2_SPECIAL_SUCCESS = 75   -- % chance to convert or franchise
local CTP2_SPECIAL_DEATH = 50     -- % chance to die after a failure
local CTP2_TITHE_CLERIC = 2       -- tithe = city size * factor / 5
local CTP2_TITHE_TELEVANGELIST = 4
local CTP2_FRANCHISE_FACTOR = 1   -- franchise = city size * factor / 5

local function ctp2_unit_on_tile(tile, owner, names)
  for unit in tile:units_iterate() do
    if unit.owner == owner and names[unit.utype:rule_name()] then
      return true
    end
  end
  return false
end

local function ctp2_pay(from, to, amount)
  amount = math.min(amount, from:gold())
  if amount > 0 then
    edit.change_gold(from, -amount)
    edit.change_gold(to, amount)
  end
end

local function ctp2_special_roll(actor, city, what)
  if random(1, 100) <= CTP2_SPECIAL_SUCCESS then
    return true
  end
  if random(1, 100) <= CTP2_SPECIAL_DEATH then
    notify.event(actor.owner, city.tile, E.UNIT_ACTION_ACTOR_FAILURE,
                 _("Your %s failed to %s in %s and was lost."),
                 actor:link_text(), what, city:link_text())
    actor:kill("caught", city.owner)
  else
    notify.event(actor.owner, city.tile, E.UNIT_ACTION_ACTOR_FAILURE,
                 _("Your %s failed to %s in %s."),
                 actor:link_text(), what, city:link_text())
  end
  return false
end

local ctp2_raid = nil

function ctp2_action_started_unit_city(action, actor, city)
  local name = action:rule_name()
  local utype = actor.utype:rule_name()

  if name == "User Action 3" then
    -- Convert City
    if ctp2_special_roll(actor, city, _("convert the city")) then
      _G[ctp2_var("ctp2_conv_", city.id)] = math.floor(actor.owner.id) + 1
      if utype == "Televangelist" then
        _G[ctp2_var("ctp2_convf_", city.id)] = CTP2_TITHE_TELEVANGELIST
      else
        _G[ctp2_var("ctp2_convf_", city.id)] = CTP2_TITHE_CLERIC
      end
      notify.event(actor.owner, city.tile, E.UNIT_ACTION_ACTOR_SUCCESS,
                   _("Your %s converted %s to your faith."),
                   actor:link_text(), city:link_text())
      notify.event(city.owner, city.tile, E.UNIT_ACTION_TARGET_HOSTILE,
                   _("%s %s converted %s. The city will pay them a tithe."),
                   actor.owner.nation:name_translation(),
                   actor:link_text(), city:link_text())
    end
  elseif name == "User Action 4" then
    -- Create Franchise
    if ctp2_special_roll(actor, city, _("create a franchise")) then
      _G[ctp2_var("ctp2_fran_", city.id)] = math.floor(actor.owner.id) + 1
      notify.event(actor.owner, city.tile, E.UNIT_ACTION_ACTOR_SUCCESS,
                   _("Your %s opened a franchise in %s."),
                   actor:link_text(), city:link_text())
      notify.event(city.owner, city.tile, E.UNIT_ACTION_TARGET_HOSTILE,
                   _("%s %s opened a franchise in %s. Send a Lawyer there to close it."),
                   actor.owner.nation:name_translation(),
                   actor:link_text(), city:link_text())
    end
  elseif name == "Poison City" and utype == "Slaver" then
    -- Slave Raid: an Abolitionist in the city catches the Slaver.
    if ctp2_unit_on_tile(city.tile, city.owner, { Abolitionist = true }) then
      notify.event(actor.owner, city.tile, E.UNIT_ACTION_ACTOR_FAILURE,
                   _("Your %s was caught by an Abolitionist in %s."),
                   actor:link_text(), city:link_text())
      notify.event(city.owner, city.tile, E.UNIT_ACTION_TARGET_HOSTILE,
                   _("An Abolitionist caught a %s Slaver in %s."),
                   actor.owner.nation:name_translation(), city:link_text())
      actor:kill("caught", city.owner)
      return
    end
    -- The action uses up the Slaver; remember it to bring it back.
    ctp2_raid = { owner = actor.owner, tile = actor.tile,
                  veteran = actor.veteran, homecity = actor:get_homecity() }
  end
end

function ctp2_action_finished_unit_city(action, success, actor, city)
  local name = action:rule_name()

  if name == "Poison City" and ctp2_raid ~= nil then
    local raid = ctp2_raid
    ctp2_raid = nil
    if success then
      local slaves = edit.create_unit(raid.owner, raid.tile,
                                      find.unit_type("Workers"), 0, nil, 0)
      edit.create_unit(raid.owner, raid.tile, find.unit_type("Slaver"),
                       raid.veteran, raid.homecity, 0)
      if slaves ~= nil then
        notify.event(raid.owner, raid.tile, E.UNIT_ACTION_ACTOR_SUCCESS,
                     _("The raid brought back slaves: %s."),
                     slaves:link_text())
      end
    end
  elseif name == "Destroy City" and success and actor ~= nil
         and actor.utype:rule_name() == "Eco-Ranger" then
    -- Creating a park uses up the Eco-Ranger.
    actor:kill("used")
  end
end

signal.connect("action_started_unit_city", "ctp2_action_started_unit_city")
signal.connect("action_finished_unit_city", "ctp2_action_finished_unit_city")

function ctp2_specials_turn(turn, year)
  local clerics = { Cleric = true, Televangelist = true }
  local lawyers = { Lawyer = true }

  for owner in players_iterate() do
    for city in owner:cities_iterate() do
      local conv = _G[ctp2_var("ctp2_conv_", city.id)] or 0
      local fran = _G[ctp2_var("ctp2_fran_", city.id)] or 0

      if conv > 0 then
        local by = find.player(conv - 1)
        if by == nil or by == owner or not by.is_alive then
          _G[ctp2_var("ctp2_conv_", city.id)] = 0
        elseif ctp2_unit_on_tile(city.tile, owner, clerics) then
          _G[ctp2_var("ctp2_conv_", city.id)] = 0
          notify.event(owner, city.tile, E.CITY_TRANSFER,
                       _("%s has returned to your faith."), city:link_text())
          notify.event(by, city.tile, E.CITY_TRANSFER,
                       _("%s has returned to its old faith."),
                       city:link_text())
        else
          local factor = _G[ctp2_var("ctp2_convf_", city.id)] or CTP2_TITHE_CLERIC
          ctp2_pay(owner, by, math.max(1, city.size * factor // 5))
        end
      end

      if fran > 0 then
        local by = find.player(fran - 1)
        if by == nil or by == owner or not by.is_alive then
          _G[ctp2_var("ctp2_fran_", city.id)] = 0
        elseif ctp2_unit_on_tile(city.tile, owner, lawyers) then
          _G[ctp2_var("ctp2_fran_", city.id)] = 0
          notify.event(owner, city.tile, E.CITY_TRANSFER,
                       _("Your Lawyer closed the %s franchise in %s."),
                       by.nation:name_translation(), city:link_text())
          notify.event(by, city.tile, E.CITY_TRANSFER,
                       _("Your franchise in %s was closed by a lawsuit."),
                       city:link_text())
        else
          ctp2_pay(owner, by,
                   math.max(1, city.size * CTP2_FRANCHISE_FACTOR // 5))
        end
      end
    end
  end
end

signal.connect("turn_begin", "ctp2_specials_turn")

-- Call to Power II Feats of Wonder.
-- Only the first civilization to accomplish a feat gets it. Its bonus is
-- a "Feat: ..." small wonder (effects.ruleset) kept in that
-- civilization's capital for a number of turns. State is kept in global
-- numbers (ctp2_feat_by_<n> = player id + 1, ctp2_feat_until_<n> = last
-- turn of the bonus, -1 once it ended) so that it is saved with the game.

local ctp2_feats = {
  { name = "Concrete", turns = 15, tech = "Concrete" },
  { name = "Gunpowder", turns = 25, tech = "Gunpowder" },
  { name = "Mass Production", turns = 15, tech = "Mass Production" },
  { name = "Computer", turns = 15, tech = "Computer" },
  { name = "Robotics", turns = 15, tech = "Robotics" },
  { name = "Life Extension", turns = 15, tech = "Life Extension" },
  { name = "Theaters", turns = 15, building = "Theater", count = 8 },
  { name = "Brokerages", turns = 20, building = "Brokerage", count = 10 },
  { name = "Internet", turns = 25, building = "Computer Center", count = 12 },
  { name = "Syndicate", turns = 25, building = "Television", count = 15 },
  { name = "Orbital Labs", turns = 25, building = "Orbital Laboratory",
    count = 20 },
  { name = "Sailed Around the World", turns = 25, sailed = true },
  { name = "Conquered by Force", turns = 25, conquered = 5 },
  { name = "City Recaptured", turns = 10, recaptured = true },
}

local function ctp2_feat_building(feat)
  return find.building_type("Feat: " .. feat.name)
end

local function ctp2_feat_city(player)
  local capital = player:primary_capital()
  if capital ~= nil then
    return capital
  end
  for city in player:cities_iterate() do
    return city
  end
  return nil
end

local function ctp2_feat_achieved(n)
  return (_G[ctp2_var("ctp2_feat_by_", n)] or 0) > 0
end

function ctp2_feat_award(n, player)
  local feat = ctp2_feats[n]

  if ctp2_feat_achieved(n) then
    return
  end
  _G[ctp2_var("ctp2_feat_by_", n)] = math.floor(player.id) + 1
  _G[ctp2_var("ctp2_feat_until_", n)] = game.current_turn() + feat.turns

  local city = ctp2_feat_city(player)
  if city ~= nil then
    city:create_building(ctp2_feat_building(feat))
  end
  notify.all(_("Feat of Wonder: the %s have accomplished %s!"),
             player.nation:plural_translation(), _(feat.name))
  notify.event(player, nil, E.WONDER_BUILD,
               _("Our Feat of Wonder %s gives us a bonus for %d turns."),
               _(feat.name), feat.turns)
end

local function ctp2_feat_remove(feat, player)
  local building = ctp2_feat_building(feat)
  for city in player:cities_iterate() do
    if city:has_building(building) then
      city:remove_building(building)
    end
  end
end

-- Keep the feat buildings where they belong and end expired feats.
function ctp2_feats_turn(turn, year)
  for n, feat in ipairs(ctp2_feats) do
    local by = _G[ctp2_var("ctp2_feat_by_", n)] or 0
    local untl = _G[ctp2_var("ctp2_feat_until_", n)] or -1

    if by > 0 and untl >= 0 then
      local player = find.player(by - 1)
      if player == nil then
        _G[ctp2_var("ctp2_feat_until_", n)] = -1
      elseif turn > untl then
        ctp2_feat_remove(feat, player)
        _G[ctp2_var("ctp2_feat_until_", n)] = -1
        notify.event(player, nil, E.WONDER_OBSOLETE,
                     _("The bonus of our Feat of Wonder %s has ended."),
                     _(feat.name))
      else
        local building = ctp2_feat_building(feat)
        local found = false
        for city in player:cities_iterate() do
          if city:has_building(building) then
            found = true
          end
        end
        if not found then
          -- Small wonders are lost with their city: move it.
          local city = ctp2_feat_city(player)
          if city ~= nil then
            city:create_building(building)
          end
        end
      end
    end
  end

  -- Remember the largest size of every civilization, for
  -- "Conquered by Force".
  for player in players_iterate() do
    local var = ctp2_var("ctp2_max_cities_", player.id)
    _G[var] = math.max(_G[var] or 0, player:num_cities())
  end
end

signal.connect("turn_begin", "ctp2_feats_turn")

function ctp2_feats_tech(tech, player, source)
  local name = tech:rule_name()

  for n, feat in ipairs(ctp2_feats) do
    if feat.tech == name and not ctp2_feat_achieved(n) then
      local first = true
      for other in players_iterate() do
        if other ~= player and other:knows_tech(tech) then
          first = false
        end
      end
      if first then
        ctp2_feat_award(n, player)
      end
    end
  end
end

signal.connect("tech_researched", "ctp2_feats_tech")

function ctp2_feats_building(building, city)
  local name = building:rule_name()

  for n, feat in ipairs(ctp2_feats) do
    if feat.building == name and not ctp2_feat_achieved(n) then
      local count = 0
      for other in city.owner:cities_iterate() do
        if other:has_building(building) then
          count = count + 1
        end
      end
      if count >= feat.count then
        ctp2_feat_award(n, city.owner)
      end
    end
  end
end

signal.connect("building_built", "ctp2_feats_building")

function ctp2_feats_city_transferred(city, loser, winner, reason)
  if reason ~= "conquest" then
    return
  end
  for n, feat in ipairs(ctp2_feats) do
    if not ctp2_feat_achieved(n) then
      if feat.recaptured and city.original == winner then
        ctp2_feat_award(n, winner)
      elseif feat.conquered and loser:num_cities() == 0
             and (_G[ctp2_var("ctp2_max_cities_", loser.id)] or 0)
                 >= feat.conquered then
        ctp2_feat_award(n, winner)
      end
    end
  end
end

signal.connect("city_transferred", "ctp2_feats_city_transferred")

-- Sailing around the world: a ship that visits every column of a map
-- that wraps east-west. Progress is not saved with the game.
local ctp2_sail_columns = {}
local ctp2_sail_xsize = nil

local ctp2_sail_feat = nil
for n, feat in ipairs(ctp2_feats) do
  if feat.sailed then
    ctp2_sail_feat = n
  end
end

function ctp2_feats_unit_moved(unit, src_tile, dst_tile)
  local n = ctp2_sail_feat

  if ctp2_feat_achieved(n)
     or dst_tile.terrain:class_name() ~= "Oceanic" then
    return
  end
  if ctp2_sail_xsize == nil then
    local wrap = server.setting.get("wrap") or ""
    if string.find(wrap, "WRAPX") then
      ctp2_sail_xsize = tonumber(server.setting.get("xsize")) or 0
    else
      ctp2_sail_xsize = 0
    end
  end
  if ctp2_sail_xsize <= 0 then
    return
  end

  local id = math.floor(unit.id)
  local seen = ctp2_sail_columns[id]
  if seen == nil then
    seen = { count = 0 }
    ctp2_sail_columns[id] = seen
  end
  local column = math.floor(dst_tile.id) % ctp2_sail_xsize
  if not seen[column] then
    seen[column] = true
    seen.count = seen.count + 1
    if seen.count >= ctp2_sail_xsize then
      ctp2_feat_award(n, unit.owner)
    end
  end
end

signal.connect("unit_moved", "ctp2_feats_unit_moved")
