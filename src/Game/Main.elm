module Game.Main exposing (main)

{-| Program entrance.

@docs main

-}

import Navigation exposing (program)
import Slime.Engine exposing (noop)
import World.Model exposing (WorldModel, initModel)
import World.Msg exposing (WorldMsg)
import Render.View exposing (view)
import Game.DebugScene exposing (debugScene1)
import Game.Engine exposing (update, subscriptions)
import Game.Level exposing (loadLevel)


{-| -}
main : Program Never WorldModel (Slime.Engine.Message WorldMsg)
main =
    program (\_ -> noop)
        { init = (\location -> ( initModel |> loadLevel location, Cmd.none ))
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
