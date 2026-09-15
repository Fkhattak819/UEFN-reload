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

fly_power := class<concrete>(power_base):

    @editable
    ClassSelector : class_and_team_selector_device = class_and_team_selector_device{}

    StartEvent<private>: event() = event(){}
    StartPower<public>():void= StartEvent.Signal()

    Init(Agent : agent)<suspends>:void=
        # StartEvent.Await() # Waiting for game to start
        ClassSelector.ChangeClass(Agent)