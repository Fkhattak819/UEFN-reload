using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

out_of_bounds_manager := class(creative_device):
    # Place these at opposite arena corners. Their transforms are the bounds source.
    @editable MaxPositionProp : creative_prop = creative_prop{}
    @editable MinPositionProp : creative_prop = creative_prop{}
    @editable Offset : float = 50.0 
    @editable MinimumBoundsSize : float = 100.0

    # Call this whenever you are moving a player to a new location 
    # It will return a new position that is inside the arena
    Check<public>(IncomingV:vector3):vector3=
        return CheckWithSource("Unknown", IncomingV)

    CheckWithSource<public>(Source : string, IncomingV:vector3):vector3=
        BoundsA := MinPositionProp.GetTransform().Translation
        BoundsB := MaxPositionProp.GetTransform().Translation

        var MinX : float = BoundsA.X
        var MaxX : float = BoundsB.X
        if (MinX > MaxX):
            set MinX = BoundsB.X
            set MaxX = BoundsA.X

        var MinY : float = BoundsA.Y
        var MaxY : float = BoundsB.Y
        if (MinY > MaxY):
            set MinY = BoundsB.Y
            set MaxY = BoundsA.Y

        var MinZ : float = BoundsA.Z
        var MaxZ : float = BoundsB.Z
        if (MinZ > MaxZ):
            set MinZ = BoundsB.Z
            set MaxZ = BoundsA.Z

        BoundsSizeX := MaxX - MinX
        BoundsSizeY := MaxY - MinY
        BoundsSizeZ := MaxZ - MinZ

        if(BoundsSizeX <= MinimumBoundsSize and BoundsSizeY <= MinimumBoundsSize):
            LogError("Bounds", "{Source} skipped bounds clamp because min/max props are not far enough apart. Link MinPositionProp and MaxPositionProp on the placed out_of_bounds_manager device.")
            return IncomingV

        var ReturnV : vector3 = IncomingV
        var WasClamped : logic = false

        # X Axis checking
        if(BoundsSizeX > MinimumBoundsSize):
            if(IncomingV.X > MaxX):
                set ReturnV.X = MaxX - Offset
                set WasClamped = true
            if(IncomingV.X < MinX):
                set ReturnV.X = MinX + Offset
                set WasClamped = true

        # Y Axis checking
        if(BoundsSizeY > MinimumBoundsSize):
            if(IncomingV.Y > MaxY):
                set ReturnV.Y = MaxY - Offset
                set WasClamped = true
            if(IncomingV.Y < MinY):
                set ReturnV.Y = MinY + Offset
                set WasClamped = true

        # Z Axis checking
        if(BoundsSizeZ > MinimumBoundsSize):
            if(IncomingV.Z > MaxZ):
                set ReturnV.Z = MaxZ - (Offset * 2.0)
                set WasClamped = true
            if(IncomingV.Z < MinZ):
                set ReturnV.Z = MinZ + (Offset * 2.0)
                set WasClamped = true

        if(WasClamped?):
            LogWarning("Bounds", "{Source} clamped destination. Incoming={IncomingV}, Clamped={ReturnV}, MinX={MinX}, MinY={MinY}, MinZ={MinZ}, MaxX={MaxX}, MaxY={MaxY}, MaxZ={MaxZ}.")

        return ReturnV

    IsInBounds<public>(IncomingV:vector3)<transacts>:logic=
        BoundsA := MinPositionProp.GetTransform().Translation
        BoundsB := MaxPositionProp.GetTransform().Translation

        var MinX : float = BoundsA.X
        var MaxX : float = BoundsB.X
        if (MinX > MaxX):
            set MinX = BoundsB.X
            set MaxX = BoundsA.X

        var MinY : float = BoundsA.Y
        var MaxY : float = BoundsB.Y
        if (MinY > MaxY):
            set MinY = BoundsB.Y
            set MaxY = BoundsA.Y

        var MinZ : float = BoundsA.Z
        var MaxZ : float = BoundsB.Z
        if (MinZ > MaxZ):
            set MinZ = BoundsB.Z
            set MaxZ = BoundsA.Z

        BoundsSizeX := MaxX - MinX
        BoundsSizeY := MaxY - MinY
        BoundsSizeZ := MaxZ - MinZ

        if (BoundsSizeX > MinimumBoundsSize):
            if (IncomingV.X < MinX or IncomingV.X > MaxX):
                return false
        if (BoundsSizeY > MinimumBoundsSize):
            if (IncomingV.Y < MinY or IncomingV.Y > MaxY):
                return false
        if (BoundsSizeZ > MinimumBoundsSize):
            if (IncomingV.Z < MinZ or IncomingV.Z > MaxZ):
                return false

        return true
