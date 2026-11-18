module Views.Trutowisko exposing (ulikListView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Types.Core exposing (..)
import Types.Decoders exposing (..)
import Types.Helpers exposing (..)
import Views.UlikDetail exposing (ulikDetailView)

ulikListView : User -> { apiaryId : String, apiaryName : String } -> Model -> Html Msg
ulikListView user info model =
    let
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        borderColor = if model.darkMode then "#333" else "#eee"
        metaBg = if model.darkMode then "#2d2d2d" else "#f1f2f6"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"

        filteredUliki =
            List.filter
                (\u ->
                    if model.ulikFilter == "all" then
                        True
                    else
                        u.state == model.ulikFilter
                )
                model.uliki
    in
    div []
        [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px", style "flex-wrap" "wrap" ]
            [ button [ onClick (NavigateTo ApiariesView), style "padding" "10px 16px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "40px" ] [ text "← Powrót" ]
            , h2 [ style "margin" "0", style "color" headingColor ] [ text ("Trutowisko: " ++ info.apiaryName) ]
            ]
        , div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-bottom" "20px", style "flex-wrap" "wrap", style "gap" "12px" ]
            [ div [ style "display" "flex", style "gap" "10px" ]
                [ button [ onClick OpenNewUlikModal, style "padding" "12px 18px", style "background-color" "#8e44ad", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "44px", style "font-size" "15px" ] [ text "+ Dodaj Ulik Weselny" ]
                ]
            , div [ style "display" "flex", style "align-items" "center", style "gap" "8px" ]
                [ span [ style "color" textColor, style "font-size" "14px" ] [ text "Filtruj stan:" ]
                , select [ onInput SetUlikFilter, style "padding" "8px 12px", style "font-size" "15px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ]
                    [ option [ value "all", selected (model.ulikFilter == "all") ] [ text "Wszystkie stany" ]
                    , option [ value "bezmatek", selected (model.ulikFilter == "bezmatek") ] [ text "(B) Bezmatek" ]
                    , option [ value "z_matecznikiem", selected (model.ulikFilter == "z_matecznikiem") ] [ text "(M) Matecznik" ]
                    , option [ value "matka_wygryziona", selected (model.ulikFilter == "matka_wygryziona") ] [ text "(N) Matka nieunasienniona" ]
                    , option [ value "matka_czerwi", selected (model.ulikFilter == "matka_czerwi") ] [ text "(UNC) Matka unasienniona" ]
                    , option [ value "pusty_ulik", selected (model.ulikFilter == "pusty_ulik") ] [ text "(P) Pusty ulik" ]
                    ]
                ]
            ]
        , div [ style "display" "flex", style "flex-direction" "column", style "gap" "15px" ]
            (List.map (ulikCardView info.apiaryId model) filteredUliki)
        ]

ulikTimelineView : Model -> UlikWeselny -> Html Msg
ulikTimelineView model ulik =
    if ulik.expectedHatchDate == "" then
        div [ style "font-size" "12px", style "color" (if model.darkMode then "#888" else "#777"), style "font-style" "italic", style "margin-top" "5px" ]
            [ text "Oś czasu: brak daty wygryzienia" ]
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
                        [ text "Oś czasu cyklu matki:" ]
                    , div [ style "position" "relative", style "height" "14px", style "background" (if model.darkMode then "#333" else "#e0e0e0"), style "border-radius" "7px", style "overflow" "hidden", style "margin-bottom" "5px" ]
                        [ div [ style "position" "absolute", style "top" "0", style "left" "0", style "width" (String.fromFloat hPct ++ "%"), style "height" "100%", style "background" "#f7dc6f", title "Do wygryzienia (jasno żółty)" ] []
                        , div [ style "position" "absolute", style "top" "0", style "left" (String.fromFloat hPct ++ "%"), style "width" (String.fromFloat (Basics.max 0 (mPct - hPct)) ++ "%"), style "height" "100%", style "background" "#d4ac0d", title "Wygryzienie do unasiennienia (ciemno żółty)" ] []
                        , div [ style "position" "absolute", style "top" "0", style "left" (String.fromFloat mPct ++ "%"), style "width" (String.fromFloat (Basics.max 0 (d30Pct - mPct)) ++ "%"), style "height" "100%", style "background" "#27ae60", title "Okres po unasiennieniu" ] []
                        , div [ style "position" "absolute", style "top" "0", style "left" (String.fromFloat d30Pct ++ "%"), style "width" (String.fromFloat (Basics.max 0 (100 - d30Pct)) ++ "%"), style "height" "100%", style "background" "#e74c3c", title "Po 30 dniach od wygryzienia (czerwony - deadline)" ] []
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
                text ""

ulikCardView : String -> Model -> UlikWeselny -> Html Msg
ulikCardView apiaryId model ulik =
    let
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        borderColor = if model.darkMode then "#333" else "#eee"
        metaBg = if model.darkMode then "#2d2d2d" else "#f1f2f6"
    in
    div [ style "background" cardBg, style "padding" "16px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "cursor" "pointer", style "color" textColor
        , onClick (NavigateTo (UlikDetailView { apiaryId = apiaryId, ulikId = ulik.id, ulikName = ulik.name }))
        ]
        [ h3 [ style "margin-top" "0", style "color" headingColor ] [ text ulik.name ]
        , p [ style "margin" "5px 0", style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#555") ] [ text ("Typ ula: " ++ ulik.hiveType) ]
        , p [ style "margin" "5px 0", style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#555") ] [ text ("Stan: " ++ ulikStateLabel (getUlikState ulik)) ]
        , div [ style "margin-top" "10px", style "font-size" "12px", style "background" metaBg, style "padding" "6px", style "border-radius" "4px", style "color" textColor ]
            [ text ("Matka: " ++ (if ulik.hasQueen then (if ulik.queen.hasOpalit then "Opalit " ++ ulik.queen.color ++ " #" ++ ulik.queen.number else "Bez opalitka") ++ (if ulik.queen.breedLine /= "" then " (" ++ ulik.queen.breedLine ++ ")" else "") else "Brak matki")) ]
        , ulikTimelineView model ulik
        , div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-top" "12px", style "border-top" ("1px solid " ++ borderColor), style "padding-top" "10px", style "flex-wrap" "wrap" ]
            [ div [ style "display" "flex", style "gap" "8px" ]
                [ button [ stopPropagationOn "click" (Decode.succeed (MoveUlikUp ulik.id, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "18px", style "padding" "6px", title "Przesuń w górę" ] [ text "⬆️" ]
                , button [ stopPropagationOn "click" (Decode.succeed (MoveUlikDown ulik.id, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "18px", style "padding" "6px", title "Przesuń w dół" ] [ text "⬇️" ]
                ]
            , div [ style "display" "flex", style "gap" "12px" ]
                [ button [ stopPropagationOn "click" (Decode.succeed (OpenMoveUlikModal apiaryId ulik, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "18px", style "padding" "6px", title "Zmień pasieczysko" ] [ text "🚚" ]
                , button [ stopPropagationOn "click" (Decode.succeed (OpenRenameUlikModal apiaryId ulik, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "18px", style "padding" "6px", title "Zmień nazwę uliku" ] [ text "✏️" ]
                , button [ stopPropagationOn "click" (Decode.succeed (OpenDeleteUlikModal apiaryId ulik, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "18px", style "padding" "6px", title "Usuń ulik" ] [ text "🗑️" ]
                ]
            ]
        ]
