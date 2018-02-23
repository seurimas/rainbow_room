module Editor.Render exposing (..)

import Html exposing (Html, div)
import Game.TwoD exposing (render)
import Editor.Model exposing (EditorModel)
import Render.DebugEntities exposing (renderTiles, renderGrid)
import Game.TwoD.Render as Render exposing (shape, rectangle, Renderable)
import Render.Utils exposing (..)
import World.Tilemap as Level
import Level.Model exposing (..)
import Lazy.List
import Vector2
import Color
import Game.TwoD exposing (..)


renderLevelTile : Maybe LevelTile -> ( Float, Float ) -> ( Float, Float ) -> Renderable
renderLevelTile tile position size =
    case tile of
        Just (Solid color) ->
            Render.shape Render.rectangle { color = color, position = position, size = size }

        Just (Item Spawn) ->
            Render.shape Render.circle { color = Color.blue, position = position, size = size }

        Just (Item Dripper) ->
            Render.shape Render.triangle { color = Color.red, position = position, size = size }

        Just (Item Boss) ->
            Render.shape Render.circle { color = Color.red, position = position, size = size }

        Nothing ->
            Render.shape Render.ring { color = Color.red, position = position, size = size }


renderSelection : EditorModel -> List Renderable
renderSelection model =
    [ renderLevelTile model.selection (uiCoordinates model ( 0, 32 )) (uiSize model ( 32, 32 ))
    ]


renderSelectables : EditorModel -> List Renderable
renderSelectables model =
    let
        drawSelectable idx tile =
            renderLevelTile tile (uiCoordinates model ( 32 + 32 * toFloat idx, 32 )) (uiSize model ( 32, 32 ))
    in
        model.tiles
            |> List.indexedMap drawSelectable


renderLevelTiles : RenderConfig -> Lazy.List.LazyList ( Int, Int, LevelTile ) -> List Renderable
renderLevelTiles renderConfig tiles =
    let
        drawTile ( x, y, tile ) =
            renderLevelTile tile ( toFloat x, toFloat y ) ( 1, 1 )
    in
        tiles
            |> Lazy.List.map (\( x, y, t ) -> ( x, y, Just t ))
            |> Lazy.List.map (\tile -> (drawTile tile))
            |> Lazy.List.toList


renderLevel : { o | renderConfig : RenderConfig, tileMap : Level.TileMap LevelTile } -> List Renderable
renderLevel ({ renderConfig, tileMap } as world) =
    let
        ( cameraStart, cameraEnd ) =
            getCameraViewport world
                |> Vector2.map (\vec -> Vector2.map floor vec)
    in
        Level.getTiles cameraStart cameraEnd tileMap
            |> renderLevelTiles renderConfig


view : EditorModel -> Html x
view ({ renderConfig } as world) =
    render renderConfig
        (renderLevel world
            ++ renderGrid world
            ++ renderSelection world
            ++ renderSelectables world
        )
