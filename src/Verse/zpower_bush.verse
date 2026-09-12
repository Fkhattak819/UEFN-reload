using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using {/Verse.org/Colors/NamedColors }
using { /Fortnite.com/Characters }
using { /Verse.org/Colors }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }

bush_power := class<concrete>(power_base):

    @editable BushBP : creative_prop_asset = DefaultCreativePropAsset
    @editable HealDelay : float = 1.5
    @editable MaxDistanceFromBushToHeal : float = 500.0
    @editable HealingAmount : float = 5.0
    @editable AbilityCooldown : float = 10.0
    @editable HealWhite : logic = true
    @editable HealBlue : logic =  false
    @editable BushSpawnOffset : vector3 = vector3{X:=0.0,Y:=0.0,Z:=30.0}
    @editable StackedHealing : logic = false # when multiple bushes are at the same location 
    @editable Size : vector3 = vector3{X:=0.3,Y:=0.3,Z:=0.3}
    var BushArray : []creative_prop = array{}
    var IsPowerActive : logic = false
    StopEvent<private>: event() = event(){}

    # @editable UIText : string = "Healing done: "
    # var HealingDone : float = 0.0
    # var MaybeTimerUI : ?Timer = false

    # Init<public>(TimerUI:Timer):void=

    #     set HealingDone = 0.0
    #     set MaybeTimerUI = option{TimerUI}
    #     TimerUI.ShowTimer()
    #     UpdateUI()

    # UpdateUI<private>():void=
    #     if(RoundedNumber := Round[HealingDone], TimerUI := MaybeTimerUI?):
    #         TimerUI.Update(UIText + "{RoundedNumber}") 
    
    # Stop/Reset Powerup
    Delete<public>():void=
        StopEvent.Signal()
        for(Bush : BushArray):
            Bush.Dispose()
        set BushArray = array{}
        set IsPowerActive = false
        Print("Bush Deleted")

    # Active
    Algo<public>(F:fort_character)<suspends>:void=
        set IsPowerActive = true
        var RecievedHealingAlready : logic = false
        race:
            StopEvent.Await()
            loop:
                if(BushArray.Length <= 0){break} # Added this to break if no bushes active
                Sleep(HealDelay)
                FortPos := F.GetTransform().Translation
                set RecievedHealingAlready = false
                for(I -> Bush : BushArray):
                    if(not StackedHealing?,RecievedHealingAlready?){Print("StackedHealing not enabled, so not healing again at the same spot")}
                    else:
                        # If bush is still in the game(not been destroyed yet)
                        if(not Bush.IsDisposed[]):
                            # Maybe instead bush we add a VFX and within that area they have increased healing?
                            # Change to DistanceXY if its from floor to ceiling
                            if(Distance(FortPos,Bush.GetTransform().Translation) <= MaxDistanceFromBushToHeal): 
                                Print("Inside healing range of bush")
                                set RecievedHealingAlready = true
                                if(HealWhite?):
                                     F.SetHealth(F.GetHealth() + HealingAmount)
                                     #set HealingDone += HealingAmount
                                if(HealBlue?):
                                    F.SetShield(F.GetShield() + HealingAmount)
                                    #set HealingDone += HealingAmount
                                #UpdateUI()
                            else:
                                # Troubleshooting
                                Print("Info print:\nBush Index:{I}\n"+
                                "Current Distance:{Distance(FortPos,Bush.GetTransform().Translation)}"+
                                "\nHeal Distance{MaxDistanceFromBushToHeal}")
                        else:
                            Print("Bush no longer exists")
                            # Can i remove elements in the array im currrently looping over?
                            if(NewBushArray := BushArray.RemoveElement[I]):
                                set BushArray = NewBushArray
                                Print("Removing it from array")
        Print("Loop Canceled")
        set IsPowerActive = false

    # When he uses remote control
    ActivatePowerup<public>(A:agent)<suspends>:void=
        if(F:=A.GetFortCharacter[]):
            MaybeBushProp := SpawnProp(BushBP,F.GetTransform().Translation + BushSpawnOffset, rotation{})(0)
            if(BushProp := MaybeBushProp?):
                T := transform:
                    Translation := F.GetTransform().Translation + BushSpawnOffset,
                    Rotation := rotation{},
                    Scale := Size
                if(BushProp.TeleportTo[T]){}
                set BushArray += array{BushProp}
            if(not IsPowerActive?):
                spawn { Algo(F) }