module Types exposing (..)

import Json.Decode as Decode

type alias User =
    { uid : String
    , email : String
    }

type alias Queen =
    { hasOpalit : Bool
    , color : String
    , number : String
    }

type alias Hive =
    { id : String
    , name : String
    , frameType : String
    , nfcTagId : String
    , queen : Queen
    , pollenTrap : String
    , order : Int
    }

type UlikState
    = Bezmatek
    | ZMatecznikiem
    | MatkaWygryziona
    | MatkaCzerwi

ulikStateToString : UlikState -> String
ulikStateToString state =
    case state of
        Bezmatek -> "bezmatek"
        ZMatecznikiem -> "z_matecznikiem"
        MatkaWygryziona -> "matka_wygryziona"
        MatkaCzerwi -> "matka_czerwi"

ulikStateLabel : UlikState -> String
ulikStateLabel state =
    case state of
        Bezmatek -> "(1) Bezmatek"
        ZMatecznikiem -> "(2) Z matecznikiem"
        MatkaWygryziona -> "(3) Matka wygryziona ale nie unasienniona"
        MatkaCzerwi -> "(4) Matka czerwi"

ulikStateFromString : String -> UlikState
ulikStateFromString s =
    case String.toLower s of
        "z_matecznikiem" -> ZMatecznikiem
        "2" -> ZMatecznikiem
        "matka_wygryziona" -> MatkaWygryziona
        "3" -> MatkaWygryziona
        "matka_czerwi" -> MatkaCzerwi
        "4" -> MatkaCzerwi
        _ -> Bezmatek

type alias UlikQueen =
    { breedLine : String
    , hasOpalit : Bool
    , color : String
    , number : String
    }

type alias UlikWeselny =
    { id : String
    , name : String
    , hiveType : String -- "Mini plus", "Odkład wielkopolski", "Apidea"
    , hasQueen : Bool
    , queen : UlikQueen
    , state : String
    , nfcTagId : String
    , order : Int
    }

getUlikState : UlikWeselny -> UlikState
getUlikState u =
    ulikStateFromString u.state

type alias Note =
    { id : String
    , text : String
    , authorId : String
    , authorEmail : String
    , timestamp : String
    }

type alias Apiary =
    { id : String
    , name : String
    , apiaryType : String -- "towarowe" or "trutowisko"
    , adminId : String
    , members : List ( String, String )
    , order : Int
    }

-- DECODERS

decodeQueen : Decode.Decoder Queen
decodeQueen =
    Decode.map3 Queen
        (Decode.field "hasOpalit"
            (Decode.oneOf
                [ Decode.bool
                , Decode.string |> Decode.map (\s -> String.toLower s == "true")
                , Decode.int |> Decode.map (\i -> i /= 0)
                ]
                |> Decode.nullable
                |> Decode.map (Maybe.withDefault False)
            )
        )
        (Decode.field "color" (Decode.oneOf [ Decode.string, Decode.succeed "" ] |> Decode.nullable |> Decode.map (Maybe.withDefault "")))
        (Decode.field "number" (Decode.oneOf [ Decode.string, Decode.int |> Decode.map String.fromInt, Decode.succeed "" ] |> Decode.nullable |> Decode.map (Maybe.withDefault "")))

decodeUlikQueen : Decode.Decoder UlikQueen
decodeUlikQueen =
    Decode.map4 UlikQueen
        (Decode.field "breedLine" (Decode.oneOf [ Decode.string, Decode.succeed "" ] |> Decode.nullable |> Decode.map (Maybe.withDefault "")))
        (Decode.field "hasOpalit"
            (Decode.oneOf
                [ Decode.bool
                , Decode.string |> Decode.map (\s -> String.toLower s == "true")
                , Decode.int |> Decode.map (\i -> i /= 0)
                ]
                |> Decode.nullable
                |> Decode.map (Maybe.withDefault False)
            )
        )
        (Decode.field "color" (Decode.oneOf [ Decode.string, Decode.succeed "" ] |> Decode.nullable |> Decode.map (Maybe.withDefault "")))
        (Decode.field "number" (Decode.oneOf [ Decode.string, Decode.int |> Decode.map String.fromInt, Decode.succeed "" ] |> Decode.nullable |> Decode.map (Maybe.withDefault "")))

decodeHives : Decode.Decoder (List Hive)
decodeHives =
    Decode.list
        (Decode.map7 (\i n f nf q pt o -> { id = i, name = n, frameType = f, nfcTagId = nf, queen = q, pollenTrap = pt, order = o })
            (Decode.field "id" Decode.string)
            (Decode.field "name" Decode.string)
            (Decode.field "frameType" Decode.string)
            (Decode.field "nfcTagId" Decode.string)
            (Decode.field "queen" decodeQueen)
            (Decode.field "pollenTrap" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault "brak"))
            (Decode.field "order" Decode.int |> Decode.maybe |> Decode.map (Maybe.withDefault 0))
        )

decodeUliki : Decode.Decoder (List UlikWeselny)
decodeUliki =
    Decode.list
        (Decode.map8 (\i n ht hq q st nf o -> { id = i, name = n, hiveType = ht, hasQueen = hq, queen = q, state = st, nfcTagId = nf, order = o })
            (Decode.field "id" Decode.string)
            (Decode.field "name" Decode.string)
            (Decode.field "hiveType" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault "Mini plus"))
            (Decode.field "hasQueen" Decode.bool |> Decode.maybe |> Decode.map (Maybe.withDefault False))
            (Decode.field "queen" decodeUlikQueen |> Decode.maybe |> Decode.map (Maybe.withDefault { breedLine = "", hasOpalit = False, color = "", number = "" }))
            (Decode.field "state" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault "bezmatek"))
            (Decode.field "nfcTagId" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault ""))
            (Decode.field "order" Decode.int |> Decode.maybe |> Decode.map (Maybe.withDefault 0))
        )

decodeApiaries : Decode.Decoder (List Apiary)
decodeApiaries =
    Decode.list
        (Decode.map6 (\i n at a m o -> { id = i, name = n, apiaryType = at, adminId = a, members = m, order = o })
            (Decode.field "id" Decode.string)
            (Decode.field "name" Decode.string)
            (Decode.field "apiaryType" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault "towarowe"))
            (Decode.field "adminId" Decode.string)
            (Decode.field "members" (Decode.keyValuePairs Decode.string))
            (Decode.field "order" Decode.int |> Decode.maybe |> Decode.map (Maybe.withDefault 0))
        )

decodeNotes : Decode.Decoder (List Note)
decodeNotes =
    Decode.list
        (Decode.map5 Note
            (Decode.field "id" Decode.string)
            (Decode.field "text" Decode.string)
            (Decode.field "authorId" Decode.string)
            (Decode.field "authorEmail" Decode.string)
            (Decode.field "timestamp" Decode.string)
        )
