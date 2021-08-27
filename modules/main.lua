require("modules.preparing")
require("modules.replicating")
require("modules.global")
require("modules.inventory")
require("modules.pos")

Main = {}

function Main.run()
    while true do
        print("main.run")
        local prep = PreparingPhase:new()
        prep:run()
        local rep = ReplicatingPhase:new()
        rep:run()
    end
end

function Main.start()
    --pcall(Main.run)
    --os.reboot()
    Main.run()
end