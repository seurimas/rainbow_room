module Render.DebugEntities exposing (debugs)

import World.Components exposing (..)
import World.Model exposing (WorldModel)
import Slime exposing (..)
import Game.TwoD.Render exposing (shape, rectangle, Renderable)
import Color exposing (..)


debugs : WorldModel -> List Renderable
debugs world =
    world
        &. (entities transforms)
        |> List.map .a
        |> List.map (\{ x, y, width, height } -> shape rectangle { color = black, position = ( x, y ), size = ( width, height ) })
