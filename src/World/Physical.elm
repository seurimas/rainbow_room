module World.Physical exposing (..)

import Slime exposing (..)
import World.Components exposing (..)
import World.Model exposing (WorldModel)
import QuickMath exposing (..)
import Vector2 exposing (..)


gravitySize =
    3


applyGravity : Float -> WorldModel -> WorldModel
applyGravity dt =
    stepEntities (entities inertias)
        (\({ a } as ent) ->
            { ent | a = add a ( 0, -gravitySize * dt ) }
        )
