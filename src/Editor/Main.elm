module Editor.Main exposing (main)

{-| Program entrance.

@docs main

-}

import Html exposing (..)
import Slime.Engine
import Editor.Model exposing (EditorModel, initModel)
import Input.Listeners exposing (InputMsg)
import Editor.Render exposing (view)
import Editor.Engine exposing (update, subscriptions)


{-| -}
main : Program Never EditorModel (Slime.Engine.Message InputMsg)
main =
    Html.program
        { init = ( initModel, Cmd.none )
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
