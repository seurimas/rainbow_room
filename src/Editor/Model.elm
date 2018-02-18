module Editor.Model exposing (..)

import Slime exposing (..)
import World.Components exposing (..)
import World.Tilemap exposing (..)
import Game.TwoD exposing (RenderConfig)
import Game.TwoD.Camera exposing (fixedArea, Camera, moveTo)
import Input.Model exposing (Interactable, InputState, initInputState)
import UI.Model exposing (Interfacable, initInterfaceState)
import Color
import QuickMath exposing (..)


renderWidth =
    800


renderHeight =
    600


renderUnits =
    16 * 12


type InterfaceZone
    = Tiles
    | LevelEditor


type alias EditorModel =
    Interfacable InterfaceZone
        (Interactable
            (EntitySet
                { renderConfig : RenderConfig
                , tileMap : TileMap Color.Color
                , selection : Color.Color
                , tiles : List Color.Color
                }
            )
        )


initModel : EditorModel
initModel =
    { idSource = initIdSource
    , renderConfig =
        { time = 0
        , size = ( 800, 600 )
        , camera =
            fixedArea renderUnits ( renderWidth, renderHeight )
                |> moveTo ( 9, 7 )
        }
    , inputState = initInputState
    , interfaceState = initInterfaceState
    , tileMap = getLevel []
    , selection = Color.blue
    , tiles = [ Color.blue, Color.red, Color.green, Color.black, Color.white ]
    }
