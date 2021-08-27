require("modules.main")

--Main.start()

io.output("output")

local rep = ReplicatingPhase:new()
rep.platformX = posX
rep.platformY = posY -1
rep.platformZ = posZ

Inventory.safeSort()

rep:craft("computercraft:turtle_normal")