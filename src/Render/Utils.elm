module Render.Utils exposing (..)

import World.Tilemap as Level
import Game.TwoD.Camera exposing (..)
import Game.TwoD exposing (..)
import Vector2


getCameraViewport : { o | renderConfig : RenderConfig } -> ( Vector2.Float2, Vector2.Float2 )
getCameraViewport { renderConfig } =
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
        ( ( cameraStartX, cameraStartY )
        , ( cameraEndX, cameraEndY )
        )


uiCoordinates : { o | renderConfig : RenderConfig } -> Vector2.Float2 -> Vector2.Float2
uiCoordinates { renderConfig } vec =
    viewportToGameCoordinates renderConfig.camera renderConfig.size (Vector2.map floor vec)


uiSize : { o | renderConfig : RenderConfig } -> Vector2.Float2 -> Vector2.Float2
uiSize { renderConfig } ( width, height ) =
    let
        ( gameWidth, gameHeight ) =
            getViewSize (Vector2.map toFloat renderConfig.size) renderConfig.camera

        ( viewWidth, viewHeight ) =
            renderConfig.size
    in
        ( width / (toFloat viewWidth) * gameWidth, height / (toFloat viewHeight) * gameHeight )


uiElement : { o | renderConfig : RenderConfig } -> { e | size : Vector2.Float2, position : Vector2.Float2 } -> { e | size : Vector2.Float2, position : Vector2.Float2 }
uiElement model element =
    { element
        | size = element.size |> uiSize model
        , position = element.position |> uiCoordinates model
    }
