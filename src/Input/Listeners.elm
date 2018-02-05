module Input.Listeners exposing (..)

import Char exposing (KeyCode)
import Dict exposing (Dict, insert)
import Slime.Engine exposing (listener)
import Keyboard exposing (downs, ups)


type InputMsg
    = KeyDown KeyCode
    | KeyUp KeyCode
    | Noop


type alias InputState =
    Dict KeyCode Bool


initInputState =
    Dict.empty


inputSubscriptions =
    [ downs KeyDown, ups KeyUp ]


trackKeys : InputMsg -> { o | inputState : InputState } -> { o | inputState : InputState }
trackKeys msg world =
    case msg of
        KeyDown key ->
            { world | inputState = insert key True world.inputState }

        KeyUp key ->
            { world | inputState = insert key False world.inputState }

        Noop ->
            world


keyListener =
    listener trackKeys


inputMsgNoop =
    Noop
