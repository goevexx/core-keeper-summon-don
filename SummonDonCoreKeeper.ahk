#SingleInstance Force
#Include "lib/SummoningStateMachine.ahk"

readyToStart := false
startSummoning := false
instructions := "1. Open Core Keeper.`n2. Fill up your inventory with as many tomes you can find. They will break.`n3. Move your character to a position so that an active spawner(e.g. with an stone mushroom statue inside) is on your right side behind a hole in the ground.`n4. Make sure the spawner is also completely secured with holes or walls.`n5. Put a tome into your fast access slot with hotkey 0 and one ranged weapon into the slot with hotkey 9.`n6. Press CTRL + F to get started power up your combat skill.`n`nControls:`nPress CTRL + F to stop/start the procedure`nPress CTRL + Q to quit this script"

resultOk := MsgBox("Hey there core keepers`n`nIt's a nice day to go summoning, ain't it? Huho.`n`n" . instructions, "Core Keeper - SummonDon", 0)
readyToStart := resultOk = "OK"
if !readyToStart
    ExitApp

summoningMachine := SummoningStateMachine()
Loop {
    if (!startSummoning) {
        continue
    }

    If !WinExist("Core Keeper") {
        MsgBox("Core Keeper is not open. You need to obey:`n`n" . instructions, "SummonDon - Core Keeper not open", "OK")
        startSummoning := false
        summoningMachine.reset()
        continue
    }
    If !WinActive("Core Keeper") {
        yesResult := MsgBox("Core Keeper needs to be your active window.`n`nWait, let me activate it...", "SummonDon - Core Keeper not active", "YesNo")
        if (yesResult = "Yes"){
            WinActivate("Core Keeper")
            setMachinesWindowBoundries()
            startSummoning := true
        } else if (yesResult = "No"){
            startSummoning := false
        }
        summoningMachine.reset()
        continue
    } else if (!summoningMachine.areWindowBoundriesSet()){
        setMachinesWindowBoundries()
    }

    summoningMachine.handleState()
}

setMachinesWindowBoundries(){
    global summoningMachine
    WinGetPos(&WinX, &WinY, &WinW, &WinH)
    summoningMachine.setWindowBoundaries(WinW, WinH)
}

$^f::{
    global
    if(readyToStart) {
        startSummoning := !startSummoning
        summoningMachine.reset()
    }
}
$^q::ExitApp