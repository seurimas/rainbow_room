module Input.Model exposing (..)

import Char exposing (KeyCode, toCode)
import Dict exposing (Dict, insert)


type alias Interactable o =
    { o | inputState : InputState }


type alias InputState =
    { keyState : Dict KeyCode Bool
    , mouseState : { x : Int, y : Int, down : Bool }
    }


initInputState =
    { keyState = Dict.empty
    , mouseState = { x = 0, y = 0, down = False }
    }


isKeyDown : Char -> InputState -> Bool
isKeyDown char inputState =
    Dict.get (toCode char) inputState.keyState
        |> Maybe.withDefault False
