module Main exposing (main)

{-| @docs main
-}

import Html exposing (div)
import World.Model exposing (WorldModel, WorldMsg, initModel)


{-| -}
main : Program Never WorldModel WorldMsg
main =
    Html.program
        { init = ( initModel, Cmd.none )
        , update = \msg model -> ( model, Cmd.none )
        , subscriptions = \model -> Sub.none
        , view = \model -> (div [] [])
        }
