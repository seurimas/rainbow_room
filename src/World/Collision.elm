module World.Collision exposing (..)

import Slime exposing (..)
import World.Level exposing (..)
import World.Model exposing (..)
import World.Components exposing (..)
import QuickMath exposing (..)
import Vector2 exposing (..)


transformLip =
    0.1


horizontalEdge transform velocity =
    if getX velocity < 0 then
        [ ( transform.x + transformLip, transform.y + transformLip )
        , ( transform.x + transformLip, transform.y + transform.height - transformLip )
        ]
    else
        [ ( transform.x + transform.width - transformLip, transform.y + transformLip )
        , ( transform.x + transform.width - transformLip, transform.y + transform.height - transformLip )
        ]


verticalEdge transform velocity =
    if getY velocity < 0 then
        [ ( transform.x + transformLip, transform.y + transformLip )
        , ( transform.x + transform.width - transformLip, transform.y + transformLip )
        ]
    else
        [ ( transform.x + transformLip, transform.y + transform.height - transformLip )
        , ( transform.x + transform.width - transformLip, transform.y + transform.height - transformLip )
        ]


farEdgeX edge movement =
    if getX movement > 0 then
        (add edge ( getX movement + transformLip, 0 ))
    else
        (add edge ( getX movement - transformLip, 0 ))


farEdgeY edge movement =
    if getY movement > 0 then
        (add edge ( 0, getY movement + transformLip ))
    else
        (add edge ( 0, getY movement - transformLip ))


horizontalSweep transform movement tiles =
    horizontalEdge transform movement
        |> List.map (\edge -> pickTiles edge (farEdgeX edge movement) tiles)
        |> List.concat


verticalSweep transform movement tiles =
    verticalEdge transform movement
        |> List.map (\edge -> pickTiles edge (farEdgeY edge movement) tiles)
        |> List.concat


applyVelocityWithCollisions : Float -> WorldModel -> WorldModel
applyVelocityWithCollisions delta world =
    let
        epsilon =
            1.0e-10

        tiles =
            world.tileMap

        horizontalHit transform movement =
            let
                collisionX ( x, _, _ ) =
                    x

                tileXs =
                    horizontalSweep transform movement tiles
                        |> List.map collisionX
            in
                if getX movement > 0 then
                    List.minimum tileXs
                else
                    List.maximum tileXs

        verticalHit transform movement =
            let
                collisionY ( _, y, _ ) =
                    y

                tileYs =
                    verticalSweep transform movement tiles
                        |> List.map collisionY
            in
                if getY movement > 0 then
                    List.minimum tileYs
                else
                    List.maximum tileYs

        moveAndTouch ({ a, b } as e) =
            let
                transform =
                    a

                velocity =
                    b

                movement =
                    scale delta velocity

                moveX tform move =
                    case horizontalHit tform move of
                        Just x ->
                            if getX move > 0 then
                                ( { tform | x = x - tform.width }, True )
                            else
                                ( { tform | x = x }, True )

                        Nothing ->
                            ( { tform | x = tform.x + getX move }, False )

                moveY tform move =
                    case verticalHit tform move of
                        Just y ->
                            if getY move > 0 then
                                ( { tform | y = y - tform.height }, True )
                            else
                                ( { tform | y = y }, True )

                        Nothing ->
                            ( { tform | y = tform.y + getY move }, False )

                ( movedX, collisionX ) =
                    moveX transform movement

                ( movedY, collisionY ) =
                    moveY movedX movement
            in
                { e
                    | a = movedY
                    , b =
                        velocity
                            |> (if collisionX then
                                    setX 0
                                else
                                    identity
                               )
                            |> (if collisionY then
                                    setY 0
                                else
                                    identity
                               )
                }
    in
        stepEntities (entities2 transforms inertias) moveAndTouch world
