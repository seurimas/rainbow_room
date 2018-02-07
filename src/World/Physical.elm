module World.Physical exposing (..)

import Slime exposing (..)
import World.Components exposing (..)
import World.Model exposing (WorldModel)
import QuickMath exposing (..)


applyTransformInertia : Float -> WorldModel -> WorldModel
applyTransformInertia dt =
    stepEntities (entities2 transforms inertias) (\({ a, b } as ent) -> { ent | a = { a | x = a.x + b.vx * dt, y = a.y + b.vy * dt } })


gravitySize =
    3


applyGravity : Float -> WorldModel -> WorldModel
applyGravity dt =
    stepEntities (entities inertias)
        (\({ a } as ent) ->
            if a.falls then
                { ent | a = { a | vy = a.vy - gravitySize * dt } }
            else
                ent
        )


stopSolids : WorldModel -> WorldModel
stopSolids world =
    let
        walls =
            world &. (entities2 transforms barriers)

        hitWall wall ({ a, b } as ent) =
            if collides a wall.a then
                case wall.b of
                    North ->
                        { ent | a = { a | y = wall.a.y + (wall.a.height + a.height) / 2 }, b = { b | vy = 0 } }

                    South ->
                        { ent | a = { a | y = wall.a.y - (wall.a.height + a.height) / 2 }, b = { b | vy = 0 } }

                    East ->
                        { ent | a = { a | x = wall.a.x + (wall.a.width + a.width) / 2 }, b = { b | vx = 0 } }

                    West ->
                        { ent | a = { a | x = wall.a.x - (wall.a.width + a.width) / 2 }, b = { b | vx = 0 } }
            else
                ent

        stopMe ent =
            List.foldl hitWall ent walls
    in
        stepEntities (entities3 transforms inertias solids) stopMe world
