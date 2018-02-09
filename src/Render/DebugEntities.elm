module Render.DebugEntities exposing (debugs)

import World.Components exposing (..)
import World.Model exposing (WorldModel)
import Slime exposing (..)
import Game.TwoD.Render as Render exposing (shape, rectangle, Renderable)
import Game.TwoD.Camera exposing (..)
import Color exposing (..)
import World.Collision exposing (..)
import World.Level as Level
import Lazy.List
import QuickMath exposing (..)


renderTiles : WorldModel -> List Renderable
renderTiles ({ tileMap } as world) =
    let
        cameraWidth =
            20

        cameraHeight =
            20

        drawTile ( x, y, tile ) =
            Render.shape Render.rectangle { color = tile, position = ( toFloat x, toFloat y ), size = ( 1, 1 ) }

        ( cameraX, cameraY ) =
            (getPosition world.renderConfig.camera)

        cameraVec =
            { vx = cameraX, vy = cameraY }

        ( cameraStart, cameraEnd ) =
            ( add cameraVec ( -cameraWidth / 2, -cameraHeight / 2 )
                |> \{ vx, vy } -> ( floor vx, floor vy )
            , add cameraVec ( cameraWidth / 2, cameraHeight / 2 )
                |> \{ vx, vy } -> ( ceiling vx, ceiling vy )
            )
    in
        Level.getTiles cameraStart cameraEnd tileMap
            |> Lazy.List.map (\tile -> (drawTile tile))
            |> Lazy.List.toList


renderPicks : List (Entity2 Transform (Vector o)) -> WorldModel -> List Renderable
renderPicks entities world =
    let
        renderMyPicks { a, b } =
            let
                transform =
                    a

                velocity =
                    b

                tiles =
                    horizontalSweep transform velocity world.tileMap ++ verticalSweep transform velocity world.tileMap

                drawTile ( x, y, _ ) =
                    Render.shape Render.circle { color = Color.black, position = ( x, y ), size = ( 0.25, 0.25 ) }
            in
                tiles |> List.map drawTile
    in
        entities |> List.map renderMyPicks |> List.concat


debugLevel : WorldModel -> List Renderable
debugLevel world =
    (renderTiles world)


debugTransforms : WorldModel -> List Renderable
debugTransforms world =
    world
        &. (entities transforms)
        |> List.map .a
        |> List.map (\{ x, y, width, height } -> shape rectangle { color = black, position = ( x, y ), size = ( width, height ) })


debugs : WorldModel -> List Renderable
debugs world =
    (debugTransforms world) ++ (debugLevel world)
