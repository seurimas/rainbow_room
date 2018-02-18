module Editor.Render exposing (..)

import Html exposing (Html, div)
import Game.TwoD exposing (render)
import Editor.Model exposing (EditorModel)
import Render.DebugEntities exposing (renderTiles, renderGrid)
import Game.TwoD.Render as Render exposing (shape, rectangle, Renderable)
import Render.Utils exposing (..)


renderSelection : EditorModel -> List Renderable
renderSelection model =
    [ shape rectangle (Debug.log "Selection" { color = model.selection, position = ( 0, 32 ) |> uiCoordinates model, size = ( 32, 32 ) |> uiSize model })
    ]


view : EditorModel -> Html x
view ({ renderConfig } as world) =
    render renderConfig (renderTiles world ++ renderGrid world ++ renderSelection world)
