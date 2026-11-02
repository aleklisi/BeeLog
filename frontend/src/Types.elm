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
    , expectedHatchDate : String
    , expectedMatingDate : String
    , nfcTagId : String
    , order : Int
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
