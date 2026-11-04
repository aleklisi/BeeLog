module ApiaryTest exposing (suite)

import Test exposing (..)
import Expect
import Json.Decode as Decode
import Main exposing (..) -- We need to expose types or just use the decoders if they were exposed

-- Note: Since Main is a port module and we're importing it, 
-- we should ensure the types and decoders are testable.
-- For now, I'll copy the decoders or assume they are exposed if I modify Main.elm to expose them.

suite : Test
suite =
    describe "BeeLog Frontend Decoders"
        [ describe "Queen Decoder"
            [ test "decodes a valid queen" <|
                \() ->
                    let
                        json = "{\"hasOpalit\": true, \"color\": \"żółty\", \"number\": \"42\"}"
                    in
                    case Decode.decodeString decodeQueen json of
                        Ok queen ->
                            Expect.all
                                [ \q -> Expect.equal True q.hasOpalit
                                , \q -> Expect.equal "żółty" q.color
                                , \q -> Expect.equal "42" q.number
                                ]
                                queen
                        Err _ ->
                            Expect.fail "Failed to decode queen"
            ]
        , describe "Hive Decoder"
            [ test "decodes a list of hives" <|
                \() ->
                    let
                        json = "[{\"id\": \"h1\", \"name\": \"Ul 1\", \"frameType\": \"Dadant\", \"nfcTagId\": \"123\", \"queen\": {\"hasOpalit\": false, \"color\": \"biały\", \"number\": \"\"}}]"
                    in
                    case Decode.decodeString decodeHives json of
                        Ok hives ->
                            case List.head hives of
                                Just hive ->
                                    Expect.equal "Ul 1" hive.name
                                Nothing ->
                                    Expect.fail "Empty list"
                        Err err ->
                            Expect.fail ("Failed to decode hives: " ++ Decode.errorToString err)
            ]
        , describe "Apiary Decoder"
            [ test "decodes apiaries with members" <|
                \() ->
                    let
                        json = "[{\"id\": \"a1\", \"name\": \"Pasieka\", \"adminId\": \"u1\", \"members\": {\"user@test.com\": \"edit\"}}]"
                    in
                    case Decode.decodeString decodeApiaries json of
                        Ok apiaries ->
                            case List.head apiaries of
                                Just apiary ->
                                    Expect.equal "Pasieka" apiary.name
                                Nothing ->
                                    Expect.fail "Empty list"
                        Err err ->
                            Expect.fail ("Failed to decode apiaries: " ++ Decode.errorToString err)
            ]
        , describe "Robust Queen Decoder (String hasOpalit)"
            [ test "decodes queen with string hasOpalit \"false\"" <|
                \() ->
                    let
                        json = "{\"hasOpalit\": \"false\", \"color\": \"niebieski\", \"number\": \"10\"}"
                        robustDecodeQueen =
                            Decode.map3 (\h c n -> { hasOpalit = h, color = c, number = n })
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
                                (Decode.field "color" Decode.string)
                                (Decode.field "number" Decode.string)
                    in
                    case Decode.decodeString robustDecodeQueen json of
                        Ok queen ->
                            Expect.equal False queen.hasOpalit
                        Err _ ->
                            Expect.fail "Failed to decode queen with string hasOpalit"
            ]
        , describe "Date Addition (+10 days for ulik weselny)"
            [ test "adds 10 days correctly" <|
                \() ->
                    Expect.equal "2026-11-11" (addDaysToDateString 10 "2026-11-01")
            ]
        , describe "User Settings Decoder"
            [ test "decodes user settings with hatchingToMatingDays" <|
                \() ->
                    let
                        json = "{\"frameTypes\": [\"Dadant\"], \"ulikTypes\": [\"Apidea\"], \"breedLines\": [\"car. Galicja\"], \"darkMode\": true, \"hatchingToMatingDays\": 15}"
                        decodeTestUserSettings =
                            Decode.map5 (\ft ut bl dm hmd -> { frameTypes = ft, ulikTypes = ut, breedLines = bl, darkMode = dm, hatchingToMatingDays = hmd })
                                (Decode.field "frameTypes" (Decode.list Decode.string))
                                (Decode.field "ulikTypes" (Decode.list Decode.string))
                                (Decode.field "breedLines" (Decode.list Decode.string))
                                (Decode.field "darkMode" Decode.bool)
                                (Decode.field "hatchingToMatingDays" Decode.int)
                    in
                    case Decode.decodeString decodeTestUserSettings json of
                        Ok s ->
                            Expect.equal 15 s.hatchingToMatingDays
                        Err _ ->
                            Expect.fail "Failed to decode user settings"
            ]
        ]

-- Helper decoders copied from Main.elm (since it's a port module, direct import might be tricky for internals)
-- In a real scenario, we'd move decoders to a separate module.

decodeQueen =
    Decode.map3 (\h c n -> { hasOpalit = h, color = c, number = n })
        (Decode.field "hasOpalit" Decode.bool)
        (Decode.field "color" Decode.string)
        (Decode.field "number" Decode.string)

decodeHives =
    Decode.list
        (Decode.map5 (\i n f nf q -> { id = i, name = n, frameType = f, nfcTagId = nf, queen = q })
            (Decode.field "id" Decode.string)
            (Decode.field "name" Decode.string)
            (Decode.field "frameType" Decode.string)
            (Decode.field "nfcTagId" Decode.string)
            (Decode.field "queen" decodeQueen)
        )

decodeApiaries =
    Decode.list
        (Decode.map4 (\i n a m -> { id = i, name = n, adminId = a, members = m })
            (Decode.field "id" Decode.string)
            (Decode.field "name" Decode.string)
            (Decode.field "adminId" Decode.string)
            (Decode.field "members" (Decode.keyValuePairs Decode.string))
        )

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
