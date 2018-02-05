module World.Msg exposing (..)

import Input.Listeners exposing (InputMsg, inputMsgNoop)


type WorldMsg
    = Input InputMsg
    | Noop


intoInputMsg msg =
    case msg of
        Input subMsg ->
            subMsg

        _ ->
            inputMsgNoop


outOfInputMsg =
    Input
