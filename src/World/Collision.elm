module World.Collision exposing (..)

import Slime exposing (..)
import World.Tilemap exposing (..)
import World.Model exposing (..)
import World.Components exposing (..)
import QuickMath exposing (..)
import Vector2 exposing (..)
import World.Collision.Listeners exposing (CollisionListener, CollisionPoint, CollisionType(..))
import Color exposing (Color)


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


bestOf_ : (CollisionPoint tile -> CollisionPoint tile -> Bool) -> CollisionPoint tile -> List (CollisionPoint tile) -> Maybe (CollisionPoint tile)
bestOf_ compare now list =
    case list of
        next :: rest ->
            if compare now next then
                bestOf_ compare next rest
            else
                bestOf_ compare now rest

        [] ->
            Just now


bestOf : (CollisionPoint tile -> CollisionPoint tile -> Bool) -> List (CollisionPoint tile) -> Maybe (CollisionPoint tile)
bestOf compare list =
    case list of
        head :: rest ->
            bestOf_ compare head rest

        [] ->
            Nothing


leftMost : List (CollisionPoint tile) -> Maybe (CollisionPoint tile)
leftMost list =
    bestOf (\( nowX, _, _, _, _ ) ( nextX, _, _, _, _ ) -> (nextX < nowX)) list


rightMost : List (CollisionPoint tile) -> Maybe (CollisionPoint tile)
rightMost list =
    bestOf (\( nowX, _, _, _, _ ) ( nextX, _, _, _, _ ) -> (nextX > nowX)) list


topMost : List (CollisionPoint tile) -> Maybe (CollisionPoint tile)
topMost list =
    bestOf (\( _, nowY, _, _, _ ) ( _, nextY, _, _, _ ) -> (nextY < nowY)) list


bottomMost : List (CollisionPoint tile) -> Maybe (CollisionPoint tile)
bottomMost list =
    bestOf (\( _, nowY, _, _, _ ) ( _, nextY, _, _, _ ) -> (nextY > nowY)) list


applyCollisionListeners : CollisionType -> List (CollisionListener x) -> EntityID -> Float2 -> Maybe (CollisionPoint x) -> WorldModel -> WorldModel
applyCollisionListeners collisionType collisionListeners id velocity maybeCollision world =
    case maybeCollision of
        Nothing ->
            world

        Just collisionPoint ->
            case collisionListeners of
                first :: rest ->
                    first { location = collisionPoint, entity = id, velocity = velocity, collisionType = collisionType } world
                        |> applyCollisionListeners collisionType rest id velocity maybeCollision

                [] ->
                    world


applyVelocityWithCollisions : List (CollisionListener WorldTile) -> Float -> WorldModel -> WorldModel
applyVelocityWithCollisions collisionListeners delta world =
    let
        epsilon =
            1.0e-10

        tiles =
            world.tileMap

        horizontalHit transform movement =
            let
                tileXs =
                    horizontalSweep transform movement tiles
            in
                if getX movement > 0 then
                    leftMost tileXs
                else
                    rightMost tileXs

        verticalHit transform movement =
            let
                tileYs =
                    verticalSweep transform movement tiles
            in
                if getY movement > 0 then
                    bottomMost tileYs
                else
                    topMost tileYs

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
                        Just ( x, y, tileX, tileY, tile ) ->
                            if getX move > 0 then
                                ( { tform | x = x - tform.width }, Just ( x, y, tileX, tileY, tile ) )
                            else
                                ( { tform | x = x }, Just ( x, y, tileX, tileY, tile ) )

                        Nothing ->
                            ( { tform | x = tform.x + getX move }, Nothing )

                moveY tform move =
                    case verticalHit tform move of
                        Just ( x, y, tileX, tileY, tile ) ->
                            if getY move > 0 then
                                ( { tform | y = y - tform.height }, Just ( x, y, tileX, tileY, tile ) )
                            else
                                ( { tform | y = y }, Just ( x, y, tileX, tileY, tile ) )

                        Nothing ->
                            ( { tform | y = tform.y + getY move }, Nothing )

                ( movedX, collisionX ) =
                    moveX transform movement

                ( movedY, collisionY ) =
                    moveY movedX movement
            in
                ( { e
                    | a = movedY
                    , b =
                        velocity
                            |> (if collisionX /= Nothing then
                                    setX 0
                                else
                                    identity
                               )
                            |> (if collisionY /= Nothing then
                                    setY 0
                                else
                                    identity
                               )
                  }
                , applyCollisionListeners Horizontal collisionListeners e.id velocity collisionX >> applyCollisionListeners Vertical collisionListeners e.id velocity collisionY
                )
    in
        stepEntitiesAndThen (entities2 transforms inertias) moveAndTouch world
