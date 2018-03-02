module Enemies.Systems exposing (..)

import World.Model exposing (..)
import World.Components exposing (..)
import Slime exposing (..)
import World.Collision.Listeners exposing (..)
import Random exposing (..)


stepDrippers : Float -> WorldModel -> WorldModel
stepDrippers dt =
    let
        stepDripper ({ a } as ent) =
            { ent | a = { a | progress = a.progress + dt } }
    in
        stepEntities (entities drippers) stepDripper


dripDrippers : WorldModel -> WorldModel
dripDrippers =
    let
        dripDrippers ({ a, b } as ent) =
            if a.progress > a.cooldown then
                ( { ent | a = { a | progress = a.progress - a.cooldown } }
                , \world ->
                    forNewEntity world
                        &=> ( transforms, { x = b.x + 0.25, y = b.y + 0.25, width = 0.5, height = 0.5 } )
                        &=> ( inertias, ( 0, 0 ) )
                        &=> ( drops, {} )
                        |> Tuple.second
                )
            else
                ( ent, identity )
    in
        stepEntitiesAndThen (entities2 drippers transforms) dripDrippers


composeBlob : CollisionListener WorldTile
composeBlob collisionEvent world =
    let
        id =
            collisionEvent.entity

        ( cx, cy, _, _, _ ) =
            collisionEvent.location
    in
        case getEntityById (entities2 drops transforms) id world of
            Just ({ a, b } as ent) ->
                (forNewEntity world
                    &=> ( transforms, { x = cx - 0.25, y = cy, width = 0.5, height = 0.5 } )
                    &=> ( inertias, ( 0, 0 ) )
                    &=> ( blobs, initBlob )
                    |> Tuple.second
                )
                    |> deletor ent.id

            Nothing ->
                world


bounceBlob : Float -> WorldModel -> WorldModel
bounceBlob dt =
    let
        launch id world =
            let
                ( direction, nextSeed ) =
                    step bool world.seed
            in
                forEntityById id { world | seed = nextSeed }
                    &=> ( inertias
                        , if direction then
                            ( -2, 5 )
                          else
                            ( 2, 5 )
                        )
                    &=> ( blobs, Moving )
                    |> Tuple.second

        progress ({ a, b } as ent) =
            ( { ent
                | a =
                    case a of
                        Waiting progress ->
                            Waiting (progress + dt)

                        _ ->
                            a
              }
            , case a of
                Waiting progress ->
                    if progress > 1 then
                        launch ent.id
                    else
                        identity

                _ ->
                    identity
            )
    in
        stepEntitiesAndThen (entities2 blobs inertias) progress


landBlob : CollisionListener WorldTile
landBlob collisionEvent world =
    let
        id =
            collisionEvent.entity

        ( vx, vy ) =
            collisionEvent.velocity
    in
        if collisionEvent.collisionType == South then
            case getComponentById blobs id world of
                Just Moving ->
                    forEntityById id world
                        &=> ( blobs, Waiting 0 )
                        &=> ( inertias, ( 0, 0 ) )
                        |> Tuple.second

                _ ->
                    world
        else if isHorizontal collisionEvent.collisionType then
            case getComponentById blobs id world of
                Just Moving ->
                    forEntityById id world
                        &=> ( inertias, ( -vx, vy ) )
                        |> Tuple.second

                _ ->
                    world
        else
            world
