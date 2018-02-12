module World.Model exposing (WorldModel, initModel)

import Slime exposing (..)
import World.Components exposing (..)
import World.Level exposing (..)
import Game.TwoD exposing (RenderConfig)
import Game.TwoD.Camera exposing (fixedArea, Camera, moveTo)
import Input.Model exposing (InputState, initInputState)
import Color
import QuickMath exposing (..)


renderWidth =
    800


renderHeight =
    600


renderUnits =
    16 * 12


type alias WorldModel =
    EntitySet
        { transforms : ComponentSet Rectangle
        , inertias : ComponentSet Inertia
        , guns : ComponentSet Gun
        , players : ComponentSet PlayerState
        , painters : ComponentSet Paint
        , paintables : ComponentSet Paintable
        , renderConfig : RenderConfig
        , inputState : InputState
        , tileMap : TileMap WorldTile
        }


initModel : WorldModel
initModel =
    { idSource = initIdSource
    , transforms = initComponents
    , inertias = initComponents
    , guns = initComponents
    , players = initComponents
    , painters = initComponents
    , paintables = initComponents
    , renderConfig = { time = 0, size = ( 800, 600 ), camera = fixedArea renderUnits ( renderWidth, renderHeight ) |> moveTo ( 0, 0 ) }
    , inputState = initInputState
    , tileMap =
        getLevel
            ([ ( 1, 2, Color.red )
             , ( 1, 3, Color.red )
             , ( 3, 3, Color.red )
             , ( 3, 4, Color.red )
             ]
                ++ (List.range 1 50
                        |> List.map (\x -> ( x, 1, Color.green ))
                   )
            )
    }
