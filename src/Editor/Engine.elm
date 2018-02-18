module Editor.Engine exposing (..)

import Slime exposing (..)
import Slime.Engine exposing (..)
import Input.Listeners exposing (inputSubscriptions, keyListener)
import World.Components exposing (..)


engine =
    initEngine (\id world -> world)
        []
        [ keyListener
        ]


subscriptions world =
    engineSubs
        (Sub.batch inputSubscriptions)


update =
    engineUpdate engine
