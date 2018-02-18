module Editor.Render exposing (..)

import Html exposing (Html, div)
import Game.TwoD exposing (render)
import Editor.Model exposing (EditorModel)
import Render.DebugEntities exposing (renderTiles, renderGrid)
import Game.TwoD.Render as Render exposing (shape, rectangle, Renderable)
import Render.Utils exposing (..)
import World.Tilemap as Level
import Lazy.List
import Vector2
import Color
import Game.TwoD exposing (..)


renderSelection : EditorModel -> List Renderable
renderSelection model =
    [ shape rectangle (uiElement model { color = model.selection, position = ( 0, 32 ), size = ( 32, 32 ) })
    ]


renderSelectables : EditorModel -> List Renderable
renderSelectables model =
    let
        drawSelectable idx color =
            shape rectangle (uiElement model { color = color, position = ( 32 + 32 * toFloat idx, 32 ), size = ( 32, 32 ) })
    in
        model.tiles
            |> List.indexedMap drawSelectable


renderLevel : { o | renderConfig : RenderConfig, tileMap : Level.TileMap Color.Color } -> List Renderable
renderLevel ({ renderConfig, tileMap } as world) =
    let
        ( cameraStart, cameraEnd ) =
            getCameraViewport world
                |> Vector2.map (\vec -> Vector2.map floor vec)
    in
        Level.getTiles cameraStart cameraEnd tileMap
            |> renderTiles renderConfig


view : EditorModel -> Html x
view ({ renderConfig } as world) =
    render renderConfig
        (renderLevel world
            ++ renderGrid world
            ++ renderSelection world
            ++ renderSelectables world
        )
