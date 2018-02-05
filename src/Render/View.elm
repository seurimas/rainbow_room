module Render.View exposing (view)

import Html exposing (Html)
import World.Model exposing (WorldModel)
import Game.TwoD exposing (render)
import Render.DebugEntities exposing (debugs)


view : WorldModel -> Html x
view ({ renderConfig } as world) =
    render renderConfig (debugs world)
