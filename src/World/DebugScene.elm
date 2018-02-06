module World.DebugScene exposing (..)

import Slime exposing (..)
import World.Model exposing (..)
import World.Components exposing (..)
import Char
import Dict
import Game.TwoD.Camera exposing (viewportToGameCoordinates)
import QuickMath exposing (..)


debugScene1 : WorldModel -> WorldModel
debugScene1 world =
    (world |> forNewEntity)
        &=> ( transforms, { x = 0, y = 0, width = 1, height = 1 } )
        &=> ( guns, { sinceLast = 0, cooldown = 0.25 } )
        |> Tuple.second


debugMover : Float -> WorldModel -> WorldModel
debugMover dt ({ inputState } as world) =
    let
        moveBy ( x, y ) a =
            Debug.log "Moved" { a | x = a.x + x, y = a.y + y }

        directions =
            [ ( 'A', ( -dt, 0 ) )
            , ( 'W', ( 0, dt ) )
            , ( 'S', ( 0, -dt ) )
            , ( 'D', ( dt, 0 ) )
            ]

        stepDirection ( key, direction ) aWorld =
            case Dict.get (Char.toCode key) inputState.keyState of
                Just True ->
                    stepEntities (entities transforms) (\ent -> { ent | a = moveBy direction ent.a }) aWorld

                _ ->
                    aWorld
    in
        List.foldl stepDirection world directions


debugShooter : Float -> WorldModel -> WorldModel
debugShooter dt ({ inputState, renderConfig } as world) =
    let
        ( worldX, worldY ) =
            viewportToGameCoordinates renderConfig.camera ( 800, 600 ) ( inputState.mouseState.x, inputState.mouseState.y )

        shootAt { x, y } ({ a, b } as ent) =
            ( { ent | b = { b | sinceLast = 0 } }
            , \newWorld ->
                forNewEntity newWorld
                    &=> ( transforms, { x = a.x - 0.1, y = a.y - 0.1, width = 0.2, height = 0.2 } )
                    &=> ( inertias, normalizeScale 6 { vx = x - a.x, vy = y - a.y, falls = True } )
                    |> Tuple.second
            )

        tickGun ({ b } as ent) =
            if b.sinceLast > b.cooldown then
                if inputState.mouseState.down then
                    shootAt { x = worldX, y = worldY } ent
                else
                    ( ent, identity )
            else
                ( { ent | b = { b | sinceLast = b.sinceLast + dt } }, identity )
    in
        stepEntitiesAndThen (entities2 transforms guns) tickGun world
