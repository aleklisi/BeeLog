module Views.Settings exposing (settingsView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (..)

settingsView : User -> Model -> Html Msg
settingsView user model =
    let
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"
    in
    div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "color" textColor ]
        [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px" ]
            [ button [ onClick (NavigateTo ApiariesView), style "padding" "6px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "← Powrót" ]
            , h2 [ style "margin" "0", style "color" headingColor ] [ text "⚙️ Ustawienia aplikacji (Per Użytkownik)" ]
            ]
        , div [ style "display" "flex", style "flex-direction" "column", style "gap" "20px" ]
            [ div []
                [ h3 [ style "color" headingColor ] [ text "Konto użytkownika" ]
                , p [ style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#666") ] [ text "Zalogowany adres e-mail:" ]
                , div [ style "font-size" "16px", style "font-weight" "bold", style "color" headingColor, style "padding" "8px 12px", style "background" (if model.darkMode then "#2d2d2d" else "#f8f9fa"), style "border-radius" "4px", attribute "data-testid" "user-email" ]
                    [ text user.email ]
                ]
            , div []
                [ h3 [ style "color" headingColor ] [ text "Wygląd i Motyw" ]
                , p [ style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#666") ] [ text "Wybierz tryb jasny lub ciemny interfejsu aplikacji." ]
                , button [ onClick ToggleDarkMode, style "padding" "10px 16px", style "background-color" (if model.darkMode then "#f1c40f" else "#2c3e50"), style "color" (if model.darkMode then "#121212" else "#ffffff"), style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "font-size" "14px" ]
                    [ text (if model.darkMode then "☀️ Przełącz na Tryb Jasny" else "🌙 Przełącz na Tryb Ciemny") ]
                ]
            , div []
                [ h3 [ style "color" headingColor ] [ text "Rodzaje ramek (Pasieka Towarowa)" ]
                , p [ style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#666") ] [ text "Skonfiguruj listę dostępnych rodzajów ramek dla uli w pasiekach towarowych." ]
                , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "15px" ]
                    [ input [ type_ "text", placeholder "Nowy rodzaj ramki (np. Dadant)", value model.newFrameTypeInput, onInput UpdateNewFrameTypeInput, style "flex" "1", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ] []
                    , button [ onClick (AddFrameType model.newFrameTypeInput), style "padding" "8px 16px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Dodaj" ]
                    ]
                , ul [ style "list-style" "none", style "padding" "0", style "margin" "0", style "display" "flex", style "flex-direction" "column", style "gap" "8px" ]
                    (List.map
                        (\ft ->
                            li [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "padding" "8px 12px", style "background" (if model.darkMode then "#2d2d2d" else "#f8f9fa"), style "border-radius" "4px" ]
                                [ span [] [ text ft ]
                                , button [ onClick (RemoveFrameType ft), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Usuń" ] [ text "❌" ]
                                ]
                        )
                        model.frameTypes
                    )
                ]
            , div []
                [ h3 [ style "color" headingColor ] [ text "Typy ulików weselnych" ]
                , p [ style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#666") ] [ text "Skonfiguruj listę dostępnych typów ulików weselnych." ]
                , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "15px" ]
                    [ input [ type_ "text", placeholder "Nowy typ uliku (np. Apidea)", value model.newUlikTypeInput, onInput UpdateNewUlikTypeInput, style "flex" "1", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ] []
                    , button [ onClick (AddUlikType model.newUlikTypeInput), style "padding" "8px 16px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Dodaj" ]
                    ]
                , ul [ style "list-style" "none", style "padding" "0", style "margin" "0", style "display" "flex", style "flex-direction" "column", style "gap" "8px" ]
                    (List.map
                        (\ut ->
                            li [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "padding" "8px 12px", style "background" (if model.darkMode then "#2d2d2d" else "#f8f9fa"), style "border-radius" "4px" ]
                                [ span [] [ text ut ]
                                , button [ onClick (RemoveUlikType ut), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Usuń" ] [ text "❌" ]
                                ]
                        )
                        model.ulikTypes
                    )
                ]
            , div []
                [ h3 [ style "color" headingColor ] [ text "Rasy i linie matek pszczelich" ]
                , p [ style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#666") ] [ text "Skonfiguruj listę dostępnych ras i linii matek pszczelich." ]
                , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "15px" ]
                    [ input [ type_ "text", placeholder "Nowa rasa/linia (np. car. Galicja)", value model.newBreedLineInput, onInput UpdateNewBreedLineInput, style "flex" "1", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ] []
                    , button [ onClick (AddBreedLine model.newBreedLineInput), style "padding" "8px 16px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Dodaj" ]
                    ]
                , ul [ style "list-style" "none", style "padding" "0", style "margin" "0", style "display" "flex", style "flex-direction" "column", style "gap" "8px" ]
                    (List.map
                        (\bl ->
                            li [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "padding" "8px 12px", style "background" (if model.darkMode then "#2d2d2d" else "#f8f9fa"), style "border-radius" "4px" ]
                                [ span [] [ text bl ]
                                , button [ onClick (RemoveBreedLine bl), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Usuń" ] [ text "❌" ]
                                ]
                        )
                        model.breedLines
                    )
                ]
            , div []
                [ h3 [ style "color" headingColor ] [ text "Liczba dni od spodziewanego wygryzienia do spodziewanego unasiennienia" ]
                , p [ style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#666") ] [ text "Liczba dni (od 1 do 30) od wygryzienia do spodziewanego unasiennienia." ]
                , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "15px" ]
                    [ input [ type_ "number", Html.Attributes.min "1", Html.Attributes.max "30", value (String.fromInt model.hatchingToMatingDays), onInput UpdateHatchingToMatingDaysInput, style "width" "120px", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ] []
                    ]
                ]
            , div []
                [ h3 [ style "color" headingColor ] [ text "Maksymalna liczba wydarzeń w historii ulika weselnego" ]
                , p [ style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#666") ] [ text "Maksymalna liczba wpisów historii przechowywanych dla ulika weselnego (od 10 do 60)." ]
                , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "15px" ]
                    [ input [ type_ "number", Html.Attributes.min "10", Html.Attributes.max "60", value (String.fromInt model.maxUlikHistoryLimit), onInput UpdateMaxUlikHistoryLimitInput, style "width" "120px", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ] []
                    ]
                ]
            ]
        ]
