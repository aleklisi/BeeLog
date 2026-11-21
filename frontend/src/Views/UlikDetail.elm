module Views.UlikDetail exposing (ulikDetailView, statusColors)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Types.Core exposing (..)
import Types.Decoders exposing (..)
import Types.Helpers exposing (..)
import I18n exposing (Translations)


statusColors : UlikState -> ( String, String )
statusColors state =
    case state of
        Bezmatek ->
            ( "#e74c3c", "#ffffff" )

        ZMatecznikiem ->
            ( "#f7dc6f", "#422006" )

        MatkaWygryziona ->
            ( "#d4ac0d", "#422006" )

        MatkaCzerwi ->
            ( "#27ae60", "#ffffff" )

        PustyUlik ->
            ( "#64748b", "#ffffff" )


statusBadge : Translations -> UlikState -> Html Msg
statusBadge t state =
    let
        ( background, foreground ) =
            statusColors state
    in
    span
        [ style "display" "inline-block"
        , style "padding" "4px 10px"
        , style "border-radius" "9999px"
        , style "background" background
        , style "color" foreground
        , style "font-weight" "700"
        , style "border" "2px solid currentColor"
        , attribute "data-testid" "mating-hive-current-status"
        ]
        [ text (t.localize (ulikStateLabel state)) ]

ulikTimelineView : Translations -> Model -> UlikWeselny -> Html Msg
ulikTimelineView t model ulik =
    if ulik.expectedHatchDate == "" then
        div [ style "font-size" "12px", style "color" (if model.darkMode then "#888" else "#777"), style "font-style" "italic", style "margin-top" "5px" ]
            [ text (t.localize "Oś czasu: brak daty wygryzienia") ]
    else
        let
            maybeHatch = parseDate ulik.expectedHatchDate
            maybeMating = if ulik.expectedMatingDate /= "" then parseDate ulik.expectedMatingDate else Nothing
            maybeNow = if model.currentDate /= "" then parseDate model.currentDate else Nothing
        in
        case maybeHatch of
            Just (hy, hm, hd) ->
                let
                    hDays = dateToDays hy hm hd
                    mDays = case maybeMating of
                        Just (my, mm, md) -> dateToDays my mm md
                        Nothing -> hDays + model.hatchingToMatingDays
                    d30Days = hDays + 30
                    nowDays = case maybeNow of
                        Just (ty, tm, td) -> dateToDays ty tm td
                        Nothing -> hDays

                    minDays = Basics.min (Basics.min hDays nowDays) (Basics.min mDays d30Days) - 5
                    maxDays = Basics.max (Basics.max hDays nowDays) (Basics.max mDays d30Days) + 10
                    spanDays = Basics.max 1 (maxDays - minDays)

                    toPct days =
                        let
                            pct = toFloat (days - minDays) / toFloat spanDays * 100
                        in
                        clamp 0 100 pct

                    hPct = toPct hDays
                    mPct = toPct mDays
                    d30Pct = toPct d30Days
                    nowPct = toPct nowDays
                in
                div [ style "margin-top" "10px", style "font-size" "12px" ]
                    [ div [ style "font-weight" "bold", style "margin-bottom" "3px", style "color" (if model.darkMode then "#ccc" else "#555") ]
                        [ text (t.localize "Oś czasu cyklu matki:") ]
                    , div [ style "position" "relative", style "height" "14px", style "background" (if model.darkMode then "#333" else "#e0e0e0"), style "border-radius" "7px", style "overflow" "hidden", style "margin-bottom" "5px" ]
                        [ div [ style "position" "absolute", style "top" "0", style "left" "0", style "width" (String.fromFloat hPct ++ "%"), style "height" "100%", style "background" "#f7dc6f", title (t.localize "Do wygryzienia (jasno żółty)") ] []
                        , div [ style "position" "absolute", style "top" "0", style "left" (String.fromFloat hPct ++ "%"), style "width" (String.fromFloat (Basics.max 0 (mPct - hPct)) ++ "%"), style "height" "100%", style "background" "#d4ac0d", title (t.localize "Wygryzienie do unasiennienia (ciemno żółty)") ] []
                        , div [ style "position" "absolute", style "top" "0", style "left" (String.fromFloat mPct ++ "%"), style "width" (String.fromFloat (Basics.max 0 (d30Pct - mPct)) ++ "%"), style "height" "100%", style "background" "#27ae60", title (t.localize "Okres po unasiennieniu") ] []
                        , div [ style "position" "absolute", style "top" "0", style "left" (String.fromFloat d30Pct ++ "%"), style "width" (String.fromFloat (Basics.max 0 (100 - d30Pct)) ++ "%"), style "height" "100%", style "background" "#e74c3c", title (t.localize "Po 30 dniach od wygryzienia (czerwony - deadline)") ] []
                        , div [ style "position" "absolute", style "top" "0", style "left" (String.fromFloat nowPct ++ "%"), style "width" "3px", style "height" "100%", style "background" "#3498db", style "z-index" "2", title ("Teraz: " ++ model.currentDate) ] []
                        ]
                    , div [ style "display" "flex", style "justify-content" "space-between", style "font-size" "10px", style "color" (if model.darkMode then "#aaa" else "#666") ]
                        [ span [] [ text ("Teraz: " ++ (if model.currentDate == "" then "-" else model.currentDate)) ]
                        , span [] [ text ("Wygryz.: " ++ ulik.expectedHatchDate) ]
                        , span [] [ text ("Unasien.: " ++ (if ulik.expectedMatingDate == "" then "-" else ulik.expectedMatingDate)) ]
                        , span [] [ text ("+30 dni: " ++ addDaysToDateString 30 ulik.expectedHatchDate) ]
                        ]
                    ]
            _ ->
                text (t.localize "")

ulikDetailView : Translations -> User -> { apiaryId : String, ulikId : String, ulikName : String } -> Model -> Html Msg
ulikDetailView t user info model =
    let
        maybeUlik = List.head (List.filter (\u -> u.id == info.ulikId) model.uliki)
        actualApiaryId = case maybeUlik of
            Just ulik -> if ulik.apiaryId /= "" then ulik.apiaryId else info.apiaryId
            Nothing -> info.apiaryId
        maybeApiary = List.head (List.filter (\a -> a.id == actualApiaryId) model.apiaries)
        apiaryName = case maybeApiary of
            Just a -> a.name
            Nothing -> "Trutowisko"
        cardBg = if model.darkMode then "#17231b" else "#f0fdf4"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"
    in
    case maybeUlik of
        Just ulik ->
            div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "color" textColor ]
                [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px", style "flex-wrap" "wrap" ]
                    [ button [ class "secondary-action", onClick (NavigateTo (UlikListView { apiaryId = actualApiaryId, apiaryName = apiaryName })), style "padding" "10px 16px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "40px" ] [ text t.back ]
                    , h2 [ style "margin" "0", style "color" headingColor ] [ text ("Ulik Weselny: " ++ ulik.name) ]
                    , button [ attribute "data-testid" "MoveMatingHive", onClick (OpenMoveUlikModal actualApiaryId ulik), style "background" "#f7dc6f", style "color" "#422006", style "border" "2px solid #b88900", style "border-radius" "4px", style "cursor" "pointer" ] [ text ("🚚 " ++ t.moveMatingHive) ]
                    ]
                , div [ style "display" "flex", style "flex-direction" "column", style "gap" "20px", style "margin-bottom" "20px" ]
                    [ div []
                        [ h3 [ style "color" headingColor ] [ text (t.localize "Dane Uliku Weselnego") ]
                        , label [] [ text (t.localize "Nazwa / Numer uliku:") ]
                        , input [ type_ "text", value ulik.name, onInput (\val -> UpdateUlikField actualApiaryId ulik.id "name" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ] []
                        , label [] [ text (t.localize "Typ ula:") ]
                        , select [ onInput (\val -> UpdateUlikField actualApiaryId ulik.id "hiveType" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ]
                            (List.map (\ut -> option [ value ut, selected (ulik.hiveType == ut) ] [ text ut ]) model.ulikTypes)
                        , label [] [ text (t.localize "Link do NFC:") ]
                        , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "10px", style "flex-wrap" "wrap" ]
                            [ input [ type_ "text", value ulik.nfcLink, placeholder (t.localize "Brak linku"), readonly True, style "flex" "1", style "min-width" "200px", style "padding" "10px", style "font-size" "16px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ] []
                            , button [ class "mating-state-m", onClick (CopyText ulik.nfcLink), style "padding" "8px 14px", style "background" "#f7dc6f", style "color" "#422006", style "border" "2px solid #b88900", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "36px" ] [ text (t.localize "📋 Kopiuj link do NFC") ]
                            ]
                        , label [] [ text (t.localize "Spodziewany termin wygryzienia:") ]
                        , input [ type_ "date", value ulik.expectedHatchDate, onInput (\val -> UpdateUlikField actualApiaryId ulik.id "expectedHatchDate" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ] []
                        , label [] [ text (t.localize "Spodziewany termin unasiennienia (+10 dni):") ]
                        , div [ style "display" "flex", style "align-items" "center", style "gap" "10px", style "margin-bottom" "10px", style "flex-wrap" "wrap" ]
                            [ input [ type_ "date", value ulik.expectedMatingDate, readonly True, style "flex" "1", style "min-width" "200px", style "padding" "10px", style "font-size" "16px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ] []
                            , if getUlikState ulik == MatkaWygryziona && ulik.expectedHatchDate /= "" && model.currentDate /= "" then
                                let
                                    hatchParsed = parseDate ulik.expectedHatchDate
                                    todayParsed = parseDate model.currentDate
                                in
                                case (hatchParsed, todayParsed) of
                                    (Just (hy, hm, hd), Just (ty, tm, td)) ->
                                        let
                                            hDays = dateToDays hy hm hd
                                            tDays = dateToDays ty tm td
                                            diff = tDays - hDays
                                        in
                                        if diff < 10 then
                                            span [ title (t.localize "Oczekiwanie na unasiennienie (przed terminem)"), style "font-size" "18px" ] [ text (t.localize "❓") ]
                                        else if diff >= 10 && diff <= 21 then
                                            span [ style "background" "#27ae60", style "color" "white", style "padding" "4px 8px", style "border-radius" "4px", style "font-size" "12px", style "font-weight" "bold", title (t.localize "W terminie (10-21 dni od wygryzienia)") ] [ text (t.localize "✓ W terminie") ]
                                        else
                                            span [ style "background" "#e74c3c", style "color" "white", style "padding" "4px 8px", style "border-radius" "4px", style "font-size" "12px", style "font-weight" "bold", title (t.localize "Przekroczono termin (>21 dni)") ] [ text (t.localize "✗ Przekroczony") ]
                                    _ ->
                                        text (t.localize "")
                              else
                                text (t.localize "")
                            ]
                        , ulikTimelineView t model ulik
                        ]
                    , div []
                        [ h3 [ style "color" headingColor ] [ text (t.localize "Stan i Matka Pszczela") ]
                        , p [ style "font-weight" "bold" ]
                            [ text (t.localize "Aktualny stan: ")
                            , statusBadge t (getUlikState ulik)
                            ]
                        , div [ class "state-transition-buttons", style "display" "flex", style "flex-direction" "column", style "gap" "8px", style "margin-bottom" "15px" ]
                            (case getUlikState ulik of
                                Bezmatek ->
                                    [ button [ class "mating-state-m", onClick (OpenUlikModal actualApiaryId ulik.id ModalPoddajMatecznik), style "padding" "8px 14px", style "background" "#f7dc6f", style "color" "#422006", style "border" "2px solid #b88900", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "36px" ] [ text (t.localize "➕ Poddano matecznik (M)") ]
                                    , button [ class "mating-state-n", onClick (OpenUlikModal actualApiaryId ulik.id ModalPoddajMatkeNieunasiennioną), style "padding" "8px 14px", style "background" "#d4ac0d", style "color" "#422006", style "border" "2px solid #8a6d00", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "36px" ] [ text (t.localize "➕ Poddano matkę nieunasiennioną (N)") ]
                                    , button [ class "destructive-action", onClick (TransitionUlikState actualApiaryId ulik.id PustyUlik), attribute "data-testid" "delete-account" ] [ text (t.localize "🧹 Opróżnij ulik (P)") ]
                                    ]
                                ZMatecznikiem ->
                                    [ button [ onClick (TransitionUlikState actualApiaryId ulik.id MatkaWygryziona), style "padding" "8px 12px", style "margin" "4px", style "cursor" "pointer" ] [ text (t.localize "🦋 Matka się wygryzła (N)") ]
                                    , button [ class "destructive-action", onClick (TransitionUlikState actualApiaryId ulik.id Bezmatek) ] [ text (t.localize "❌ Matecznik się nie wygryzł (B)") ]
                                    , button [ class "destructive-action", onClick (TransitionUlikState actualApiaryId ulik.id PustyUlik), attribute "data-testid" "delete-account" ] [ text (t.localize "🧹 Opróżnij ulik (P)") ]
                                    ]
                                MatkaWygryziona ->
                                    [ button [ onClick (TransitionUlikState actualApiaryId ulik.id MatkaCzerwi) ] [ text (t.localize "👑 Matka się unasienniła (UNC)") ]
                                    , if not ulik.queen.hasOpalit then
                                        button [ class "mating-state-m", onClick (OpenUlikModal actualApiaryId ulik.id ModalZaopalitkuj), style "padding" "8px 14px", style "background" "#f7dc6f", style "color" "#422006", style "border" "2px solid #b88900", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "36px" ] [ text (t.localize "🏷️ Zaopalitkuj") ]
                                      else
                                        text (t.localize "")
                                    , button [ class "destructive-action", onClick (TransitionUlikState actualApiaryId ulik.id Bezmatek), attribute "data-testid" "delete-account" ] [ text (t.localize "⚠️ Matka strutowiała / zniknęła (B)") ]
                                    , button [ class "destructive-action", onClick (TransitionUlikState actualApiaryId ulik.id PustyUlik), attribute "data-testid" "delete-account" ] [ text (t.localize "🧹 Opróżnij ulik (P)") ]
                                    ]
                                MatkaCzerwi ->
                                    [ span [ style "color" "#27ae60", style "font-style" "italic", style "display" "block", style "margin-bottom" "10px" ] [ text (t.localize "Matka unasienniona / czerwi (pełny sukces uliku weselnego)") ]
                                    , if not ulik.queen.hasOpalit then
                                        button [ class "mating-state-m", onClick (OpenUlikModal actualApiaryId ulik.id ModalZaopalitkuj), style "padding" "8px 14px", style "background" "#f7dc6f", style "color" "#422006", style "border" "2px solid #b88900", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "36px" ] [ text (t.localize "🏷️ Zaopalitkuj") ]
                                      else
                                        text (t.localize "")
                                    , button [ class "mating-state-m", onClick (TransitionUlikState actualApiaryId ulik.id Bezmatek), style "padding" "8px 14px", style "background" "#f7dc6f", style "color" "#422006", style "border" "2px solid #b88900", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "36px" ] [ text (t.localize "zabieram matkę (B)") ]
                                    , button [ class "destructive-action", onClick (TransitionUlikState actualApiaryId ulik.id PustyUlik), attribute "data-testid" "delete-account" ] [ text (t.localize "🧹 Opróżnij ulik (P)") ]
                                    ]
                                PustyUlik ->
                                    [ button [ class "mating-state-b", onClick (TransitionUlikState actualApiaryId ulik.id Bezmatek), style "padding" "8px 14px", style "background" "#e74c3c", style "color" "white", style "border" "2px solid #a93226", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "36px" ] [ text (t.localize "➕ Przejdź do Bezmatek (B)") ]
                                    , button [ class "mating-state-n", onClick (OpenUlikModal actualApiaryId ulik.id ModalPoddajMatkeNieunasiennioną), style "padding" "8px 14px", style "background" "#d4ac0d", style "color" "#422006", style "border" "2px solid #8a6d00", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "36px" ] [ text (t.localize "➕ Poddano matkę nieunasiennioną (N)") ]
                                    ]
                            )
                        , label [] [ text (t.localize "Czy jest tam matka:") ]
                        , select [ onInput (\val -> UpdateUlikField actualApiaryId ulik.id "hasQueen" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ]
                            [ option [ value "true", selected ulik.hasQueen ] [ text (t.localize "Tak") ]
                            , option [ value "false", selected (not ulik.hasQueen) ] [ text (t.localize "Nie") ]
                            ]
                        , if ulik.hasQueen then
                            div []
                                [ label [] [ text (t.localize "Rasa i linia matki:") ]
                                , let
                                    allBreedLines =
                                        if List.member ulik.queen.breedLine model.breedLines || ulik.queen.breedLine == "" then
                                            model.breedLines
                                        else
                                            model.breedLines ++ [ ulik.queen.breedLine ]
                                  in
                                  select [ onInput (\val -> UpdateUlikField actualApiaryId ulik.id "queen.breedLine" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ]
                                    (List.map (\bl -> option [ value bl, selected (ulik.queen.breedLine == bl) ] [ text bl ]) allBreedLines)
                                , label [] [ text (t.localize "Obecność Opalitka:") ]
                                , select [ onInput (\val -> UpdateUlikField actualApiaryId ulik.id "queen.hasOpalit" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ]
                                    [ option [ value "true", selected ulik.queen.hasOpalit ] [ text (t.localize "Tak (Opalitka)") ]
                                    , option [ value "false", selected (not ulik.queen.hasOpalit) ] [ text (t.localize "Nie") ]
                                    ]
                                , if ulik.queen.hasOpalit then
                                    div []
                                        [ label [] [ text (t.localize "Kolor Opalitka:") ]
                                        , select [ onInput (\val -> UpdateUlikField actualApiaryId ulik.id "queen.color" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ]
                                            [ option [ value "Biały", selected (ulik.queen.color == "Biały") ] [ text (t.localize "Biały") ]
                                            , option [ value "Żółty", selected (ulik.queen.color == "Żółty") ] [ text (t.localize "Żółty") ]
                                            , option [ value "Czerwony", selected (ulik.queen.color == "Czerwony") ] [ text (t.localize "Czerwony") ]
                                            , option [ value "Zielony", selected (ulik.queen.color == "Zielony") ] [ text (t.localize "Zielony") ]
                                            , option [ value "Niebieski", selected (ulik.queen.color == "Niebieski") ] [ text (t.localize "Niebieski") ]
                                            ]
                                        , label [] [ text (t.localize "Numer Opalitka:") ]
                                        , input [ type_ "text", value ulik.queen.number, onInput (\val -> UpdateUlikField actualApiaryId ulik.id "queen.number" val), style "width" "100%", style "padding" "10px", style "font-size" "16px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "box-sizing" "border-box" ] []
                                        ]
                                  else
                                    text (t.localize "")
                                ]
                          else
                            text (t.localize "")
                        ]
                    ]
                , div [ style "margin-top" "20px", style "border-top" ("1px solid " ++ (if model.darkMode then "#333" else "#eee")), style "padding-top" "15px" ]
                    [ h3 [ style "color" headingColor, style "margin-bottom" "10px" ] [ text (t.localize "Historia zmian uliku") ]
                    , if List.isEmpty ulik.history then
                        div [ style "font-size" "13px", style "color" (if model.darkMode then "#888" else "#777"), style "font-style" "italic" ]
                            [ text (t.localize "Brak wpisów w historii") ]
                      else
                        div [ style "display" "flex", style "flex-direction" "column", style "gap" "10px" ]
                            (List.map (historyEntryView t model) ulik.history)
                    ]
                ]
        _ ->
            div [] [ text (if t.matingHives == "Mating hives" then "Loading mating hive..." else "Ładowanie uliku...") ]

historyEntryView : Translations -> Model -> UlikHistoryEntry -> Html Msg
historyEntryView t model entry =
    let
        cardBg = if model.darkMode then "#1f3326" else "#ecfccb"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        mutedColor = if model.darkMode then "#95a5a6" else "#7f8c8d"
        prevLabel = ulikStateShortLabel entry.prevState
        newLabel = ulikStateShortLabel entry.state
        matkaText =
            if entry.breedLine /= "" || entry.hasOpalit then
                "Matka: " ++ (if entry.hasOpalit then "Opalit " ++ entry.color ++ " #" ++ entry.number else "") ++ (if entry.breedLine /= "" then (if entry.hasOpalit then " (" ++ entry.breedLine ++ ")" else entry.breedLine) else "")
            else
                ""
    in
    div [ style "background" cardBg, style "padding" "10px 12px", style "border-radius" "6px", style "border-left" "4px solid #3498db", style "color" textColor, style "font-size" "13px" ]
        [ div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-bottom" "4px" ]
            [ span [ style "font-weight" "bold" ] [ text (t.localize prevLabel ++ " - " ++ entry.description ++ " -> " ++ t.localize newLabel) ]
            , span [ style "font-size" "11px", style "color" mutedColor ] [ text entry.timestamp ]
            ]
        , if matkaText /= "" then
            div [ style "font-size" "12px", style "color" mutedColor ] [ text matkaText ]
          else
            text (t.localize "")
        ]
