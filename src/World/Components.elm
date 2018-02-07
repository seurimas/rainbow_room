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
    , spread : Float
    , projectileCount : Int
    }


guns =
    componentSpec .guns (\guns world -> { world | guns = guns })


type Barrier
    = North
    | East
    | South
    | West


barriers =
    componentSpec .barriers (\barriers world -> { world | barriers = barriers })


type Solid
    = Object


solids =
    componentSpec .solids (\solids world -> { world | solids = solids })


players =
    componentSpec .players (\players world -> { world | players = players })


deletor =
    deleteEntity transforms
        &-> inertias
        &-> guns
        &-> barriers
        &-> solids
        &-> players
