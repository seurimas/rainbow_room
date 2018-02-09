module QuickMath exposing (..)

import Vector2


type alias Rectangle =
    { x : Float, y : Float, width : Float, height : Float }


type alias Vector =
    Vector2.Float2


normalizeScale : Float -> Vector -> Vector
normalizeScale scale ( vx, vy ) =
    let
        size2 =
            vx * vx + vy * vy

        size =
            sqrt size2
    in
        if size2 > 0 then
            ( scale * vx / size, scale * vy / size )
        else
            ( 0, 0 )


rotate : Float -> Vector -> Vector
rotate amount ( vx, vy ) =
    let
        cosT =
            cos amount

        sinT =
            sin amount
    in
        ( vx * cosT - vy * sinT, vx * sinT + vy * cosT )


collides : Rectangle -> Rectangle -> Bool
collides me them =
    not
        ((me.x > them.x + them.width)
            || (me.x + me.width < them.x)
            || (me.y > them.y + them.height)
            || (me.y + me.height < them.y)
        )


type HDir
    = Left
    | Right


sign : Float -> Float
sign val =
    if val < 0 then
        -1
    else
        1


rect ( x, y, width, height ) =
    { x = x, y = y, width = width, height = height }


pos { x, y } =
    ( x, y )


size { width, height } =
    ( width, height )


center { x, y, width, height } =
    ( x + width / 2, y + height / 2 )
