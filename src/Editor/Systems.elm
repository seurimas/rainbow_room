module Editor.Systems exposing (..)

import UI.Model exposing (..)
import Editor.Model exposing (..)
import Color
import Input.Utils exposing (mouseGameCoordinates)
import World.Tilemap exposing (setTile, unsetTile)
import Level.Model exposing (LevelTile)
import Navigation exposing (modifyUrl)
import Level.Json exposing (levelEncode)
import Input.Listeners exposing (InputMsg)
import Json.Encode


determineUiItems : EditorModel -> ( Int, Int ) -> Maybe InterfaceZone
determineUiItems _ ( x, y ) =
    if y < 32 then
        if x > 800 - 32 then
            Just LevelLink
        else
            Just Tiles
    else
        Just LevelEditor


determineSelectable : EditorModel -> ( Int, Int ) -> Maybe (Maybe LevelTile)
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
                    case selection of
                        Just aTile ->
                            { world
                                | tileMap =
                                    setTile ( floor worldX, floor worldY ) aTile world.tileMap
                            }

                        Nothing ->
                            { world
                                | tileMap =
                                    unsetTile ( floor worldX, floor worldY ) world.tileMap
                            }

            _ ->
                world


trackLevel : EditorModel -> ( EditorModel, Cmd InputMsg )
trackLevel ({ trackedLevel, tileMap } as world) =
    { world | trackedLevel = tileMap }
        ! (if trackedLevel == tileMap then
            []
           else
            [ modifyUrl ("#" ++ Json.Encode.encode 0 (levelEncode tileMap)) ]
          )


enterLevel : EditorModel -> ( EditorModel, Cmd InputMsg )
enterLevel ({ interfaceState, tileMap } as world) =
    case interfaceState of
        Down LevelLink _ ->
            world ! [ Navigation.load ("../Game/Main.elm#" ++ Json.Encode.encode 0 (levelEncode tileMap)) ]

        _ ->
            world ! []
