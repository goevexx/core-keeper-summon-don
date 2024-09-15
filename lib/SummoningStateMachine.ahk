#Requires AutoHotkey v2.0

; The Machine managing the summoning state
class SummoningStateMachine {
    __New(summonThreshhold := 10000) {
        this.initState()
        this.summonThreshhold := summonThreshhold
    }

    initState(){
        this.setState(IdleState(this))
    }

    setState(state) {
        if(HasProp(this, "currentState")){
            previoustateName := this.currentState.__Class
        } else {
            previoustateName := "(no state)"
        }
        this.currentState := state
    }

    handleState(){
        this.currentState.handle()
    }

    reset() {
        this.initState()
    }

    setWindowBoundaries(windowWidth, windowHeight){
        this.windowWidth := windowWidth
        this.windowHeight := windowHeight
        this.clickX := windowWidth * 3/4
        this.clickY := windowHeight / 2
    }
    
    areWindowBoundriesSet(){
        return HasProp(this, "windowWidth") and HasProp(this, "windowHeight") and HasProp(this, "clickX") and HasProp(this, "clickY")
    }
}

; The way your current state looks like while you are summoning
class SummoningStateMachineState {
    __New(context) {
        this.context := context
        this.startTime := A_TickCount
    }

    ; Sets the context's state
    changeState(state){
        this.context.setState(state)
    }

    ; Needs to be implemented in subclasses
    handle(){
    }

    ; Get's elapsed time in ms
    getElapsedTime(){
        elapsedTime := A_TickCount - this.startTime
        return elapsedTime
    }

    clickX => this.context.clickX
    clickY => this.context.clickY
}


; State implementations

class IdleState extends SummoningStateMachineState {
    handle(){
        this.startSummoning()
    }

    startSummoning(){
        this.changeState(AggroState(this.context))
    }
}

; Take Aggro
class AggroState extends SummoningStateMachineState {
    handle(){
        this.takeRangedWeapon()
        this.aggro()
        this.changeState(SummonState(this.context))
    }

    takeRangedWeapon() {
        SendInput("9")
        Sleep(200)
    }

    aggro() {
        Click(this.clickX, this.clickY, "Left")
        Sleep(200)
    }
}

; Summon
class SummonState extends SummoningStateMachineState {
    __New(context) {
        super.__New(context)
        this.tomeInHand := false
        this.lastTimeSummoned := -10000
        this.summoned := false
    }

    handle() {
        if(!this.tomeInHand) {
            this.takeTome()
            this.tomeInHand := true
        }
        if(!this.summoned){
            this.summon()
        }
        if(this.getMillisecondsSinceLastSummon() > 5000){
            this.changeState(AggroState(this.context))
        }
    }

    takeTome() {
        SendInput("0")
        Sleep(200)
    }

    getMillisecondsSinceLastSummon(){
        return A_TickCount - this.lastTimeSummoned
    }

    summon() {
        Click(this.clickX, this.clickY, "Right")
        Sleep(200)
        this.summoned := true
        this.lastTimeSummoned := A_TickCount
    }
}

