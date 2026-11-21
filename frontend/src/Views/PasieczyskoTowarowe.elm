module Views.PasieczyskoTowarowe exposing (hiveListView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Types.Core exposing (..)
import Types.Decoders exposing (..)
import Types.Helpers exposing (..)
import Views.HiveDetail exposing (hiveDetailView)
import I18n exposing (Translations)

hiveListView : Translations -> User -> { apiaryId : String, apiaryName : String } -> Model -> Html Msg
hiveListView t user info model =
    div []
        [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px", style "flex-wrap" "wrap" ]
            [ button [ class "secondary-action", onClick (NavigateTo ApiariesView), style "padding" "10px 16px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "40px" ] [ text t.back ]
            , h2 [ style "margin" "0", style "color" (if model.darkMode then "#ffffff" else "inherit") ] [ text (t.localize "Pasieka: " ++ info.apiaryName) ]
            ]
        , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "20px", style "flex-wrap" "wrap" ]
            [ button [ onClick OpenNewHiveModal ] [ text t.addHive ]
            ]
        , div [ style "display" "flex", style "flex-direction" "column", style "gap" "15px" ]
            (List.map (hiveCardView t info.apiaryId model) (List.filter (\hive -> hive.apiaryId == info.apiaryId) model.hives))
        ]

hiveCardView : Translations -> String -> Model -> Hive -> Html Msg
hiveCardView t apiaryId model hive =
    let
        cardBg = if model.darkMode then "#17231b" else "#f0fdf4"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        borderColor = if model.darkMode then "#333" else "#eee"
        metaBg = if model.darkMode then "#2d2d2d" else "#f1f2f6"
    in
    div [ style "background" cardBg, style "padding" "16px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "cursor" "grab", style "color" textColor
        , draggable "true"
        , on "dragstart" (Decode.succeed (StartOrderDrag CommercialHives apiaryId hive.id))
        , preventDefaultOn "dragover" (Decode.succeed ( OrderDragOver CommercialHives apiaryId hive.id, True ))
        , on "dragend" (Decode.succeed EndOrderDrag)
        , attribute "data-testid" "commercial-hive-card"
        , attribute "data-hive-id" hive.id
        , attribute "data-order-collection" "commercial-hives"
        , attribute "data-order-apiary-id" apiaryId
        , attribute "data-order-id" hive.id
        , onClick (NavigateCard (HiveDetailView { apiaryId = apiaryId, hiveId = hive.id, hiveName = hive.name }))
        , on "mousedown" (Decode.succeed ResetCardClickSuppression)
        ]
        [ div [ style "display" "flex", style "align-items" "center", style "justify-content" "space-between", style "gap" "12px" ]
            [ h3 [ style "margin" "0", style "color" headingColor ] [ text hive.name ]
            , button [ attribute "data-testid" "delete-hive-trigger", stopPropagationOn "click" (Decode.succeed (OpenDeleteHiveModal apiaryId hive, True)), style "background" "#c0392b", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "font-size" "18px", style "padding" "6px", title t.delete ] [ text (t.localize "🗑️") ]
            ]
        , p [ style "margin" "5px 0", style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#555") ] [ text (t.frameType ++ " " ++ hive.frameType) ]
        , div [ style "margin-top" "10px", style "font-size" "12px", style "background" metaBg, style "padding" "6px", style "border-radius" "4px", style "color" textColor ]
            [ text (t.localize "Matka: " ++ (if hive.queen.hasOpalit then t.localize "Opalitek " ++ t.localize hive.queen.color ++ " #" ++ hive.queen.number else t.localize "Brak opalitka")) ]
        ]
