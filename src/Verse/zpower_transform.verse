
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

# A Verse-authored creative device that can be placed in a level
transform_power := class<concrete>(power_base):

    @editable AbilityDuration : float = 8.0
    @editable AbilityCooldown : float = 30.0
    @editable Mover : creative_prop = creative_prop{} 
    @editable ItemGranter : item_granter_device = item_granter_device{}
    @editable ItemChecker : conditional_button_device = conditional_button_device{}
    @editable AudioPlayer : audio_player_device = audio_player_device{}
    @editable ImmunityManager : immunity_manager = immunity_manager{}
    StopEvent<private>: event() = event(){}  

    ActivateAbility(Instigator : agent, Target : agent)<suspends>:void=
        if(ItemChecker.IsHoldingItem[Instigator]):
            if(IFC := Instigator.GetFortCharacter[], TFC := Target.GetFortCharacter[]):
                TFC.Hide()
                AudioPlayer.Play(Target)
                race:
                    StopEvent.Await()
                    loop:
                        block:
                            TPos := TFC.GetTransform().Translation
                            TRo := TFC.GetTransform().Rotation
                            Mover.MoveTo(TPos,TRo,0.1)
                    Sleep(AbilityDuration)

                Print("Race Broke Transfrom Power")
                Mover.MoveTo(TeleAwayPos,rotation{},0.1)
                TFC.Show()
                spawn. ImmunityManager.Apply(Target)

    Delete():void=
        StopEvent.Signal()