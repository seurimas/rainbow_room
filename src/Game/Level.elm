module Game.Level exposing (..)

import Slime exposing (..)
import World.Model exposing (WorldModel)
import World.Components exposing (..)
import Navigation exposing (Location)
import Level.Json exposing (locationTileMap)
import Dict
import Level.Model exposing (..)


loadLevel : Location -> WorldModel -> WorldModel
loadLevel location worldModel =
    let
        levelMap =
            locationTileMap location

        newLevel =
            levelMap
                |> Dict.toList
                |> List.filterMap
                    (\( xy, levelTile ) ->
                        case levelTile of
                            Solid color ->
                                Just ( xy, newTile color )

                            _ ->
                                Nothing
                    )
                |> Dict.fromList

        spawners =
            levelMap
                |> Dict.toList
                |> List.filterMap
                    (\( xy, levelTile ) ->
                        case levelTile of
                            Item Spawn ->
                                Just xy

                            _ ->
                                Nothing
                    )

        spawn ( x, y ) world =
            forNewEntity world
                &=> ( transforms, { x = toFloat x, y = toFloat y, width = 1, height = 1 } )
                &=> ( inertias, ( 0, 0 ) )
                &=> ( players, initPlayer )
                &=> ( guns, { sinceLast = 0, cooldown = 0.25, spread = 0.2, projectileCount = 8 } )
                |> Tuple.second
    in
        List.foldl spawn { worldModel | tileMap = newLevel } spawners
