module Level.Json exposing (..)

import Json.Encode as Encode
import Json.Decode as Decode
import Level.Model exposing (..)
import World.Tilemap exposing (..)
import Dict
import Color exposing (..)
import Array


tileEncode : LevelTile -> Encode.Value
tileEncode tile =
    case tile of
        Solid color ->
            let
                { red, green, blue } =
                    toRgb color
            in
                Encode.list
                    [ Encode.string "color"
                    , Encode.int red
                    , Encode.int green
                    , Encode.int blue
                    ]

        Item item ->
            case item of
                Spawn ->
                    Encode.list [ Encode.string "item", Encode.string "spawn" ]


tileDecode : Decode.Decoder LevelTile
tileDecode =
    let
        solidDecode =
            Decode.index 0 Decode.string
                |> Decode.andThen
                    (\string ->
                        if string == "solid" then
                            Decode.index 1 Decode.int
                                |> Decode.andThen
                                    (\red ->
                                        Decode.index 2 Decode.int
                                            |> Decode.andThen
                                                (\green ->
                                                    Decode.index 3 Decode.int
                                                        |> Decode.andThen
                                                            (\blue ->
                                                                Decode.succeed (Color.rgb red green blue)
                                                            )
                                                )
                                    )
                        else
                            Decode.fail "Not a solid"
                    )

        itemDecode =
            Decode.index 0 Decode.string
                |> Decode.andThen
                    (\string ->
                        if string == "item" then
                            Decode.index 1 Decode.string
                                |> Decode.andThen
                                    (\itemType ->
                                        case itemType of
                                            "Spawn" ->
                                                Decode.succeed (Item Spawn)

                                            _ ->
                                                Decode.fail "Not a valid item"
                                    )
                        else
                            Decode.fail "Not an item"
                    )
    in
        Decode.oneOf
            [ solidDecode |> Decode.map Solid
            , itemDecode
            ]


levelEncode : TileMap LevelTile -> Encode.Value
levelEncode tiles =
    tiles
        |> Dict.toList
        |> List.map (\( ( x, y ), tile ) -> Encode.list [ Encode.int x, Encode.int y, tileEncode tile ])
        |> Encode.list


levelDecode : Decode.Decoder (TileMap LevelTile)
levelDecode =
    Decode.list
        (Decode.index 0 Decode.int
            |> Decode.andThen
                (\x ->
                    Decode.index 1 Decode.int
                        |> Decode.andThen
                            (\y ->
                                Decode.index 2 tileDecode
                                    |> Decode.map (\tile -> ( x, y, tile ))
                            )
                )
        )
        |> Decode.map getLevel
