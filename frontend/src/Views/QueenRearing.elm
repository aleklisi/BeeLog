module Views.QueenRearing exposing (queenRearingView)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import QueenRearing.Domain as Domain
import String
import Types.Core exposing (..)
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
        input key labelText inputType =
            label [ style "display" "flex", style "flex-direction" "column", style "gap" "4px" ]
                [ text labelText
                , Html.input [ type_ inputType, value (formValue key), onInput (QueenRearingInput key), attribute "data-testid" ("qr-input-" ++ key), style "padding" "8px" ] []
                ]
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
        batchView batch =
            let
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
                            [ label [] [ text (tr "Starter colony" "Starter")
                              , select [ value (formValue "starterId"), onInput (QueenRearingInput "starterId"), attribute "data-testid" ("qr-starter-" ++ batch.id) ]
                                    (option [ value "" ] [ text (tr "Choose a free starter" "Wybierz wolny starter") ] :: List.map (\colony -> option [ value colony.id ] [ text colony.hiveNumber ]) availableStarters)
                              ]
                            , input "graftedAt" (tr "Graft date and time" "Data i godzina przekładania") "datetime-local"
                            , input "timeZone" (tr "IANA time zone" "Strefa czasowa IANA") "text"
                            , actionButton (tr "Start batch" "Rozpocznij serię") (StartRearingBatch batch.id)
                            ]

                        Domain.InStarter ->
                            [ input "count" (tr "Accepted cells (0 to graft count)" "Przyjęte mateczniki (0 do liczby larw)") "number"
                            , label [] [ text (tr "Free finisher" "Wolny finisher")
                              , select [ value (formValue "finisherId"), onInput (QueenRearingInput "finisherId"), attribute "data-testid" "qr-finisher-select" ]
                                    (option [ value "" ] [ text (tr "Choose a free finisher" "Wybierz wolny finisher") ] :: List.map (\colony -> option [ value colony.id ] [ text colony.hiveNumber ]) availableFinishers)
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
            div [ attribute "data-testid" ("qr-batch-" ++ batch.id), style "padding" "12px", style "margin" "8px 0", style "border" "1px solid #ddd", style "border-radius" "6px" ]
                ([ h4 [] [ text (batch.number ++ " · " ++ statusText) ]
                 , p [] [ text (tr "Grafts: " "Przełożone larwy: " ++ String.fromInt batch.graftCount ++ tr " · Accepted: " " · Przyjęte: " ++ Maybe.withDefault "—" (Maybe.map String.fromInt batch.acceptedCount) ++ tr " · Emerged: " " · Wygryzione: " ++ Maybe.withDefault "—" (Maybe.map String.fromInt batch.emergedCount)) ]
                 , p [] [ text (tr "Incubator bar: " "Listwa inkubatorowa: " ++ Maybe.withDefault "—" batch.incubatorBar) ]
                 , p [] [ text scheduleDetails ]
                 , case nextActionField of
                    Just date ->
                        p [ attribute "data-testid" ("qr-next-action-" ++ batch.id), style "padding" "6px", style "border-radius" "4px", style "background" urgencyColor ]
                            [ text (tr "Next action: " "Następne działanie: " ++ date ++ " — " ++ deadlineText) ]

                    Nothing ->
                        text ""
                 ]
                    ++ transitionControls
                    ++ [ actionButton (tr "Delete batch" "Usuń serię") (DeleteRearingBatch batch.id) ]
                )
    in
    div [ attribute "data-testid" "queen-rearing-view" ]
        [ div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center" ]
            [ h2 [] [ text (if english then "Queen Rearing" else "Hodowla matek") ]
            , actionButton (tr "Resources" "Zasoby") (NavigateTo QueenRearingResourcesView)
            ]
        , section (tr "New batch" "Nowa seria")
            [ div [ style "display" "flex", style "gap" "10px", style "align-items" "end", style "flex-wrap" "wrap" ]
                [ label [] [ text (tr "Active breeder queen" "Aktywna matka reprodukcyjna")
                  , select [ value (formValue "breederQueenId"), onInput (QueenRearingInput "breederQueenId"), attribute "data-testid" "qr-breeder-select" ]
                        (option [ value "" ] [ text (tr "Choose a breeder queen" "Wybierz matkę reprodukcyjną") ] :: List.map (\queen -> option [ value queen.id ] [ text (queen.hiveNumber ++ " · " ++ queen.breed ++ " " ++ queen.line) ]) activeQueens)
                  ]
                , input "graftCount" (tr "Grafts" "Liczba przełożonych larw") "number"
                , actionButton (tr "Create planned batch" "Utwórz zaplanowaną serię") CreatePlannedRearingBatch
                ]
            ]
        , section (tr "Batches" "Serie hodowlane")
            [ if List.isEmpty model.queenRearingData.rearingBatches then p [] [ text (tr "No batches yet." "Brak serii.") ] else text ""
            , div [] (List.map batchView sortedBatches)
            ]
        ]


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
