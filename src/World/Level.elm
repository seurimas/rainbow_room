module World.Level exposing (..)

import Dict exposing (Dict)
import Lazy.List exposing (..)
import QuickMath exposing (..)
import Color exposing (Color)


type alias TileMap tile =
    Dict ( Int, Int ) tile


type alias WorldTile =
    Color


pickTile_ : ( Int, Int ) -> Vector o -> TileMap tile -> Maybe ( Float, Float, tile )
pickTile_ ( tx, ty ) { vx, vy } tiles =
    getTile ( tx, ty ) tiles
        |> Maybe.map (\tile -> ( vx, vy, tile ))


roundDirection : Float -> Float -> Int
roundDirection direction value =
    if direction > 0 then
        floor value + 1
    else
        ceiling value - 1


pickTiles_ : List (Maybe ( Float, Float, tile )) -> Vector o -> Vector t -> TileMap tile -> List ( Float, Float, tile )
pickTiles_ found vec0 vecn tiles =
    if (floor vec0.vx) == (floor vecn.vx) && (floor vec0.vy) == (floor vecn.vy) then
        List.filterMap identity found
    else if List.length found > 100 then
        Debug.crash "Large."
    else
        let
            dx =
                (vecn.vx - vec0.vx)

            dy =
                (vecn.vy - vec0.vy)

            x1 =
                roundDirection dx vec0.vx

            y1 =
                roundDirection dy vec0.vy

            tx =
                (toFloat x1 - vec0.vx) / dx

            ty =
                (toFloat y1 - vec0.vy) / dy
        in
            if tx > 2 || ty > 2 then
                List.filterMap identity found
            else if tx > ty then
                let
                    collision =
                        { vx = toFloat x1, vy = vec0.vy + (dy / dx) * tx }

                    tile =
                        if dx > 0 then
                            ( x1, floor vec0.vy )
                        else
                            ( x1 - 1, floor vec0.vy )
                in
                    pickTiles_ ((pickTile_ tile collision tiles) :: found) collision vecn tiles
            else if ty > tx then
                let
                    collision =
                        { vx = vec0.vx + (dx / dy) * ty, vy = toFloat y1 }

                    tile =
                        if dy > 0 then
                            ( floor vec0.vx, y1 )
                        else
                            ( floor vec0.vx, y1 - 1 )
                in
                    pickTiles_ ((pickTile_ tile collision tiles) :: found) collision vecn tiles
            else
                let
                    collision =
                        { vx = toFloat x1, vy = toFloat y1 }

                    tile =
                        ( if dx > 0 then
                            x1
                          else
                            x1 - 1
                        , if dy > 0 then
                            y1
                          else
                            y1 - 1
                        )
                in
                    pickTiles_ ((pickTile_ ( x1, y1 ) collision tiles) :: found) collision vecn tiles


pickTiles : Vector o -> Vector o -> TileMap tile -> List ( Float, Float, tile )
pickTiles start end tiles =
    pickTiles_ [] start end tiles


getTile : ( Int, Int ) -> TileMap tile -> Maybe tile
getTile =
    Dict.get


getTiles : ( Int, Int ) -> ( Int, Int ) -> TileMap tile -> LazyList ( Int, Int, tile )
getTiles ( x1, y1 ) ( x2, y2 ) tiles =
    let
        xs =
            drop x1 numbers
                |> take (x2 - x1)

        ys =
            drop y1 numbers
                |> take (y2 - y1)

        points =
            product2 xs ys

        _ =
            (toList points)

        getAndTag ( x, y ) =
            getTile ( x, y ) tiles
                |> Maybe.map (\tile -> ( x, y, tile ))
    in
        Lazy.List.filterMap getAndTag points


setTile : ( Int, Int ) -> tile -> TileMap tile -> TileMap tile
setTile =
    Dict.insert


setTiles : List ( Int, Int, tile ) -> TileMap tile -> TileMap tile
setTiles newTiles tiles =
    let
        add ( x, y, t ) =
            setTile ( x, y ) t
    in
        List.foldr add tiles newTiles


getLevel : List ( Int, Int, tile ) -> TileMap tile
getLevel =
    (flip setTiles) (Dict.empty)
