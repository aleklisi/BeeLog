module Types exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode

type alias User =
    { uid : String
    , email : String
    }

type alias Queen =
    { hasOpalit : Bool
    , color : String
    , number : String
    }

type alias Korpus =
    { id : String
    , hasQueen : Bool
    , hasExcluderAbove : Bool
    }

type alias Hive =
    { id : String
    , name : String
    , frameType : String
    , nfcTagId : String
    , queen : Queen
    , pollenTrap : String
    , order : Int
    , korpusy : List Korpus
    }

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
        Bezmatek -> "(B) Bezmatek"
        ZMatecznikiem -> "(M) Matecznik"
        MatkaWygryziona -> "(N) Matka nieunasienniona"
        MatkaCzerwi -> "(UNC) Matka unasienniona"

ulikStateFromString : String -> UlikState
ulikStateFromString s =
    case String.toLower s of
        "z_matecznikiem" -> ZMatecznikiem
        "2" -> ZMatecznikiem
        "m" -> ZMatecznikiem
        "matecznik" -> ZMatecznikiem
        "matka_wygryziona" -> MatkaWygryziona
        "3" -> MatkaWygryziona
        "n" -> MatkaWygryziona
        "matka nieunasienniona" -> MatkaWygryziona
        "matka_czerwi" -> MatkaCzerwi
        "4" -> MatkaCzerwi
        "unc" -> MatkaCzerwi
        "matka unasienniona" -> MatkaCzerwi
        "b" -> Bezmatek
        "bezmatek" -> Bezmatek
        _ -> Bezmatek

type alias UlikQueen =
    { breedLine : String
    , hasOpalit : Bool
    , color : String
    , number : String
    }

type alias UlikHistoryEntry =
    { timestamp : String
    , prevState : String
    , state : String
    , description : String
    , breedLine : String
    , expectedHatchDate : String
    , expectedMatingDate : String
    , hasOpalit : Bool
    , color : String
    , number : String
    }

ulikStateShortLabel : String -> String
ulikStateShortLabel s =
    case String.toLower s of
        "bezmatek" -> "(B)"
        "b" -> "(B)"
        "z_matecznikiem" -> "(M)"
        "m" -> "(M)"
        "matecznik" -> "(M)"
        "matka_wygryziona" -> "(N)"
        "n" -> "(N)"
        "matka nieunasienniona" -> "(N)"
        "matka_czerwi" -> "(UNC)"
        "unc" -> "(UNC)"
        "matka unasienniona" -> "(UNC)"
        _ -> "(B)"

type alias UlikWeselny =
    { id : String
    , name : String
    , hiveType : String -- "Mini plus", "Odkład wielkopolski", "Apidea"
    , hasQueen : Bool
    , queen : UlikQueen
    , state : String
    , expectedHatchDate : String
    , expectedMatingDate : String
    , nfcTagId : String
    , order : Int
    , history : List UlikHistoryEntry
    }

parseDate : String -> Maybe (Int, Int, Int)
parseDate str =
    case String.split "-" str of
        [ y, m, d ] ->
            Maybe.map3 (\year month day -> ( year, month, day ))
                (String.toInt y)
                (String.toInt m)
                (String.toInt d)
        _ ->
            Nothing

andMap : Decode.Decoder a -> Decode.Decoder (a -> b) -> Decode.Decoder b
andMap decoder functionDecoder =
    Decode.map2 (\f a -> f a) functionDecoder decoder

daysInMonthList : Int -> List Int
daysInMonthList y =
    let
        leap = (modBy 4 y == 0 && modBy 100 y /= 0) || (modBy 400 y == 0)
    in
    [ 31, (if leap then 29 else 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]

dateToDays : Int -> Int -> Int -> Int
dateToDays y m d =
    let
        prevYears = y - 1
        leapYears = prevYears // 4 - prevYears // 100 + prevYears // 400
        daysInYears = prevYears * 365 + leapYears
        daysInPrevMonths = List.sum (List.take (m - 1) (daysInMonthList y))
    in
    daysInYears + daysInPrevMonths + d

cumulativeSum : List Int -> List Int
cumulativeSum lst =
    Tuple.second
        (List.foldl
            (\x (acc, res) ->
                let
                    newAcc = acc + x
                in
                (newAcc, res ++ [ newAcc ])
            )
            (0, [])
            lst
        )

daysToDate : Int -> (Int, Int, Int)
daysToDate totalDays =
    let
        approxY = max 1 (totalDays // 365)
        findY yr =
            if dateToDays (yr + 1) 1 1 > totalDays then yr else findY (yr + 1)
        y = findY (approxY - 1)
        dayOfYear = totalDays - dateToDays y 1 1 + 1
        mList = daysInMonthList y
        cumDays = cumulativeSum mList
        findM mo lst prevCum =
            case lst of
                c :: rest ->
                    if dayOfYear <= c then
                        (mo, dayOfYear - prevCum)
                    else
                        findM (mo + 1) rest c
                [] -> (12, 31)
        (m, d) = findM 1 cumDays 0
    in
    (y, m, d)

addDaysToDateString : Int -> String -> String
addDaysToDateString days dateStr =
    case parseDate dateStr of
        Just (y, m, d) ->
            let
                total = dateToDays y m d + days
                (ny, nm, nd) = daysToDate total
                pad n = (if n < 10 then "0" else "") ++ String.fromInt n
            in
            String.fromInt ny ++ "-" ++ pad nm ++ "-" ++ pad nd
        Nothing ->
            ""

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
    , uliki : List UlikWeselny
    , hives : List Hive
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
        (Decode.succeed Hive
            |> andMap (Decode.field "id" Decode.string)
            |> andMap (Decode.field "name" Decode.string)
            |> andMap (Decode.field "frameType" Decode.string)
            |> andMap (Decode.field "nfcTagId" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault ""))
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
            |> andMap (Decode.field "name" Decode.string)
            |> andMap (Decode.field "hiveType" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault "Mini plus"))
            |> andMap (Decode.field "hasQueen" Decode.bool |> Decode.maybe |> Decode.map (Maybe.withDefault False))
            |> andMap (Decode.field "queen" decodeUlikQueen |> Decode.maybe |> Decode.map (Maybe.withDefault { breedLine = "", hasOpalit = False, color = "", number = "" }))
            |> andMap (Decode.field "state" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault "bezmatek"))
            |> andMap (Decode.field "expectedHatchDate" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault ""))
            |> andMap (Decode.field "expectedMatingDate" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault ""))
            |> andMap (Decode.field "nfcTagId" Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault ""))
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

type alias UserSettings =
    { frameTypes : List String
    , ulikTypes : List String
    , breedLines : List String
    , darkMode : Bool
    , hatchingToMatingDays : Int
    , maxUlikHistoryLimit : Int
    }

decodeUserSettings : Decode.Decoder UserSettings
decodeUserSettings =
    Decode.succeed UserSettings
        |> andMap (Decode.field "frameTypes" (Decode.list Decode.string))
        |> andMap (Decode.field "ulikTypes" (Decode.list Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault [ "Mini plus", "Odkład wielkopolski", "Apidea" ])))
        |> andMap (Decode.field "breedLines" (Decode.list Decode.string |> Decode.maybe |> Decode.map (Maybe.withDefault [ "car. Galicja", "cau. M", "cau. KP", "cau. Woźnica", "car. Słowenka" ])))
        |> andMap (Decode.field "darkMode" (Decode.oneOf [ Decode.bool, Decode.string |> Decode.map (\s -> String.toLower s == "true") ] |> Decode.maybe |> Decode.map (Maybe.withDefault False)))
        |> andMap (Decode.field "hatchingToMatingDays" (Decode.int |> Decode.maybe |> Decode.map (Maybe.withDefault 12)))
        |> andMap (Decode.field "maxUlikHistoryLimit" (Decode.int |> Decode.maybe |> Decode.map (Maybe.withDefault 40)))

