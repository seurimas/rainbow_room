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
import Level.Model exposing (..)
import Navigation exposing (Location)
import Json.Decode as Decode
import Level.Json exposing (locationTileMap)


renderWidth =
    800


renderHeight =
    600


renderUnits =
    16 * 12


type InterfaceZone
    = Tiles
    | LevelEditor
    | LevelLink


type alias EditorModel =
    Interfacable InterfaceZone
        (Interactable
            (EntitySet
                { renderConfig : RenderConfig
                , tileMap : TileMap LevelTile
                , trackedLevel : TileMap LevelTile
                , selection : LevelTile
                , tiles : List LevelTile
                }
            )
        )


initModel : Location -> EditorModel
initModel location =
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
    , tileMap = locationTileMap location
    , trackedLevel = getLevel []
    , selection = Solid Color.blue
    , tiles =
        [ Solid Color.blue
        , Solid Color.red
        , Solid Color.green
        , Solid Color.black
        , Item Spawn
        ]
    }
