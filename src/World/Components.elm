module World.Components exposing (..)

import Slime exposing (componentSpec, deleteEntity, (&->), EntityDeletor)
import QuickMath exposing (..)
import Color exposing (..)


type alias WorldTile =
    { color : Color
    , timeSince : Float
    }


newTile : Color -> WorldTile
newTile color =
    { color = color, timeSince = 0 }


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


type alias Dripper =
    { progress : Float
    , cooldown : Float
    , paint : Paint
    }


drippers =
    componentSpec .drippers (\drippers world -> { world | drippers = drippers })


initDripper paint =
    { progress = 0
    , cooldown = 8
    , paint = paint
    }


type alias Drop =
    {}


drops =
    componentSpec .drops (\drops world -> { world | drops = drops })


type Blob
    = Waiting Float
    | Moving


blobs =
    componentSpec .blobs (\blobs world -> { world | blobs = blobs })


initBlob =
    Waiting 0


type alias BossSpawn =
    {}


bossSpawns =
    componentSpec .bossSpawns (\bossSpawns world -> { world | bossSpawns = bossSpawns })


type alias Boss =
    {}


bosses =
    componentSpec .bosses (\bosses world -> { world | bosses = bosses })


deletor =
    deleteEntity transforms
        &-> inertias
        &-> guns
        &-> players
        &-> painters
        &-> paintables
        &-> drops
        &-> bosses
        &-> bossSpawns
        &-> blobs
