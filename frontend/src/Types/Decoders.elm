module Types.Decoders exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Types.Core exposing (..)

andMap : Decode.Decoder a -> Decode.Decoder (a -> b) -> Decode.Decoder b
andMap decoder functionDecoder =
    Decode.map2 (\f a -> f a) functionDecoder decoder

decodeKorpus : Decode.Decoder Korpus
decodeKorpus =
    Decode.succeed Korpus
        |> andMap (Decode.field "id" (Decode.oneOf [ Decode.string, Decode.succeed "1" ] |> Decode.nullable |> Decode.map (Maybe.withDefault "1")))
        |> andMap (Decode.field "hasQueen" (Decode.oneOf [ Decode.bool, Decode.string |> Decode.map (\s -> String.toLower s == "true") ] |> Decode.nullable |> Decode.map (Maybe.withDefault False)))
        |> andMap (Decode.field "hasExcluderAbove" (Decode.oneOf [ Decode.bool, Decode.string |> Decode.map (\s -> String.toLower s == "true") ] |> Decode.nullable |> Decode.map (Maybe.withDefault False)))

encodeKorpus : Korpus -> Encode.Value
encodeKorpus k =
    Encode.object
        [ ("id", Encode.string k.id)
        , ("hasQueen", Encode.bool k.hasQueen)
        , ("hasExcluderAbove", Encode.bool k.hasExcluderAbove)
        ]

encodeKorpusy : List Korpus -> Encode.Value
encodeKorpusy ks =
    Encode.list encodeKorpus ks

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
        (Decode.succeed Hive
            |> andMap (Decode.field "id" Decode.string)
            |> andMap (Decode.maybe (Decode.field "apiaryId" Decode.string) |> Decode.map (Maybe.withDefault ""))
            |> andMap (Decode.field "name" Decode.string)
            |> andMap (Decode.field "hiveType" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault "korpusowy"))
            |> andMap (Decode.field "frameType" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault "Wielkopolska"))
            |> andMap (Decode.field "broodFrameType" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault "Wielkopolska"))
            |> andMap (Decode.field "broodFrameCount" Decode.int |> Decode.maybe |> Decode.map (Maybe.withDefault 10))
            |> andMap (Decode.field "superFrameType" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault "Wielkopolska 1/2"))
            |> andMap (Decode.field "superCount" Decode.int |> Decode.maybe |> Decode.map (Maybe.withDefault 1))
            |> andMap (Decode.oneOf [ Decode.field "nfcLink" Decode.string, Decode.field "nfcTagId" Decode.string ] |> Decode.maybe |> Decode.map (Maybe.withDefault ""))
            |> andMap (Decode.field "queen" decodeQueen |> Decode.maybe |> Decode.map (Maybe.withDefault { hasOpalit = False, color = "", number = "" }))
            |> andMap (Decode.field "pollenTrap" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault "brak"))
            |> andMap (Decode.field "order" Decode.int |> Decode.maybe |> Decode.map (Maybe.withDefault 0))
            |> andMap (Decode.field "korpusy" (Decode.list decodeKorpus) |> Decode.maybe |> Decode.map (Maybe.withDefault [ { id = "1", hasQueen = False, hasExcluderAbove = False } ]))
        )

decodeUlikHistoryEntry : Decode.Decoder UlikHistoryEntry
decodeUlikHistoryEntry =
    Decode.succeed UlikHistoryEntry
        |> andMap (Decode.field "timestamp" (Decode.oneOf [ Decode.string, Decode.succeed "" ] |> Decode.nullable |> Decode.map (Maybe.withDefault "")))
        |> andMap (Decode.field "prevState" (Decode.oneOf [ Decode.string, Decode.succeed "" ] |> Decode.nullable |> Decode.map (Maybe.withDefault "")))
        |> andMap (Decode.field "state" (Decode.oneOf [ Decode.string, Decode.succeed "" ] |> Decode.nullable |> Decode.map (Maybe.withDefault "")))
        |> andMap (Decode.field "description" (Decode.oneOf [ Decode.string, Decode.succeed "" ] |> Decode.nullable |> Decode.map (Maybe.withDefault "")))
        |> andMap (Decode.field "breedLine" (Decode.oneOf [ Decode.string, Decode.succeed "" ] |> Decode.nullable |> Decode.map (Maybe.withDefault "")))
        |> andMap (Decode.field "expectedHatchDate" (Decode.oneOf [ Decode.string, Decode.succeed "" ] |> Decode.nullable |> Decode.map (Maybe.withDefault "")))
        |> andMap (Decode.field "expectedMatingDate" (Decode.oneOf [ Decode.string, Decode.succeed "" ] |> Decode.nullable |> Decode.map (Maybe.withDefault "")))
        |> andMap (Decode.field "hasOpalit" (Decode.oneOf [ Decode.bool, Decode.string |> Decode.map (\s -> String.toLower s == "true") ] |> Decode.nullable |> Decode.map (Maybe.withDefault False)))
        |> andMap (Decode.field "color" (Decode.oneOf [ Decode.string, Decode.succeed "" ] |> Decode.nullable |> Decode.map (Maybe.withDefault "")))
        |> andMap (Decode.field "number" (Decode.oneOf [ Decode.string, Decode.succeed "" ] |> Decode.nullable |> Decode.map (Maybe.withDefault "")))

decodeUliki : Decode.Decoder (List UlikWeselny)
decodeUliki =
    Decode.list
        (Decode.succeed UlikWeselny
            |> andMap (Decode.field "id" Decode.string)
            |> andMap (Decode.maybe (Decode.field "apiaryId" Decode.string) |> Decode.map (Maybe.withDefault ""))
            |> andMap (Decode.field "name" Decode.string)
            |> andMap (Decode.field "hiveType" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault "Mini plus"))
            |> andMap (Decode.field "hasQueen" Decode.bool |> Decode.maybe |> Decode.map (Maybe.withDefault False))
            |> andMap (Decode.field "queen" decodeUlikQueen |> Decode.maybe |> Decode.map (Maybe.withDefault { breedLine = "", hasOpalit = False, color = "", number = "" }))
            |> andMap (Decode.field "state" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault "bezmatek"))
            |> andMap (Decode.field "expectedHatchDate" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault ""))
            |> andMap (Decode.field "expectedMatingDate" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault ""))
            |> andMap (Decode.oneOf [ Decode.field "nfcLink" Decode.string, Decode.field "nfcTagId" Decode.string ] |> Decode.maybe |> Decode.map (Maybe.withDefault ""))
            |> andMap (Decode.field "order" Decode.int |> Decode.maybe |> Decode.map (Maybe.withDefault 0))
            |> andMap (Decode.field "history" (Decode.list decodeUlikHistoryEntry) |> Decode.maybe |> Decode.map (Maybe.withDefault []))
        )

decodeApiaries : Decode.Decoder (List Apiary)
decodeApiaries =
    Decode.list
        (Decode.succeed Apiary
            |> andMap (Decode.field "id" Decode.string)
            |> andMap (Decode.field "name" Decode.string)
            |> andMap (Decode.field "apiaryType" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault "towarowe"))
            |> andMap (Decode.field "adminId" Decode.string)
            |> andMap (Decode.field "members" (Decode.keyValuePairs Decode.string))
            |> andMap (Decode.field "order" Decode.int |> Decode.maybe |> Decode.map (Maybe.withDefault 0))
            |> andMap (Decode.field "uliki" decodeUliki |> Decode.maybe |> Decode.map (Maybe.withDefault []))
            |> andMap (Decode.field "hives" decodeHives |> Decode.maybe |> Decode.map (Maybe.withDefault []))
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

decodeUserSettings : Decode.Decoder UserSettings
decodeUserSettings =
    Decode.succeed UserSettings
        |> andMap (Decode.field "frameTypes" (Decode.list Decode.string))
        |> andMap (Decode.field "ulikTypes" (Decode.list Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault [ "Mini plus", "Odkład wielkopolski", "Apidea" ])))
        |> andMap (Decode.field "breedLines" (Decode.list Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault [ "car. Galicja", "cau. M", "cau. KP", "cau. Woźnica", "car. Słowenka" ])))
        |> andMap (Decode.field "darkMode" (Decode.oneOf [ Decode.bool, Decode.string |> Decode.map (\s -> String.toLower s == "true") ] |> Decode.maybe |> Decode.map (Maybe.withDefault False)))
        |> andMap (Decode.field "hatchingToMatingDays" (Decode.int |> Decode.maybe |> Decode.map (Maybe.withDefault 12)))
        |> andMap (Decode.field "maxUlikHistoryLimit" (Decode.int |> Decode.maybe |> Decode.map (Maybe.withDefault 40)))
        |> andMap (Decode.field "enableTrutowiska" (Decode.oneOf [ Decode.bool, Decode.string |> Decode.map (\s -> String.toLower s == "true") ] |> Decode.maybe |> Decode.map (Maybe.withDefault True)))
        |> andMap (Decode.field "enablePasieczyskaTowarowe" (Decode.oneOf [ Decode.bool, Decode.string |> Decode.map (\s -> String.toLower s == "true") ] |> Decode.maybe |> Decode.map (Maybe.withDefault True)))
