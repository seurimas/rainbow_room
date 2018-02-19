module Level.Model exposing (..)

import Color exposing (Color)


type LevelItem
    = Spawn


type LevelTile
    = Solid Color
    | Item LevelItem
