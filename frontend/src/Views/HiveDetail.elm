module Views.HiveDetail exposing (hiveDetailView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Json.Decode as Decode
import Types.Core exposing (..)
import Types.Decoders exposing (..)
import Types.Helpers exposing (..)
import I18n exposing (Translations)

hiveDetailView : Translations -> User -> { apiaryId : String, hiveId : String, hiveName : String } -> Model -> Html Msg
hiveDetailView t user info model =
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
                [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px", style "flex-wrap" "wrap" ]
                    [ button [ onClick (NavigateTo (HiveListView { apiaryId = actualApiaryId, apiaryName = apiaryName })), style "padding" "10px 16px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "40px" ] [ text t.back ]
                    , h2 [ style "margin" "0", style "color" headingColor ] [ text (t.localize "Karta Ula: " ++ hive.name) ]
                    ]
                , div [ style "display" "flex", style "flex-direction" "column", style "gap" "20px", style "margin-bottom" "20px" ]
                    [ div []
                        [ h3 [ style "color" headingColor ] [ text (if t.hive == "Hive" then "Technical data" else "Dane Techniczne") ]
                        , label [] [ text (t.localize "Nazwa Ula:") ]
                        , input [ type_ "text", value hive.name, onInput (\val -> UpdateHiveField actualApiaryId hive.id "name" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ] []
                        , label [] [ text (t.localize "Typ ula:") ]
                        , select [ onInput (\val -> UpdateHiveField actualApiaryId hive.id "hiveType" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ]
                            [ option [ value "korpusowy", selected (hive.hiveType == "korpusowy") ] [ text (t.localize "Ul korpusowy") ]
                            , option [ value "lezak", selected (hive.hiveType == "lezak") ] [ text (t.localize "Ul leżak") ]
                            , option [ value "kombinowany", selected (hive.hiveType == "kombinowany") ] [ text (t.localize "Ul kombinowany") ]
                            ]
                        , if hive.hiveType == "korpusowy" then
                            div []
                                [ label [] [ text (t.localize "Typ Ramki:") ]
                                , select [ onInput (\val -> UpdateHiveField actualApiaryId hive.id "frameType" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ]
                                    (List.map (\ft -> option [ value ft, selected (hive.frameType == ft) ] [ text ft ]) model.frameTypes)
                                ]
                          else if hive.hiveType == "lezak" then
                            div []
                                [ label [] [ text (t.localize "Typ ramki gniazdowej:") ]
                                , select [ onInput (\val -> UpdateHiveField actualApiaryId hive.id "broodFrameType" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ]
                                    (List.map (\ft -> option [ value ft, selected (hive.broodFrameType == ft) ] [ text ft ]) model.frameTypes)
                                , label [] [ text (t.localize "Maksymalna liczba ramek w gnieździe:") ]
                                , input [ type_ "number", value (String.fromInt hive.maxBroodFrames), onInput (\val -> UpdateHiveField actualApiaryId hive.id "maxBroodFrames" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ] []
                                , label [ style "margin-top" "5px", style "margin-bottom" "12px", style "display" "flex", style "align-items" "center", style "gap" "8px", style "cursor" "pointer", style "font-weight" "bold" ]
                                    [ input [ type_ "checkbox", checked hive.hasSuper, onCheck (\b -> UpdateHiveField actualApiaryId hive.id "hasSuper" (if b then "true" else "false")), id "detailHasSuperCheck" ] []
                                    , span [] [ text (t.localize "Czy jest nadstawka") ]
                                    ]
                                , if hive.hasSuper then
                                    div [ style "padding-left" "10px", style "border-left" "3px solid #3498db", style "margin-bottom" "10px" ]
                                        [ label [] [ text (t.localize "Typ ramki nadstawkowej (nadstawki):") ]
                                        , select [ onInput (\val -> UpdateHiveField actualApiaryId hive.id "superFrameType" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ]
                                            (List.map (\ft -> option [ value ft, selected (hive.superFrameType == ft) ] [ text ft ]) model.frameTypes)
                                        , label [] [ text (t.localize "Maksymalna liczba ramek w nadstawce:") ]
                                        , input [ type_ "number", value (String.fromInt hive.maxSuperFrames), onInput (\val -> UpdateHiveField actualApiaryId hive.id "maxSuperFrames" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ] []
                                        ]
                                  else
                                    text (t.localize "")
                                ]
                          else
                            div []
                                [ label [] [ text (t.localize "Typ ramki gniazdowej:") ]
                                , select [ onInput (\val -> UpdateHiveField actualApiaryId hive.id "broodFrameType" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ]
                                    (List.map (\ft -> option [ value ft, selected (hive.broodFrameType == ft) ] [ text ft ]) model.frameTypes)
                                , label [] [ text (t.localize "Liczba ramek gniazdowych:") ]
                                , input [ type_ "number", value (String.fromInt hive.broodFrameCount), onInput (\val -> UpdateHiveField actualApiaryId hive.id "broodFrameCount" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ] []
                                , label [] [ text (t.localize "Typ ramki nadstawkowej (nadstawki):") ]
                                , select [ onInput (\val -> UpdateHiveField actualApiaryId hive.id "superFrameType" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ]
                                    (List.map (\ft -> option [ value ft, selected (hive.superFrameType == ft) ] [ text ft ]) model.frameTypes)
                                ]
                        , label [] [ text (t.localize "Poławiacz pyłku:") ]
                        , select [ onInput (\val -> UpdatePollenTrap actualApiaryId hive.id val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ]
                            [ option [ value "brak", selected (hive.pollenTrap == "brak") ] [ text (t.localize "Brak") ]
                            , option [ value "powałkowy", selected (hive.pollenTrap == "powałkowy") ] [ text (t.localize "Powałkowy") ]
                            , option [ value "dennicowy", selected (hive.pollenTrap == "dennicowy") ] [ text (t.localize "Dennicowy") ]
                            ]
                        , label [] [ text (t.localize "Link do NFC:") ]
                        , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "10px", style "flex-wrap" "wrap" ]
                            [ input [ type_ "text", value hive.nfcLink, placeholder (t.localize "Brak linku"), readonly True, style "flex" "1", style "min-width" "200px", style "padding" "10px", style "font-size" "16px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ] []
                            , button [ onClick (CopyText hive.nfcLink), style "padding" "10px 16px", style "background" "#2980b9", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "40px" ] [ text (t.localize "📋 Kopiuj link do NFC") ]
                            ]
                        ]
                    , div []
                        [ h3 [ style "color" headingColor ] [ text (t.localize "Matka Pszczela") ]
                        , label [] [ text (t.localize "Obecność Opalitka:") ]
                        , select [ onInput (\val -> UpdateHiveField actualApiaryId hive.id "queen.hasOpalit" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ]
                            [ option [ value "true", selected hive.queen.hasOpalit ] [ text (t.localize "Tak (Opalitka)") ]
                            , option [ value "false", selected (not hive.queen.hasOpalit) ] [ text (t.localize "Nie / Czarny opalitek") ]
                            ]
                        , if hive.queen.hasOpalit then
                            div []
                                [ label [] [ text (t.localize "Kolor Opalitka:") ]
                                , select [ onInput (\val -> UpdateHiveField actualApiaryId hive.id "queen.color" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ]
                                    [ option [ value "Biały", selected (hive.queen.color == "Biały") ] [ text (t.localize "Biały") ]
                                    , option [ value "Żółty", selected (hive.queen.color == "Żółty") ] [ text (t.localize "Żółty") ]
                                    , option [ value "Czerwony", selected (hive.queen.color == "Czerwony") ] [ text (t.localize "Czerwony") ]
                                    , option [ value "Zielony", selected (hive.queen.color == "Zielony") ] [ text (t.localize "Zielony") ]
                                    , option [ value "Niebieski", selected (hive.queen.color == "Niebieski") ] [ text (t.localize "Niebieski") ]
                                    ]
                                , label [] [ text (t.localize "Numer Opalitka:") ]
                                , input [ type_ "text", value hive.queen.number, onInput (\val -> UpdateHiveField actualApiaryId hive.id "queen.number" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ] []
                                ]
                          else
                            text (t.localize "")
                        ]
                    ]
                , hr [] []
                , if hive.hiveType == "korpusowy" then
                    div []
                        [ h3 [ style "color" headingColor ] [ text (t.localize "Edytor Korpusów (Stan Ula)") ]
                        , p [ style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#666") ]
                            [ text (t.localize "Zarządzaj korpusami ula, obecnością matki w poszczególnych korpusach oraz kratami odgrodowymi.")
                            , br [] []
                            , text (t.localize "Przeciągnij korpus i upuść w górnej strefie, aby przenieść go nad inny, lub w dolnej strefie, aby umieścić go pod nim.")
                            ]
                        , div [ style "display" "flex", style "flex-direction" "column", style "gap" "10px", style "margin-bottom" "15px", style "margin-top" "10px" ]
                            [ Keyed.node "div" []
                                (List.map
                                    (\korpus -> ( korpus.id, korpusItemView t actualApiaryId hive.id (List.length hive.korpusy) model korpus ))
                                    hive.korpusy
                                )
                            ]
                        ]
                  else if hive.hiveType == "lezak" then
                    div []
                        [ h3 [ style "color" headingColor ] [ text (t.localize "Konfiguracja Gniazda i Nadstawek") ]
                        , div [ style "background" (if model.darkMode then "#242424" else "#fdfefe"), style "border" ("1px solid " ++ (if model.darkMode then "#444" else "#dcdde1")), style "padding" "14px", style "border-radius" "6px", style "margin-bottom" "10px", style "color" textColor ]
                            [ p [ style "font-weight" "bold", style "margin-top" "0" ] [ text (t.localize "Gniazdo:") ]
                            , p [] [ text (t.localize "Ramka: " ++ hive.broodFrameType ++ t.localize " | Maks. pojemność: " ++ String.fromInt hive.maxBroodFrames ++ t.localize " ramek") ]
                            , div [ style "display" "flex", style "align-items" "center", style "gap" "10px", style "margin-top" "10px" ]
                                [ text (t.localize "Liczba ramek:")
                                , button
                                    [ onClick (UpdateHiveField actualApiaryId hive.id "broodFrameCount" (String.fromInt (Basics.max 1 (hive.broodFrameCount - 1))))
                                    , style "padding" "6px 12px", style "font-size" "16px", style "border-radius" "4px", style "cursor" "pointer", style "background" (if model.darkMode then "#444" else "#e0e0e0"), style "border" "none", style "color" textColor
                                    ]
                                    [ text (t.localize "➖") ]
                                , span [ style "font-weight" "bold", style "font-size" "18px" ] [ text (String.fromInt hive.broodFrameCount ++ " / " ++ String.fromInt hive.maxBroodFrames) ]
                                , button
                                    [ onClick (UpdateHiveField actualApiaryId hive.id "broodFrameCount" (String.fromInt (Basics.min hive.maxBroodFrames (hive.broodFrameCount + 1))))
                                    , style "padding" "6px 12px", style "font-size" "16px", style "border-radius" "4px", style "cursor" "pointer", style "background" (if model.darkMode then "#444" else "#e0e0e0"), style "border" "none", style "color" textColor
                                    ]
                                    [ text (t.localize "➕") ]
                                ]
                            ]
                        , if hive.hasSuper then
                            div [ style "background" (if model.darkMode then "#242424" else "#fdfefe"), style "border" ("1px solid " ++ (if model.darkMode then "#444" else "#dcdde1")), style "padding" "14px", style "border-radius" "6px", style "margin-bottom" "15px", style "color" textColor ]
                                [ p [ style "font-weight" "bold", style "margin-top" "0" ] [ text (t.localize "Nadstawka:") ]
                                , p [] [ text (t.localize "Ramka nadstawki: " ++ hive.superFrameType ++ t.localize " | Maks. pojemność: " ++ String.fromInt hive.maxSuperFrames ++ t.localize " ramek") ]
                                , div [ style "display" "flex", style "align-items" "center", style "gap" "10px", style "margin-top" "10px" ]
                                    [ text (t.localize "Liczba ramek w nadstawce:")
                                    , button
                                        [ onClick (UpdateHiveField actualApiaryId hive.id "superFrameCount" (String.fromInt (Basics.max 1 (hive.superFrameCount - 1))))
                                        , style "padding" "6px 12px", style "font-size" "16px", style "border-radius" "4px", style "cursor" "pointer", style "background" (if model.darkMode then "#444" else "#e0e0e0"), style "border" "none", style "color" textColor
                                        ]
                                        [ text (t.localize "➖") ]
                                    , span [ style "font-weight" "bold", style "font-size" "18px" ] [ text (String.fromInt hive.superFrameCount ++ " / " ++ String.fromInt hive.maxSuperFrames) ]
                                    , button
                                        [ onClick (UpdateHiveField actualApiaryId hive.id "superFrameCount" (String.fromInt (Basics.min hive.maxSuperFrames (hive.superFrameCount + 1))))
                                        , style "padding" "6px 12px", style "font-size" "16px", style "border-radius" "4px", style "cursor" "pointer", style "background" (if model.darkMode then "#444" else "#e0e0e0"), style "border" "none", style "color" textColor
                                        ]
                                        [ text (t.localize "➕") ]
                                    ]
                                ]
                          else
                            div [ style "background" (if model.darkMode then "#242424" else "#fdfefe"), style "border" ("1px solid " ++ (if model.darkMode then "#444" else "#dcdde1")), style "padding" "14px", style "border-radius" "6px", style "margin-bottom" "15px", style "color" (if model.darkMode then "#aaa" else "#777") ]
                                [ p [ style "margin" "0", style "font-style" "italic" ] [ text (t.localize "Brak nadstawki (zaznacz pole „Czy jest nadstawka” w Danych Technicznych powyżej, aby dodać).") ] ]
                        ]
                  else
                    div []
                        [ h3 [ style "color" headingColor ] [ text (t.localize "Konfiguracja Gniazda i Nadstawek") ]
                        , div [ style "background" (if model.darkMode then "#242424" else "#fdfefe"), style "border" ("1px solid " ++ (if model.darkMode then "#444" else "#dcdde1")), style "padding" "14px", style "border-radius" "6px", style "margin-bottom" "10px", style "color" textColor ]
                            [ p [ style "font-weight" "bold", style "margin-top" "0" ] [ text (t.localize "Gniazdo:") ]
                            , p [] [ text (t.localize "Ramka: " ++ hive.broodFrameType ++ t.localize " | Liczba ramek: " ++ String.fromInt hive.broodFrameCount) ]
                            ]
                        , div [ style "background" (if model.darkMode then "#242424" else "#fdfefe"), style "border" ("1px solid " ++ (if model.darkMode then "#444" else "#dcdde1")), style "padding" "14px", style "border-radius" "6px", style "margin-bottom" "15px", style "color" textColor ]
                            [ p [ style "font-weight" "bold", style "margin-top" "0" ] [ text (t.localize "Nadstawki:") ]
                            , p [] [ text (t.localize "Ramka nadstawki: " ++ hive.superFrameType ++ t.localize " | Liczba nadstawek: " ++ String.fromInt hive.superCount) ]
                            , div [ style "display" "flex", style "gap" "10px", style "margin-top" "10px", style "flex-wrap" "wrap" ]
                                [ button
                                    [ onClick (UpdateHiveField actualApiaryId hive.id "superCount" (String.fromInt (hive.superCount + 1)))
                                    , style "padding" "8px 14px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "font-weight" "bold"
                                    ]
                                    [ text (t.localize "➕ Dodaj nadstawkę") ]
                                , button
                                    [ onClick (UpdateHiveField actualApiaryId hive.id "superCount" (String.fromInt (Basics.max 0 (hive.superCount - 1))))
                                    , style "padding" "8px 14px", style "background" (if hive.superCount <= 0 then "#bdc3c7" else "#e74c3c"), style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" (if hive.superCount <= 0 then "not-allowed" else "pointer"), style "font-weight" "bold"
                                    , disabled (hive.superCount <= 0)
                                    ]
                                    [ text (t.localize "➖ Zabierz nadstawkę") ]
                                ]
                            ]
                        ]
                , hr [] []
                , h3 [ style "color" headingColor ] [ text (t.localize "Notatki") ]
                , div [ style "margin-bottom" "15px" ]
                    [ textarea [ value model.newNoteText, onInput UpdateNewNoteText, placeholder (t.localize "Wpisz notatkę lub użyj dyktowania głosowego..."), style "width" "100%", style "height" "80px", style "padding" "10px", style "font-size" "16px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ] []
                    , div [ style "display" "flex", style "gap" "10px", style "margin-top" "10px", style "flex-wrap" "wrap" ]
                        [ button [ onClick StartSpeechDictation, style "padding" "10px 14px", style "background" "#e67e22", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "40px" ] [ text (t.localize "🎤 Dyktuj") ]
                        , button [ onClick (SubmitSaveNote actualApiaryId info.hiveId model.newNoteText user.uid user.email), style "padding" "10px 14px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "40px" ] [ text (t.localize "Zapisz Notatkę") ]
                        , button [ onClick (SubmitHiveSnapshot actualApiaryId info.hiveId user), style "padding" "10px 14px", style "background" "#8e44ad", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "40px", title (t.localize "Zapisz pełny stan ula jako notatkę") ] [ text (t.localize "📸 Zrzut Ula") ]
                        ]
                    ]
                , div []
                    (List.map (noteItemView t actualApiaryId info.hiveId model) model.notes)
                ]
        _ ->
            div [] [ text (if t.hive == "Hive" then "Loading hive..." else "Ładowanie ula...") ]

noteItemView : Translations -> String -> String -> Model -> Note -> Html Msg
noteItemView t apiaryId hiveId model note =
    let
        isEditing = model.editingNoteId == Just note.id
        cardBg = if model.darkMode then "#242424" else "#f8f9f9"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"
    in
    div [ style "background" cardBg, style "padding" "12px", style "border-radius" "4px", style "margin-bottom" "10px", style "border-left" "4px solid #27ae60", style "color" textColor ]
        (if isEditing then
            [ textarea [ value model.editNoteText, onInput UpdateEditNoteText, style "width" "100%", style "height" "60px", style "padding" "8px", style "font-size" "16px", style "margin-bottom" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ] []
            , div [ style "display" "flex", style "gap" "8px", style "flex-wrap" "wrap" ]
                [ button [ onClick (SubmitUpdateNote apiaryId hiveId note.id), style "padding" "8px 14px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "36px" ] [ text (t.localize "Zapisz") ]
                , button [ onClick CancelEditNote, style "padding" "8px 14px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "36px" ] [ text (t.localize "Anuluj") ]
                ]
            ]
         else
            [ div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-bottom" "4px", style "flex-wrap" "wrap" ]
                [ span [ style "font-size" "12px", style "color" (if model.darkMode then "#95a5a6" else "#7f8c8d") ] [ text (note.authorEmail ++ " (" ++ note.timestamp ++ ")") ]
                , div [ style "display" "flex", style "gap" "8px" ]
                    [ button [ onClick (StartEditNote note), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "16px", style "padding" "4px", title (t.localize "Edytuj") ] [ text (t.localize "✏️") ]
                    , button [ onClick (SubmitDeleteNote apiaryId hiveId note.id), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "16px", style "padding" "4px", title (t.localize "Usuń") ] [ text (t.localize "🗑️") ]
                    ]
                ]
            , div [ style "white-space" "pre-wrap", style "word-break" "break-word" ] [ text note.text ]
            ]
        )

korpusItemView : Translations -> String -> String -> Int -> Model -> Korpus -> Html Msg
korpusItemView t apiaryId hiveId totalCount model korpus =
    let
        boxBg = if model.darkMode then "#242424" else "#fdfefe"
        borderColor = if model.darkMode then "#444" else "#dcdde1"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
    in
    div
        [ class
            ("transform-gpu transition-[transform,opacity,box-shadow] duration-300 ease-out "
                ++ (if model.draggedKorpusId == Just korpus.id then
                        "scale-[1.02] -rotate-1 opacity-60 shadow-xl ring-2 ring-amber-400 z-10"
                    else
                        "scale-100 rotate-0 opacity-100 shadow-sm hover:shadow-md"
                   )
            )
        , attribute "data-korpus-id" korpus.id
        , attribute "data-korpus-card" (apiaryId ++ "|" ++ hiveId ++ "|" ++ korpus.id)
        ]
        [ if korpus.hasExcluderAbove then
            div [ style "display" "flex", style "align-items" "center", style "justify-content" "center", style "padding" "6px", style "background" (if model.darkMode then "#332200" else "#fcf3cf"), style "border" (if model.darkMode then "1px dashed #f39c12" else "1px dashed #f1c40f"), style "border-radius" "4px", style "margin-bottom" "5px", style "font-size" "13px", style "font-weight" "bold", style "color" (if model.darkMode then "#f1c40f" else "#d68910") ]
                [ text (t.localize "🟧 Krata odgrodowa") ]
          else
            text (t.localize "")
        , if korpus.hasFoilAbove then
            div [ style "display" "flex", style "align-items" "center", style "justify-content" "center", style "padding" "6px", style "background" (if model.darkMode then "#173344" else "#eaf2f8"), style "border" (if model.darkMode then "1px dashed #5dade2" else "1px dashed #3498db"), style "border-radius" "4px", style "margin-bottom" "5px", style "font-size" "13px", style "font-weight" "bold", style "color" (if model.darkMode then "#85c1e9" else "#2874a6") ]
                [ text (t.localize "🟦 Szczelna folia nad korpusem") ]
          else
            text (t.localize "")
        , div
            [ attribute "data-korpus-drop" (apiaryId ++ "|" ++ hiveId ++ "|" ++ korpus.id ++ "|before")
            , class "transition-[background-color,opacity] duration-200 ease-out"
            , title (t.localize "Upuść tutaj, aby przenieść korpus nad ten korpus")
            , style "height" "24px"
            , style "background" (if model.draggedKorpusId == Nothing then "transparent" else "#85c1e9")
            , style "opacity" (if model.draggedKorpusId == Nothing then "0.35" else "1")
            , style "border-radius" "4px"
            ]
            []
        , div [ style "background" boxBg, style "border" ("1px solid " ++ borderColor), style "padding" "14px", style "border-radius" "6px", style "color" textColor ]
            [ div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-bottom" "8px", style "flex-wrap" "wrap", style "gap" "8px" ]
                [ span [ style "font-weight" "bold" ] [ text (t.localize "Korpus #" ++ korpus.id) ]
                , button [ attribute "data-korpus-drag-handle" korpus.id, class "transition-transform duration-150 hover:scale-110 active:scale-95", on "pointerdown" (Decode.succeed (StartKorpusDrag korpus.id)), style "touch-action" "none", style "cursor" (if model.draggedKorpusId == Just korpus.id then "grabbing" else "grab"), style "font-size" "18px", style "padding" "6px 10px", style "border" "1px solid #aaa", style "border-radius" "4px", title (t.localize "Przeciągnij korpus, aby zmienić jego położenie") ] [ text "⠿" ]
                , div [ style "display" "flex", style "gap" "6px", style "align-items" "center", style "flex-wrap" "wrap" ]
                    [ button [ onClick (AddKorpusAbove apiaryId hiveId korpus.id), style "padding" "6px 10px", style "background" "#2980b9", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "36px", title (t.localize "Dodaj korpus nad") ] [ text (t.localize "+ ⬆️") ]
                    , button [ onClick (AddKorpusBelow apiaryId hiveId korpus.id), style "padding" "6px 10px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "36px", title (t.localize "Dodaj korpus pod") ] [ text (t.localize "+ ⬇️") ]
                    , button [ onClick (DeleteKorpus apiaryId hiveId korpus.id), disabled (totalCount <= 1), style "padding" "6px 10px", style "background" (if totalCount <= 1 then "#bdc3c7" else "#c0392b"), style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" (if totalCount <= 1 then "not-allowed" else "pointer"), style "min-height" "36px", title (if totalCount <= 1 then "W ulu musi pozostać co najmniej jeden korpus" else "Usuń ten korpus") ] [ text (t.localize "🗑️") ]
                    ]
                ]
            , div [ style "display" "flex", style "flex-direction" "column", style "gap" "8px", style "margin-top" "8px", style "border-top" ("1px solid " ++ borderColor), style "padding-top" "8px" ]
                [ div [ style "display" "flex", style "align-items" "center", style "gap" "8px" ]
                    [ label [ style "display" "flex", style "align-items" "center", style "gap" "8px", style "cursor" "pointer", style "font-size" "14px", style "padding" "4px 0" ]
                        [ input [ type_ "checkbox", checked korpus.hasQueen, onCheck (\_ -> ToggleKorpusQueen apiaryId hiveId korpus.id), style "width" "18px", style "height" "18px" ] []
                        , text (t.localize "Matka")
                        ]
                    , span [ title (t.localize "matka jest w tym korpusie"), style "cursor" "help", style "font-size" "12px", style "color" (if model.darkMode then "#888" else "#666"), style "border" "1px solid #888", style "border-radius" "50%", style "width" "18px", style "height" "18px", style "display" "inline-flex", style "align-items" "center", style "justify-content" "center" ] [ text (t.localize "i") ]
                    ]
                , div [ style "display" "flex", style "align-items" "center", style "gap" "8px" ]
                    [ label [ style "display" "flex", style "align-items" "center", style "gap" "8px", style "cursor" "pointer", style "font-size" "14px", style "padding" "4px 0" ]
                        [ input [ type_ "checkbox", checked korpus.hasExcluderAbove, onCheck (\_ -> ToggleKorpusExcluder apiaryId hiveId korpus.id), style "width" "18px", style "height" "18px" ] []
                        , text (t.localize "Krata odgrodowa nad korpusem")
                        ]
                    ]
                , div [ style "display" "flex", style "align-items" "center", style "gap" "8px" ]
                    [ label [ style "display" "flex", style "align-items" "center", style "gap" "8px", style "cursor" "pointer", style "font-size" "14px", style "padding" "4px 0" ]
                        [ input [ type_ "checkbox", checked korpus.hasFoilAbove, onCheck (\_ -> ToggleKorpusFoil apiaryId hiveId korpus.id), style "width" "18px", style "height" "18px" ] []
                        , text (t.localize "Folia na korpusie")
                        ]
                    , span [ title (t.localize "Szczelna folia odcina korpusy położone nad nią od korpusów poniżej. Oznaczenie działa jak krata odgrodowa i znajduje się nad tym korpusem."), style "cursor" "help", style "font-size" "12px", style "color" (if model.darkMode then "#888" else "#666"), style "border" "1px solid #888", style "border-radius" "50%", style "width" "18px", style "height" "18px", style "display" "inline-flex", style "align-items" "center", style "justify-content" "center" ] [ text (t.localize "i") ]
                    ]
                , div [ style "display" "flex", style "align-items" "center", style "gap" "8px" ]
                    [ label [ style "display" "flex", style "align-items" "center", style "gap" "8px", style "cursor" "pointer", style "font-size" "14px", style "padding" "4px 0" ]
                        [ input [ type_ "checkbox", checked korpus.hasOpenEntrance, onCheck (\_ -> ToggleKorpusEntrance apiaryId hiveId korpus.id), style "width" "18px", style "height" "18px" ] []
                        , text (t.localize "Otwarty wylotek w korpusie")
                        ]
                    , span [ title (t.localize "Otwiera wylotek w tym korpusie i pozwala prowadzić ul dwurodzinny."), style "cursor" "help", style "font-size" "12px", style "color" (if model.darkMode then "#888" else "#666"), style "border" "1px solid #888", style "border-radius" "50%", style "width" "18px", style "height" "18px", style "display" "inline-flex", style "align-items" "center", style "justify-content" "center" ] [ text (t.localize "i") ]
                    ]
        , div
            [ attribute "data-korpus-drop" (apiaryId ++ "|" ++ hiveId ++ "|" ++ korpus.id ++ "|after")
            , class "transition-[background-color,opacity] duration-200 ease-out"
            , title (t.localize "Upuść tutaj, aby przenieść korpus pod ten korpus")
            , style "height" "24px"
            , style "background" (if model.draggedKorpusId == Nothing then "transparent" else "#82e0aa")
            , style "opacity" (if model.draggedKorpusId == Nothing then "0.35" else "1")
            , style "border-radius" "4px"
            ]
            []
                ]
            ]
        ]
