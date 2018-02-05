module World.Model exposing (WorldModel, WorldMsg, initModel)

import Slime exposing (..)
import World.Components exposing (..)


type alias WorldModel =
    EntitySet
        { transforms : ComponentSet Transform
        }


type WorldMsg
    = Noop


initModel : WorldModel
initModel =
    { idSource = initIdSource
    , transforms = initComponents
    }
