module Views.QueenRearingResources exposing (queenRearingResourcesView)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types.Core exposing (..)
import I18n exposing (Translations)


queenRearingResourcesView : Translations -> Model -> Html Msg
queenRearingResourcesView t model =
    let
        english = t.isEnglish
        tr en pl = if english then en else pl
        formValue key = Dict.get key model.queenRearingForm |> Maybe.withDefault ""
        sectionCard section title emoji count testId content =
            let
                expanded = List.member section model.expandedSettingsSections
                cardClass = "rounded-xl border p-4 shadow-sm " ++ (if model.darkMode then "border-slate-700 bg-slate-900 text-slate-100" else "border-slate-200 bg-white text-slate-900")
            in
            div [ class cardClass, attribute "data-testid" ("qr-resource-section-" ++ testId) ]
                [ button [ class "flex min-h-11 w-full items-center justify-between text-left", onClick (ToggleSettingsSection section), attribute "aria-expanded" (if expanded then "true" else "false"), attribute "data-testid" ("qr-resource-toggle-" ++ testId) ]
                    [ span [ class "text-lg font-semibold" ] [ text (emoji ++ " " ++ title) ]
                    , span [ class "rounded-full bg-slate-100 px-3 py-1 text-sm text-slate-700 dark:bg-slate-800 dark:text-slate-200" ] [ text (String.fromInt count) ]
                    ]
                , if expanded then div [ class "mt-4 border-t border-slate-200 pt-4 dark:border-slate-700" ] content else text ""
                ]
        inputClass = "min-h-11 w-full rounded-md border px-3 py-2 text-sm " ++ (if model.darkMode then "border-slate-600 bg-slate-800 text-slate-100" else "border-slate-300 bg-white text-slate-900")
        field key caption inputType =
            label [ class "flex flex-col gap-1 text-sm font-medium" ]
                [ text caption
                , Html.input [ class inputClass, type_ inputType, value (formValue key), onInput (QueenRearingInput key), attribute "data-testid" ("qr-input-" ++ key) ] []
                ]
        row identifier details kind active =
            div [ class "flex flex-col gap-3 border-b border-slate-200 py-3 last:border-0 dark:border-slate-700 sm:flex-row sm:items-center sm:justify-between", attribute "data-testid" ("qr-resource-" ++ identifier) ]
                [ span [ class "text-sm" ] [ text details ]
                , div [ class "flex flex-wrap gap-2" ]
                    ([ button [ class "bg-blue-600", onClick (EditQueenResource kind identifier) ] [ text (tr "Edit" "Edytuj") ] ]
                        ++ (if kind == "breederQueens" && active then [ button [ class "bg-amber-600", onClick (RetireBreederQueen identifier) ] [ text (tr "Retire" "Wycofaj") ] ] else [])
                        ++ [ button [ class "destructive-action", onClick (DeleteQueenResource kind identifier), attribute "title" (tr "Delete" "Usuń") ] [ text (tr "Delete" "Usuń") ] ]
                    )
                ]
        editor kind =
            let
                editing = Maybe.map .kind model.editingQueenResource == Just kind
                formFields =
                    [ field "hiveNumber" (tr "Hive number" "Numer ula") "text"
                    ]
                        ++ (if kind == "breederQueens" then
                                [ label [ class "flex flex-col gap-1 text-sm font-medium" ]
                                    [ text (tr "Breed and line" "Rasa i linia")
                                    , select [ class inputClass, value (formValue "breedLine"), onInput (QueenRearingInput "breedLine"), attribute "data-testid" "qr-input-breedLine" ]
                                        (option [ value "" ] [ text (tr "Choose a breed and line" "Wybierz rasę i linię") ] :: List.map (\line -> option [ value line ] [ text line ]) model.breedLines)
                                    ]
                                , label [ class "flex flex-col gap-1 text-sm font-medium" ] [ text (tr "Marking color" "Kolor opalitka"), select [ class inputClass, value (formValue "markingColor"), onInput (QueenRearingInput "markingColor"), attribute "data-testid" "qr-input-markingColor" ] (option [ value "" ] [ text (tr "Choose color" "Wybierz kolor") ] :: List.map (\color -> option [ value color ] [ text color ]) [ "blue", "white", "yellow", "red", "green" ]) ]
                                , field "markingCode" (tr "Marking number" "Numer na opalitku") "text"
                                ]
                            else [])
                save = button [ class "save-action", onClick (SaveQueenResource kind), attribute "data-testid" ("qr-resource-save-" ++ kind) ] [ text (if editing then tr "Save changes" "Zapisz zmiany" else tr "Add" "Dodaj") ]
                cancel = if editing then [ button [ class "bg-slate-600", onClick CancelQueenResourceEdit ] [ text (tr "Cancel" "Anuluj") ] ] else []
            in
            div []
                [ div [ class "mb-4 grid grid-cols-1 gap-3 rounded-lg bg-slate-50 p-3 dark:bg-slate-800 sm:grid-cols-2" ] formFields
                , div [ class "flex flex-wrap gap-2" ] (save :: cancel)
                ]
        breederRows = List.map (\queen -> row queen.id (queen.hiveNumber ++ " · " ++ queen.breed ++ " " ++ queen.line ++ " · " ++ queen.markingColor ++ " " ++ queen.markingCode ++ " · " ++ (if queen.active then tr "Active" "Aktywna" else tr "Inactive" "Nieaktywna")) "breederQueens" queen.active) model.queenRearingData.breederQueens
        listing records = if List.isEmpty records then p [ class "py-3 text-sm text-slate-500 dark:text-slate-400" ] [ text (tr "No resources yet." "Brak zasobów.") ] else div [] records
        card section title emoji kind count rows = sectionCard section title emoji count kind (editor kind :: [ listing rows ])
    in
    div [ class "mx-auto max-w-5xl space-y-4", attribute "data-testid" "queen-rearing-resources-view" ]
        [ div [ class "mb-2 flex flex-wrap items-center justify-between gap-3" ]
            [ h2 [ class "m-0 text-2xl font-bold" ] [ text (tr "Queen rearing resources" "Zasoby hodowli matek") ]
            , button [ onClick (NavigateTo QueenRearingView) ] [ text (tr "← Queen rearing" "← Hodowla matek") ]
            ]
        , card SectionBreederQueens (tr "Breeder queens" "Matki reprodukcyjne") "👑" "breederQueens" (List.length model.queenRearingData.breederQueens) (List.map (\queen -> row queen.id (queen.hiveNumber ++ " · " ++ queen.breed ++ " " ++ queen.line ++ " · " ++ queen.markingColor ++ " " ++ queen.markingCode ++ " · " ++ (if queen.active then tr "Active" "Aktywna" else tr "Inactive" "Nieaktywna")) "breederQueens" queen.active) model.queenRearingData.breederQueens)
        , card SectionStarters (tr "Starter colonies" "Startery") "🐝" "starterColonies" (List.length model.queenRearingData.starterColonies) (List.map (\colony -> row colony.id colony.hiveNumber "starterColonies" False) model.queenRearingData.starterColonies)
        , card SectionFinishers (tr "Finisher colonies" "Finishery") "🍯" "finisherColonies" (List.length model.queenRearingData.finisherColonies) (List.map (\colony -> row colony.id colony.hiveNumber "finisherColonies" False) model.queenRearingData.finisherColonies)
        ]
