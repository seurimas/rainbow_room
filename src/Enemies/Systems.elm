module Enemies.Systems exposing (..)

import World.Model exposing (..)
import World.Components exposing (..)
import Slime exposing (..)
import Color


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
                        &=> ( painters, Color.red )
                        &=> ( drops, {} )
                        |> Tuple.second
                )
            else
                ( ent, identity )
    in
        stepEntitiesAndThen (entities2 drippers transforms) dripDrippers
