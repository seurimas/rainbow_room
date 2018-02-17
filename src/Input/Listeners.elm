module Input.Listeners exposing (..)

import Char exposing (KeyCode)
import Dict exposing (Dict, insert)
import Slime.Engine exposing (listener)
import Keyboard
import Mouse
import Input.Model exposing (..)


type InputMsg
    = KeyDown KeyCode
    | KeyUp KeyCode
    | MouseAt Mouse.Position
    | MouseDown Mouse.Position
    | MouseUp Mouse.Position
    | Noop


inputSubscriptions =
    [ Keyboard.downs KeyDown, Keyboard.ups KeyUp, Mouse.moves MouseAt, Mouse.downs MouseDown, Mouse.ups MouseUp ]


trackKeys : InputMsg -> Interactable o -> Interactable o
trackKeys msg ({ inputState } as world) =
    case msg of
        KeyDown key ->
            { world | inputState = { inputState | keyState = insert key True inputState.keyState } }

        KeyUp key ->
            { world | inputState = { inputState | keyState = insert key False inputState.keyState } }

        MouseAt position ->
            { world | inputState = { inputState | mouseState = { x = position.x, y = position.y, down = inputState.mouseState.down } } }

        MouseUp position ->
            { world | inputState = { inputState | mouseState = { x = position.x, y = position.y, down = False } } }

        MouseDown position ->
            { world | inputState = { inputState | mouseState = { x = position.x, y = position.y, down = True } } }

        Noop ->
            world


keyListener =
    listener trackKeys


inputMsgNoop =
    Noop
