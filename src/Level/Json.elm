module Level.Json exposing (..)

import Json.Encode as Encode
import Json.Decode as Decode
import Level.Model exposing (..)
import World.Tilemap exposing (..)
import Dict
import Color exposing (..)
import Array
import Navigation exposing (Location)


tileEncode : LevelTile -> Encode.Value
tileEncode tile =
    case tile of
        Solid color ->
            let
                { red, green, blue } =
                    toRgb color
            in
                Encode.list
                    [ Encode.int red
                    , Encode.int green
                    , Encode.int blue
                    ]

        Item item ->
            case item of
                Spawn ->
                    Encode.list [ Encode.string "item", Encode.string "spawn" ]

                Dripper ->
                    Encode.list [ Encode.string "item", Encode.string "dripper" ]

                Boss ->
                    Encode.list [ Encode.string "item", Encode.string "boss" ]


tileDecode : Decode.Decoder LevelTile
tileDecode =
    let
        solidDecode =
            Decode.list Decode.int
                |> Decode.andThen
                    (\solid ->
                        case solid of
                            [ red, green, blue ] ->
                                Decode.succeed (Color.rgb red green blue)

                            _ ->
                                Decode.fail "Not a solid"
                    )

        itemDecode =
            Decode.list Decode.string
                |> Decode.andThen
                    (\item ->
                        case item of
                            [ "item", "spawn" ] ->
                                Decode.succeed (Item Spawn)

                            [ "item", "dripper" ] ->
                                Decode.succeed (Item Dripper)

                            [ "item", "boss" ] ->
                                Decode.succeed (Item Boss)

                            _ ->
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


locationTileMap : Location -> TileMap LevelTile
locationTileMap location =
    case location.hash of
        "" ->
            getLevel []

        hash ->
            Decode.decodeString levelDecode (hash |> String.split "%22" |> String.join "\"" |> String.dropLeft 1)
                |> (\result ->
                        case result of
                            Ok tileMap ->
                                tileMap

                            Err error ->
                                Debug.crash error
                   )
