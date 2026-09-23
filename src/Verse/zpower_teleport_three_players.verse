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

teleport_3_player_power := class<concrete>(remote_power_base):

    @editable TeleportLocationProps : []creative_prop = array{}
    @editable Teleporter : teleporter_device = teleporter_device{}
    @editable TeleporterMover : creative_prop = creative_prop{}
    @editable TeleSFX : audio_player_device = audio_player_device{}
    @editable FreezeTime : float = 1.0
    @editable AbilityCooldown : float = 30.0
    
    var MaybeTimerUI : ?Timer = false
    # @editable UIText : string = "Not Avaliable"
    var Subs : []cancelable = array{}

    Init<public>(Agent : agent, TimerUI:Timer):void=
        set MaybeTimerUI = option{TimerUI}
        TimerUI.ShowTimer()

    # UpdateUI<private>():void=
    #     if(TimerUI := MaybeTimerUI?):
    #         TimerUI.Update(UIText) 

    Delete<public>():void=
        set MaybeTimerUI = false
      
    ActivateAbility<public>(A:agent, AllCPMap : [agent]CustomPlayer)<suspends>:void=
        if(FC := A.GetFortCharacter[]):
            RemoteRemover.Remove(A)
            TeleSFX.Play(A)
            MyAgents := GetActiveAgentsArray(A, AllCPMap)
            Pos := FC.GetTransform().Translation
            Rot := FC.GetTransform().Rotation
            TeleporterMover.MoveTo(Pos, Rot, 0.1)
            for(Index -> Prop : TeleportLocationProps):
                if(Teleporter.TeleportTo[Prop.GetTransform().Translation, rotation{}]):
                    if(MyAgent := MyAgents[Index]):
                        Teleporter.Teleport(MyAgent)
                        if(MyFC := MyAgent.GetFortCharacter[]):
                            MyFC.PutInStasis(stasis_args{AllowTurning := true, AllowFalling := false, AllowEmotes := true})
                    else:
                        Print("No More Teleports")
            # UpdateUI()
            Sleep(FreezeTime)
            for(NewA : MyAgents, NFC := NewA.GetFortCharacter[]):
                NFC.ReleaseFromStasis()

    GetActiveAgentsArray<private>(A : agent, AllCPMap:[agent]CustomPlayer):[]agent=
        var AgentArray : []agent = array{}
        var I : int = 0
        for(Key -> Value : AllCPMap, I <= 2, Key <> A):
            IsInLobby := Value.GetIsInLobby()
            if(not IsInLobby?):
                set AgentArray += array{Key}
                set I += 1
        Shuffle(AgentArray)
        return AgentArray