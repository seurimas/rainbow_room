module Editor.Render exposing (..)

import Html exposing (Html, div)
import Game.TwoD exposing (render)
import World.Model exposing (WorldModel)
import Render.DebugEntities exposing (renderTiles, renderGrid)


view : WorldModel -> Html x
view ({ renderConfig } as world) =
    render renderConfig (renderTiles world ++ renderGrid world)
