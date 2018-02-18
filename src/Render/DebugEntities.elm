module Render.DebugEntities exposing (..)

import World.Components exposing (..)
import World.Model exposing (WorldModel)
import Slime exposing (..)
import Game.TwoD.Render as Render exposing (shape, rectangle, Renderable)
import Game.TwoD.Camera exposing (..)
import Game.TwoD exposing (RenderConfig)
import Color exposing (..)
import World.Collision exposing (..)
import World.Tilemap as Level
import Lazy.List
import QuickMath exposing (..)
import Vector2 exposing (..)
import Render.Utils exposing (getCameraViewport)


renderGrid : { o | renderConfig : RenderConfig } -> List Renderable
renderGrid ({ renderConfig } as world) =
    let
        ( ( cameraStartX, cameraStartY ), ( cameraEndX, cameraEndY ) ) =
            getCameraViewport world
    in
        (List.range (floor cameraStartX) (ceiling cameraEndX)
            |> List.map (\x -> shape rectangle { color = Color.gray, position = ( toFloat x, cameraStartY ), size = ( 0.1, cameraEndY - cameraStartY ) })
        )
            ++ (List.range (floor cameraStartY) (ceiling cameraEndY)
                    |> List.map (\y -> shape rectangle { color = Color.gray, position = ( cameraStartX, toFloat y ), size = ( cameraEndX - cameraStartX, 0.1 ) })
               )


renderTiles : RenderConfig -> Lazy.List.LazyList ( Int, Int, Color ) -> List Renderable
renderTiles renderConfig tiles =
    let
        drawTile ( x, y, tile ) =
            Render.shape Render.rectangle { color = tile, position = ( toFloat x, toFloat y ), size = ( 1, 1 ) }
    in
        tiles
            |> Lazy.List.map (\tile -> (drawTile tile))
            |> Lazy.List.toList


renderWorldTiles : { o | renderConfig : RenderConfig, tileMap : Level.TileMap WorldTile } -> List Renderable
renderWorldTiles ({ renderConfig, tileMap } as world) =
    let
        ( cameraStart, cameraEnd ) =
            getCameraViewport world
                |> Vector2.map (\vec -> Vector2.map floor vec)
    in
        Level.getTiles cameraStart cameraEnd tileMap
            |> Lazy.List.map (\( x, y, worldTile ) -> ( x, y, worldTile.color ))
            |> renderTiles renderConfig


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
    (renderWorldTiles world) ++ (renderGrid world)


debugTransforms : WorldModel -> List Renderable
debugTransforms world =
    world
        &. (entities transforms)
        |> List.map .a
        |> List.map (\{ x, y, width, height } -> shape rectangle { color = black, position = ( x, y ), size = ( width, height ) })


debugs : WorldModel -> List Renderable
debugs world =
    (debugTransforms world) ++ (debugLevel world)
