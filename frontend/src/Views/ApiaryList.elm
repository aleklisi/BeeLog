module Views.ApiaryList exposing (apiariesView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Types.Core exposing (..)
import Types.Decoders exposing (..)
import Types.Helpers exposing (..)
import I18n exposing (Translations)

apiariesView : Translations -> User -> Model -> Html Msg
apiariesView t user model =
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
            , button [ onClick OpenNewApiaryModal, style "padding" "10px 16px", style "background-color" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text t.addApiary ]
            ]
        , if List.isEmpty filteredApiaries then
            p [ attribute "data-testid" "apiary-empty-state" ] [ text (if model.apiaryFilter == "trutowisko" then t.noMatingApiaries else if model.apiaryFilter == "towarowe" then t.noCommercialApiaries else t.noApiaries) ]
          else text ""
        , div [ style "display" "flex", style "flex-direction" "column", style "gap" "15px" ]
            (List.map (apiaryCardView t user model) filteredApiaries)
        ]

apiaryCardView : Translations -> User -> Model -> Apiary -> Html Msg
apiaryCardView t user model apiary =
    let
        isAdmin = apiary.adminId == user.uid
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        borderColor = if model.darkMode then "#333" else "#eee"
        isTrutowisko = apiary.apiaryType == "trutowisko"
        typeLabel = if isTrutowisko then t.matingApiaries else t.commercialApiaries
        typeBadgeBg = if isTrutowisko then "#8e44ad" else "#2980b9"
        navTarget = if isTrutowisko then
                        UlikListView { apiaryId = apiary.id, apiaryName = apiary.name }
                    else
                        HiveListView { apiaryId = apiary.id, apiaryName = apiary.name }

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
    div [ style "background" cardBg, style "padding" "15px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "cursor" "pointer", style "color" textColor ]
        [ div [ onClick (NavigateTo navTarget) ]
            [ div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-bottom" "8px" ]
                [ h3 [ style "margin" "0", style "color" headingColor ] [ text apiary.name ]
                , span [ style "background" typeBadgeBg, style "color" "white", style "padding" "2px 8px", style "border-radius" "12px", style "font-size" "11px" ] [ text typeLabel ]
                ]
            , p [ style "font-size" "12px", style "color" (if model.darkMode then "#95a5a6" else "#7f8c8d"), style "margin" "0 0 8px 0" ] [ text (if isAdmin then t.owner else t.shared) ]
            , if isTrutowisko then
                div [ style "margin-top" "8px", style "font-size" "12px", style "background" (if model.darkMode then "#2d2d2d" else "#f8f9fa"), style "padding" "8px", style "border-radius" "6px", style "color" textColor ]
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
                div [ style "margin-top" "8px", style "font-size" "12px", style "background" (if model.darkMode then "#2d2d2d" else "#f8f9fa"), style "padding" "8px", style "border-radius" "6px", style "color" textColor ]
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
        , div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-top" "10px", style "border-top" ("1px solid " ++ borderColor), style "padding-top" "8px" ]
            [ div [ style "display" "flex", style "gap" "4px" ]
                [ button [ stopPropagationOn "click" (Decode.succeed (MoveApiaryUp apiary.id, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title t.moveLeft ] [ text "⬅️" ]
                , button [ stopPropagationOn "click" (Decode.succeed (MoveApiaryDown apiary.id, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title t.moveRight ] [ text "➡️" ]
                ]
            , if isAdmin then
                div [ style "display" "flex", style "gap" "10px" ]
                    [ button [ onClick (OpenEditApiaryModal apiary), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title t.edit ] [ text "✏️" ]
                    , button [ onClick (OpenDeleteApiaryModal apiary), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title t.delete ] [ text "🗑️" ]
                    , button [ onClick (NavigateTo (SharingView { apiaryId = apiary.id, apiaryName = apiary.name })), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title t.share ] [ text "👥" ]
                    ]
              else
                text ""
            ]
        ]
