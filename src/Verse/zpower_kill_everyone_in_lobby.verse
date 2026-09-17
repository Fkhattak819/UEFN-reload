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


# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.


kill_everyone_power := class<concrete>(power_base):
    #This power kills half

    @editable BPMover : creative_prop = creative_prop{}
    @editable BPDestination : creative_prop = creative_prop{}
    @editable AudioPlayerDevice : audio_player_device = audio_player_device{}
    @editable ExplosiveDevice : explosive_device = explosive_device{}
    @editable UIText : string = "KILL HALF THE LOBBY | 1 USE"
    @editable UITextFinished : string = "NO MORE USES"
    @editable PlayTime : float = 0.5
    @editable AbilityCooldown : float = 45.0

    var MaybeTimerUI : ?Timer = false

    Init<public>(CTimer : Timer):void=
        set MaybeTimerUI = option{CTimer}
        CTimer.Update(UIText) 

    UpdateUI<private>():void=
        if(TimerUI := MaybeTimerUI?):
            TimerUI.Update(UITextFinished) 
 
    ActivateAbility(Agent : agent, CPMap : [agent]CustomPlayer)<suspends>:void=
        if(FC := Agent.GetFortCharacter[]):
            AudioPlayerDevice.Play(Agent)
            FC.SetVulnerability(false)
            ExplosiveDevice.Explode(Agent)
            Agents := GetActiveAgentsArray(Agent, CPMap)
            # if. BPMover.TeleportTo[BPDestination.GetTransform().Translation, rotation{}]
            UpdateUI()

            # for(Index -> MyAgent : Agents, OtherFC := MyAgent.GetFortCharacter[]):
            #     OtherFC.PutInStasis(stasis_args{AllowTurning := true})
            Sleep(PlayTime)
            for(Index -> MyAgent : Agents, OtherFC := MyAgent.GetFortCharacter[]):
                OtherFC.SetVulnerability(true)
                OtherFC.ReleaseFromStasis()
            Sleep(0.1)
            spawn. DamageAgents(Agents, FC)
           
            if(BPMover.TeleportTo[TeleAwayPos,rotation{}]){Print("Brought Everthing Away")}

            FC.SetVulnerability(true)
            ExplosiveDevice.Reset()

    GetActiveAgentsArray<private>(A : agent, AllCPMap:[agent]CustomPlayer):[]agent=
        var AgentArray : []agent = array{}
        var I : int = 0
        for(Key -> Value : AllCPMap):
            IsInLobby := Value.GetIsInLobby()
            # if player is not in lobby = player active?
            if(not IsInLobby? and A <> Key and Mod[I,2] = 0):
                set AgentArray += array{Key}
            set I += 1
        
        return AgentArray

    DamageAgents(AgentToDamage : []agent, FC : fort_character)<suspends>:void =
        for(Index -> MyAgent : AgentToDamage, OtherFC := MyAgent.GetFortCharacter[]):
            Sleep(0.1)
            OtherFC.Damage(damage_args{Amount := 1000.0, Instigator := option{FC}, Source := option {custom_game_action_causer{} }})