module World.Components exposing (..)

import Slime exposing (componentSpec, deleteEntity, (&->), EntityDeletor)
import QuickMath exposing (..)
import Color exposing (..)


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


type alias Paint =
    Color


type alias Paintable =
    Paint


painters =
    componentSpec .painters (\painters world -> { world | painters = painters })


paintables =
    componentSpec .paintables (\paintables world -> { world | paintables = paintables })


deletor =
    deleteEntity transforms
        &-> inertias
        &-> guns
        &-> players
        &-> painters
        &-> paintables
