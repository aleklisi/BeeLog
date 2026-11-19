module QueenRearing.Domain exposing
    ( BatchStatus(..)
    , ColonyAvailability(..)
    , QueenRearingDefaults
    , Schedule
    , SortableBatch
    , Urgency(..)
    , addCalendarDays
    , calculateSchedule
    , classifyUrgency
    , defaultSettings
    , eligibleTransition
    , sortBatches
    , validAcceptedCount
    , validDefaults
    , validEmergenceCount
    )

import String


type alias QueenRearingDefaults =
    { graftCount : Int
    , starterDurationDays : Int
    , isolationDay : Int
    , emergenceDay : Int
    }


type alias Schedule =
    { starterTransferAt : String
    , isolationAt : String
    , emergenceAt : String
    }


type BatchStatus
    = Planned
    | InStarter
    | InFinisher
    | InIncubator
    | Completed


type ColonyAvailability
    = Available
    | Reserved


type Urgency
    = Overdue
    | DueWithin24Hours
    | Later
    | NoDeadline


type alias SortableBatch =
    { number : String
    , status : BatchStatus
    , nextActionAt : Maybe Int
    }


defaultSettings : QueenRearingDefaults
defaultSettings =
    { graftCount = 24
    , starterDurationDays = 2
    , isolationDay = 10
    , emergenceDay = 11
    }


validDefaults : QueenRearingDefaults -> Bool
validDefaults settings =
    settings.graftCount > 0
        && settings.starterDurationDays >= 1
        && settings.starterDurationDays <= 10
        && settings.isolationDay > settings.starterDurationDays
        && settings.emergenceDay >= settings.isolationDay


validAcceptedCount : Int -> Int -> Bool
validAcceptedCount graftCount acceptedCount =
    graftCount > 0 && acceptedCount >= 0 && acceptedCount <= graftCount


validEmergenceCount : Int -> Int -> Bool
validEmergenceCount acceptedCount emergedCount =
    acceptedCount >= 0 && emergedCount >= 0 && emergedCount <= acceptedCount


eligibleTransition : BatchStatus -> Int -> BatchStatus -> Bool
eligibleTransition current acceptedCount next =
    case ( current, next ) of
        ( Planned, InStarter ) ->
            True

        ( InStarter, InFinisher ) ->
            acceptedCount > 0

        ( InStarter, Completed ) ->
            acceptedCount == 0

        ( InFinisher, InIncubator ) ->
            acceptedCount > 0

        ( InFinisher, Completed ) ->
            True

        ( InIncubator, Completed ) ->
            True

        _ ->
            False


calculateSchedule : QueenRearingDefaults -> String -> Maybe Schedule
calculateSchedule settings graftedAt =
    if not (validDefaults settings) then
        Nothing

    else
        Just
            { starterTransferAt = addCalendarDays settings.starterDurationDays graftedAt
            , isolationAt = addCalendarDays settings.isolationDay graftedAt
            , emergenceAt = addCalendarDays settings.emergenceDay graftedAt
            }


addCalendarDays : Int -> String -> String
addCalendarDays offset localDateTime =
    case String.split "T" localDateTime of
        [ datePart, timePart ] ->
            case String.split "-" datePart |> List.filterMap String.toInt of
                [ year, month, day ] ->
                    let
                        moved = moveDate (Basics.max 0 offset) { year = year, month = month, day = day }
                    in
                    formatDate moved ++ "T" ++ timePart

                _ ->
                    localDateTime

        _ ->
            localDateTime


type alias DateParts =
    { year : Int, month : Int, day : Int }


moveDate : Int -> DateParts -> DateParts
moveDate remaining date =
    if remaining <= 0 then
        date

    else
        let
            daysInCurrentMonth = daysInMonth date.year date.month
        in
        if date.day < daysInCurrentMonth then
            moveDate (remaining - 1) { date | day = date.day + 1 }

        else if date.month < 12 then
            moveDate (remaining - 1) { year = date.year, month = date.month + 1, day = 1 }

        else
            moveDate (remaining - 1) { year = date.year + 1, month = 1, day = 1 }


daysInMonth : Int -> Int -> Int
daysInMonth year month =
    case month of
        2 ->
            if modBy 400 year == 0 || (modBy 4 year == 0 && modBy 100 year /= 0) then
                29

            else
                28

        4 ->
            30

        6 ->
            30

        9 ->
            30

        11 ->
            30

        _ ->
            31


formatDate : DateParts -> String
formatDate date =
    String.padLeft 4 '0' (String.fromInt date.year)
        ++ "-"
        ++ String.padLeft 2 '0' (String.fromInt date.month)
        ++ "-"
        ++ String.padLeft 2 '0' (String.fromInt date.day)


classifyUrgency : Int -> Maybe Int -> Urgency
classifyUrgency now deadline =
    case deadline of
        Nothing ->
            NoDeadline

        Just dueAt ->
            if dueAt <= now then
                Overdue

            else if dueAt - now <= 24 * 60 * 60 * 1000 then
                DueWithin24Hours

            else
                Later


sortBatches : Int -> List SortableBatch -> List SortableBatch
sortBatches now batches =
    List.sortWith (compareBatch now) batches


compareBatch : Int -> SortableBatch -> SortableBatch -> Order
compareBatch now left right =
    let
        leftGroup = groupFor now left
        rightGroup = groupFor now right
        deadlineOrder = Maybe.withDefault 0 left.nextActionAt - Maybe.withDefault 0 right.nextActionAt
    in
    if leftGroup < rightGroup then
        LT

    else if leftGroup > rightGroup then
        GT

    else if leftGroup < 2 && deadlineOrder /= 0 then
        if deadlineOrder < 0 then LT else GT

    else
        compare left.number right.number


groupFor : Int -> SortableBatch -> Int
groupFor now batch =
    case batch.status of
        Planned ->
            2

        Completed ->
            3

        _ ->
            case batch.nextActionAt of
                Just deadline ->
                    if deadline <= now then 0 else 1

                Nothing ->
                    1
