module World.Collision.Listeners exposing (..)

import Slime exposing (..)
import World.Model exposing (WorldModel)
import Vector2 exposing (Float2)


type alias CollisionPoint tile =
    ( Float, Float, Int, Int, tile )


type CollisionType
    = North
    | South
    | West
    | East


isHorizontal : CollisionType -> Bool
isHorizontal collisionType =
    case collisionType of
        East ->
            True

        West ->
            True

        _ ->
            False


isVertical : CollisionType -> Bool
isVertical collisionType =
    case collisionType of
        South ->
            True

        North ->
            True

        _ ->
            False


type alias CollisionEvent tile =
    { location : CollisionPoint tile
    , entity : EntityID
    , collisionType : CollisionType
    , velocity : Float2
    }


type alias CollisionListener tile =
    CollisionEvent tile -> WorldModel -> WorldModel
