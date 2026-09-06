
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

team_manager := class(creative_device):

    SoloTeamCapacity<private> : int = 1
    DefaultTeamCount<private> : int = 12

    PowerTeamAssignments<private> : [int]int = map{
        10 => 2
        29 => 3
        38 => 4
    }

    AddPlayerToDefaultTeam<public>(JoiningPlayer : player):void=
        var TeamList : []team = array{}
        set TeamList = Self.GetPlayspace().GetTeamCollection().GetTeams()
        var TeamOffset : int = 0
        loop:
            if(TeamOffset >= DefaultTeamCount - 1):
                Print("Error: Failed to Find a Team for Player!")
                break
            if(CandidateTeam := TeamList[TeamOffset], Members := GetPlayspace().GetTeamCollection().GetAgents[CandidateTeam]):
                if(Members.Length = SoloTeamCapacity,Members[0] = agent[JoiningPlayer]):
                    Print("Success: Player already in his own team.")
                    break
                if(Members.Length <= 0, PlayerAgent := agent[JoiningPlayer]):
                    if(GetPlayspace().GetTeamCollection().AddToTeam[PlayerAgent, CandidateTeam]):
                        Print("Success: Player added to a new team.")
                        break
                    else{Print("Error: Failed to add player to team index:{TeamOffset}")}
            else{Print("?Could not find team?")}
            set TeamOffset += 1

    ResetTeams<public>(PlayerStates : [agent]CustomPlayer):void=
        var TeamList : []team = array{}
        set TeamList = Self.GetPlayspace().GetTeamCollection().GetTeams()
        var TeamOffset : int = 0
        for(MemberAgent -> MemberState : PlayerStates):
            if(CandidateTeam := TeamList[TeamOffset], GetPlayspace().GetTeamCollection().AddToTeam[MemberAgent, CandidateTeam]){}
            set TeamOffset += 1

    CheckForTeamChange<public>(PlayerState:CustomPlayer):void=
        SelectedPower := PlayerState.GetPowerUp()
        if(AssignedTeamNumber := PowerTeamAssignments[SelectedPower]):
            var TeamList : []team = array{}
            set TeamList = Self.GetPlayspace().GetTeamCollection().GetTeams()
            SwitchingAgent := PlayerState.MyAgentObj
            if(DestinationTeam := TeamList[AssignedTeamNumber - 1]):
                if(Members := GetPlayspace().GetTeamCollection().GetAgents[DestinationTeam], Members.Length = SoloTeamCapacity):
                    Print("Power Index {SelectedPower} cant be switched to {AssignedTeamNumber - 1}, since this team is already full")
                else:
                    if(GetPlayspace().GetTeamCollection().AddToTeam[SwitchingAgent, DestinationTeam]):
                        Print("Power Index {SelectedPower} Switched to team Index {AssignedTeamNumber - 1}")

    CheckIfTeamsAreEqual<public>():void=
        var TeamList : []team = array{}
        set TeamList = Self.GetPlayspace().GetTeamCollection().GetTeams()
        var OccupiedTeams : int = 0
        var EmptyTeams : int = 0
        for(TeamOffset := 0 .. TeamList.Length - 1):
            if(CandidateTeam := TeamList[TeamOffset], Members := GetPlayspace().GetTeamCollection().GetAgents[CandidateTeam]):
                if(Members.Length = SoloTeamCapacity):
                    set OccupiedTeams += 1
                else if(Members.Length = 0):
                    set EmptyTeams += 1
                else:
                    if(Members.Length > SoloTeamCapacity):
                        Print("Team not correctly set up")
        Print("{OccupiedTeams} teams are set up correctly (Team Size 1),\n{EmptyTeams} teams are empty")
