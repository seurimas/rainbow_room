module Editor.Model exposing (EditorModel, initModel)

import Slime exposing (..)
import World.Components exposing (..)
import World.Tilemap exposing (..)
import Game.TwoD exposing (RenderConfig)
import Game.TwoD.Camera exposing (fixedArea, Camera, moveTo)
import Input.Model exposing (Interactable, InputState, initInputState)
import Color
import QuickMath exposing (..)


renderWidth =
    800


renderHeight =
    600


renderUnits =
    16 * 12


type alias EditorModel =
    Interactable
        (EntitySet
            { renderConfig : RenderConfig
            , uiRenderConfig : RenderConfig
            , tileMap : TileMap WorldTile
            , selection : Color.Color
            }
        )


initModel : EditorModel
initModel =
    { idSource = initIdSource
    , renderConfig = { time = 0, size = ( 800, 600 ), camera = fixedArea renderUnits ( renderWidth, renderHeight ) |> moveTo ( 0, 0 ) }
    , uiRenderConfig = { time = 0, size = ( 800, 600 ), camera = fixedArea renderUnits ( 800, 600 ) |> moveTo ( 400, 300 ) }
    , inputState = initInputState
    , tileMap = getLevel []
    , selection = Color.blue
    }
