module World.Model exposing (WorldModel, initModel)

import Slime exposing (..)
import World.Components exposing (..)
import World.Tilemap exposing (..)
import Game.TwoD exposing (RenderConfig)
import Game.TwoD.Camera exposing (fixedArea, Camera, moveTo)
import Input.Model exposing (Interactable, InputState, initInputState)
import Color
import QuickMath exposing (..)
import Random exposing (Seed, initialSeed)


renderWidth =
    800


renderHeight =
    600


renderUnits =
    16 * 12


type alias WorldModel =
    Interactable
        (EntitySet
            { transforms : ComponentSet Rectangle
            , inertias : ComponentSet Inertia
            , guns : ComponentSet Gun
            , players : ComponentSet PlayerState
            , painters : ComponentSet Paint
            , paintables : ComponentSet Paintable
            , bossSpawns : ComponentSet BossSpawn
            , drippers : ComponentSet Dripper
            , drops : ComponentSet Drop
            , blobs : ComponentSet Blob
            , bosses : ComponentSet Boss
            , renderConfig : RenderConfig
            , uiRenderConfig : RenderConfig
            , tileMap : TileMap WorldTile
            , seed : Seed
            }
        )


initModel : WorldModel
initModel =
    { idSource = initIdSource
    , transforms = initComponents
    , inertias = initComponents
    , guns = initComponents
    , players = initComponents
    , painters = initComponents
    , paintables = initComponents
    , drippers = initComponents
    , bossSpawns = initComponents
    , drops = initComponents
    , blobs = initComponents
    , bosses = initComponents
    , seed = initialSeed 8675309
    , renderConfig = { time = 0, size = ( 800, 600 ), camera = fixedArea renderUnits ( renderWidth, renderHeight ) |> moveTo ( 0, 0 ) }
    , uiRenderConfig = { time = 0, size = ( 800, 600 ), camera = fixedArea renderUnits ( 800, 600 ) |> moveTo ( 400, 300 ) }
    , inputState = initInputState
    , tileMap = getLevel []
    }
