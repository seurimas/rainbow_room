module Game.Engine exposing (..)

import Slime exposing (..)
import Slime.Engine exposing (..)
import Input.Listeners exposing (inputSubscriptions, keyListener)
import World.Msg exposing (..)
import World.Components exposing (..)
import Game.DebugScene exposing (debugShooter)
import World.Physical exposing (applyGravity, breakInertias)
import World.Collision exposing (applyVelocityWithCollisions)
import Player.Systems exposing (cameraFollow, applyPlayerMovement, transferPlayerInput)
import World.Collision.Painting exposing (setThePaint, paintTheTown)


engine =
    initEngine deletor
        [ timedSystem debugShooter
        , untimedSystem transferPlayerInput
        , timedSystem applyGravity
        , untimedSystem breakInertias
        , timedSystem setThePaint
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
