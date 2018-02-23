module World.Tilemap exposing (..)

import Dict exposing (Dict)
import Lazy.List exposing (..)
import QuickMath exposing (..)
import Color exposing (Color)


type alias TileMap tile =
    Dict ( Int, Int ) tile


pickTile_ : ( Int, Int ) -> Vector -> TileMap tile -> Maybe ( Float, Float, Int, Int, tile )
pickTile_ ( tx, ty ) ( vx, vy ) tiles =
    getTile ( tx, ty ) tiles
        |> Maybe.map (\tile -> ( vx, vy, tx, ty, tile ))


roundDirection : Float -> Float -> Int
roundDirection direction value =
    if direction > 0 then
        floor value + 1
    else
        ceiling value - 1


pickTiles_ : List (Maybe ( Float, Float, Int, Int, tile )) -> Vector -> Vector -> TileMap tile -> List ( Float, Float, Int, Int, tile )
pickTiles_ found ( x0, y0 ) ( xn, yn ) tiles =
    if (floor x0) == (floor xn) && (floor y0) == (floor yn) then
        List.filterMap identity found
    else if List.length found > 100 then
        Debug.crash (toString found)
    else
        let
            dx =
                (xn - x0)

            dy =
                (yn - y0)

            x1 =
                roundDirection dx x0

            y1 =
                roundDirection dy y0

            tx =
                (toFloat x1 - x0) / dx

            ty =
                (toFloat y1 - y0) / dy
        in
            if tx > 2 || ty > 2 then
                List.filterMap identity found
            else if tx > ty then
                let
                    collision =
                        ( toFloat x1, y0 + (dy / dx) * tx )

                    tile =
                        if dx > 0 then
                            ( x1, floor y0 )
                        else
                            ( x1 - 1, floor y0 )
                in
                    pickTiles_ ((pickTile_ tile collision tiles) :: found) collision ( xn, yn ) tiles
            else if ty > tx then
                let
                    collision =
                        ( x0 + (dx / dy) * ty, toFloat y1 )

                    tile =
                        if dy > 0 then
                            ( floor x0, y1 )
                        else
                            ( floor x0, y1 - 1 )
                in
                    pickTiles_ ((pickTile_ tile collision tiles) :: found) collision ( xn, yn ) tiles
            else
                let
                    collision =
                        ( toFloat x1, toFloat y1 )

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
                    pickTiles_ ((pickTile_ ( x1, y1 ) collision tiles) :: found) collision ( xn, yn ) tiles


pickTiles : Vector -> Vector -> TileMap tile -> List ( Float, Float, Int, Int, tile )
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


unsetTile : ( Int, Int ) -> TileMap tile -> TileMap tile
unsetTile =
    Dict.remove


setTiles : List ( Int, Int, tile ) -> TileMap tile -> TileMap tile
setTiles newTiles tiles =
    let
        add ( x, y, t ) =
            setTile ( x, y ) t
    in
        List.foldr add tiles newTiles


updateTiles : (( Int, Int ) -> tile -> tile) -> TileMap tile -> TileMap tile
updateTiles update tiles =
    Dict.map update tiles


getLevel : List ( Int, Int, tile ) -> TileMap tile
getLevel =
    (flip setTiles) (Dict.empty)
