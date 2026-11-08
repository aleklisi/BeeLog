module Views.PasieczyskoTowarowe exposing (hiveListView, hiveDetailView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Types exposing (..)

hiveListView : User -> { apiaryId : String, apiaryName : String } -> Model -> Html Msg
hiveListView user info model =
    div []
        [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px" ]
            [ button [ onClick (NavigateTo ApiariesView), style "padding" "6px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "← Powrót" ]
            , h2 [ style "margin" "0", style "color" (if model.darkMode then "#ffffff" else "inherit") ] [ text ("Pasieka: " ++ info.apiaryName) ]
            ]
        , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "20px" ]
            [ button [ onClick OpenNewHiveModal, style "padding" "10px 16px", style "background-color" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "+ Dodaj Nowy Ul" ]
            ]
        , div [ style "display" "flex", style "flex-direction" "column", style "gap" "15px" ]
            (List.map (hiveCardView info.apiaryId model) model.hives)
        ]

hiveCardView : String -> Model -> Hive -> Html Msg
hiveCardView apiaryId model hive =
    let
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        borderColor = if model.darkMode then "#333" else "#eee"
        metaBg = if model.darkMode then "#2d2d2d" else "#f1f2f6"
    in
    div [ style "background" cardBg, style "padding" "15px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "cursor" "pointer", style "color" textColor
        , onClick (NavigateTo (HiveDetailView { apiaryId = apiaryId, hiveId = hive.id, hiveName = hive.name }))
        ]
        [ h3 [ style "margin-top" "0", style "color" headingColor ] [ text hive.name ]
        , p [ style "margin" "5px 0", style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#555") ] [ text ("Typ ramki: " ++ hive.frameType) ]
        , div [ style "margin-top" "10px", style "font-size" "12px", style "background" metaBg, style "padding" "5px", style "border-radius" "4px", style "color" textColor ]
            [ text ("Matka: " ++ (if hive.queen.hasOpalit then "Opalitek " ++ hive.queen.color ++ " #" ++ hive.queen.number else "Brak opalitka")) ]
        , div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-top" "10px", style "border-top" ("1px solid " ++ borderColor), style "padding-top" "10px" ]
            [ div [ style "display" "flex", style "gap" "4px" ]
                [ button [ stopPropagationOn "click" (Decode.succeed (MoveHiveUp hive.id, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Przesuń w górę" ] [ text "⬆️" ]
                , button [ stopPropagationOn "click" (Decode.succeed (MoveHiveDown hive.id, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Przesuń w dół" ] [ text "⬇️" ]
                ]
            , div [ style "display" "flex", style "gap" "8px" ]
                [ button [ stopPropagationOn "click" (Decode.succeed (OpenRenameHiveModal apiaryId hive, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Zmień nazwę ula" ] [ text "✏️" ]
                , button [ stopPropagationOn "click" (Decode.succeed (OpenDeleteHiveModal apiaryId hive, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Usuń ul" ] [ text "🗑️" ]
                ]
            ]
        ]

hiveDetailView : User -> { apiaryId : String, hiveId : String, hiveName : String } -> Model -> Html Msg
hiveDetailView user info model =
    let
        maybeHive = List.head (List.filter (\h -> h.id == info.hiveId) model.hives)
        actualApiaryId = case maybeHive of
            Just hive -> if hive.apiaryId /= "" then hive.apiaryId else info.apiaryId
            Nothing -> info.apiaryId
        maybeApiary = List.head (List.filter (\a -> a.id == actualApiaryId) model.apiaries)
        apiaryName = case maybeApiary of
            Just a -> a.name
            Nothing -> "Pasieka"
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"
    in
    case maybeHive of
        Just hive ->
            div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "color" textColor ]
                [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px" ]
                    [ button [ onClick (NavigateTo (HiveListView { apiaryId = actualApiaryId, apiaryName = apiaryName })), style "padding" "6px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "← Powrót" ]
                    , h2 [ style "margin" "0", style "color" headingColor ] [ text ("Karta Ula: " ++ hive.name) ]
                    ]
                , div [ style "display" "flex", style "flex-direction" "column", style "gap" "20px", style "margin-bottom" "20px" ]
                    [ div []
                        [ h3 [ style "color" headingColor ] [ text "Dane Techniczne" ]
                        , label [] [ text "Nazwa Ula:" ]
                        , input [ type_ "text", value hive.name, onInput (\val -> UpdateHiveField actualApiaryId hive.id "name" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                        , label [] [ text "Typ Ramki:" ]
                        , select [ onInput (\val -> UpdateHiveField actualApiaryId hive.id "frameType" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                            (List.map (\ft -> option [ value ft, selected (hive.frameType == ft) ] [ text ft ]) model.frameTypes)
                        , label [] [ text "Poławiacz pyłku:" ]
                        , select [ onInput (\val -> UpdatePollenTrap actualApiaryId hive.id val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                            [ option [ value "brak", selected (hive.pollenTrap == "brak") ] [ text "Brak" ]
                            , option [ value "powałkowy", selected (hive.pollenTrap == "powałkowy") ] [ text "Powałkowy" ]
                            , option [ value "dennicowy", selected (hive.pollenTrap == "dennicowy") ] [ text "Dennicowy" ]
                            ]
                        , label [] [ text "Link do NFC:" ]
                        , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "10px" ]
                            [ input [ type_ "text", value hive.nfcLink, placeholder "Brak linku", readonly True, style "flex" "1", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                            , button [ onClick (CopyText hive.nfcLink), style "padding" "8px 12px", style "background" "#2980b9", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "📋 Kopiuj link do NFC" ]
                            ]
                        ]
                    , div []
                        [ h3 [ style "color" headingColor ] [ text "Matka Pszczela" ]
                        , label [] [ text "Obecność Opalitka:" ]
                        , select [ onInput (\val -> UpdateHiveField actualApiaryId hive.id "queen.hasOpalit" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                            [ option [ value "true", selected hive.queen.hasOpalit ] [ text "Tak (Opalitka)" ]
                            , option [ value "false", selected (not hive.queen.hasOpalit) ] [ text "Nie / Czarny opalitek" ]
                            ]
                        , if hive.queen.hasOpalit then
                            div []
                                [ label [] [ text "Kolor Opalitka:" ]
                                , select [ onInput (\val -> UpdateHiveField actualApiaryId hive.id "queen.color" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                    [ option [ value "Biały", selected (hive.queen.color == "Biały") ] [ text "Biały" ]
                                    , option [ value "Żółty", selected (hive.queen.color == "Żółty") ] [ text "Żółty" ]
                                    , option [ value "Czerwony", selected (hive.queen.color == "Czerwony") ] [ text "Czerwony" ]
                                    , option [ value "Zielony", selected (hive.queen.color == "Zielony") ] [ text "Zielony" ]
                                    , option [ value "Niebieski", selected (hive.queen.color == "Niebieski") ] [ text "Niebieski" ]
                                    ]
                                , label [] [ text "Numer Opalitka:" ]
                                , input [ type_ "text", value hive.queen.number, onInput (\val -> UpdateHiveField actualApiaryId hive.id "queen.number" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                                ]
                          else
                            text ""
                        ]
                    ]
                , hr [] []
                , h3 [ style "color" headingColor ] [ text "Notatki" ]
                , div [ style "margin-bottom" "15px" ]
                    [ textarea [ value model.newNoteText, onInput UpdateNewNoteText, placeholder "Wpisz notatkę lub użyj dyktowania głosowego...", style "width" "100%", style "height" "80px", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                    , div [ style "display" "flex", style "gap" "10px", style "margin-top" "10px" ]
                        [ button [ onClick StartSpeechDictation, style "padding" "8px 14px", style "background" "#e67e22", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "🎤 Dyktuj" ]
                        , button [ onClick (SubmitSaveNote actualApiaryId info.hiveId model.newNoteText user.uid user.email), style "padding" "8px 14px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Zapisz Notatkę" ]
                        , button [ onClick (SubmitHiveSnapshot actualApiaryId info.hiveId user), style "padding" "8px 14px", style "background" "#8e44ad", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", title "Zapisz pełny stan ula jako notatkę" ] [ text "📸 Zrzut Ula" ]
                        ]
                    ]
                , div []
                    (List.map (noteItemView actualApiaryId info.hiveId model) model.notes)
                ]
        _ ->
            div [] [ text "Ładowanie ula..." ]

noteItemView : String -> String -> Model -> Note -> Html Msg
noteItemView apiaryId hiveId model note =
    let
        isEditing = model.editingNoteId == Just note.id
        cardBg = if model.darkMode then "#242424" else "#f8f9f9"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"
    in
    div [ style "background" cardBg, style "padding" "10px", style "border-radius" "4px", style "margin-bottom" "10px", style "border-left" "4px solid #27ae60", style "color" textColor ]
        (if isEditing then
            [ textarea [ value model.editNoteText, onInput UpdateEditNoteText, style "width" "100%", style "height" "60px", style "padding" "6px", style "margin-bottom" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
            , div [ style "display" "flex", style "gap" "8px" ]
                [ button [ onClick (SubmitUpdateNote apiaryId hiveId note.id), style "padding" "4px 10px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Zapisz" ]
                , button [ onClick CancelEditNote, style "padding" "4px 10px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Anuluj" ]
                ]
            ]
         else
            [ div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-bottom" "4px" ]
                [ span [ style "font-size" "11px", style "color" (if model.darkMode then "#95a5a6" else "#7f8c8d") ] [ text (note.authorEmail ++ " (" ++ note.timestamp ++ ")") ]
                , div [ style "display" "flex", style "gap" "6px" ]
                    [ button [ onClick (StartEditNote note), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "12px", title "Edytuj" ] [ text "✏️" ]
                    , button [ onClick (SubmitDeleteNote apiaryId hiveId note.id), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "12px", title "Usuń" ] [ text "🗑️" ]
                    ]
                ]
            , div [ style "white-space" "pre-wrap", style "word-break" "break-word" ] [ text note.text ]
            ]
        )
