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
    (((world |> forNewEntity)
        &=> ( transforms, { x = 2, y = 3, width = 1, height = 1 } )
        &=> ( inertias, { vx = 0, vy = 0, falls = True } )
        &=> ( solids, Object )
        &=> ( players, True )
        &=> ( guns, { sinceLast = 0, cooldown = 0.25, spread = 0.2, projectileCount = 8 } )
        |> Tuple.second
        |> forNewEntity
     )
        &=> ( transforms, { x = -2, y = -2, width = 2, height = 1 } )
        &=> ( barriers, North )
        |> Tuple.second
        |> forNewEntity
    )
        &=> ( transforms, { x = -1, y = -3, width = 1, height = 2 } )
        &=> ( barriers, East )
        |> Tuple.second


debugMover : Float -> WorldModel -> WorldModel
debugMover dt ({ inputState } as world) =
    let
        moveBy ( x, y ) ({ b } as ent) =
            { ent | b = { b | vx = x, vy = y } }

        directions =
            [ ( 'A', ( -1, 0 ) )
            , ( 'W', ( 0, 1 ) )
            , ( 'S', ( 0, -1 ) )
            , ( 'D', ( 1, 0 ) )
            ]

        stepDirection ( key, direction ) aWorld =
            case Dict.get (Char.toCode key) inputState.keyState of
                Just True ->
                    stepEntities (entities3 transforms inertias players) (moveBy direction) aWorld

                _ ->
                    aWorld
    in
        List.foldl stepDirection world directions
            |> stepEntities (entities3 transforms inertias players)
                (\({ a, b } as ent) ->
                    case Dict.get (Char.toCode ' ') inputState.keyState of
                        Just True ->
                            { ent | a = { a | x = 0, y = 0 }, b = { b | vx = 0, vy = 0 } }

                        _ ->
                            ent
                )


debugShooter : Float -> WorldModel -> WorldModel
debugShooter dt ({ inputState, renderConfig } as world) =
    let
        ( worldX, worldY ) =
            viewportToGameCoordinates renderConfig.camera ( 800, 600 ) ( inputState.mouseState.x, inputState.mouseState.y )

        shootAt { x, y } ({ a, b } as ent) =
            ( { ent | b = { b | sinceLast = 0 } }
            , \newWorld ->
                forNewEntities (List.range (-b.projectileCount // 2) ((b.projectileCount + 1) // 2))
                    newWorld
                    (\offset spawnPair ->
                        spawnPair
                            &=> ( transforms, { x = a.x + a.width / 2 - 0.1, y = a.y + a.height / 2 - 0.1, width = 0.2, height = 0.2 } )
                            &=> ( solids, Object )
                            &=> ( inertias
                                , normalizeScale 6
                                    { vx = x - a.x
                                    , vy = y - a.y
                                    , falls = True
                                    }
                                    |> rotate (toFloat offset * b.spread / toFloat b.projectileCount)
                                )
                    )
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
