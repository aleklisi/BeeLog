module Views.QueenRearing exposing (queenRearingView)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import QueenRearing.Domain as Domain
import String
import Types.Core exposing (..)
import Types.QueenRearing as QueenRearing
import I18n exposing (Translations)


queenRearingView : Translations -> User -> Model -> Html Msg
queenRearingView t _ model =
    let
        english = t.isEnglish
        tr en pl =
            if english then
                en

            else
                pl
        formValue key = Dict.get key model.queenRearingForm |> Maybe.withDefault ""
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"
        fieldStyles = [ style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ]
        input key labelText inputType =
            label []
                [ text labelText
                , Html.input ([ type_ inputType, value (formValue key), onInput (QueenRearingInput key), attribute "data-testid" ("qr-input-" ++ key) ] ++ fieldStyles) []
                ]
        selectField key testId options =
            select ([ value (formValue key), onInput (QueenRearingInput key), attribute "data-testid" testId ] ++ fieldStyles) options
        actionButton label msg = button [ onClick msg, style "padding" "8px 12px", style "margin" "4px", style "cursor" "pointer" ] [ text label ]
        section title children =
            div [ class ("mb-4 rounded-xl border p-4 shadow-sm " ++ (if model.darkMode then "border-slate-700 bg-slate-900 text-slate-100" else "border-slate-200 bg-white text-slate-900")) ]
                (h3 [ class "mb-4 mt-0 text-lg font-semibold" ] [ text title ] :: children)
        availableStarters = List.filter (\colony -> colony.availability == Domain.Available) model.queenRearingData.starterColonies
        availableFinishers = List.filter (\colony -> colony.availability == Domain.Available) model.queenRearingData.finisherColonies
        activeQueens = List.filter .active model.queenRearingData.breederQueens
        sortedBatches =
            let
                sortedNumbers =
                    model.queenRearingData.rearingBatches
                        |> List.map (\batch -> { number = batch.number, status = batch.status, nextActionAt = batch.deadlineEpoch })
                        |> Domain.sortBatches model.currentEpoch
                        |> List.map .number
            in
            List.filterMap (\number -> List.filter (\batch -> batch.number == number) model.queenRearingData.rearingBatches |> List.head) sortedNumbers
        detailId =
            case model.viewState of
                QueenRearingBatchView identifier -> Just identifier
                _ -> Nothing
        batchView batch =
            let
                graftDate = String.left 10 batch.graftedAt
                starterDate = Maybe.withDefault (Domain.addCalendarDays batch.starterDurationDays graftDate) batch.starterTransferAt
                finisherDate = Maybe.withDefault (Domain.addCalendarDays batch.isolationDay graftDate) batch.isolationAt
                emergenceDate = Maybe.withDefault (Domain.addCalendarDays batch.emergenceDay graftDate) batch.emergenceAt
                timeline = batchTimeline english model.currentDate batch graftDate starterDate finisherDate emergenceDate
                statusText =
                    case batch.status of
                        Domain.Planned -> tr "Planned" "Zaplanowana"
                        Domain.InStarter -> tr "In starter" "W starterze"
                        Domain.InFinisher -> tr "In finisher" "W finisherze"
                        Domain.InIncubator -> tr "In incubator" "W inkubatorze"
                        Domain.Completed -> tr "Completed" "Zakończona"
                scheduleDetails =
                    [ batch.starterTransferAt |> Maybe.map (\date -> tr "Starter transfer: " "Przeniesienie do startera: " ++ date)
                    , batch.isolationAt |> Maybe.map (\date -> tr "Isolation: " "Izolacja: " ++ date)
                    , batch.emergenceAt |> Maybe.map (\date -> tr "Expected emergence: " "Przewidywane wygryzienie: " ++ date)
                    ]
                        |> List.filterMap identity
                        |> String.join " · "
                nextActionField =
                    case batch.status of
                        Domain.InStarter -> batch.starterTransferAt
                        Domain.InFinisher -> batch.isolationAt
                        Domain.InIncubator -> batch.emergenceAt
                        _ -> Nothing
                urgency = Domain.classifyUrgency model.currentEpoch batch.deadlineEpoch
                urgencyColor =
                    case urgency of
                        Domain.Overdue -> "#e74c3c"
                        Domain.DueWithin24Hours -> "#f1c40f"
                        Domain.Later -> "#27ae60"
                        Domain.NoDeadline -> "#7f8c8d"
                deadlineText =
                    case ( urgency, batch.deadlineEpoch ) of
                        ( Domain.Overdue, Just due ) -> tr "Overdue by " "Opóźnienie: " ++ remainingText (model.currentEpoch - due)
                        ( Domain.DueWithin24Hours, Just due ) -> tr "Due in " "Termin za " ++ remainingText (due - model.currentEpoch)
                        ( Domain.Later, Just due ) -> tr "Due in " "Termin za " ++ remainingText (due - model.currentEpoch)
                        _ -> tr "No upcoming action" "Brak nadchodzących działań"
                transitionControls =
                    case batch.status of
                        Domain.Planned ->
                            [ label [] [ text (tr "Active breeder queen" "Aktywna matka reprodukcyjna")
                              , selectField "breederQueenId" ("qr-breeder-" ++ batch.id)
                                    (option [ value "" ] [ text (tr "Choose a breeder queen" "Wybierz matkę reprodukcyjną") ] :: List.map (\queen -> option [ value queen.id ] [ text (String.fromInt queen.hiveNumber ++ " · " ++ queen.breed ++ " " ++ queen.line) ]) activeQueens)
                              ]
                            , input "graftCount" (tr "Grafts" "Liczba przełożonych larw") "number"
                            , label [] [ text (tr "Starter colony" "Starter")
                              , selectField "starterId" ("qr-starter-" ++ batch.id)
                                    (option [ value "" ] [ text (tr "Choose a free starter" "Wybierz wolny starter") ] :: List.map (\colony -> option [ value colony.id ] [ text (String.fromInt colony.hiveNumber) ]) availableStarters)
                              ]
                            , input "graftedAt" (tr "Graft date" "Data przekładania") "date"
                            , actionButton (tr "Start batch" "Rozpocznij serię") (StartRearingBatch batch.id)
                            ]

                        Domain.InStarter ->
                            [ input "count" (tr "Accepted cells (0 to graft count)" "Przyjęte mateczniki (0 do liczby larw)") "number"
                            , label [] [ text (tr "Free finisher" "Wolny finisher")
                              , selectField "finisherId" "qr-finisher-select"
                                    (option [ value "" ] [ text (tr "Choose a free finisher" "Wybierz wolny finisher") ] :: List.map (\colony -> option [ value colony.id ] [ text (String.fromInt colony.hiveNumber) ]) availableFinishers)
                              ]
                            , actionButton (tr "Move to finisher" "Przenieś do finishera") (TransitionRearingBatch batch.id "toFinisher")
                            , actionButton (tr "Complete with zero accepted cells" "Zakończ bez przyjętych mateczników") (TransitionRearingBatch batch.id "zeroComplete")
                            ]

                        Domain.InFinisher ->
                            [ input "incubatorBar" (tr "Incubator bar number" "Numer listwy inkubatorowej") "text"
                            , actionButton (tr "Move to incubator" "Przenieś do inkubatora") (TransitionRearingBatch batch.id "toIncubator")
                            , input "count" (tr "Emerged queens (0 to accepted count)" "Wygryzione matki (0 do przyjętych)") "number"
                            , actionButton (tr "Complete directly" "Zakończ bezpośrednio") (TransitionRearingBatch batch.id "completeDirect")
                            ]

                        Domain.InIncubator ->
                            [ input "count" (tr "Emerged queens (0 to accepted count)" "Wygryzione matki (0 do przyjętych)") "number"
                            , actionButton (tr "Complete batch" "Zakończ serię") (TransitionRearingBatch batch.id "completeIncubator")
                            ]

                        Domain.Completed ->
                            []
            in
            div
                ([ attribute "data-testid" ("qr-batch-" ++ batch.id), style "padding" "12px", style "margin" "8px 0", style "border" "1px solid #ddd", style "border-radius" "6px" ]
                    ++ (if detailId == Just batch.id then [] else [ onClick (NavigateTo (QueenRearingBatchView batch.id)), style "cursor" "pointer" ])
                )
                (if detailId == Just batch.id then
                ([ h4 [] [ text (batch.number ++ " · " ++ statusText) ]
                 , p [] [ text (tr "Breeder queen: " "Matka reprodukcyjna: " ++ (model.queenRearingData.breederQueens |> List.filter (\queen -> queen.id == batch.breederQueenId) |> List.head |> Maybe.map (\queen -> String.fromInt queen.hiveNumber ++ " · " ++ queen.breed ++ " " ++ queen.line ++ " · " ++ queen.markingColor ++ " " ++ queen.markingCode) |> Maybe.withDefault batch.breederQueenId)) ]
                 , p [] [ text (tr "Grafts: " "Przełożone larwy: " ++ String.fromInt batch.graftCount ++ tr " · Accepted: " " · Przyjęte: " ++ Maybe.withDefault "—" (Maybe.map String.fromInt batch.acceptedCount) ++ tr " · Emerged: " " · Wygryzione: " ++ Maybe.withDefault "—" (Maybe.map String.fromInt batch.emergedCount)) ]
                 , p [] [ text (tr "Starter colony: " "Starter: " ++ (batch.starterColonyId |> Maybe.andThen (\identifier -> model.queenRearingData.starterColonies |> List.filter (\colony -> colony.id == identifier) |> List.head) |> Maybe.map (.hiveNumber >> String.fromInt) |> Maybe.withDefault "—") ++ tr " · Finisher colony: " " · Finisher: " ++ (batch.finisherColonyId |> Maybe.andThen (\identifier -> model.queenRearingData.finisherColonies |> List.filter (\colony -> colony.id == identifier) |> List.head) |> Maybe.map (.hiveNumber >> String.fromInt) |> Maybe.withDefault "—")) ]
                 , p [] [ text (tr "Incubator bar: " "Listwa inkubatorowa: " ++ Maybe.withDefault "—" batch.incubatorBar) ]
                 , p [] [ text (tr "Starter duration: " "Czas w starterze: " ++ String.fromInt batch.starterDurationDays ++ tr " days · Isolation day: " " dni · Dzień izolacji: " ++ String.fromInt batch.isolationDay ++ tr " · Emergence day: " " · Dzień wygryzienia: " ++ String.fromInt batch.emergenceDay) ]
                 , p [] [ text scheduleDetails ]
                 , timeline
                 , case nextActionField of
                    Just date ->
                        p [ attribute "data-testid" ("qr-next-action-" ++ batch.id), style "padding" "6px", style "border-radius" "4px", style "background" urgencyColor ]
                            [ text (tr "Next action: " "Następne działanie: " ++ date ++ " — " ++ deadlineText) ]

                    Nothing ->
                        text ""
                 ]
                    ++ transitionControls
                    ++ [ button [ stopPropagationOn "click" (Decode.succeed (DeleteRearingBatch batch.id, True)), style "background" "#c0392b", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "font-size" "18px", style "padding" "6px", title (tr "Delete batch" "Usuń serię") ] [ text "🗑️" ] ]
                )
                else
                    [ h4 [] [ text (batch.number ++ " · " ++ statusText) ]
                    , p [] [ text (tr "Grafted: " "Data przełożenia larw: " ++ graftDate ++ " · " ++ tr "Expected emergence: " "Planowane wygryzienie: " ++ emergenceDate) ]
                    ]
                )
    in
    div [ attribute "data-testid" "queen-rearing-view" ]
        [ div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center" ]
            [ h2 [] [ text (if english then "Queen Rearing" else "Hodowla matek") ]
            , actionButton (tr "Resources" "Zasoby") (NavigateTo QueenRearingResourcesView)
            ]
        , if detailId == Nothing then section (tr "New batch" "Nowa seria")
            [ actionButton (tr "Create planned batch" "Utwórz zaplanowaną serię") CreatePlannedRearingBatch ]
          else text ""
        , case detailId of
            Just identifier ->
                div []
                    [ actionButton (tr "← Batches" "← Lista serii") (NavigateTo QueenRearingView)
                    , case List.filter (\batch -> batch.id == identifier) model.queenRearingData.rearingBatches |> List.head of
                        Just batch -> batchView batch
                        Nothing -> p [] [ text (tr "Batch not found." "Nie znaleziono serii.") ]
                    ]
            Nothing ->
                section (tr "Batches" "Serie hodowlane")
                    [ if List.isEmpty model.queenRearingData.rearingBatches then p [] [ text (tr "No batches yet." "Brak serii.") ] else text ""
                    , div [] (List.map batchView sortedBatches)
                    ]
        ]


batchTimeline : Bool -> String -> QueenRearing.RepeatingBatch -> String -> String -> String -> String -> Html Msg
batchTimeline english today batch graftDate starterDate finisherDate emergenceDate =
    let
        tr en pl = if english then en else pl
        graftDay = dateOrdinal graftDate
        starterDay = dateOrdinal starterDate
        finisherDay = dateOrdinal finisherDate
        emergenceDay = dateOrdinal emergenceDate
        todayDay = dateOrdinal today
        valid = graftDay >= 0 && starterDay >= graftDay && finisherDay >= starterDay && emergenceDay >= finisherDay
        spanDays = Basics.max 1 (emergenceDay - graftDay + 2)
        pct day = clamp 0 100 (toFloat (day - graftDay) / toFloat spanDays * 100)
        graftPct = pct graftDay
        starterPct = pct starterDay
        finisherPct = pct finisherDay
        emergencePct = pct emergenceDay
        usesIncubator = batch.status == Domain.InIncubator || (batch.status == Domain.Completed && batch.incubatorBar /= Nothing)
        segment left width color label =
            div [ style "position" "absolute", style "top" "0", style "left" (String.fromFloat left ++ "%"), style "width" (String.fromFloat (Basics.max 0 width) ++ "%"), style "height" "100%", style "background" color, title label ] []
    in
    if not valid then
        text ""
    else
        div [ attribute "data-testid" ("qr-timeline-" ++ batch.id), style "margin" "10px 0", style "font-size" "12px" ]
            [ div [ style "font-weight" "bold", style "margin-bottom" "4px" ] [ text (tr "Batch timeline" "Oś czasu serii") ]
            , div [ style "position" "relative", style "height" "16px", style "background" "#e0e0e0", style "border-radius" "8px", style "overflow" "hidden" ]
                ([ segment graftPct (starterPct - graftPct) "#f7dc6f" (tr "Starter" "Starter")
                 , segment starterPct (finisherPct - starterPct) "#d4ac0d" (tr "Finisher" "Finisher")
                 , segment finisherPct (emergencePct - finisherPct) (if usesIncubator then "#27ae60" else "#82c8a5") (if usesIncubator then tr "Incubation" "Inkubacja" else tr "Finisher" "Finisher")
                 , if batch.status == Domain.Completed && Maybe.withDefault 0 batch.emergedCount > 0 || (todayDay >= emergenceDay && todayDay >= 0) then segment emergencePct (100 - emergencePct) "#e74c3c" (tr "Emerged" "Wygryzione") else text ""
                 ] ++ (if todayDay >= graftDay && todayDay <= emergenceDay then
                    [ div [ style "position" "absolute", style "top" "0", style "left" (String.fromFloat (pct todayDay) ++ "%"), style "width" "3px", style "height" "100%", style "background" "#3498db", style "z-index" "2", title (tr "Today" "Dzisiaj") ] [] ]
                    else []))
            , div [ style "display" "flex", style "justify-content" "space-between", style "font-size" "10px" ]
                [ span [] [ text (tr "Grafting " "Przekładanie " ++ graftDate) ]
                , span [] [ text (tr "Starter " "Starter " ++ starterDate) ]
                , span [] [ text ((if usesIncubator then tr "Incubator " "Inkubator " else tr "Finisher " "Finisher ") ++ finisherDate) ]
                , span [] [ text (tr "Emergence " "Wygryzienie " ++ emergenceDate) ]
                ]
            ]


dateOrdinal : String -> Int
dateOrdinal date =
    case String.split "-" (String.left 10 date) |> List.filterMap String.toInt of
        [ year, month, day ] ->
            let
                years = year - 1
                leapYears = years // 4 - years // 100 + years // 400
                monthDays = List.take (Basics.max 0 (month - 1)) [ 31, if modBy 400 year == 0 || (modBy 4 year == 0 && modBy 100 year /= 0) then 29 else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ] |> List.sum
            in
            years * 365 + leapYears + monthDays + day - 1
        _ ->
            -1


remainingText : Int -> String
remainingText milliseconds =
    let
        hour = 60 * 60 * 1000
        day = 24 * hour
    in
    if milliseconds < day then
        String.fromInt ((milliseconds + hour - 1) // hour) ++ " h"

    else
        String.fromInt ((milliseconds + day - 1) // day) ++ " d"
