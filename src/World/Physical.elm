module World.Physical exposing (..)

import Slime exposing (..)
import World.Components exposing (..)
import World.Model exposing (WorldModel)
import QuickMath exposing (..)
import Vector2 exposing (..)


gravitySize =
    8


maxSpeed =
    40


maxSpeedSquared =
    maxSpeed * maxSpeed


applyGravity : Float -> WorldModel -> WorldModel
applyGravity dt =
    stepEntities (entities inertias)
        (\({ a } as ent) ->
            { ent | a = add a ( 0, -gravitySize * dt ) }
        )


breakInertias : WorldModel -> WorldModel
breakInertias =
    stepEntities (entities inertias)
        (\({ a } as ent) ->
            { ent
                | a =
                    if lengthSquared a > maxSpeedSquared then
                        scale maxSpeed (normalize a)
                    else
                        a
            }
        )
