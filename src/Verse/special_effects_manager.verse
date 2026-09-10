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


special_effects_manager := class<concrete>:

    @editable BlinkingEffectDelay<private> : float = 0.2
    @editable BlinkingEffectAmount<private> : int = 5
    @editable IsInvincibleWhileBlinking<private> : logic = true
    @editable IsBlinking<private> : logic = true
    @editable HealToMax<private> : logic = true    
    StopEvent<private>: event() = event(){}  

    BlinkingInvincibilityEffect<public>(F:fort_character)<suspends>:void=
        race:
            StopEvent.Await()
            block:
                if(HealToMax?):
                    F.SetHealth(F.GetMaxHealth())
                    F.SetShield(F.GetMaxHealth())
                if(IsInvincibleWhileBlinking?):
                    F.SetVulnerability(false)
                if(IsBlinking?):
                    for(I:=1 .. BlinkingEffectAmount):
                        F.Hide()
                        Sleep(BlinkingEffectDelay)
                        F.Show()
                        Sleep(BlinkingEffectDelay)
                else{Sleep(BlinkingEffectAmount * BlinkingEffectDelay)}
                if(IsInvincibleWhileBlinking?):
                    F.SetVulnerability(true)
        Sleep(2.0)
        F.SetVulnerability(true)
        F.Show()

    InvisibleInvincibilityEffect<public>(F:fort_character)<suspends>:void=
        race:
            StopEvent.Await()
            block:
                F.SetHealth(F.GetMaxHealth())
                F.SetShield(F.GetMaxHealth())
                F.Hide()
                Sleep(BlinkingEffectDelay)
                F.SetVulnerability(false)


    ResetSettings<public>(F:fort_character):void=
        StopEvent.Signal()
        F.SetVulnerability(true)
        F.Show()