module Views.QueenRearing exposing (queenRearingView)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import QueenRearing.Domain as Domain
import String
import Types.Core exposing (..)
import Types.QueenRearing as QR
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
        section title children =
            div [ style "background" (if model.darkMode then "#1e1e1e" else "white"), style "padding" "16px", style "border-radius" "8px", style "margin-bottom" "16px" ]
                (h3 [ style "margin-top" "0" ] [ text title ] :: children)
        actionButton label msg = button [ onClick msg, style "padding" "8px 12px", style "margin" "4px", style "cursor" "pointer" ] [ text label ]
        resourceForm =
            [ div [ style "display" "grid", style "grid-template-columns" "repeat(auto-fit, minmax(160px, 1fr))", style "gap" "10px" ]
                [ label [] [ text (tr "Resource type" "Rodzaj zasobu")
                  , select [ value (formValue "kind"), onInput (QueenRearingInput "kind"), attribute "data-testid" "qr-resource-kind" ]
                        [ option [ value "breederQueens" ] [ text (tr "Breeder queen" "Matka reprodukcyjna") ]
                        , option [ value "starterColonies" ] [ text (tr "Starter colony" "Starter") ]
                        , option [ value "finisherColonies" ] [ text (tr "Finisher colony" "Finisher") ]
                        ]
                  ]
                , if formValue "kind" == "breederQueens" then input "breed" (tr "Breed" "Rasa") "text" else text ""
                , if formValue "kind" == "breederQueens" then input "line" (tr "Line" "Linia") "text" else text ""
                , if formValue "kind" == "breederQueens" then input "markingColor" (tr "Marking color" "Kolor opalitka") "text" else text ""
                , if formValue "kind" == "breederQueens" then input "markingCode" (tr "Marking code" "Oznaczenie") "text" else text ""
                , input "hiveNumber" (tr "Hive number" "Numer ula") "text"
                ]
            , actionButton (if model.editingQueenResource == Nothing then tr "Add resource" "Dodaj zasób" else tr "Save resource" "Zapisz zasób") (SaveQueenResource (formValue "kind"))
            ]
        resourceList title records =
            section title
                [ if List.isEmpty records then p [] [ text (tr "No resources yet." "Brak zasobów.") ] else text ""
                , div [] records
                ]
        breederItem queen =
            resourceRow queen.id (queen.hiveNumber ++ " · " ++ queen.breed ++ " " ++ queen.line ++ " · " ++ queen.markingColor ++ " " ++ queen.markingCode) (if queen.active then tr "Active" "Aktywna" else tr "Inactive" "Nieaktywna") "breederQueens"
        colonyItem colony =
            resourceRow colony.id (colony.hiveNumber ++ " · " ++ String.fromInt colony.completedSeries ++ " " ++ tr "completed series" "ukończonych serii") (if colony.availability == Domain.Reserved then tr "Reserved" "Zarezerwowany" else tr "Available" "Dostępny") "starterColonies"
        finisherItem colony =
            resourceRow colony.id (colony.hiveNumber ++ " · " ++ String.fromInt colony.completedSeries ++ " " ++ tr "completed series" "ukończonych serii") (if colony.availability == Domain.Reserved then tr "Reserved" "Zarezerwowany" else tr "Available" "Dostępny") "finisherColonies"
        resourceRow id details availability kind =
            div [ attribute "data-testid" ("qr-resource-" ++ id), style "display" "flex", style "align-items" "center", style "justify-content" "space-between", style "gap" "10px", style "padding" "8px", style "border-bottom" "1px solid #ddd" ]
                [ span [] [ text (details ++ " — " ++ availability) ]
                , div []
                    ([ actionButton (tr "Edit" "Edytuj") (EditQueenResource kind id)
                     ]
                        ++ (if kind == "breederQueens" && availability == tr "Active" "Aktywna" then [ actionButton (tr "Retire" "Wycofaj") (RetireBreederQueen id) ] else [])
                        ++ [ actionButton (tr "Delete" "Usuń") (DeleteQueenResource kind id) ]
                    )
                ]
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
            , actionButton (if english then "Settings" else "Ustawienia") (NavigateTo SettingsView)
            ]
        , section (tr "Resources" "Zasoby") resourceForm
        , resourceList (tr "Breeder queens" "Matki reprodukcyjne") (List.map breederItem model.queenRearingData.breederQueens)
        , resourceList (tr "Starter colonies" "Startery") (List.map colonyItem model.queenRearingData.starterColonies)
        , resourceList (tr "Finisher colonies" "Finishery") (List.map finisherItem model.queenRearingData.finisherColonies)
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
