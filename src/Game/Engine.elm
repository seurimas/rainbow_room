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
import Enemies.Systems exposing (stepDrippers, dripDrippers, composeBlob, bounceBlob, landBlob)


engine =
    initEngine deletor
        [ timedSystem debugShooter
        , untimedSystem transferPlayerInput
        , timedSystem applyGravity
        , untimedSystem breakInertias
        , timedSystem setThePaint
        , timedSystem stepDrippers
        , untimedSystem dripDrippers
        , timedSystem bounceBlob
        , timedSystem (applyVelocityWithCollisions [ paintTheTown, composeBlob, landBlob ])
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
