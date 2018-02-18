module Input.Utils exposing (..)

import Game.TwoD.Camera exposing (..)
import Game.TwoD exposing (..)
import Input.Model exposing (..)
import Vector2


mouseGameCoordinates : { o | renderConfig : RenderConfig, inputState : InputState } -> Vector2.Float2
mouseGameCoordinates { renderConfig, inputState } =
    viewportToGameCoordinates renderConfig.camera renderConfig.size ( inputState.mouseState.x, inputState.mouseState.y )
