module World.Engine exposing (..)

import Slime exposing (..)
import Slime.Engine exposing (..)
import Input.Listeners exposing (..)
import World.Msg exposing (..)
import World.Components exposing (..)
import World.DebugScene exposing (debugMover, debugShooter)
import World.Physical exposing (applyTransformInertia, applyGravity)


engine =
    initEngine deletor
        [ timedSystem debugMover
        , timedSystem debugShooter
        , timedSystem applyTransformInertia
        , timedSystem applyGravity
        ]
        [ listenerMap intoInputMsg outOfInputMsg keyListener
        ]


subscriptions world =
    engineSubs
        (Sub.batch inputSubscriptions
            |> Sub.map outOfInputMsg
        )


update =
    engineUpdate engine
