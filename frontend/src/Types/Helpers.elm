module Types.Helpers exposing (..)

import Types.Core exposing (UlikState(..), UlikWeselny)

ulikStateToString : UlikState -> String
ulikStateToString state =
    case state of
        Bezmatek -> "bezmatek"
        ZMatecznikiem -> "z_matecznikiem"
        MatkaWygryziona -> "matka_wygryziona"
        MatkaCzerwi -> "matka_czerwi"
        PustyUlik -> "pusty_ulik"

ulikStateLabel : UlikState -> String
ulikStateLabel state =
    case state of
        Bezmatek -> "(B) Bezmatek"
        ZMatecznikiem -> "(M) Matecznik"
        MatkaWygryziona -> "(N) Matka nieunasienniona"
        MatkaCzerwi -> "(UNC) Matka unasienniona"
        PustyUlik -> "(P) Pusty ulik"

ulikStateFromString : String -> UlikState
ulikStateFromString s =
    case String.toLower s of
        "pusty_ulik" -> PustyUlik
        "p" -> PustyUlik
        "pusty" -> PustyUlik
        "pusty ulik" -> PustyUlik
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

ulikStateShortLabel : String -> String
ulikStateShortLabel s =
    case String.toLower s of
        "pusty_ulik" -> "(P)"
        "p" -> "(P)"
        "pusty" -> "(P)"
        "pusty ulik" -> "(P)"
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

getUlikState : UlikWeselny -> UlikState
getUlikState u =
    ulikStateFromString u.state
