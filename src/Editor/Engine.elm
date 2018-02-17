module Editor.Engine exposing (..)

import Slime exposing (..)
import Slime.Engine exposing (..)
import Input.Listeners exposing (inputSubscriptions, keyListener)
import World.Msg exposing (..)
import World.Components exposing (..)
import Game.DebugScene exposing (debugShooter)
import World.Physical exposing (applyGravity)
import World.Collision exposing (applyVelocityWithCollisions)
import Player.Systems exposing (cameraFollow, applyPlayerMovement, transferPlayerInput)
import World.Collision.Painting exposing (setThePaint, paintTheTown)


engine =
    initEngine deletor
        []
        [ keyListener
        ]


subscriptions world =
    engineSubs
        (Sub.batch inputSubscriptions)


update =
    engineUpdate engine
