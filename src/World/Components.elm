module World.Components exposing (..)

import Slime exposing (componentSpec, deleteEntity, (&->), EntityDeletor)
import QuickMath exposing (..)


transforms =
    componentSpec .transforms (\transforms world -> { world | transforms = transforms })


type alias Inertia =
    Vector


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


type alias PlayerState =
    { moveLeft : Bool
    , moveRight : Bool
    , wantRun : Bool
    , wantJump : Bool
    }


initPlayer =
    { moveLeft = False, moveRight = False, wantRun = False, wantJump = False }


players =
    componentSpec .players (\players world -> { world | players = players })


deletor =
    deleteEntity transforms
        &-> inertias
        &-> guns
        &-> barriers
        &-> solids
        &-> players
