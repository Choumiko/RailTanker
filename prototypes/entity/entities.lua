function copyPrototype(type, name, newName, change_results)
  if not data.raw[type][name] then error("type "..type.." "..name.." doesn't exist") end
  local p = table.deepcopy(data.raw[type][name])
  p.name = newName
  if p.minable and p.minable.result then
    p.minable.result = newName
  end
  if change_results then
    if p.place_result then
      p.place_result = newName
    end
    if p.result then
      p.result = newName
    end
  end
  return p
end
--<GotLag> just set the sprite scale to 0.9 and reduce the x shift to 1.72
local tanker = copyPrototype("cargo-wagon", "cargo-wagon", "rail-tanker", true)
tanker.icon = "__RailTanker__/graphics/rail-tanker.png"
tanker.inventory_size = 1
tanker.color = {r = 1.0, g = 1.0, b = 1.0, a = 0.5}
tanker.pictures =
  {
    priority = "very-low",
    width = 363,
    height = 231,
    axially_symmetrical = false,
    --back_equals_front = true,
    direction_count = 256,
    filenames =
    {
      "__RailTanker__/graphics/rail-tanker/rail-tanker-spritesheet-1.png",
      "__RailTanker__/graphics/rail-tanker/rail-tanker-spritesheet-2.png",
      "__RailTanker__/graphics/rail-tanker/rail-tanker-spritesheet-3.png",
      "__RailTanker__/graphics/rail-tanker/rail-tanker-spritesheet-4.png",
      "__RailTanker__/graphics/rail-tanker/rail-tanker-spritesheet-5.png",
      "__RailTanker__/graphics/rail-tanker/rail-tanker-spritesheet-6.png",
      "__RailTanker__/graphics/rail-tanker/rail-tanker-spritesheet-7.png",
      "__RailTanker__/graphics/rail-tanker/rail-tanker-spritesheet-8.png",
    },
    line_length = 4,
    lines_per_file = 8,
    shift={1.93, -0.38}
  --shift={1.72, -0.38},
  --scale = 0.9

  }

tanker.horizontal_doors = nil
tanker.vertical_doors = nil

data:extend{tanker}
data:extend(
  {
    {
      type = "storage-tank",
      name = "rail-tanker-proxy",
      icon = "__RailTanker__/graphics/trans-icon.png",
      flags = {"placeable-player", "player-creation", "placeable-off-grid"},
      max_health = 1,
      destructible = nil,
      minable = nil,
      --corpse = "medium-remnants",
      collision_box = {{-1.0, -1.0}, {1.0, 1.0}},
      collision_mask = {"ghost-layer"},
      selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
      --selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
      order="z",
      fluid_box =
      {
        base_area = 250,
        --pipe_covers = pipecoverspictures(),
        pipe_connections =
        {


          { position = {0.4, -1.2} },
          { position = {-0.4, -1.2} },
          -- { position = {1, -1.2} },
          -- { position = {-1, -1.2} },

          { position = {-0.4, 1.2} },
          { position = {0.4, 1.2} },
          -- { position = {1, 1.2} },
          -- { position = {-1, 1.2} },


          { position = {1.2, 0.4} },
          { position = {1.2, -0.4} },
          -- { position = {1.2, 1} },
          -- { position = {1.2, -1} },


          { position = {-1.2, 0.4} },
          { position = {-1.2, -0.4} },
        -- { position = {-1.2, 1} },
        -- { position = {-1.2, -1} },


        },
      },
      window_bounding_box = {{-0.125, 0.6875}, {0.1875, 1.1875}},
      pictures =
      {
        picture =
        {
          sheet =
          {
            filename = "__RailTanker__/graphics/trans.png",
            priority = "extra-high",
            frames = 1,
            width = 1,
            height = 1,
            shift = {0, 0}
          }
        },
        fluid_background =
        {
          filename = "__RailTanker__/graphics/trans.png",
          priority = "extra-high",
          width = 1,
          height = 1,
        },
        window_background =
        {
          filename = "__RailTanker__/graphics/trans.png",
          priority = "extra-high",
          width = 1,
          height = 1,
        },
        flow_sprite =
        {
          filename = "__RailTanker__/graphics/trans.png",
          priority = "extra-high",
          width = 1,
          height = 1,
        },
        gas_flow =
        {
          filename = "__RailTanker__/graphics/trans.png",
          priority = "extra-high",
          width = 1,
          height = 1,
          frame_count = 1,
        }
      },
      flow_length_in_ticks = 360,
      vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
      working_sound =
      {
        sound = {
          filename = "__base__/sound/storage-tank.ogg",
          volume = 0.8
        },
        apparent_volume = 1.5,
        max_sounds_per_type = 3
      },
      circuit_wire_connection_points =
      {
        {
          shadow =
          {
            red = {2.6875, 1.3125},
            green = {2.6875, 1.3125},
          },
          wire =
          {
            red = {1.1875, -0.28125},
            green = {1.1875, -0.28125},
          }
        },
        {
          shadow =
          {
            red = {0.21875, 1.1875},
            green = {0.21875, 1.1875},
          },
          wire =
          {
            red = {-1, -0.25},
            green = {-1, -0.25},
          }
        },
        {
          shadow =
          {
            red = {2.6875, 1.3125},
            green = {2.6875, 1.3125},
          },
          wire =
          {
            red = {1.1875, -0.28125},
            green = {1.1875, -0.28125},
          }
        },
        {
          shadow =
          {
            red = {0.21875, 1.1875},
            green = {0.21875, 1.1875},
          },
          wire =
          {
            red = {-1, -0.25},
            green = {-1, -0.25},
          }
        }
      },
      circuit_connector_sprites =
      {
        get_circuit_connector_sprites({-0.1875, -0.375}, nil, 7),
        get_circuit_connector_sprites({0.375, -0.53125}, nil, 1),
        get_circuit_connector_sprites({-0.1875, -0.375}, nil, 7),
        get_circuit_connector_sprites({0.375, -0.53125}, nil, 1),
      },
      circuit_wire_max_distance = 0.1
    },

    {
      type = "storage-tank",
      name = "rail-tanker-proxy-noconnect",
      icon = "__RailTanker__/graphics/trans-icon.png",
      flags = {"placeable-player", "player-creation", "placeable-off-grid"},
      max_health = 1,
      --corpse = "medium-remnants",
      collision_box = {{-1.0, -1.0}, {1.0, 1.0}},
      collision_mask = {"ghost-layer"},
      --selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
      selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
      order="z",
      fluid_box =
      {
        base_area = 250,
        -- pipe_covers = pipecoverspictures(),
        pipe_connections =
        {

        },
      },
      window_bounding_box = {{-0.125, 0.6875}, {0.1875, 1.1875}},
      pictures =
      {
        picture =
        {
          sheet =
          {
            filename = "__RailTanker__/graphics/trans.png",
            priority = "extra-high",
            frames = 1,
            width = 1,
            height = 1,
            shift = {0, 0}
          }
        },
        fluid_background =
        {
          filename = "__RailTanker__/graphics/trans.png",
          priority = "extra-high",
          width = 1,
          height = 1,
        },
        window_background =
        {
          filename = "__RailTanker__/graphics/trans.png",
          priority = "extra-high",
          width = 1,
          height = 1,
        },
        flow_sprite =
        {
          filename = "__RailTanker__/graphics/trans.png",
          priority = "extra-high",
          width = 1,
          height = 1,
        },
        gas_flow =
        {
          filename = "__RailTanker__/graphics/trans.png",
          priority = "extra-high",
          width = 1,
          height = 1,
          frame_count = 1,
        }
      },
      flow_length_in_ticks = 360,
      circuit_wire_connection_points =
      {
        {
          shadow =
          {
            red = {2.6875, 1.3125},
            green = {2.6875, 1.3125},
          },
          wire =
          {
            red = {1.1875, -0.28125},
            green = {1.1875, -0.28125},
          }
        },
        {
          shadow =
          {
            red = {0.21875, 1.1875},
            green = {0.21875, 1.1875},
          },
          wire =
          {
            red = {-1, -0.25},
            green = {-1, -0.25},
          }
        },
        {
          shadow =
          {
            red = {2.6875, 1.3125},
            green = {2.6875, 1.3125},
          },
          wire =
          {
            red = {1.1875, -0.28125},
            green = {1.1875, -0.28125},
          }
        },
        {
          shadow =
          {
            red = {0.21875, 1.1875},
            green = {0.21875, 1.1875},
          },
          wire =
          {
            red = {-1, -0.25},
            green = {-1, -0.25},
          }
        }
      },
      circuit_connector_sprites =
      {
        get_circuit_connector_sprites({-0.1875, -0.375}, nil, 7),
        get_circuit_connector_sprites({0.375, -0.53125}, nil, 1),
        get_circuit_connector_sprites({-0.1875, -0.375}, nil, 7),
        get_circuit_connector_sprites({0.375, -0.53125}, nil, 1),
      },
      circuit_wire_max_distance = 0.1
    },
  })
