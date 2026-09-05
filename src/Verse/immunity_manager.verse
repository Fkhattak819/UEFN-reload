
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
immunity_manager := class<concrete>():

    @editable ProtectVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    Apply(EnemyAgent : agent)<suspends>:void= 
        if(FC := EnemyAgent.GetFortCharacter[]):
            FC.SetVulnerability(false)
            ProtectVFX.Pickup(EnemyAgent)
            Sleep(0.8)
            FC.SetVulnerability(true)

    ApplyBoth(InstigatorAgent : agent, EnemyAgent : agent)<suspends>:void= 
        if(IFC := InstigatorAgent.GetFortCharacter[], FC := EnemyAgent.GetFortCharacter[]):
            FC.SetVulnerability(false)
            IFC.SetVulnerability(false)
            ProtectVFX.Pickup(EnemyAgent)
            ProtectVFX.Pickup(InstigatorAgent)
            Sleep(0.8)
            FC.SetVulnerability(true)
            IFC.SetVulnerability(true)