module World.Physical exposing (..)

import Slime exposing (..)
import World.Components exposing (..)
import World.Model exposing (WorldModel)


applyTransformInertia : Float -> WorldModel -> WorldModel
applyTransformInertia dt =
    stepEntities (entities2 transforms inertias) (\({ a, b } as ent) -> { ent | a = { a | x = a.x + b.vx * dt, y = a.y + b.vy * dt } })


gravitySize =
    7


applyGravity : Float -> WorldModel -> WorldModel
applyGravity dt =
    stepEntities (entities inertias)
        (\({ a } as ent) ->
            if a.falls then
                { ent | a = { a | vy = a.vy - gravitySize * dt } }
            else
                ent
        )
