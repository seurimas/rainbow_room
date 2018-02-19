module Editor.Engine exposing (..)

import Slime exposing (..)
import Slime.Engine exposing (..)
import Input.Listeners exposing (inputSubscriptions, keyListener)
import Editor.Systems exposing (..)
import UI.Systems exposing (watchState)


engine =
    initEngine (\id world -> world)
        [ untimedSystem (watchState determineUiItems)
        , untimedSystem selectTile
        , untimedSystem placeTile
        , systemWith { timing = untimed, options = cmds } trackLevel
        , systemWith { timing = untimed, options = cmds } enterLevel
        ]
        [ keyListener
        ]


subscriptions world =
    engineSubs
        (Sub.batch inputSubscriptions)


update =
    engineUpdate engine
