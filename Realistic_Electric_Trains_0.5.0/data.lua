--data.lua

mod = "KNF_Realistic_Electric_Trains_fix"
path = "__" .. mod .. "__/"
graphics = path .. "graphics/"

require("config")
require("prototypes.items")
require("prototypes.entities")
require("prototypes.equipment")
require("prototypes.recipes")
require("prototypes.research")

require("compatibility.train_overhaul")
