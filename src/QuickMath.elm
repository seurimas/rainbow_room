module QuickMath exposing (..)


type alias Rectangle o =
    { o | x : Float, y : Float, width : Float, height : Float }


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


rotate : Float -> Vector o -> Vector o
rotate amount ({ vx, vy } as vec) =
    let
        cosT =
            cos amount

        sinT =
            sin amount
    in
        { vec | vx = vx * cosT - vy * sinT, vy = vx * sinT + vy * cosT }


collides : Rectangle o -> Rectangle o -> Bool
collides me them =
    not
        ((me.x - me.width / 2 > them.x + them.width / 2)
            || (me.x + me.width / 2 < them.x - them.width / 2)
            || (me.y - me.height / 2 > them.y + them.height / 2)
            || (me.y + me.height / 2 < them.y - them.height / 2)
        )
