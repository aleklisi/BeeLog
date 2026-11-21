module Views.ApiaryList exposing (apiariesView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Types.Core exposing (..)
import Types.Decoders exposing (..)
import Types.Helpers exposing (..)
import Views.Trutowisko exposing (attentionSummaryText, attentionUlikNames)
import I18n exposing (Translations)

apiariesView : Translations -> Model -> Html Msg
apiariesView t model =
    let
        filteredApiaries =
            List.filter
                (\a ->
                    if not model.enablePasieczyskaTowarowe && a.apiaryType == "towarowe" then
                        False
                    else if not model.enableTrutowiska && a.apiaryType == "trutowisko" then
                        False
                    else if model.apiaryFilter == "towarowe" && model.enablePasieczyskaTowarowe then
                        a.apiaryType == "towarowe"
                    else if model.apiaryFilter == "trutowisko" && model.enableTrutowiska then
                        a.apiaryType == "trutowisko"
                    else
                        True
                )
                model.apiaries
    in
    div []
        [ div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-bottom" "15px" ]
            [ h2 [ style "margin" "0", style "color" (if model.darkMode then "#ffffff" else "inherit") ] [ text (if model.apiaryFilter == "trutowisko" then t.matingApiariesHeading else if model.apiaryFilter == "towarowe" then t.commercialApiariesHeading else t.apiaries) ]
            , button [ onClick OpenNewApiaryModal ] [ text t.addApiary ]
            ]
        , if List.isEmpty filteredApiaries then
            p [ attribute "data-testid" "apiary-empty-state" ] [ text (if model.apiaryFilter == "trutowisko" then t.noMatingApiaries else if model.apiaryFilter == "towarowe" then t.noCommercialApiaries else t.noApiaries) ]
          else text ""
        , div [ style "display" "flex", style "flex-direction" "column", style "gap" "15px" ]
            (List.map (apiaryCardView t model) filteredApiaries)
        ]

apiaryCardView : Translations -> Model -> Apiary -> Html Msg
apiaryCardView t model apiary =
    let
        cardBg = if model.darkMode then "#17231b" else "#f0fdf4"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        isTrutowisko = apiary.apiaryType == "trutowisko"
        typeLabel = if isTrutowisko then t.matingApiaries else t.commercialApiaries
        typeBadgeBg = if isTrutowisko then "#8e44ad" else "#2980b9"
        navTarget = if isTrutowisko then
                        UlikListView { apiaryId = apiary.id, apiaryName = apiary.name }
                    else
                        HiveListView { apiaryId = apiary.id, apiaryName = apiary.name }

        attentionNames =
            if isTrutowisko then
                attentionUlikNames model.currentDate apiary.uliki

            else
                []

        bezmatekCount = List.length (List.filter (\u -> getUlikState u == Bezmatek) apiary.uliki)
        matecznikCount = List.length (List.filter (\u -> getUlikState u == ZMatecznikiem) apiary.uliki)
        pustyUlikCount = List.length (List.filter (\u -> getUlikState u == PustyUlik) apiary.uliki)
        nieunasiennionaCount = List.length (List.filter (\u -> getUlikState u == MatkaWygryziona) apiary.uliki)
        unasiennionaCount = List.length (List.filter (\u -> getUlikState u == MatkaCzerwi) apiary.uliki)
        totalUlikiCount = List.length apiary.uliki

        totalHivesCount = List.length apiary.hives
        frameTypeCounts =
            List.map
                (\ft ->
                    ( ft, List.length (List.filter (\h -> h.frameType == ft) apiary.hives) )
                )
                model.frameTypes
            |> List.filter (\(ft, count) -> count > 0)

        otherFrameTypes =
            apiary.hives
            |> List.map .frameType
            |> List.filter (\ft -> not (List.member ft model.frameTypes))
            |> List.foldl (\ft acc -> if List.member ft acc then acc else acc ++ [ft]) []

        extraCounts =
            List.map
                (\ft ->
                    ( ft, List.length (List.filter (\h -> h.frameType == ft) apiary.hives) )
                )
                otherFrameTypes

        allHivesTypeCounts = frameTypeCounts ++ extraCounts
    in
    div [ style "background" cardBg, style "padding" "15px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "cursor" "grab", style "color" textColor
        , draggable "true"
        , on "dragstart" (Decode.succeed (StartOrderDrag Apiaries "" apiary.id))
        , preventDefaultOn "dragover" (Decode.succeed ( OrderDragOver Apiaries "" apiary.id, True ))
        , on "dragend" (Decode.succeed EndOrderDrag)
        , attribute "data-testid" "apiary-card"
        , attribute "data-apiary-id" apiary.id
        , attribute "data-order-collection" "apiaries"
        , attribute "data-order-apiary-id" ""
        , attribute "data-order-id" apiary.id
        ]
        [ div [ onClick (NavigateCard navTarget), on "mousedown" (Decode.succeed ResetCardClickSuppression) ]
            [ div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-bottom" "8px" ]
                [ div [ style "display" "flex", style "align-items" "center", style "gap" "8px" ]
                    ([ h3 [ style "margin" "0", style "color" headingColor ] [ text apiary.name ] ]
                        ++ (if not (List.isEmpty attentionNames) then
                                let
                                    alertText =
                                        attentionSummaryText t attentionNames
                                in
                                [ button
                                    [ type_ "button"
                                    , title alertText
                                    , attribute "aria-label" alertText
                                    , attribute "data-testid" "apiary-attention-alert"
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

                            else
                                []
                           )
                    )
                , div [ style "display" "flex", style "align-items" "center", style "gap" "8px" ]
                    [ span [ style "background" typeBadgeBg, style "color" "white", style "padding" "2px 8px", style "border-radius" "12px", style "font-size" "11px" ] [ text typeLabel ]
                    , div [ style "display" "flex", style "align-items" "center", style "gap" "8px", stopPropagationOn "click" (Decode.succeed ( NoOp, True )) ]
                        [ button [ onClick (OpenEditApiaryModal apiary), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title t.edit ] [ text "✏️" ]
                        , button [ onClick (OpenDeleteApiaryModal apiary), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title t.delete ] [ text "🗑️" ]
                        ]
                    ]
                ]
            , if isTrutowisko then
                div [ style "margin-top" "8px", style "font-size" "12px", style "background" (if model.darkMode then "#1f3326" else "#ecfccb"), style "padding" "8px", style "border-radius" "6px", style "color" textColor ]
                    [ div [ style "font-weight" "bold", style "margin-bottom" "4px" ] [ text (t.matingHivesTotal ++ String.fromInt totalUlikiCount ++ ")") ]
                    , div [ style "display" "flex", style "flex-wrap" "wrap", style "gap" "10px" ]
                        [ span [ title t.stateQueenless ] [ text ("(B) Bezmatek: " ++ String.fromInt bezmatekCount) ]
                        , span [ title t.stateCell ] [ text ("(M) Matecznik: " ++ String.fromInt matecznikCount) ]
                        , span [ title t.stateEmptyMatingHive ] [ text ("(P) Pusty: " ++ String.fromInt pustyUlikCount) ]
                        , span [ title t.stateUnmated ] [ text ("(N) Nieunasienniona: " ++ String.fromInt nieunasiennionaCount) ]
                        , span [ title t.stateMated ] [ text ("(UNC) Unasienniona: " ++ String.fromInt unasiennionaCount) ]
                        ]
                    ]
              else
                div [ style "margin-top" "8px", style "font-size" "12px", style "background" (if model.darkMode then "#1f3326" else "#ecfccb"), style "padding" "8px", style "border-radius" "6px", style "color" textColor ]
                    [ div [ style "font-weight" "bold", style "margin-bottom" "4px" ] [ text (t.commercialHivesTotal ++ String.fromInt totalHivesCount ++ ")") ]
                    , if List.isEmpty allHivesTypeCounts then
                        div [ style "color" (if model.darkMode then "#888" else "#777"), style "font-style" "italic" ] [ text t.noHivesShort ]
                      else
                        div [ style "display" "flex", style "flex-wrap" "wrap", style "gap" "10px" ]
                            (List.map
                                (\(ft, count) ->
                                    span [ title ft ] [ text (ft ++ ": " ++ String.fromInt count) ]
                                )
                                allHivesTypeCounts
                            )
                    ]
            ]
        ]
