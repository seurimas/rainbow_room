module Editor.Systems exposing (..)

import UI.Model exposing (..)
import Editor.Model exposing (..)
import Color
import Input.Utils exposing (mouseGameCoordinates)
import World.Tilemap exposing (setTile)
import Level.Model exposing (LevelTile)


determineUiItems : EditorModel -> ( Int, Int ) -> Maybe InterfaceZone
determineUiItems _ ( _, y ) =
    if y < 32 then
        Just Tiles
    else
        Just LevelEditor


determineSelectable : EditorModel -> ( Int, Int ) -> Maybe LevelTile
determineSelectable model ( x, y ) =
    if y > 32 then
        Nothing
    else
        List.drop (floor ((toFloat x) / 32 - 1)) model.tiles
            |> List.head


selectTile : EditorModel -> EditorModel
selectTile ({ interfaceState, inputState } as world) =
    case interfaceState of
        Down Tiles _ ->
            let
                selectable =
                    determineSelectable world ( inputState.mouseState.x, inputState.mouseState.y )
            in
                case selectable of
                    Just found ->
                        { world | selection = found }

                    _ ->
                        world

        _ ->
            world


placeTile : EditorModel -> EditorModel
placeTile ({ interfaceState, inputState, selection } as world) =
    if not inputState.mouseState.down then
        world
    else
        case interfaceState of
            Down LevelEditor _ ->
                let
                    ( worldX, worldY ) =
                        Debug.log "Place" (mouseGameCoordinates world)
                in
                    { world
                        | tileMap =
                            setTile ( floor worldX, floor worldY ) selection world.tileMap
                    }

            _ ->
                world
