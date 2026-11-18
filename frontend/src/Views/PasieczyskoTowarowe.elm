module Views.PasieczyskoTowarowe exposing (hiveListView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Types.Core exposing (..)
import Types.Decoders exposing (..)
import Types.Helpers exposing (..)
import Views.HiveDetail exposing (hiveDetailView)

hiveListView : User -> { apiaryId : String, apiaryName : String } -> Model -> Html Msg
hiveListView user info model =
    div []
        [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px", style "flex-wrap" "wrap" ]
            [ button [ onClick (NavigateTo ApiariesView), style "padding" "10px 16px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "40px" ] [ text "← Powrót" ]
            , h2 [ style "margin" "0", style "color" (if model.darkMode then "#ffffff" else "inherit") ] [ text ("Pasieka: " ++ info.apiaryName) ]
            ]
        , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "20px", style "flex-wrap" "wrap" ]
            [ button [ onClick OpenNewHiveModal, style "padding" "12px 18px", style "background-color" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "min-height" "44px", style "font-size" "15px" ] [ text "+ Dodaj Nowy Ul" ]
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
    div [ style "background" cardBg, style "padding" "16px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "cursor" "pointer", style "color" textColor
        , onClick (NavigateTo (HiveDetailView { apiaryId = apiaryId, hiveId = hive.id, hiveName = hive.name }))
        ]
        [ h3 [ style "margin-top" "0", style "color" headingColor ] [ text hive.name ]
        , p [ style "margin" "5px 0", style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#555") ] [ text ("Typ ramki: " ++ hive.frameType) ]
        , div [ style "margin-top" "10px", style "font-size" "12px", style "background" metaBg, style "padding" "6px", style "border-radius" "4px", style "color" textColor ]
            [ text ("Matka: " ++ (if hive.queen.hasOpalit then "Opalitek " ++ hive.queen.color ++ " #" ++ hive.queen.number else "Brak opalitka")) ]
        , div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-top" "12px", style "border-top" ("1px solid " ++ borderColor), style "padding-top" "10px", style "flex-wrap" "wrap" ]
            [ div [ style "display" "flex", style "gap" "8px" ]
                [ button [ stopPropagationOn "click" (Decode.succeed (MoveHiveUp hive.id, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "18px", style "padding" "6px", title "Przesuń w górę" ] [ text "⬆️" ]
                , button [ stopPropagationOn "click" (Decode.succeed (MoveHiveDown hive.id, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "18px", style "padding" "6px", title "Przesuń w dół" ] [ text "⬇️" ]
                ]
            , div [ style "display" "flex", style "gap" "12px" ]
                [ button [ stopPropagationOn "click" (Decode.succeed (OpenRenameHiveModal apiaryId hive, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "18px", style "padding" "6px", title "Zmień nazwę ula" ] [ text "✏️" ]
                , button [ stopPropagationOn "click" (Decode.succeed (OpenDeleteHiveModal apiaryId hive, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "18px", style "padding" "6px", title "Usuń ul" ] [ text "🗑️" ]
                ]
            ]
        ]
