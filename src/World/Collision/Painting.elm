module World.Collision.Painting exposing (..)

import Slime exposing (..)
import World.Collision.Listeners exposing (..)
import Color exposing (Color)
import World.Level exposing (..)
import World.Components exposing (..)


paintTheTown : CollisionListener Color
paintTheTown collisionEvent world =
    let
        id =
            collisionEvent.entity

        ( _, _, tx, ty, _ ) =
            collisionEvent.location

        ( vx, vy ) =
            collisionEvent.velocity
    in
        case getComponentById painters id world of
            Just aColor ->
                case getTile ( tx, ty ) world.tileMap of
                    Just tileColor ->
                        if tileColor == aColor then
                            forEntityById id world
                                &=> ( inertias
                                    , if collisionEvent.collisionType == Horizontal then
                                        ( -vx, vy )
                                      else
                                        ( vx, -vy )
                                    )
                                |> Tuple.second
                        else
                            { world
                                | tileMap = setTile ( tx, ty ) aColor world.tileMap
                            }
                                |> deletor id

                    Nothing ->
                        world

            -- Should never happen...
            _ ->
                world
