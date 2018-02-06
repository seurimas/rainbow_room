module World.Model exposing (WorldModel, initModel)

import Slime exposing (..)
import World.Components exposing (..)
import Game.TwoD exposing (RenderConfig)
import Game.TwoD.Camera exposing (fixedArea, Camera, moveTo)
import Input.Listeners exposing (InputState, initInputState)


renderWidth =
    800


renderHeight =
    600


renderUnits =
    8 * 6


type alias WorldModel =
    EntitySet
        { transforms : ComponentSet Transform
        , inertias : ComponentSet Inertia
        , guns : ComponentSet Gun
        , renderConfig : RenderConfig
        , inputState : InputState
        }


initModel : WorldModel
initModel =
    { idSource = initIdSource
    , transforms = initComponents
    , inertias = initComponents
    , guns = initComponents
    , renderConfig = { time = 0, size = ( 800, 600 ), camera = fixedArea renderUnits ( renderWidth, renderHeight ) |> moveTo ( 0, 0 ) }
    , inputState = initInputState
    }
