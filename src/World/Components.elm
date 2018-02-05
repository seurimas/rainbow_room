module World.Components exposing (..)

import Slime exposing (componentSpec)


type alias Transform =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    }


transforms =
    componentSpec .transforms (\transforms world -> { world | transforms = transforms })
