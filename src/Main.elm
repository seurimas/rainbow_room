module Main exposing (main)

{-| Program entrance.

@docs main

-}

import Html exposing (div)
import Slime.Engine
import World.Model exposing (WorldModel, initModel)
import World.Msg exposing (WorldMsg)
import Render.View exposing (view)
import World.DebugScene exposing (debugScene1)
import World.Engine exposing (update, subscriptions)


{-| -}
main : Program Never WorldModel (Slime.Engine.Message WorldMsg)
main =
    Html.program
        { init = ( initModel |> debugScene1, Cmd.none )
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
