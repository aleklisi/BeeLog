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
    }

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
    , adminId : String
    , members : List ( String, String )
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

decodeHives : Decode.Decoder (List Hive)
decodeHives =
    Decode.list
        (Decode.map6 (\i n f nf q pt -> { id = i, name = n, frameType = f, nfcTagId = nf, queen = q, pollenTrap = pt })
            (Decode.field "id" Decode.string)
            (Decode.field "name" Decode.string)
            (Decode.field "frameType" Decode.string)
            (Decode.field "nfcTagId" Decode.string)
            (Decode.field "queen" decodeQueen)
            (Decode.field "pollenTrap" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault "brak"))
        )

decodeApiaries : Decode.Decoder (List Apiary)
decodeApiaries =
    Decode.list
        (Decode.map4 Apiary
            (Decode.field "id" Decode.string)
            (Decode.field "name" Decode.string)
            (Decode.field "adminId" Decode.string)
            (Decode.field "members" (Decode.keyValuePairs Decode.string))
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
