module Render.DebugEntities exposing (..)

import World.Components exposing (..)
import World.Model exposing (WorldModel)
import Slime exposing (..)
import Game.TwoD.Render as Render exposing (shape, rectangle, Renderable)
import Game.TwoD.Camera exposing (..)
import Color exposing (..)
import World.Collision exposing (..)
import World.Tilemap as Level
import Lazy.List
import QuickMath exposing (..)
import Vector2 exposing (..)


renderGrid : WorldModel -> List Renderable
renderGrid ({ renderConfig, tileMap } as world) =
    let
        ( cameraWidth, cameraHeight ) =
            getViewSize (Vector2.map toFloat renderConfig.size) renderConfig.camera

        ( cameraCenterX, cameraCenterY ) =
            getPosition renderConfig.camera

        cameraStartX =
            cameraCenterX - cameraWidth / 2

        cameraEndX =
            cameraCenterX + cameraWidth / 2

        cameraStartY =
            cameraCenterY - cameraHeight / 2

        cameraEndY =
            cameraCenterY + cameraHeight / 2
    in
        (List.range (floor cameraStartX) (ceiling cameraEndX)
            |> List.map (\x -> shape rectangle { color = Color.gray, position = ( toFloat x, cameraStartY ), size = ( 0.1, cameraHeight ) })
        )
            ++ (List.range (floor cameraStartY) (ceiling cameraEndY)
                    |> List.map (\y -> shape rectangle { color = Color.gray, position = ( cameraStartX, toFloat y ), size = ( cameraWidth, 0.1 ) })
               )


renderTiles : WorldModel -> List Renderable
renderTiles ({ renderConfig, tileMap } as world) =
    let
        cameraWidth =
            20

        cameraHeight =
            20

        drawTile ( x, y, tile ) =
            Render.shape Render.rectangle { color = tile.color, position = ( toFloat x, toFloat y ), size = ( 1, 1 ) }

        ( cameraX, cameraY ) =
            (getPosition renderConfig.camera)

        cameraVec =
            ( cameraX, cameraY )

        ( cameraStart, cameraEnd ) =
            ( add cameraVec ( -cameraWidth / 2, -cameraHeight / 2 )
                |> Vector2.map floor
            , add cameraVec ( cameraWidth / 2, cameraHeight / 2 )
                |> Vector2.map ceiling
            )
    in
        Level.getTiles cameraStart cameraEnd tileMap
            |> Lazy.List.map (\tile -> (drawTile tile))
            |> Lazy.List.toList


renderPicks : List (Entity2 Rectangle Vector) -> WorldModel -> List Renderable
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

                drawTile ( x, y, tx, ty, _ ) =
                    Render.shape Render.circle { color = Color.black, position = ( x, y ), size = ( 0.25, 0.25 ) }
            in
                tiles |> List.map drawTile
    in
        entities |> List.map renderMyPicks |> List.concat


debugLevel : WorldModel -> List Renderable
debugLevel world =
    (renderTiles world) ++ (renderGrid world)


debugTransforms : WorldModel -> List Renderable
debugTransforms world =
    world
        &. (entities transforms)
        |> List.map .a
        |> List.map (\{ x, y, width, height } -> shape rectangle { color = black, position = ( x, y ), size = ( width, height ) })


debugs : WorldModel -> List Renderable
debugs world =
    (debugTransforms world) ++ (debugLevel world)
