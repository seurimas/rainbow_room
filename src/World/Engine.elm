module World.Engine exposing (..)

import Slime exposing (..)
import Slime.Engine exposing (..)
import Input.Listeners exposing (inputSubscriptions, keyListener)
import World.Msg exposing (..)
import World.Components exposing (..)
import World.DebugScene exposing (debugShooter)
import World.Physical exposing (applyGravity)
import World.Collision exposing (applyVelocityWithCollisions)
import Player.Systems exposing (cameraFollow, applyPlayerMovement, transferPlayerInput)
import World.Collision.Painting exposing (paintTheTown)


engine =
    initEngine deletor
        [ timedSystem debugShooter
        , untimedSystem transferPlayerInput
        , timedSystem applyGravity
        , timedSystem (applyVelocityWithCollisions [ paintTheTown ])
        , timedSystem applyPlayerMovement
        , timedSystem cameraFollow
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
