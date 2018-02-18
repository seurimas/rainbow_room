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
        ]
        [ keyListener
        ]


subscriptions world =
    engineSubs
        (Sub.batch inputSubscriptions)


update =
    engineUpdate engine
