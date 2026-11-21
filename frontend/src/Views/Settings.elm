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
        cardBg = if model.darkMode then "#17231b" else "#f0fdf4"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"
        sectionBorderColor = if model.darkMode then "#444" else "#ddd"
        numericInputClass =
            "box-border min-h-10 w-32 rounded-md border px-3 py-2 text-sm shadow-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 "
                ++ (if model.darkMode then
                        "border-slate-600 bg-slate-800 text-slate-100"
                    else
                        "border-slate-300 bg-white text-slate-900"
                   )

        moduleToggleRowClass =
            "flex min-h-11 items-center gap-3 rounded-md px-3 py-2 font-semibold cursor-pointer "
                ++ (if model.darkMode then
                        "bg-slate-800 text-slate-100"
                    else
                        "bg-slate-50 text-slate-800"
                   )

        moduleToggleWithHelpClass = moduleToggleRowClass ++ " justify-between"

        moduleToggleLabelClass = "flex min-w-0 items-center gap-3 cursor-pointer"

        moduleToggleClass = "size-5 shrink-0 cursor-pointer accent-blue-600"

        scheduleStep day title description =
            div [ style "position" "relative", style "min-width" "135px", style "flex" "1", style "padding-top" "24px" ]
                [ span [ style "position" "absolute", style "top" "5px", style "left" "0", style "width" "12px", style "height" "12px", style "border-radius" "50%", style "background" (if model.darkMode then "#86efac" else "#16a34a"), style "box-shadow" (if model.darkMode then "0 0 0 4px #14532d" else "0 0 0 4px #dcfce7") ] []
                , strong [ style "display" "block", style "font-size" "14px", style "color" headingColor ] [ text ((if t.isEnglish then "Day " else "Dzień ") ++ String.fromInt day) ]
                , span [ style "display" "block", style "font-weight" "600", style "font-size" "13px", style "margin-top" "3px" ] [ text title ]
                , span [ style "display" "block", style "font-size" "12px", style "margin-top" "3px", style "color" (if model.darkMode then "#b0b0b0" else "#666") ] [ text description ]
                ]

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
                [ class "settings-secondary-action settings-section-toggle"
                , onClick (ToggleSettingsSection section)
                , style "display" "flex"
                , style "align-items" "center"
                , style "justify-content" "space-between"
                , style "width" "100%"
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
            [ button [ class "settings-primary-action", onClick (NavigateTo ApiariesView), style "padding" "6px 12px" ] [ text t.back ]
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
                            , button [ class "destructive-action", onClick OpenAccountDeletion, style "margin-top" "12px", style "padding" "9px 14px", attribute "data-testid" "delete-account" ] [ text (if t.isEnglish then "Delete account" else "Usuń konto") ]
                            ]
                        , div []
                            [ settingHeader t.appearance ""
                            , button [ class "settings-preference-action", onClick ToggleDarkMode, style "padding" "10px 16px", style "background-image" (if model.darkMode then "none" else "radial-gradient(circle at 12px 10px, #fff 1px, transparent 1.5px), radial-gradient(circle at 34px 22px, #dbeafe 1px, transparent 1.5px), radial-gradient(circle at 52px 8px, #fff 1px, transparent 1.5px)"), style "background-size" "60px 32px", style "margin-top" "10px" ]
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
                            [ div [ class moduleToggleWithHelpClass ]
                                [ label [ class moduleToggleLabelClass ]
                                    [ input [ type_ "checkbox", checked model.enablePasieczyskaTowarowe, onCheck (\_ -> ToggleEnablePasieczyskaTowarowe), attribute "data-testid" "commercial-apiaries-toggle", class moduleToggleClass ] []
                                    , text t.enableCommercial
                                    ]
                                , infoIcon t.commercialHelp
                                ]
                            ]
                        , div []
                            [ settingHeader t.frameTypes t.frameTypesHelp
                            , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "15px", style "margin-top" "10px" ]
                                [ input [ type_ "text", placeholder t.newFrameType, value model.newFrameTypeInput, onInput UpdateNewFrameTypeInput, style "flex" "1", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ] []
                                , button [ class "settings-primary-action", onClick (AddFrameType model.newFrameTypeInput), style "padding" "8px 16px" ] [ text t.add ]
                                ]
                            , ul [ style "list-style" "none", style "padding" "0", style "margin" "0", style "display" "flex", style "flex-direction" "column", style "gap" "8px" ]
                                (List.map
                                    (\ft ->
                                        li [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "padding" "8px 12px", style "background" (if model.darkMode then "#2d2d2d" else "#f8f9fa"), style "border-radius" "4px" ]
                                            [ span [] [ text ft ]
                                            , button [ class "settings-icon-destructive-action", onClick (RemoveFrameType ft), style "font-size" "14px", title t.remove, attribute "aria-label" t.remove ] [ text "❌" ]
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
                            [ div [ class moduleToggleWithHelpClass ]
                                [ label [ class moduleToggleLabelClass ]
                                    [ input [ type_ "checkbox", checked model.enableTrutowiska, onCheck (\_ -> ToggleEnableTrutowiska), attribute "data-testid" "mating-apiaries-toggle", class moduleToggleClass ] []
                                    , text t.enableMating
                                    ]
                                , infoIcon t.matingHelp
                                ]
                            ]
                        , div []
                            [ settingHeader t.ulikTypes t.ulikTypesHelp
                            , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "15px", style "margin-top" "10px" ]
                                [ input [ type_ "text", placeholder t.newUlikType, value model.newUlikTypeInput, onInput UpdateNewUlikTypeInput, style "flex" "1", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ] []
                                , button [ class "settings-primary-action", onClick (AddUlikType model.newUlikTypeInput), style "padding" "8px 16px" ] [ text t.add ]
                                ]
                            , ul [ style "list-style" "none", style "padding" "0", style "margin" "0", style "display" "flex", style "flex-direction" "column", style "gap" "8px" ]
                                (List.map
                                    (\ut ->
                                        li [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "padding" "8px 12px", style "background" (if model.darkMode then "#2d2d2d" else "#f8f9fa"), style "border-radius" "4px" ]
                                            [ span [] [ text ut ]
                                            , button [ class "settings-icon-destructive-action", onClick (RemoveUlikType ut), style "font-size" "14px", title t.remove, attribute "aria-label" t.remove ] [ text "❌" ]
                                            ]
                                    )
                                    model.ulikTypes
                                )
                            ]
                        , div []
                            [ settingHeader t.breedLines t.breedLinesHelp
                            , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "15px", style "margin-top" "10px" ]
                                [ input [ type_ "text", placeholder t.newBreedLine, value model.newBreedLineInput, onInput UpdateNewBreedLineInput, style "flex" "1", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ] []
                                , button [ class "settings-primary-action", onClick (AddBreedLine model.newBreedLineInput), style "padding" "8px 16px" ] [ text t.add ]
                                ]
                            , ul [ style "list-style" "none", style "padding" "0", style "margin" "0", style "display" "flex", style "flex-direction" "column", style "gap" "8px" ]
                                (List.map
                                    (\bl ->
                                        li [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "padding" "8px 12px", style "background" (if model.darkMode then "#2d2d2d" else "#f8f9fa"), style "border-radius" "4px" ]
                                            [ span [] [ text bl ]
                                            , button [ class "settings-icon-destructive-action", onClick (RemoveBreedLine bl), style "font-size" "14px", title t.remove, attribute "aria-label" t.remove ] [ text "❌" ]
                                            ]
                                    )
                                    model.breedLines
                                )
                            ]
                        , div []
                            [ settingHeader t.hatchingMatingDays t.hatchingMatingHelp
                            , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "15px", style "margin-top" "10px" ]
                                [ input [ type_ "number", Html.Attributes.min "1", Html.Attributes.max "30", value (String.fromInt model.hatchingToMatingDays), onInput UpdateHatchingToMatingDaysInput, class numericInputClass ] []
                                ]
                            ]
                        , div []
                            [ settingHeader t.maxHistory t.maxHistoryHelp
                            , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "15px", style "margin-top" "10px" ]
                                [ input [ type_ "number", Html.Attributes.min "10", Html.Attributes.max "60", value (String.fromInt model.maxUlikHistoryLimit), onInput UpdateMaxUlikHistoryLimitInput, class numericInputClass ] []
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
                        [ label [ class moduleToggleRowClass ]
                            [ input [ type_ "checkbox", checked model.enableQueenRearing, onCheck (\_ -> ToggleEnableQueenRearing), attribute "data-testid" "queen-rearing-toggle", class moduleToggleClass ] []
                            , text t.enableQueenRearing
                            ]
                        , p [] [ text t.queenRearingDefaults ]
                        , div [ style "display" "grid", style "grid-template-columns" "repeat(auto-fit, minmax(180px, 1fr))", style "gap" "10px" ]
                            [ label [ style "display" "flex", style "flex-direction" "column", style "gap" "6px" ] [ text t.graftCount, input [ type_ "number", Html.Attributes.min "1", value (String.fromInt model.defaultGraftCount), onInput (UpdateQueenSetting "graft"), class numericInputClass ] [] ]
                            , label [ style "display" "flex", style "flex-direction" "column", style "gap" "6px" ] [ text t.starterDuration, input [ type_ "number", Html.Attributes.min "1", Html.Attributes.max "10", value (String.fromInt model.starterDurationDays), onInput (UpdateQueenSetting "starter"), class numericInputClass ] [] ]
                            , label [ style "display" "flex", style "flex-direction" "column", style "gap" "6px" ] [ text t.isolationDay, input [ type_ "number", Html.Attributes.min "2", value (String.fromInt model.isolationDay), onInput (UpdateQueenSetting "isolation"), class numericInputClass ] [] ]
                            , label [ style "display" "flex", style "flex-direction" "column", style "gap" "6px" ] [ text t.emergenceDay, input [ type_ "number", Html.Attributes.min "2", value (String.fromInt model.emergenceDay), onInput (UpdateQueenSetting "emergence"), class numericInputClass ] [] ]
                            ]
                        , div [ attribute "data-testid" "queen-rearing-schedule-timeline", style "overflow-x" "auto", style "padding" "12px 8px", style "border-radius" "8px", style "background" (if model.darkMode then "#1e293b" else "#f8fafc") ]
                            [ p [ style "margin" "0 0 8px 0", style "font-size" "13px", style "font-weight" "600", style "color" headingColor ] [ text (if t.isEnglish then "Batch schedule from grafting (day 0)" else "Harmonogram serii od przekładania larw (dzień 0)") ]
                            , div [ style "display" "flex", style "position" "relative", style "min-width" "580px", style "gap" "12px" ]
                                [ div [ style "position" "absolute", style "top" "10px", style "left" "6px", style "right" "6px", style "height" "2px", style "background" (if model.darkMode then "#475569" else "#bbf7d0") ] []
                                , scheduleStep 0
                                    (if t.isEnglish then "Grafting and placing in the starter" else "Przekładanie larw i umieszczenie w starterze")
                                    (if t.isEnglish then "Start of the batch" else "Początek serii")
                                , scheduleStep (model.starterDurationDays + 1)
                                    (if t.isEnglish then "Transfer to finisher" else "Przeniesienie do finiszera")
                                    (if t.isEnglish then "Starter work ends" else "Koniec pracy startera")
                                , scheduleStep model.isolationDay (if t.isEnglish then "Isolation" else "Izolacja") (if t.isEnglish then "Queen cells are isolated" else "Odizolowanie mateczników")
                                , scheduleStep model.emergenceDay (if t.isEnglish then "Emergence" else "Wygryzienie") (if t.isEnglish then "Expected queen emergence" else "Przewidywane wygryzienie matek")
                                ]
                            ]
                        ]
                  else
                    text ""
                ]
            , div [ style "display" "flex", style "flex-direction" "column" ]
                [ sectionHeader SectionPrywatnosc "🔒" (t.localize "Prywatność i zgody") "settings-section-toggle-prywatnosc"
                , if isExpanded SectionPrywatnosc then
                    div [ style "display" "flex", style "flex-direction" "column", style "gap" "12px", attribute "data-testid" "settings-section-prywatnosc" ]
                        [ div [ style "display" "flex", style "justify-content" "space-between", style "gap" "12px", style "align-items" "center" ]
                            [ div []
                                [ strong [] [ text (t.localize "Niezbędna pamięć przeglądarki") ]
                                , p [ style "margin" "4px 0", style "font-size" "14px" ] [ text (t.localize "Zawsze aktywna: logowanie Firebase, ustawienia interfejsu i zapis tej decyzji.") ]
                                ]
                            , span [ attribute "aria-label" (t.localize "Zawsze aktywne"), style "white-space" "nowrap" ] [ text (t.localize "Zawsze aktywne") ]
                            ]
                        , label [ style "display" "flex", style "align-items" "center", style "gap" "10px", style "cursor" "pointer" ]
                            [ input [ type_ "checkbox", checked model.consentAnalytics, onCheck (\_ -> ToggleConsentAnalytics), attribute "data-testid" "analytics-toggle" ] []
                            , span [] [ text (t.localize "Opcjonalna diagnostyka i analityka") ]
                            ]
                        , p [ style "margin" "0", style "font-size" "14px" ] [ text (t.localize "Opcja jest domyślnie wyłączona. Zmiana zostaje zapisana w tej przeglądarce.") ]
                        , button [ onClick OpenPrivacyPolicy, attribute "data-testid" "open-privacy-policy", style "align-self" "flex-start", style "padding" "8px 12px" ] [ text (t.localize "Polityka prywatności") ]
                        ]
                  else
                    text ""
                ]
            ]
        ]
        |> (\page ->
            if model.showAccountDeletion then
                div [] [ page, div [ style "position" "fixed", style "inset" "0", style "background" "rgba(0,0,0,.6)", style "display" "grid", style "place-items" "center", style "z-index" "1000" ]
                    [ div [ style "background" cardBg, style "color" textColor, style "padding" "24px", style "border-radius" "8px", style "width" "min(420px,90vw)" ]
                        [ h2 [] [ text (if t.isEnglish then "Delete account" else "Usuń konto") ]
                        , p [] [ text ((if t.isEnglish then "Type exactly " else "Wpisz dokładnie: ") ++ "Tak, usuwam konto!") ]
                        , input [ type_ "text", value model.deletionPhrase, onInput UpdateDeletionPhrase, disabled model.deletionBusy, attribute "autocomplete" "off", attribute "data-testid" "delete-account-phrase", style "width" "100%", style "padding" "8px", style "box-sizing" "border-box" ] []
                        , case model.deletionError of
                            Just err ->
                                p [ style "color" "#dc2626" ] [ text (t.localize err) ]

                            Nothing ->
                                text ""
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "8px", style "margin-top" "16px" ]
                            [ button [ class "destructive-action", onClick CloseAccountDeletion, disabled model.deletionBusy ] [ text (if t.isEnglish then "Cancel" else "Anuluj") ]
                            , button [ class "destructive-action", onClick SubmitAccountDeletion, disabled model.deletionBusy, attribute "data-testid" "confirm-delete-account" ] [ text (if model.deletionBusy then (if t.isEnglish then "Deleting…" else "Usuwanie…") else (if t.isEnglish then "Delete" else "Usuń")) ]
                            ]
                        ]
                    ]
                ]
            else page
        )
