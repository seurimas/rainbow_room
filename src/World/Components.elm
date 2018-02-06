module World.Components exposing (..)

import Slime exposing (componentSpec, deleteEntity, (&->), EntityDeletor)


type alias Transform =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    }


transforms =
    componentSpec .transforms (\transforms world -> { world | transforms = transforms })


type alias Inertia =
    { vx : Float
    , vy : Float
    , falls : Bool
    }


inertias =
    componentSpec .inertias (\inertias world -> { world | inertias = inertias })


type alias Gun =
    { sinceLast : Float
    , cooldown : Float
    }


guns =
    componentSpec .guns (\guns world -> { world | guns = guns })


deletor =
    deleteEntity transforms
