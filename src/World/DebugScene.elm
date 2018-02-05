module World.DebugScene exposing (..)

import Slime exposing (..)
import World.Model exposing (..)
import World.Components exposing (..)
import Char
import Dict


debugScene1 : WorldModel -> WorldModel
debugScene1 world =
    (world |> forNewEntity)
        &=> ( transforms, { x = 0, y = 0, width = 1, height = 1 } )
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
            case Dict.get (Char.toCode key) inputState of
                Just True ->
                    stepEntities (entities transforms) (\ent -> { ent | a = moveBy direction ent.a }) aWorld

                _ ->
                    aWorld
    in
        List.foldl stepDirection world directions
