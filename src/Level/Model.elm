module Level.Model exposing (..)

import Color exposing (Color)


type LevelItem
    = Spawn
    | Dripper
    | Boss


type LevelTile
    = Solid Color
    | Item LevelItem
