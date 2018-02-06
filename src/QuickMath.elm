module QuickMath exposing (..)


type alias Vector o =
    { o | vx : Float, vy : Float }


normalizeScale : Float -> Vector o -> Vector o
normalizeScale scale ({ vx, vy } as o) =
    let
        size2 =
            vx * vx + vy * vy

        size =
            sqrt size2
    in
        if size2 > 0 then
            { o | vx = scale * vx / size, vy = scale * vy / size }
        else
            { o | vx = 0, vy = 0 }


normalize : Vector o -> Vector o
normalize =
    normalizeScale 1
