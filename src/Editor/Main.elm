module Editor.Main exposing (main)

{-| Program entrance.

@docs main

-}

import Navigation exposing (program)
import Slime.Engine exposing (noop)
import Editor.Model exposing (EditorModel, initModel)
import Input.Listeners exposing (InputMsg)
import Editor.Render exposing (view)
import Editor.Engine exposing (update, subscriptions)


{-| -}
main : Program Never EditorModel (Slime.Engine.Message InputMsg)
main =
    program (\_ -> noop)
        { init = (\location -> ( initModel location, Cmd.none ))
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
