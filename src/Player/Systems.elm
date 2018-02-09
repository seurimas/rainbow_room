module Player.Systems exposing (..)

import World.Model exposing (..)
import World.Components exposing (..)
import World.Collision exposing (..)
import World.Level as Level
import Slime exposing (..)
import Char exposing (KeyCode)
import QuickMath exposing (..)
import Vector2 exposing (..)
import Game.TwoD.Camera as Camera
import Input.Model exposing (..)


feet transform =
    ( floor (transform.x + transform.width / 2), floor (transform.y - 0.1) )


grip direction transform =
    case direction of
        Left ->
            ( floor (transform.x - 0.1), floor (transform.y + transform.height / 2) )

        Right ->
            ( floor (transform.x + transform.width + 0.1), floor (transform.y + transform.height / 2) )


transferPlayerInput : WorldModel -> WorldModel
transferPlayerInput ({ inputState } as world) =
    let
        setInputs ({ a } as ent) =
            { ent
                | a =
                    { a
                        | moveLeft = isKeyDown 'A' inputState
                        , moveRight = isKeyDown 'D' inputState
                        , wantJump = isKeyDown ' ' inputState
                        , wantRun = isKeyDown 'J' inputState
                    }
            }
    in
        stepEntities (entities players) setInputs world


applyPlayerMovement : Float -> WorldModel -> WorldModel
applyPlayerMovement delta world =
    let
        maxSpeed =
            8

        accRate =
            40

        decRate =
            80

        jumpSpeed =
            6

        getAcc input =
            case ( input.moveLeft, input.moveRight ) of
                ( True, False ) ->
                    -(accRate * delta)

                ( False, True ) ->
                    (accRate * delta)

                _ ->
                    0

        getRunningAcc input =
            if input.wantRun then
                (getAcc input) * 2
            else
                getAcc input

        accelerate vel acc =
            let
                bumpedX =
                    (getX vel)
                        + (if (getX vel) == 0 || (sign acc == sign (getX vel)) then
                            acc
                           else
                            (sign acc) * decRate * delta
                          )

                clampedX =
                    clamp -maxSpeed maxSpeed bumpedX
            in
                if acc /= 0 then
                    vel |> setX clampedX
                else if (getX vel) > 0 then
                    vel |> setX (max 0 ((getX vel) - decRate * delta))
                else
                    vel |> setX (min 0 ((getX vel) + decRate * delta))

        lean ({ a, b, c } as e) =
            let
                vel =
                    a

                input =
                    b

                acceleration =
                    getRunningAcc input

                newVel =
                    accelerate vel acceleration
            in
                { e | a = newVel }

        tileAtFeet { c } =
            Level.getTile (feet c) world.tileMap

        jump ({ a, b, c, id } as e) =
            let
                vel =
                    a

                input =
                    b

                transform =
                    c

                wantJump =
                    input.wantJump

                tilesToGrip =
                    ( Level.getTile (grip Left transform) world.tileMap
                    , Level.getTile (grip Right transform) world.tileMap
                    )

                canJumpUp =
                    case (tileAtFeet e) of
                        Just tile ->
                            (getY vel) <= 0

                        Nothing ->
                            False

                wallJump velocity =
                    case ( tilesToGrip, input.moveLeft, input.moveRight ) of
                        ( ( Just _, _ ), True, _ ) ->
                            ( jumpSpeed, jumpSpeed )

                        ( ( _, Just _ ), _, True ) ->
                            ( -jumpSpeed, jumpSpeed )

                        _ ->
                            velocity
            in
                if wantJump && canJumpUp then
                    { e | a = setY jumpSpeed vel }
                else if wantJump then
                    { e | a = wallJump e.a }
                else
                    e
    in
        stepEntities (entities3 inertias players transforms) (lean >> jump) world


cameraFollow : Float -> WorldModel -> WorldModel
cameraFollow delta ({ renderConfig } as world) =
    let
        cameraMove =
            8 * delta

        player =
            world
                &. (entities2 transforms players)
                |> List.head

        targetCameraPos =
            case player of
                Just pEnt ->
                    ( pEnt.a.x + pEnt.a.width / 2
                    , pEnt.a.y + pEnt.a.height / 2
                    )

                Nothing ->
                    Camera.getPosition world.renderConfig.camera
    in
        { world | renderConfig = { renderConfig | camera = Camera.follow cameraMove delta targetCameraPos world.renderConfig.camera } }
