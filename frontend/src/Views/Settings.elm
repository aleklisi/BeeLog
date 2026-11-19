module Views.Settings exposing (settingsView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Types.Core exposing (..)
import Types.Decoders exposing (..)
import Types.Helpers exposing (..)
import I18n exposing (Translations)

settingsView : Translations -> User -> Model -> Html Msg
settingsView t user model =
    let
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"
        sectionBorderColor = if model.darkMode then "#444" else "#ddd"

        infoIcon explanation =
            span
                [ title explanation
                , style "cursor" "help"
                , style "font-size" "11px"
                , style "color" (if model.darkMode then "#888" else "#666")
                , style "border" "1px solid #888"
                , style "border-radius" "50%"
                , style "width" "15px"
                , style "height" "15px"
                , style "display" "inline-flex"
                , style "align-items" "center"
                , style "justify-content" "center"
                , style "flex-shrink" "0"
                ]
                [ text "i" ]

        settingHeader titleText explanation =
            div [ style "display" "flex", style "align-items" "center", style "justify-content" "space-between", style "margin-bottom" "5px" ]
                [ h3 [ style "color" headingColor, style "margin" "0" ] [ text titleText ]
                , infoIcon explanation
                ]

        isExpanded section =
            List.member section model.expandedSettingsSections

        sectionToggleIcon section =
            if isExpanded section then "∧" else "∨"

        sectionHeader section emoji titleText testId =
            let
                expanded = isExpanded section
            in
            button
                [ onClick (ToggleSettingsSection section)
                , style "display" "flex"
                , style "align-items" "center"
                , style "justify-content" "space-between"
                , style "width" "100%"
                , style "background" "none"
                , style "border" "none"
                , style "border-bottom" ("2px solid " ++ sectionBorderColor)
                , style "padding" "0 0 8px 0"
                , style "margin-bottom" (if expanded then "16px" else "0")
                , style "cursor" "pointer"
                , style "text-align" "left"
                , attribute "data-testid" testId
                , attribute "aria-expanded" (if expanded then "true" else "false")
                ]
                [ h2 [ style "margin" "0", style "color" headingColor ] [ text (emoji ++ " " ++ titleText) ]
                , span
                    [ style "display" "inline-flex"
                    , style "align-items" "center"
                    , style "justify-content" "center"
                    , style "width" "28px"
                    , style "height" "28px"
                    , style "border-radius" "50%"
                    , style "border" ("1px solid " ++ sectionBorderColor)
                    , style "font-size" "14px"
                    , style "color" headingColor
                    , style "flex-shrink" "0"
                    , attribute "aria-hidden" "true"
                    ]
                    [ text (sectionToggleIcon section) ]
                ]
    in
    div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "color" textColor ]
        [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px" ]
            [ button [ onClick (NavigateTo ApiariesView), style "padding" "6px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text t.back ]
            , h2 [ style "margin" "0", style "color" headingColor ] [ text t.settings ]
            ]
        , div [ style "display" "flex", style "flex-direction" "column", style "gap" "30px" ]
            [ -- Sekcja 1: Ogólne
              div [ style "display" "flex", style "flex-direction" "column" ]
                [ sectionHeader SectionOgolne "📂" t.general "settings-section-toggle-ogolne"
                , if isExpanded SectionOgolne then
                    div [ style "display" "flex", style "flex-direction" "column", style "gap" "20px", attribute "data-testid" "settings-section-ogolne" ]
                        [ div []
                            [ settingHeader t.account ""
                            , p [ style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#666"), style "margin" "0 0 8px 0" ] [ text t.signedInEmail ]
                            , div [ style "font-size" "16px", style "font-weight" "bold", style "color" headingColor, style "padding" "8px 12px", style "background" (if model.darkMode then "#2d2d2d" else "#f8f9fa"), style "border-radius" "4px", attribute "data-testid" "user-email" ]
                                [ text user.email ]
                            ]
                        , div []
                            [ settingHeader t.appearance ""
                            , button [ onClick ToggleDarkMode, style "padding" "10px 16px", style "background-color" (if model.darkMode then "#f1c40f" else "#2c3e50"), style "color" (if model.darkMode then "#121212" else "#ffffff"), style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "font-size" "14px", style "margin-top" "10px" ]
                                [ text (if model.darkMode then t.lightMode else t.darkMode) ]
                            ]
                        , div []
                            [ settingHeader t.language ""
                            , select
                                [ value (languageToString model.language)
                                , on "change" (Decode.map (ChangeLanguage << languageFromString) (Decode.at [ "target", "value" ] Decode.string))
                                , attribute "data-testid" "language-select"
                                , style "padding" "8px"
                                , style "background" inputBg
                                , style "color" inputColor
                                , style "border" inputBorder
                                , style "border-radius" "4px"
                                ]
                                [ option [ value "pl" ] [ text "Polski" ]
                                , option [ value "en" ] [ text "English" ]
                                ]
                            ]
                        ]
                  else
                    text ""
                ]

            -- Sekcja 2: Pasieczyska towarowe
            , div [ style "display" "flex", style "flex-direction" "column" ]
                [ sectionHeader SectionPasieczyskaTowarowe "🍯" t.sectionCommercial "settings-section-toggle-pasieczyska"
                , if isExpanded SectionPasieczyskaTowarowe then
                    div [ style "display" "flex", style "flex-direction" "column", style "gap" "20px", attribute "data-testid" "settings-section-pasieczyska" ]
                        [ div []
                            [ settingHeader t.enableCommercial t.commercialHelp
                            , label [ style "display" "flex", style "align-items" "center", style "gap" "10px", style "cursor" "pointer", style "font-weight" "bold", style "color" headingColor, style "margin-top" "10px" ]
                        [ input [ type_ "checkbox", checked model.enablePasieczyskaTowarowe, onCheck (\_ -> ToggleEnablePasieczyskaTowarowe), attribute "data-testid" "commercial-apiaries-toggle", style "width" "18px", style "height" "18px", style "cursor" "pointer" ] []
                                , text t.enabled
                                ]
                            ]
                        , div []
                            [ settingHeader t.frameTypes t.frameTypesHelp
                            , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "15px", style "margin-top" "10px" ]
                                [ input [ type_ "text", placeholder t.newFrameType, value model.newFrameTypeInput, onInput UpdateNewFrameTypeInput, style "flex" "1", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ] []
                                , button [ onClick (AddFrameType model.newFrameTypeInput), style "padding" "8px 16px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text t.add ]
                                ]
                            , ul [ style "list-style" "none", style "padding" "0", style "margin" "0", style "display" "flex", style "flex-direction" "column", style "gap" "8px" ]
                                (List.map
                                    (\ft ->
                                        li [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "padding" "8px 12px", style "background" (if model.darkMode then "#2d2d2d" else "#f8f9fa"), style "border-radius" "4px" ]
                                            [ span [] [ text ft ]
                                            , button [ onClick (RemoveFrameType ft), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title t.remove ] [ text "❌" ]
                                            ]
                                    )
                                    model.frameTypes
                                )
                            ]
                        ]
                  else
                    text ""
                ]

            -- Sekcja 3: Trutowiska
            , div [ style "display" "flex", style "flex-direction" "column" ]
                [ sectionHeader SectionTrutowiska "👑" t.sectionMating "settings-section-toggle-trutowiska"
                , if isExpanded SectionTrutowiska then
                    div [ style "display" "flex", style "flex-direction" "column", style "gap" "20px", attribute "data-testid" "settings-section-trutowiska" ]
                        [ div []
                            [ settingHeader t.enableMating t.matingHelp
                            , label [ style "display" "flex", style "align-items" "center", style "gap" "10px", style "cursor" "pointer", style "font-weight" "bold", style "color" headingColor, style "margin-top" "10px" ]
                        [ input [ type_ "checkbox", checked model.enableTrutowiska, onCheck (\_ -> ToggleEnableTrutowiska), attribute "data-testid" "mating-apiaries-toggle", style "width" "18px", style "height" "18px", style "cursor" "pointer" ] []
                                , text t.enabled
                                ]
                            ]
                        , div []
                            [ settingHeader t.ulikTypes t.ulikTypesHelp
                            , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "15px", style "margin-top" "10px" ]
                                [ input [ type_ "text", placeholder t.newUlikType, value model.newUlikTypeInput, onInput UpdateNewUlikTypeInput, style "flex" "1", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ] []
                                , button [ onClick (AddUlikType model.newUlikTypeInput), style "padding" "8px 16px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text t.add ]
                                ]
                            , ul [ style "list-style" "none", style "padding" "0", style "margin" "0", style "display" "flex", style "flex-direction" "column", style "gap" "8px" ]
                                (List.map
                                    (\ut ->
                                        li [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "padding" "8px 12px", style "background" (if model.darkMode then "#2d2d2d" else "#f8f9fa"), style "border-radius" "4px" ]
                                            [ span [] [ text ut ]
                                            , button [ onClick (RemoveUlikType ut), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title t.remove ] [ text "❌" ]
                                            ]
                                    )
                                    model.ulikTypes
                                )
                            ]
                        , div []
                            [ settingHeader t.breedLines t.breedLinesHelp
                            , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "15px", style "margin-top" "10px" ]
                                [ input [ type_ "text", placeholder t.newBreedLine, value model.newBreedLineInput, onInput UpdateNewBreedLineInput, style "flex" "1", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ] []
                                , button [ onClick (AddBreedLine model.newBreedLineInput), style "padding" "8px 16px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text t.add ]
                                ]
                            , ul [ style "list-style" "none", style "padding" "0", style "margin" "0", style "display" "flex", style "flex-direction" "column", style "gap" "8px" ]
                                (List.map
                                    (\bl ->
                                        li [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "padding" "8px 12px", style "background" (if model.darkMode then "#2d2d2d" else "#f8f9fa"), style "border-radius" "4px" ]
                                            [ span [] [ text bl ]
                                            , button [ onClick (RemoveBreedLine bl), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title t.remove ] [ text "❌" ]
                                            ]
                                    )
                                    model.breedLines
                                )
                            ]
                        , div []
                            [ settingHeader t.hatchingMatingDays t.hatchingMatingHelp
                            , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "15px", style "margin-top" "10px" ]
                                [ input [ type_ "number", Html.Attributes.min "1", Html.Attributes.max "30", value (String.fromInt model.hatchingToMatingDays), onInput UpdateHatchingToMatingDaysInput, style "width" "120px", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ] []
                                ]
                            ]
                        , div []
                            [ settingHeader t.maxHistory t.maxHistoryHelp
                            , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "15px", style "margin-top" "10px" ]
                                [ input [ type_ "number", Html.Attributes.min "10", Html.Attributes.max "60", value (String.fromInt model.maxUlikHistoryLimit), onInput UpdateMaxUlikHistoryLimitInput, style "width" "120px", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ] []
                                ]
                            ]
                        ]
                  else
                    text ""
                ]

            -- Sekcja 4: Hodowla matek
            , div [ style "display" "flex", style "flex-direction" "column" ]
                [ sectionHeader SectionQueenRearing "🐝" t.queenRearing "settings-section-toggle-queen-rearing"
                , if isExpanded SectionQueenRearing then
                    div [ style "display" "flex", style "flex-direction" "column", style "gap" "14px", attribute "data-testid" "settings-section-queen-rearing" ]
                        [ label [ style "display" "flex", style "align-items" "center", style "gap" "10px" ]
                            [ input [ type_ "checkbox", checked model.enableQueenRearing, onCheck (\_ -> ToggleEnableQueenRearing), attribute "data-testid" "queen-rearing-toggle" ] []
                            , text t.enableQueenRearing
                            ]
                        , p [] [ text t.queenRearingDefaults ]
                        , div [ style "display" "grid", style "grid-template-columns" "repeat(auto-fit, minmax(180px, 1fr))", style "gap" "10px" ]
                            [ label [] [ text t.graftCount, input [ type_ "number", Html.Attributes.min "1", value (String.fromInt model.defaultGraftCount), onInput (UpdateQueenSetting "graft") ] [] ]
                            , label [] [ text t.starterDuration, input [ type_ "number", Html.Attributes.min "1", Html.Attributes.max "10", value (String.fromInt model.starterDurationDays), onInput (UpdateQueenSetting "starter") ] [] ]
                            , label [] [ text t.isolationDay, input [ type_ "number", Html.Attributes.min "2", value (String.fromInt model.isolationDay), onInput (UpdateQueenSetting "isolation") ] [] ]
                            , label [] [ text t.emergenceDay, input [ type_ "number", Html.Attributes.min "2", value (String.fromInt model.emergenceDay), onInput (UpdateQueenSetting "emergence") ] [] ]
                            ]
                        ]
                  else
                    text ""
                ]
            ]
        ]
