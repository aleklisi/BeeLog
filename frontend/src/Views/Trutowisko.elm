module Views.Trutowisko exposing (attentionReason, attentionReasons, attentionSummaryText, attentionUlikNames, ulikAttentionReasons, ulikListView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Types.Core exposing (..)
import Types.Decoders exposing (..)
import Types.Helpers exposing (..)
import Views.UlikDetail exposing (ulikDetailView)
import I18n exposing (Translations)


attentionReasons : String -> String -> String -> String -> List String
attentionReasons state expectedHatchDate expectedMatingDate currentDate =
    let
        bezmatekReason =
            if state == "bezmatek" then
                [ "Brak matki w ulu" ]
            else
                []

        emergenceReason =
            if state == "z_matecznikiem" && isDueOrBeforeToday expectedHatchDate currentDate then
                [ "Sprawdź, czy matka się wygryzła" ]
            else
                []

        matingReason =
            if state == "matka_wygryziona" && isDueOrBeforeToday expectedMatingDate currentDate then
                [ "Minął oczekiwany termin unasiennienia matki" ]
            else
                []

        overdueInseminationReason =
            if (state == "z_matecznikiem" || state == "matka_wygryziona") then
                case ( validDateDays expectedHatchDate, validDateDays currentDate ) of
                    ( Just hatchDays, Just todayDays ) ->
                        if hatchDays + 30 < todayDays then
                            [ "Minął deadline 30 dni od wygryzienia – matka nadal nieunasienniona" ]
                        else
                            []

                    _ ->
                        []
            else
                []
    in
    bezmatekReason ++ emergenceReason ++ matingReason ++ overdueInseminationReason


attentionReason : String -> String -> String -> String -> Maybe String
attentionReason state expectedHatchDate expectedMatingDate currentDate =
    List.head (attentionReasons state expectedHatchDate expectedMatingDate currentDate)


ulikAttentionReasons : String -> UlikWeselny -> List String
ulikAttentionReasons currentDate ulik =
    attentionReasons ulik.state ulik.expectedHatchDate ulik.expectedMatingDate currentDate


attentionUlikNames : String -> List UlikWeselny -> List String
attentionUlikNames currentDate uliki =
    uliki
        |> List.filter (\u -> not (List.isEmpty (ulikAttentionReasons currentDate u)))
        |> List.map .name


attentionSummaryText : Translations -> List String -> String
attentionSummaryText t names =
    t.localize "Uliki wymagające akcji: " ++ String.join ", " names


isDueOrBeforeToday : String -> String -> Bool
isDueOrBeforeToday expectedDate currentDate =
    case ( validDateDays expectedDate, validDateDays currentDate ) of
        ( Just expectedDays, Just todayDays ) ->
            expectedDays <= todayDays

        _ ->
            False


validDateDays : String -> Maybe Int
validDateDays dateString =
    parseDate dateString
        |> Maybe.andThen
            (\( year, month, day ) ->
                if year > 0 && month >= 1 && month <= 12 && day >= 1 && day <= Maybe.withDefault 0 (List.drop (month - 1) (daysInMonthList year) |> List.head) then
                    Just (dateToDays year month day)
                else
                    Nothing
            )

ulikListView : Translations -> User -> { apiaryId : String, apiaryName : String } -> Model -> Html Msg
ulikListView t user info model =
    let
        cardBg = if model.darkMode then "#17231b" else "#f0fdf4"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        borderColor = if model.darkMode then "#333" else "#eee"
        metaBg = if model.darkMode then "#2d2d2d" else "#f1f2f6"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"

        stateFilteredUliki =
            List.filter
                (\u ->
                    if model.ulikFilter == "all" then
                        True
                    else
                        u.state == model.ulikFilter
                )
                model.uliki

        filteredUliki =
            if model.ulikActionRequiredOnly then
                List.filter (\u -> not (List.isEmpty (ulikAttentionReasons model.currentDate u))) stateFilteredUliki
            else
                stateFilteredUliki
    in
    div []
        [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px", style "flex-wrap" "wrap" ]
            [ button [ class "secondary-action", onClick (NavigateTo ApiariesView), style "padding" "10px 16px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "40px" ] [ text t.back ]
            , h2 [ style "margin" "0", style "color" headingColor ] [ text (t.localize "Trutowisko: " ++ info.apiaryName) ]
            ]
        , div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-bottom" "20px", style "flex-wrap" "wrap", style "gap" "12px" ]
            [ div [ style "display" "flex", style "gap" "10px" ]
                [ button [ onClick OpenNewUlikModal ] [ text t.addMatingHive ]
                ]
            , div [ style "display" "flex", style "align-items" "center", style "gap" "16px", style "flex-wrap" "wrap" ]
                [ label [ for "filter-action-required", style "display" "flex", style "align-items" "center", style "gap" "8px", style "cursor" "pointer", style "color" textColor, style "font-size" "14px", style "user-select" "none" ]
                    [ input
                        [ type_ "checkbox"
                        , id "filter-action-required"
                        , checked model.ulikActionRequiredOnly
                        , onCheck (\_ -> ToggleUlikActionRequiredOnly)
                        , style "cursor" "pointer"
                        , style "width" "18px"
                        , style "height" "18px"
                        ]
                        []
                    , text (t.localize "Tylko wymagające akcji")
                    ]
                , div [ style "display" "flex", style "align-items" "center", style "gap" "8px" ]
                    [ span [ style "color" textColor, style "font-size" "14px" ] [ text t.filterState ]
                    , select [ onInput SetUlikFilter, style "padding" "8px 12px", style "font-size" "15px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ]
                        [ option [ value "all", selected (model.ulikFilter == "all") ] [ text t.allStates ]
                        , option [ value "bezmatek", selected (model.ulikFilter == "bezmatek") ] [ text (t.localize "(B) Bezmatek") ]
                        , option [ value "z_matecznikiem", selected (model.ulikFilter == "z_matecznikiem") ] [ text (t.localize "(M) Matecznik") ]
                        , option [ value "matka_wygryziona", selected (model.ulikFilter == "matka_wygryziona") ] [ text (t.localize "(N) Matka nieunasienniona") ]
                        , option [ value "matka_czerwi", selected (model.ulikFilter == "matka_czerwi") ] [ text (t.localize "(UNC) Matka unasienniona") ]
                        , option [ value "pusty_ulik", selected (model.ulikFilter == "pusty_ulik") ] [ text (t.localize "(P) Pusty ulik") ]
                        ]
                    ]
                ]
            ]
        , if List.isEmpty filteredUliki then
            div [ style "padding" "32px 16px", style "text-align" "center", style "background" cardBg, style "border-radius" "8px", style "border" ("1px dashed " ++ borderColor), style "color" (if model.darkMode then "#aaa" else "#666") ]
                [ p [ style "margin" "0", style "font-size" "15px" ]
                    [ text
                        (if model.ulikActionRequiredOnly then
                            t.localize "Brak ulików wymagających akcji."
                         else if model.ulikFilter /= "all" then
                            t.localize "Brak ulików o wybranym stanie."
                         else
                            t.localize "Brak ulików w tym trutowisku."
                        )
                    ]
                ]
          else
            div [ style "display" "flex", style "flex-direction" "column", style "gap" "15px" ]
                (List.map (ulikCardView t info.apiaryId model) filteredUliki)
        ]

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
                    [ div [ style "display" "flex", style "align-items" "center", style "gap" "6px", style "font-weight" "bold", style "margin-bottom" "3px", style "color" (if model.darkMode then "#ccc" else "#555") ]
                        [ text (t.localize "Oś czasu cyklu matki:")
                        , node "details"
                            [ style "position" "relative", style "font-weight" "normal" ]
                            [ node "summary"
                                [ title (t.localize "Wyjaśnij kolory osi czasu")
                                , attribute "aria-label" (t.localize "Wyjaśnienie kolorów osi czasu cyklu matki")
                                , stopPropagationOn "click" (Decode.succeed ( NoOp, True ))
                                , style "display" "inline-flex"
                                , style "align-items" "center"
                                , style "justify-content" "center"
                                , style "width" "18px"
                                , style "height" "18px"
                                , style "border" "1px solid #888"
                                , style "border-radius" "50%"
                                , style "cursor" "pointer"
                                , style "font-size" "11px"
                                , style "list-style" "none"
                                ]
                                [ text (t.localize "i") ]
                            , div
                                [ style "position" "absolute"
                                , style "z-index" "3"
                                , style "top" "22px"
                                , style "left" "0"
                                , style "width" "min(320px, 80vw)"
                                , style "padding" "10px"
                                , style "background" (if model.darkMode then "#2d2d2d" else "white")
                                , style "color" (if model.darkMode then "#e0e0e0" else "#333")
                                , style "border" (if model.darkMode then "1px solid #555" else "1px solid #ccc")
                                , style "border-radius" "5px"
                                , style "box-shadow" "0 2px 8px rgba(0,0,0,0.2)"
                                ]
                                [ timelineLegendRow t "#f7dc6f" "Do spodziewanego wygryzienia: matka powinna się wygryźć."
                                , timelineLegendRow t "#d4ac0d" "Od wygryzienia do terminu unasiennienia: młoda matka dojrzewa i powinna odbyć loty godowe."
                                , timelineLegendRow t "#27ae60" "Po spodziewanym terminie unasiennienia: matka powinna być już unasienniona."
                                , timelineLegendRow t "#e74c3c" "Po 30 dniach od wygryzienia: matka zbyt długo się nie unasienniła; sprawdź jej stan."
                                , timelineLegendRow t "#3498db" "Niebieska kreska pokazuje dzisiejszą datę."
                                ]
                            ]
                        ]
                    , div [ style "position" "relative", style "height" "14px", style "background" (if model.darkMode then "#333" else "#e0e0e0"), style "border-radius" "7px", style "overflow" "hidden", style "margin-bottom" "5px" ]
                        [ div [ style "position" "absolute", style "top" "0", style "left" "0", style "width" (String.fromFloat hPct ++ "%"), style "height" "100%", style "background" "#f7dc6f", title (t.localize "Do wygryzienia (jasno żółty)") ] []
                        , div [ style "position" "absolute", style "top" "0", style "left" (String.fromFloat hPct ++ "%"), style "width" (String.fromFloat (Basics.max 0 (mPct - hPct)) ++ "%"), style "height" "100%", style "background" "#d4ac0d", title (t.localize "Wygryzienie do unasiennienia (ciemno żółty)") ] []
                        , div [ style "position" "absolute", style "top" "0", style "left" (String.fromFloat mPct ++ "%"), style "width" (String.fromFloat (Basics.max 0 (d30Pct - mPct)) ++ "%"), style "height" "100%", style "background" "#27ae60", title (t.localize "Okres po unasiennieniu") ] []
                        , div [ style "position" "absolute", style "top" "0", style "left" (String.fromFloat d30Pct ++ "%"), style "width" (String.fromFloat (Basics.max 0 (100 - d30Pct)) ++ "%"), style "height" "100%", style "background" "#e74c3c", title (t.localize "Po 30 dniach od wygryzienia (czerwony - deadline)") ] []
                        , div [ style "position" "absolute", style "top" "0", style "left" (String.fromFloat nowPct ++ "%"), style "width" "3px", style "height" "100%", style "background" "#3498db", style "z-index" "2", title (t.localize "Teraz: " ++ model.currentDate) ] []
                        ]
                    , div [ style "display" "flex", style "justify-content" "space-between", style "font-size" "10px", style "color" (if model.darkMode then "#aaa" else "#666") ]
                        [ span [] [ text (t.localize "Teraz: " ++ (if model.currentDate == "" then "-" else model.currentDate)) ]
                        , span [] [ text (t.localize "Wygryz.: " ++ ulik.expectedHatchDate) ]
                        , span [] [ text (t.localize "Unasien.: " ++ (if ulik.expectedMatingDate == "" then "-" else ulik.expectedMatingDate)) ]
                        , span [] [ text (t.localize "+30 dni: " ++ addDaysToDateString 30 ulik.expectedHatchDate) ]
                        ]
                    ]
            _ ->
                text (t.localize "")


timelineLegendRow : Translations -> String -> String -> Html Msg
timelineLegendRow t color description =
    div [ style "display" "flex", style "align-items" "flex-start", style "gap" "7px", style "margin-bottom" "6px" ]
        [ span [ style "flex" "0 0 12px", style "height" "12px", style "margin-top" "2px", style "border-radius" "3px", style "background" color, attribute "aria-hidden" "true" ] []
        , span [] [ text (t.localize description) ]
        ]

ulikCardView : Translations -> String -> Model -> UlikWeselny -> Html Msg
ulikCardView t apiaryId model ulik =
    let
        cardBg = if model.darkMode then "#17231b" else "#f0fdf4"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        borderColor = if model.darkMode then "#333" else "#eee"
        metaBg = if model.darkMode then "#2d2d2d" else "#f1f2f6"
    in
    div [ style "background" cardBg, style "padding" "16px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "cursor" "grab", style "color" textColor
        , draggable "true"
        , on "dragstart" (Decode.succeed (StartOrderDrag MatingHives apiaryId ulik.id))
        , preventDefaultOn "dragover" (Decode.succeed ( OrderDragOver MatingHives apiaryId ulik.id, True ))
        , on "dragend" (Decode.succeed EndOrderDrag)
        , attribute "data-testid" "mating-hive-card"
        , attribute "data-ulik-id" ulik.id
        , attribute "data-order-collection" "mating-hives"
        , attribute "data-order-apiary-id" apiaryId
        , attribute "data-order-id" ulik.id
        , onClick (NavigateCard (UlikDetailView { apiaryId = apiaryId, ulikId = ulik.id, ulikName = ulik.name }))
        , on "mousedown" (Decode.succeed ResetCardClickSuppression)
        ]
        [ div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "gap" "8px" ]
            ([ h3 [ style "margin" "0", style "color" headingColor ] [ text ulik.name ] ]
                ++ (let
                        reasons = ulikAttentionReasons model.currentDate ulik
                        combinedReason = String.join " / " (List.map t.localize reasons)
                    in
                    if List.isEmpty reasons then
                        []
                    else
                        [ button
                            [ type_ "button"
                            , title combinedReason
                            , attribute "aria-label" combinedReason
                            , stopPropagationOn "click" (Decode.succeed ( NoOp, True ))
                            , style "color" "#e74c3c"
                            , style "background" "transparent"
                            , style "border" "none"
                            , style "font-size" "22px"
                            , style "font-weight" "bold"
                            , style "cursor" "help"
                            , style "padding" "4px 8px"
                            ]
                            [ text (t.localize "!") ]
                        ]
                   )
            )
        , p [ style "margin" "5px 0", style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#555") ] [ text (t.localize "Typ ula: " ++ t.localize ulik.hiveType) ]
        , p [ style "margin" "5px 0", style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#555") ] [ text (t.localize "Stan: " ++ t.localize (ulikStateLabel (getUlikState ulik))) ]
        , div [ style "margin-top" "10px", style "font-size" "12px", style "background" metaBg, style "padding" "6px", style "border-radius" "4px", style "color" textColor ]
            [ text (t.localize "Matka: " ++ (if ulik.hasQueen then (if ulik.queen.hasOpalit then t.localize "Opalit " ++ t.localize ulik.queen.color ++ " #" ++ ulik.queen.number else t.localize "Bez opalitka") ++ (if ulik.queen.breedLine /= "" then " (" ++ ulik.queen.breedLine ++ ")" else "") else t.localize "Brak matki")) ]
        , ulikTimelineView t model ulik
        , div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-top" "12px", style "border-top" ("1px solid " ++ borderColor), style "padding-top" "10px", style "flex-wrap" "wrap" ]
            [ div [ style "display" "flex", style "gap" "12px" ]
                [ button [ attribute "data-testid" "MoveMatingHive", stopPropagationOn "click" (Decode.succeed (OpenMoveUlikModal apiaryId ulik, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "18px", style "padding" "6px", title t.moveMatingHive ] [ text (t.localize "🚚") ]
                , button [ stopPropagationOn "click" (Decode.succeed (OpenRenameUlikModal apiaryId ulik, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "18px", style "padding" "6px", title t.edit ] [ text (t.localize "✏️") ]
                , button [ stopPropagationOn "click" (Decode.succeed (OpenDeleteUlikModal apiaryId ulik, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "18px", style "padding" "6px", title t.delete ] [ text (t.localize "🗑️") ]
                ]
            ]
        ]
