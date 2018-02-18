module UI.Systems exposing (..)

import Input.Model exposing (..)
import UI.Model exposing (..)


watchState :
    (Interactable (Interfacable t o) -> ( Int, Int ) -> Maybe t)
    -> Interactable (Interfacable t o)
    -> Interactable (Interfacable t o)
watchState getItem ({ inputState, interfaceState } as world) =
    let
        item =
            getItem world ( inputState.mouseState.x, inputState.mouseState.y )

        nextInterfaceState =
            case item of
                Just newItem ->
                    if inputState.mouseState.down then
                        case interfaceState of
                            OutOfScreen ->
                                Down newItem newItem

                            Over oldItem ->
                                Down oldItem newItem

                            Down start current ->
                                Down start newItem
                    else
                        Over newItem

                Nothing ->
                    if inputState.mouseState.down then
                        interfaceState
                    else
                        OutOfScreen
    in
        { world | interfaceState = nextInterfaceState }
