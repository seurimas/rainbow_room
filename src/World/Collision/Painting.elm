module World.Collision.Painting exposing (..)

import Slime exposing (..)
import World.Collision.Listeners exposing (..)
import Color exposing (Color)
import World.Tilemap exposing (..)
import World.Components exposing (..)
import World.Model exposing (WorldModel)


setThePaint : Float -> WorldModel -> WorldModel
setThePaint dt ({ tileMap } as world) =
    { world
        | tileMap = updateTiles (\location ({ timeSince } as tile) -> { tile | timeSince = timeSince + dt }) tileMap
    }


paintTheTown : CollisionListener WorldTile
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
                    Just tile ->
                        if (tile.color == aColor) && (tile.timeSince > 0.25) then
                            forEntityById id world
                                &=> ( inertias
                                    , if isHorizontal collisionEvent.collisionType then
                                        ( -vx, vy )
                                      else
                                        ( vx, -vy )
                                    )
                                |> Tuple.second
                        else
                            { world
                                | tileMap = setTile ( tx, ty ) (newTile aColor) world.tileMap
                            }
                                |> deletor id

                    Nothing ->
                        world

            -- Should never happen...
            _ ->
                world
