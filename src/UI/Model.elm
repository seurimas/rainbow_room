module UI.Model exposing (..)


type alias Interfacable t o =
    { o | interfaceState : InterfaceState t }


type InterfaceState t
    = OutOfScreen
    | Over t
    | Down t t


initInterfaceState =
    OutOfScreen


isOver : t -> Interfacable t o -> Bool
isOver item { interfaceState } =
    case interfaceState of
        OutOfScreen ->
            False

        Over active ->
            item == active

        Down old current ->
            item == current
