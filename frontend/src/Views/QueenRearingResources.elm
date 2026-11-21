module Views.QueenRearingResources exposing (queenRearingResourcesView)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import I18n exposing (Translations)
import QueenRearing.Domain as QueenDomain
import Types.Core exposing (..)


queenRearingResourcesView : Translations -> Model -> Html Msg
queenRearingResourcesView t model =
    let
        english =
            t.isEnglish

        tr en pl =
            if english then
                en

            else
                pl

        formValue kind key =
            Dict.get (kind ++ "." ++ key) model.queenRearingForm |> Maybe.withDefault ""

        sectionCard section title emoji count testId content =
            let
                expanded =
                    List.member section model.expandedSettingsSections

                sectionBorderColor =
                    if model.darkMode then
                        "#444"

                    else
                        "#ddd"
            in
            div [ class "flex flex-col", attribute "data-testid" ("qr-resource-section-" ++ testId) ]
                [ button
                    [ class "settings-secondary-action settings-section-toggle"
                    , onClick (ToggleSettingsSection section)
                    , style "display" "flex"
                    , style "align-items" "center"
                    , style "justify-content" "space-between"
                    , style "width" "100%"
                    , style "border-bottom" ("2px solid " ++ sectionBorderColor)
                    , style "padding" "0 0 8px 0"
                    , style "margin-bottom"
                        (if expanded then
                            "16px"

                         else
                            "0"
                        )
                    , style "cursor" "pointer"
                    , style "text-align" "left"
                    , attribute "aria-expanded"
                        (if expanded then
                            "true"

                         else
                            "false"
                        )
                    , attribute "data-testid" ("qr-resource-toggle-" ++ testId)
                    ]
                    [ h2
                        [ style "margin" "0"
                        , style "color"
                            (if model.darkMode then
                                "#ffffff"

                             else
                                "#2c3e50"
                            )
                        ]
                        [ text (emoji ++ " " ++ title) ]
                    , span
                        [ class "inline-flex items-center gap-2"
                        , style "flex-shrink" "0"
                        ]
                        [ span [ class "rounded-full bg-slate-100 px-3 py-1 text-sm text-slate-700 dark:bg-slate-800 dark:text-slate-200" ] [ text (String.fromInt count) ]
                        , span
                            [ style "display" "inline-flex"
                            , style "align-items" "center"
                            , style "justify-content" "center"
                            , style "width" "28px"
                            , style "height" "28px"
                            , style "border-radius" "50%"
                            , style "border" ("1px solid " ++ sectionBorderColor)
                            , style "font-size" "14px"
                            , style "color"
                                (if model.darkMode then
                                    "#ffffff"

                                 else
                                    "#2c3e50"
                                )
                            , style "flex-shrink" "0"
                            , attribute "aria-hidden" "true"
                            ]
                            [ text
                                (if expanded then
                                    "∧"

                                 else
                                    "∨"
                                )
                            ]
                        ]
                    ]
                , if expanded then
                    div [ class "flex flex-col gap-4", attribute "data-testid" ("qr-resource-content-" ++ testId) ] content

                  else
                    text ""
                ]

        inputClass =
            "min-h-11 w-full rounded-md border px-3 py-2 text-sm "
                ++ (if model.darkMode then
                        "border-slate-600 bg-slate-800 text-slate-100"

                    else
                        "border-slate-300 bg-white text-slate-900"
                   )

        field kind key caption inputType =
            label [ class "flex flex-col gap-1 text-sm font-medium" ]
                [ text caption
                , Html.input
                    ([ class inputClass, type_ inputType, value (formValue kind key), onInput (QueenRearingInput (kind ++ "." ++ key)), attribute "data-testid" ("qr-input-" ++ kind ++ "-" ++ key) ]
                        ++ (if key == "hiveNumber" then
                                [ Html.Attributes.min "1", required True ]

                            else
                                []
                           )
                    )
                    []
                ]

        colonyNameField kind =
            field kind "name" (tr "Name" "Nazwa") "text"

        row identifier details kind =
            div [ class "flex flex-col gap-3 border-b border-slate-200 py-3 last:border-0 dark:border-slate-700 sm:flex-row sm:items-center sm:justify-between", attribute "data-testid" ("qr-resource-" ++ identifier) ]
                [ if kind == "starterColonies" || kind == "finisherColonies" || kind == "breederQueens" then
                    button [ class "text-left text-sm font-medium text-blue-700 underline", onClick (NavigateTo (QueenResourceDetailView { kind = kind, id = identifier })), attribute "data-testid" ("qr-resource-open-" ++ identifier) ] [ text details ]

                  else
                    span [ class "text-sm" ] [ text details ]
                , div [ class "flex flex-wrap gap-2" ]
                    [ button
                        [ class "destructive-action"
                        , onClick (DeleteQueenResource kind identifier)
                        , attribute "title" (tr "Delete" "Usuń")
                        , attribute "aria-label" (tr "Delete" "Usuń")
                        ]
                        [ text "🗑️" ]
                    ]
                ]

        editor kind =
            let
                editing =
                    Maybe.map .kind model.editingQueenResource == Just kind

                formFields =
                    (if kind == "starterColonies" || kind == "finisherColonies" then
                        [ colonyNameField kind ]

                     else
                        []
                    )
                        ++ [ field kind "hiveNumber" (tr "Hive number" "Numer ula") "number"
                           ]
                        ++ (if kind == "breederQueens" then
                                [ label [ class "flex flex-col gap-1 text-sm font-medium" ]
                                    [ text (tr "Breed and line" "Rasa i linia")
                                    , select [ class inputClass, value (formValue kind "breedLine"), onInput (QueenRearingInput (kind ++ ".breedLine")), attribute "data-testid" "qr-input-breedLine" ]
                                        (option [ value "" ] [ text (tr "Choose a breed and line" "Wybierz rasę i linię") ] :: List.map (\line -> option [ value line ] [ text line ]) model.breedLines)
                                    ]
                                , label [ class "flex flex-col gap-1 text-sm font-medium" ] [ text (tr "Marking color" "Kolor opalitka"), select [ class inputClass, value (formValue kind "markingColor"), onInput (QueenRearingInput (kind ++ ".markingColor")), attribute "data-testid" "qr-input-markingColor" ] (option [ value "" ] [ text (tr "Choose color" "Wybierz kolor") ] :: List.map (\color -> option [ value color ] [ text (tr color (markingColorLabel color)) ]) [ "blue", "white", "yellow", "red", "green" ]) ]
                                , field kind "markingCode" (tr "Marking number" "Numer na opalitku") "text"
                                ]

                            else
                                []
                           )

                save =
                    button [ class "save-action", onClick (SaveQueenResource kind), attribute "data-testid" ("qr-resource-save-" ++ kind) ]
                        [ text
                            (if editing then
                                tr "Save changes" "Zapisz zmiany"

                             else
                                tr "Add" "Dodaj"
                            )
                        ]

                cancel =
                    if editing then
                        [ button [ class "destructive-action", onClick CancelQueenResourceEdit ] [ text (tr "Cancel" "Anuluj") ] ]

                    else
                        []
            in
            div []
                [ div [ class "mb-4 grid grid-cols-1 gap-3 rounded-lg bg-slate-50 p-3 dark:bg-slate-800 sm:grid-cols-2" ] formFields
                , div [ class "flex flex-wrap gap-2" ] (save :: cancel)
                ]

        breederRows =
            List.map (\queen -> row queen.id (String.fromInt queen.hiveNumber ++ " · " ++ queen.breed ++ " " ++ queen.line ++ " · " ++ tr queen.markingColor (markingColorLabel queen.markingColor) ++ " " ++ queen.markingCode) "breederQueens") model.queenRearingData.breederQueens

        listing records =
            if List.isEmpty records then
                p [ class "py-3 text-sm text-slate-500 dark:text-slate-400" ] [ text (tr "No resources yet." "Brak zasobów.") ]

            else
                div [] records

        card section title emoji kind count rows =
            sectionCard section title emoji count kind (editor kind :: [ listing rows ])
    in
    case model.viewState of
        QueenResourceDetailView info ->
            let
                isBreederQueen =
                    info.kind == "breederQueens"

                starters =
                    info.kind == "starterColonies"

                colonies =
                    if starters then
                        model.queenRearingData.starterColonies

                    else
                        model.queenRearingData.finisherColonies

                selected =
                    List.filter (\colony -> colony.id == info.id) colonies |> List.head

                selectedQueen =
                    List.filter (\queen -> queen.id == info.id) model.queenRearingData.breederQueens |> List.head

                editingSelectedResource =
                    model.editingQueenResource
                        == Just { kind = info.kind, id = info.id }

                batches =
                    List.filter
                        (\batch ->
                            (if starters then
                                batch.starterColonyId

                             else
                                batch.finisherColonyId
                            )
                                == Just info.id
                        )
                        model.queenRearingData.rearingBatches

                queenBatches =
                    List.filter (\batch -> batch.breederQueenId == info.id) model.queenRearingData.rearingBatches

                occupied batch =
                    let
                        startDate =
                            if starters then
                                batch.graftedAt

                            else
                                Maybe.withDefault batch.graftedAt batch.starterTransferAt

                        endDate =
                            if starters then
                                Maybe.withDefault batch.graftedAt batch.starterTransferAt

                            else
                                Maybe.withDefault (Maybe.withDefault batch.graftedAt batch.starterTransferAt) batch.isolationAt
                    in
                    div [ class "rounded border p-3", attribute "data-testid" ("qr-occupancy-" ++ batch.id) ]
                        [ strong [] [ text (tr "Batch " "Seria " ++ batch.number) ]
                        , p [ class "m-0 text-sm" ] [ text (startDate ++ " – " ++ endDate) ]
                        , p [ class "m-0 text-sm text-slate-600" ]
                            [ text
                                (tr "Status: " "Status: "
                                    ++ (case batch.status of
                                            QueenDomain.Planned ->
                                                tr "Planned" "Zaplanowana"

                                            QueenDomain.InStarter ->
                                                tr "In starter" "W starterze"

                                            QueenDomain.InFinisher ->
                                                tr "In finisher" "W finisherze"

                                            QueenDomain.InIncubator ->
                                                tr "In incubator" "W cieplarce"

                                            QueenDomain.Completed ->
                                                tr "Completed" "Zakończona"
                                       )
                                )
                            ]
                        ]
            in
            div [ class "mx-auto max-w-5xl space-y-4", attribute "data-testid" "queen-resource-detail-view" ]
                [ button [ onClick (NavigateTo QueenRearingResourcesView) ] [ text (tr "← Resources" "← Zasoby") ]
                , h2 [ class "text-2xl font-bold" ]
                    [ text
                        (if isBreederQueen then
                            selectedQueen |> Maybe.map (\queen -> tr "Breeder queen" "Matka reprodukcyjna" ++ " · " ++ String.fromInt queen.hiveNumber) |> Maybe.withDefault (tr "Resource not found" "Nie znaleziono zasobu")

                         else
                            selected
                            |> Maybe.map
                                (\colony ->
                                    (if colony.name == "" then
                                        tr
                                            (if starters then
                                                "Starter"

                                             else
                                                "Finisher"
                                            )
                                            (if starters then
                                                "Starter"

                                             else
                                                "Finisher"
                                            )

                                     else
                                        colony.name
                                    )
                                        ++ " · "
                                        ++ String.fromInt colony.hiveNumber
                                )
                            |> Maybe.withDefault (tr "Resource not found" "Nie znaleziono zasobu")
                        )
                    ]
                , if isBreederQueen then
                    case selectedQueen of
                        Just queen ->
                            div [ class "space-y-3 rounded-lg border p-4", attribute "data-testid" "qr-breeder-queen-detail" ]
                                [ h3 [] [ text (tr "Mother details" "Informacje o matce") ]
                                , p [ class "m-0 text-sm" ] [ text (tr "Hive number: " "Numer ula: " ++ String.fromInt queen.hiveNumber) ]
                                , p [ class "m-0 text-sm" ] [ text (tr "Breed: " "Rasa: " ++ queen.breed) ]
                                , p [ class "m-0 text-sm" ] [ text (tr "Line: " "Linia: " ++ queen.line) ]
                                , p [ class "m-0 text-sm" ] [ text (tr "Marking: " "Opalitka: " ++ tr queen.markingColor (markingColorLabel queen.markingColor) ++ " " ++ queen.markingCode) ]
                                , p [ class "m-0 text-sm" ] [ text (tr "Status: " "Status: " ++ (if queen.active then tr "Active" "Aktywna" else tr "Inactive" "Nieaktywna")) ]
                                , h3 [] [ text (tr "Rearing batches" "Serie wychowu") ]
                                , if List.isEmpty queenBatches then
                                    p [ class "text-sm text-slate-500" ] [ text (tr "No batches for this queen." "Brak serii przypisanych do tej matki.") ]
                                  else
                                    div [ class "space-y-2" ] (List.map occupied queenBatches)
                                , if editingSelectedResource then editor info.kind else text ""
                                , div [ class "flex flex-wrap gap-2" ]
                                    [ button [ onClick (EditQueenResource info.kind queen.id), style "background" "#f7dc6f", style "color" "#422006", style "border" "2px solid #b88900", style "border-radius" "4px", style "cursor" "pointer", style "font-size" "14px", style "padding" "6px", title (tr "Edit" "Edytuj"), attribute "data-testid" "qr-resource-edit" ] [ text "✏️" ]
                                    , button [ onClick (DeleteQueenResource info.kind queen.id), style "background" "#c0392b", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "font-size" "14px", style "padding" "6px", title (tr "Delete" "Usuń"), attribute "data-testid" "qr-resource-delete" ] [ text "🗑️" ]
                                    ]
                                ]
                        Nothing ->
                            text ""

                  else
                    case selected of
                    Just colony ->
                        div [ class "space-y-3 rounded-lg border p-4" ]
                            [ h3 [] [ text (tr "Availability calendar" "Kalendarz zajętości") ]
                            , if List.isEmpty batches then
                                p [ class "text-sm text-slate-500" ] [ text (tr "No scheduled batches." "Brak zaplanowanych serii.") ]

                              else
                                div [ class "space-y-2" ] (List.map occupied batches)
                            , if editingSelectedResource then
                                editor info.kind

                              else
                                text ""
                            , div [ class "flex flex-wrap gap-2" ]
                                [ button [ onClick (EditQueenResource info.kind colony.id), style "background" "#f7dc6f", style "color" "#422006", style "border" "2px solid #b88900", style "border-radius" "4px", style "cursor" "pointer", style "font-size" "14px", style "padding" "6px", title (tr "Edit" "Edytuj") ] [ text "✏️" ]
                                , button [ onClick (DeleteQueenResource info.kind colony.id), style "background" "#c0392b", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "font-size" "14px", style "padding" "6px", title (tr "Delete" "Usuń") ] [ text "🗑️" ]
                                ]
                            ]

                    Nothing ->
                        text ""
                ]

        _ ->
            div [ class "mx-auto max-w-5xl space-y-4", attribute "data-testid" "queen-rearing-resources-view" ]
                [ div [ class "mb-2 flex flex-wrap items-center justify-between gap-3" ]
                    [ h2 [ class "m-0 text-2xl font-bold" ] [ text (tr "Queen rearing resources" "Zasoby hodowli matek") ]
                    , button [ onClick (NavigateTo QueenRearingView) ] [ text (tr "← Queen rearing" "← Hodowla matek") ]
                    ]
                , card SectionBreederQueens (tr "Breeder queens" "Matki reprodukcyjne") "👑" "breederQueens" (List.length model.queenRearingData.breederQueens) breederRows
                , card SectionStarters
                    (tr "Starter colonies" "Startery")
                    "🐝"
                    "starterColonies"
                    (List.length model.queenRearingData.starterColonies)
                    (List.map
                        (\colony ->
                            row colony.id
                                ((if colony.name == "" then
                                    ""

                                  else
                                    colony.name ++ " · "
                                 )
                                    ++ String.fromInt colony.hiveNumber
                                )
                                "starterColonies"
                        )
                        model.queenRearingData.starterColonies
                    )
                , card SectionFinishers
                    (tr "Finisher colonies" "Finishery")
                    "🍯"
                    "finisherColonies"
                    (List.length model.queenRearingData.finisherColonies)
                    (List.map
                        (\colony ->
                            row colony.id
                                ((if colony.name == "" then
                                    ""

                                  else
                                    colony.name ++ " · "
                                 )
                                    ++ String.fromInt colony.hiveNumber
                                )
                                "finisherColonies"
                        )
                        model.queenRearingData.finisherColonies
                    )
                ]


markingColorLabel : String -> String
markingColorLabel color =
    case String.toLower color of
        "blue" ->
            "🔵 Niebieski"

        "white" ->
            "⚪ Biały"

        "yellow" ->
            "🟡 Żółty"

        "red" ->
            "🔴 Czerwony"

        "green" ->
            "🟢 Zielony"

        _ ->
            color
