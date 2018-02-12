module World.DebugScene exposing (..)

import Slime exposing (..)
import World.Model exposing (..)
import World.Components exposing (..)
import Char
import Dict
import Game.TwoD.Camera exposing (viewportToGameCoordinates)
import QuickMath exposing (..)
import Color


debugScene1 : WorldModel -> WorldModel
debugScene1 world =
    (((world |> forNewEntity)
        &=> ( transforms, { x = 2, y = 3, width = 1, height = 1 } )
        &=> ( inertias, ( 0, 0 ) )
        &=> ( players, initPlayer )
        &=> ( guns, { sinceLast = 0, cooldown = 0.25, spread = 0.2, projectileCount = 8 } )
        |> Tuple.second
     )
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
                            &=> ( painters, Color.blue )
                            &=> ( inertias
                                , normalizeScale 6
                                    ( x - a.x
                                    , y - a.y
                                    )
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
