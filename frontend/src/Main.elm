port module Main exposing (main, moveById, normalizeOrder, replaceVisibleItems)

import Browser
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (Value)
import Json.Encode as Encode
import Types.Core exposing (..)
import Types.Decoders exposing (..)
import Types.Helpers exposing (..)
import Types.QueenRearing as QR
import I18n exposing (Translations, translationsFor)
import QueenRearing.Domain as QueenDomain
import Views.ApiaryList exposing (apiariesView)
import Views.HiveDetail exposing (hiveDetailView)
import Views.PasieczyskoTowarowe exposing (hiveListView)
import Views.Settings exposing (settingsView)
import Views.QueenRearing exposing (queenRearingView)
import Views.Trutowisko exposing (ulikAttentionReasons, ulikListView)
import Views.UlikDetail exposing (ulikDetailView)

type alias OrderDrop =
    { collection : OrderCollection
    , apiaryId : String
    , draggedId : String
    , targetId : String
    , after : Bool
    }

main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

-- MODEL

type alias Flags =
    { darkMode : Bool
    , language : String
    , initialHash : String
    }

init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        hash = flags.initialHash
        (pending, cmd) =
            if String.startsWith "#hive/" hash then
                let
                    parts = String.split "/" hash
                in
                case (List.head (List.drop 1 parts), List.head (List.drop 2 parts)) of
                    (Just apiaryId, Just hiveId) ->
                        ( Just (PendingHive { apiaryId = apiaryId, hiveId = hiveId })
                        , jsLoadHives { apiaryId = apiaryId, deepLinkId = hiveId }
                        )
                    _ ->
                        ( Nothing, Cmd.none )
            else if String.startsWith "#ulik/" hash then
                let
                    parts = String.split "/" hash
                in
                case (List.head (List.drop 1 parts), List.head (List.drop 2 parts)) of
                    (Just apiaryId, Just ulikId) ->
                        ( Just (PendingUlik { apiaryId = apiaryId, ulikId = ulikId })
                        , jsLoadUliki { apiaryId = apiaryId, deepLinkId = ulikId }
                        )
                    _ ->
                        ( Nothing, Cmd.none )
            else
                ( Nothing, Cmd.none )
    in
    ( { authState = LoggedOut
      , viewState = LoginView
      , apiaries = []
      , hives = []
      , draggedKorpusId = Nothing
      , draggedOrderItem = Nothing
      , suppressCardClick = False
      , uliki = []
      , notes = []
      , errorMessage = Nothing
      , successMessage = Nothing
      , darkMode = flags.darkMode
      , language = languageFromString flags.language
      , pendingDeepLink = pending
      , currentDate = ""
      , currentEpoch = 0
      , apiaryFilter = "all"
      , ulikFilter = "all"
      , ulikActionRequiredOnly = False
      , frameTypes = [ "Wielkopolska", "Wielkopolska 18", "Wielkopolska 1/2", "Warszawska zwykła", "MiniPlus", "Dadant" ]
      , newFrameTypeInput = ""
      , ulikTypes = [ "Mini plus", "Odkład wielkopolski", "Apidea" ]
      , newUlikTypeInput = ""
      , breedLines = [ "car. Galicja", "cau. M", "cau. KP", "cau. Woźnica", "car. Słowenka" ]
      , newBreedLineInput = ""
      , hatchingToMatingDays = 12
      , maxUlikHistoryLimit = 40
      , enableTrutowiska = True
      , enablePasieczyskaTowarowe = True
      , enableQueenRearing = False
      , defaultGraftCount = 24
      , starterDurationDays = 2
      , isolationDay = 10
      , emergenceDay = 11
      , menuExpanded = False
      , previousPrimaryView = Nothing
      , queenRearingData = QR.QueenRearingData [] [] [] []
      , queenRearingForm = Dict.fromList [ ( "kind", "breederQueens" ), ( "availability", "PUSTY" ), ( "graftCount", "24" ), ( "graftedAt", "" ), ( "timeZone", "Europe/Warsaw" ), ( "count", "" ), ( "starterId", "" ), ( "finisherId", "" ), ( "incubatorBar", "" ) ]
      , editingQueenResource = Nothing
      , expandedSettingsSections = []
      , showAccountDeletion = False
      , deletionPhrase = ""
      , deletionError = Nothing
      , deletionBusy = False
      , showNewApiaryModal = False
      , newApiaryName = ""
      , newApiaryType = "towarowe"
      , showEditApiaryModal = Nothing
      , editApiaryNameInput = ""
      , showDeleteApiaryModal = Nothing
      , showNewHiveModal = False
      , newHiveName = ""
      , newHiveType = "korpusowy"
      , newHiveFrameType = "Wielkopolska"
      , newHiveBroodFrameType = "Wielkopolska"
      , newHiveBroodFrameCount = 10
      , newHiveMaxBroodFrames = 24
      , newHiveHasSuper = False
      , newHiveSuperFrameType = "Wielkopolska 1/2"
      , newHiveSuperCount = 1
      , newHiveSuperFrameCount = 10
      , newHiveMaxSuperFrames = 18
      , showNewUlikModal = False
      , newUlikName = ""
      , newUlikHiveType = "Mini plus"
      , newNoteText = ""
      , editingNoteId = Nothing
      , editNoteText = ""
      , showRenameHiveModal = Nothing
      , renameHiveInput = ""
      , showDeleteHiveModal = Nothing
      , showRenameUlikModal = Nothing
      , renameUlikInput = ""
      , showDeleteUlikModal = Nothing
      , showMoveUlikModal = Nothing
      , moveUlikTargetApiaryId = ""
      , activeUlikModal = Nothing
      , modalBreedLine = ""
      , modalHatchDate = ""
      , modalIsOpalitkovana = "Nie"
      , modalOpalitColor = "Biały"
      , modalOpalitNumber = ""
      }
    , cmd
    )


syncApiaryContents : Model -> List Apiary
syncApiaryContents model =
    case model.viewState of
        HiveListView info ->
            List.map
                (\apiary ->
                    if apiary.id == info.apiaryId then
                        { apiary | hives = model.hives }
                    else
                        apiary
                )
                model.apiaries

        HiveDetailView info ->
            List.map
                (\apiary ->
                    if apiary.id == info.apiaryId then
                        { apiary | hives = model.hives }
                    else
                        apiary
                )
                model.apiaries

        UlikListView info ->
            List.map
                (\apiary ->
                    if apiary.id == info.apiaryId then
                        { apiary | uliki = model.uliki }
                    else
                        apiary
                )
                model.apiaries

        UlikDetailView info ->
            List.map
                (\apiary ->
                    if apiary.id == info.apiaryId then
                        { apiary | uliki = model.uliki }
                    else
                        apiary
                )
                model.apiaries

        _ ->
            model.apiaries

-- PORTS (OUT)

port jsLoginGoogle : () -> Cmd msg
port jsLogout : () -> Cmd msg
port jsDeleteAccount : String -> Cmd msg
port accountDeletionResult : (Value -> msg) -> Sub msg
port jsLoadApiaries : String -> Cmd msg
port jsCreateApiary : { name : String, apiaryType : String, uid : String } -> Cmd msg
port jsUpdateApiary : { apiaryId : String, name : String } -> Cmd msg
port jsDeleteApiary : { apiaryId : String } -> Cmd msg
port jsLoadHives : { apiaryId : String, deepLinkId : String } -> Cmd msg
port jsCreateHive : { apiaryId : String, name : String, hiveType : String, frameType : String, broodFrameType : String, broodFrameCount : Int, maxBroodFrames : Int, hasSuper : Bool, superFrameType : String, superCount : Int, superFrameCount : Int, maxSuperFrames : Int } -> Cmd msg
port jsUpdateHive : { apiaryId : String, hiveId : String, field : String, value : String } -> Cmd msg
port jsUpdateHiveFull : { apiaryId : String, hiveId : String, fields : Value } -> Cmd msg
port jsLoadUliki : { apiaryId : String, deepLinkId : String } -> Cmd msg
port jsCreateUlik : { apiaryId : String, name : String, hiveType : String } -> Cmd msg
port jsUpdateUlik : { apiaryId : String, ulikId : String, field : String, value : String } -> Cmd msg
port jsUpdateUlikFull : { apiaryId : String, ulikId : String, fields : Value } -> Cmd msg
port jsUpdateUlikName : { apiaryId : String, ulikId : String, newName : String } -> Cmd msg
port jsDeleteUlik : { apiaryId : String, ulikId : String } -> Cmd msg
port jsMoveUlik : { sourceApiaryId : String, targetApiaryId : String, ulikId : String } -> Cmd msg
port jsStartSpeechRecognition : () -> Cmd msg
port jsLoadNotes : { apiaryId : String, hiveId : String } -> Cmd msg
port jsSaveNote : { apiaryId : String, hiveId : String, text : String, authorId : String, authorEmail : String } -> Cmd msg
port jsUpdateNote : { apiaryId : String, hiveId : String, noteId : String, text : String } -> Cmd msg
port jsDeleteNote : { apiaryId : String, hiveId : String, noteId : String } -> Cmd msg
port jsUpdateHiveName : { apiaryId : String, hiveId : String, newName : String } -> Cmd msg
port jsDeleteHive : { apiaryId : String, hiveId : String } -> Cmd msg
port jsCopyText : String -> Cmd msg
port jsSaveApiaryOrders : List Apiary -> Cmd msg
port jsSaveHiveOrders : { apiaryId : String, hives : List Hive } -> Cmd msg
port jsSaveUlikOrders : { apiaryId : String, uliki : List UlikWeselny } -> Cmd msg
port jsLoadUserSettings : { uid : String, email : String } -> Cmd msg
port jsSaveUserSettings : { uid : String, email : String, frameTypes : List String, ulikTypes : List String, breedLines : List String, darkMode : Bool, language : String, hatchingToMatingDays : Int, maxUlikHistoryLimit : Int, enableTrutowiska : Bool, enablePasieczyskaTowarowe : Bool, enableQueenRearing : Bool, defaultGraftCount : Int, starterDurationDays : Int, isolationDay : Int, emergenceDay : Int } -> Cmd msg
port jsLoadQueenRearing : String -> Cmd msg
port jsCreateQueenResource : { uid : String, kind : String, fields : Value } -> Cmd msg
port jsUpdateQueenResource : { uid : String, kind : String, id : String, fields : Value } -> Cmd msg
port jsDeleteQueenResource : { uid : String, kind : String, id : String } -> Cmd msg
port jsCreatePlannedRearingBatch : { uid : String, year : String, fields : Value } -> Cmd msg
port jsStartRearingBatch : { uid : String, batchId : String, starterId : String, graftedAt : String, timeZone : String, starterDurationDays : Int, isolationDay : Int, emergenceDay : Int, schedule : Value } -> Cmd msg
port jsTransitionRearingBatch : { uid : String, batchId : String, action : String, colonyId : String, count : Int, incubatorBar : String } -> Cmd msg
port jsDeleteRearingBatch : { uid : String, batchId : String } -> Cmd msg

-- PORTS (IN)

port authStateChanged : ({ uid : String, email : String } -> msg) -> Sub msg
port apiariesReceived : (Value -> msg) -> Sub msg
port hivesReceived : (Value -> msg) -> Sub msg
port ulikiReceived : (Value -> msg) -> Sub msg
port notesReceived : (Value -> msg) -> Sub msg
port speechRecognized : (String -> msg) -> Sub msg
port operationError : (String -> msg) -> Sub msg
port successMessageReceived : (String -> msg) -> Sub msg
port todayReceived : (String -> msg) -> Sub msg
port currentEpochReceived : (Int -> msg) -> Sub msg
port userSettingsReceived : (Value -> msg) -> Sub msg
port queenRearingReceived : (Value -> msg) -> Sub msg
port korpusDropReceived : (Value -> msg) -> Sub msg
port orderDropReceived : (Value -> msg) -> Sub msg

-- MESSAGES

-- HELPER

saveSettings : User -> Model -> Cmd Msg
saveSettings user model =
    jsSaveUserSettings
        { uid = user.uid
        , email = user.email
        , frameTypes = model.frameTypes
        , ulikTypes = model.ulikTypes
        , breedLines = model.breedLines
        , darkMode = model.darkMode
        , language = languageToString model.language
        , hatchingToMatingDays = model.hatchingToMatingDays
        , maxUlikHistoryLimit = model.maxUlikHistoryLimit
        , enableTrutowiska = model.enableTrutowiska
        , enablePasieczyskaTowarowe = model.enablePasieczyskaTowarowe
        , enableQueenRearing = model.enableQueenRearing
        , defaultGraftCount = model.defaultGraftCount
        , starterDurationDays = model.starterDurationDays
        , isolationDay = model.isolationDay
        , emergenceDay = model.emergenceDay
        }


queenFormValue : String -> Model -> String
queenFormValue key model =
    Dict.get key model.queenRearingForm |> Maybe.withDefault ""


queenResourceFields : String -> Bool -> Model -> Value
queenResourceFields kind isEditing model =
    let
        field key = Encode.string (queenFormValue key model)
        identifying = [ ( "hiveNumber", field "hiveNumber" ) ]
    in
    if kind == "breederQueens" then
        Encode.object
            (identifying
                ++ [ ( "breed", field "breed" )
                   , ( "line", field "line" )
                   , ( "markingColor", field "markingColor" )
                   , ( "markingCode", field "markingCode" )
                   ]
                ++ (if isEditing then [] else [ ( "active", Encode.bool True ) ])
            )

    else if isEditing then
        Encode.object identifying

    else
        Encode.object
            (identifying
                ++ [ ( "availability", Encode.string "PUSTY" )
                   , ( "completedSeries", Encode.int 0 )
                   , ( "activeBatchId", Encode.null )
                   ]
            )

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickLoginGoogle ->
            ( model, jsLoginGoogle () )

        ClickLogout ->
            ( { model | authState = LoggedOut, viewState = LoginView, apiaries = [] }
            , jsLogout ()
            )

        ToggleDarkMode ->
            let
                newDarkMode = not model.darkMode
                newModel = { model | darkMode = newDarkMode }
                cmd =
                    case model.authState of
                        LoggedIn user ->
                            saveSettings user newModel
                        _ ->
                            Cmd.none
            in
            ( newModel, cmd )

        ChangeLanguage language ->
            let
                newModel = { model | language = language }
                cmd = case model.authState of
                    LoggedIn user -> saveSettings user newModel
                    _ -> Cmd.none
            in
            ( newModel, cmd )

        ToggleEnableTrutowiska ->
            let
                newEnable = not model.enableTrutowiska
                newFilter = if not newEnable && model.apiaryFilter == "trutowisko" then "all" else model.apiaryFilter
                disablingCurrent = not newEnable && (model.viewState == MatingApiariesView || model.previousPrimaryView == Just MatingApiariesView)
                nextView = if disablingCurrent then (if model.enablePasieczyskaTowarowe then CommercialApiariesView else SettingsView) else model.viewState
                fallbackFilter = if disablingCurrent && model.enablePasieczyskaTowarowe then "towarowe" else newFilter
                newModel = { model | enableTrutowiska = newEnable, apiaryFilter = fallbackFilter, viewState = nextView, previousPrimaryView = if disablingCurrent then Nothing else model.previousPrimaryView }
                cmd =
                    case model.authState of
                        LoggedIn user ->
                            saveSettings user newModel
                        _ ->
                            Cmd.none
            in
            ( newModel, cmd )

        ToggleEnablePasieczyskaTowarowe ->
            let
                newEnable = not model.enablePasieczyskaTowarowe
                newFilter = if not newEnable && model.apiaryFilter == "towarowe" then (if model.enableTrutowiska then "trutowisko" else "all") else model.apiaryFilter
                disablingCurrent = not newEnable && (model.viewState == CommercialApiariesView || model.previousPrimaryView == Just CommercialApiariesView)
                nextView = if disablingCurrent then (if model.enableTrutowiska then MatingApiariesView else SettingsView) else model.viewState
                fallbackFilter = if disablingCurrent && model.enableTrutowiska then "trutowisko" else newFilter
                newModel = { model | enablePasieczyskaTowarowe = newEnable, apiaryFilter = fallbackFilter, viewState = nextView, previousPrimaryView = if disablingCurrent then Nothing else model.previousPrimaryView }
                cmd =
                    case model.authState of
                        LoggedIn user ->
                            saveSettings user newModel
                        _ ->
                            Cmd.none
            in
            ( newModel, cmd )

        ToggleEnableQueenRearing ->
            let
                enabled = not model.enableQueenRearing
                disablingCurrent = not enabled && (model.viewState == QueenRearingView || model.previousPrimaryView == Just QueenRearingView)
                fallback = if disablingCurrent then (if model.enablePasieczyskaTowarowe then CommercialApiariesView else if model.enableTrutowiska then MatingApiariesView else SettingsView) else model.viewState
                fallbackFilter = if disablingCurrent then (if model.enablePasieczyskaTowarowe then "towarowe" else if model.enableTrutowiska then "trutowisko" else model.apiaryFilter) else model.apiaryFilter
                newModel = { model | enableQueenRearing = enabled, viewState = fallback, apiaryFilter = fallbackFilter, previousPrimaryView = if disablingCurrent then Nothing else model.previousPrimaryView }
                cmd =
                    case model.authState of
                        LoggedIn user -> saveSettings user newModel
                        _ -> Cmd.none
            in
            ( newModel, cmd )

        ToggleMainMenu ->
            ( { model | menuExpanded = not model.menuExpanded }, Cmd.none )

        ToggleSettingsSection section ->
            let
                newExpanded =
                    if List.member section model.expandedSettingsSections then
                        List.filter (\s -> s /= section) model.expandedSettingsSections
                    else
                        section :: model.expandedSettingsSections
            in
            ( { model | expandedSettingsSections = newExpanded }, Cmd.none )

        OpenAccountDeletion ->
            ( { model | showAccountDeletion = True, deletionPhrase = "", deletionError = Nothing }, Cmd.none )

        CloseAccountDeletion ->
            if model.deletionBusy then ( model, Cmd.none ) else ( { model | showAccountDeletion = False, deletionError = Nothing }, Cmd.none )

        UpdateDeletionPhrase phrase ->
            ( { model | deletionPhrase = phrase, deletionError = Nothing }, Cmd.none )

        SubmitAccountDeletion ->
            if model.deletionBusy then ( model, Cmd.none )
            else if model.deletionPhrase /= "Tak, usuwam konto!" then ( { model | deletionError = Just "Wpisana fraza jest nieprawidłowa." }, Cmd.none )
            else ( { model | deletionBusy = True, deletionError = Nothing }, jsDeleteAccount model.deletionPhrase )

        AccountDeletionFinished result ->
            case result of
                Ok _ ->
                    ( { model | showAccountDeletion = False, deletionBusy = False, authState = LoggedOut, viewState = LoginView, successMessage = Just (if model.language == EN then "Your account and data were deleted." else "Konto i dane zostały usunięte.") }
                    , jsLogout ()
                    )
                Err err -> ( { model | deletionBusy = False, deletionError = Just err }, Cmd.none )

        UpdateQueenSetting setting raw ->
            case String.toInt raw of
                Nothing ->
                    ( model, Cmd.none )
                Just parsed ->
                    let
                        candidate =
                            case setting of
                                "graft" ->
                                    { model | defaultGraftCount = Basics.max 1 parsed }

                                "starter" ->
                                    { model | starterDurationDays = clamp 1 10 parsed }

                                "isolation" ->
                                    { model | isolationDay = parsed }

                                _ ->
                                    { model | emergenceDay = parsed }
                        valid = candidate.isolationDay > candidate.starterDurationDays && candidate.emergenceDay >= candidate.isolationDay
                        newModel = if valid then candidate else { candidate | errorMessage = Just "Isolation must follow starter transfer and emergence must not precede isolation." }
                        cmd =
                            if valid then
                                case model.authState of
                                    LoggedIn user -> saveSettings user newModel
                                    _ -> Cmd.none
                            else
                                Cmd.none
                    in
                    ( newModel, cmd )

        AuthStateUpdated { uid, email } ->
            if uid == "" then
                ( { model | authState = LoggedOut, viewState = LoginView }, Cmd.none )
            else
                let
                    user = { uid = uid, email = email }
                in
                ( { model | authState = LoggedIn user, viewState = ApiariesView }
                , Cmd.batch [ jsLoadApiaries uid, jsLoadUserSettings { uid = uid, email = email }, jsLoadQueenRearing uid ]
                )

        LoadApiariesData uid ->
            ( model, jsLoadApiaries uid )

        UserSettingsReceived result ->
            case result of
                Ok settings ->
                    ( { model | frameTypes = settings.frameTypes, ulikTypes = settings.ulikTypes, breedLines = settings.breedLines, darkMode = settings.darkMode, language = settings.language, hatchingToMatingDays = settings.hatchingToMatingDays, maxUlikHistoryLimit = settings.maxUlikHistoryLimit, enableTrutowiska = settings.enableTrutowiska, enablePasieczyskaTowarowe = settings.enablePasieczyskaTowarowe, enableQueenRearing = settings.enableQueenRearing, defaultGraftCount = settings.defaultGraftCount, starterDurationDays = settings.starterDurationDays, isolationDay = settings.isolationDay, emergenceDay = settings.emergenceDay, queenRearingForm = Dict.insert "graftCount" (String.fromInt settings.defaultGraftCount) model.queenRearingForm }, Cmd.none )
                Err _ ->
                    ( model, Cmd.none )

        QueenRearingDataReceived result ->
            case result of
                Ok data ->
                    ( { model | queenRearingData = data }, Cmd.none )

                Err error ->
                    ( { model | errorMessage = Just ("Queen-rearing data could not be read: " ++ error) }, Cmd.none )

        QueenRearingInput key value ->
            ( { model | queenRearingForm = Dict.insert key value model.queenRearingForm }, Cmd.none )

        SaveQueenResource kind ->
            case model.authState of
                LoggedIn user ->
                    let
                        fields = queenResourceFields kind (model.editingQueenResource /= Nothing) model
                        command =
                            case model.editingQueenResource of
                                Just editing ->
                                    jsUpdateQueenResource { uid = user.uid, kind = editing.kind, id = editing.id, fields = fields }

                                Nothing ->
                                    jsCreateQueenResource { uid = user.uid, kind = kind, fields = fields }
                    in
                    ( { model | editingQueenResource = Nothing }, command )

                _ ->
                    ( model, Cmd.none )

        EditQueenResource kind id ->
            let
                pairs =
                    if kind == "breederQueens" then
                        model.queenRearingData.breederQueens
                            |> List.filter (\item -> item.id == id)
                            |> List.head
                            |> Maybe.map (\item -> [ ( "breed", item.breed ), ( "line", item.line ), ( "markingColor", item.markingColor ), ( "markingCode", item.markingCode ), ( "hiveNumber", item.hiveNumber ) ])
                            |> Maybe.withDefault []

                    else
                        let
                            colonies = if kind == "starterColonies" then model.queenRearingData.starterColonies else model.queenRearingData.finisherColonies
                        in
                        colonies
                            |> List.filter (\item -> item.id == id)
                            |> List.head
                            |> Maybe.map (\item -> [ ( "hiveNumber", item.hiveNumber ) ])
                            |> Maybe.withDefault []
            in
            ( { model | editingQueenResource = Just { kind = kind, id = id }, queenRearingForm = List.foldl (\( key, value ) form -> Dict.insert key value form) model.queenRearingForm pairs }, Cmd.none )

        RetireBreederQueen id ->
            case model.authState of
                LoggedIn user ->
                    ( model
                    , jsUpdateQueenResource { uid = user.uid, kind = "breederQueens", id = id, fields = Encode.object [ ( "active", Encode.bool False ) ] }
                    )

                _ ->
                    ( model, Cmd.none )

        DeleteQueenResource kind id ->
            case model.authState of
                LoggedIn user ->
                    ( model, jsDeleteQueenResource { uid = user.uid, kind = kind, id = id } )

                _ ->
                    ( model, Cmd.none )

        CreatePlannedRearingBatch ->
            case ( model.authState, String.toInt (queenFormValue "graftCount" model), String.toInt (String.left 4 model.currentDate) ) of
                ( LoggedIn user, Just graftCount, Just year ) ->
                    if graftCount <= 0 || queenFormValue "breederQueenId" model == "" then
                        ( { model | errorMessage = Just "Choose a breeder queen and enter a positive whole graft count." }, Cmd.none )

                    else
                    let
                        fields = Encode.object
                            [ ( "breederQueenId", Encode.string (queenFormValue "breederQueenId" model) )
                            , ( "graftCount", Encode.int graftCount )
                            , ( "createdAt", Encode.string model.currentDate )
                            ]
                    in
                    ( model, jsCreatePlannedRearingBatch { uid = user.uid, year = String.fromInt year, fields = fields } )

                _ ->
                    ( { model | errorMessage = Just "Choose a breeder queen and enter a positive whole graft count." }, Cmd.none )

        StartRearingBatch batchId ->
            case model.authState of
                LoggedIn user ->
                    let
                        defaults = { graftCount = model.defaultGraftCount, starterDurationDays = model.starterDurationDays, isolationDay = model.isolationDay, emergenceDay = model.emergenceDay }
                    in
                    case QueenDomain.calculateSchedule defaults (queenFormValue "graftedAt" model) of
                        Just schedule ->
                            ( model
                            , jsStartRearingBatch
                                { uid = user.uid
                                , batchId = batchId
                                , starterId = queenFormValue "starterId" model
                                , graftedAt = queenFormValue "graftedAt" model
                                , timeZone = queenFormValue "timeZone" model
                                , starterDurationDays = model.starterDurationDays
                                , isolationDay = model.isolationDay
                                , emergenceDay = model.emergenceDay
                                , schedule = Encode.object
                                    [ ( "starterTransferAt", Encode.string schedule.starterTransferAt )
                                    , ( "isolationAt", Encode.string schedule.isolationAt )
                                    , ( "emergenceAt", Encode.string schedule.emergenceAt )
                                    ]
                                }
                            )

                        Nothing ->
                            ( { model | errorMessage = Just "The queen-rearing schedule defaults are invalid." }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        TransitionRearingBatch batchId action ->
            case ( model.authState, String.toInt (queenFormValue "count" model) ) of
                ( LoggedIn user, Just count ) ->
                    ( model
                    , jsTransitionRearingBatch
                        { uid = user.uid
                        , batchId = batchId
                        , action = action
                        , colonyId = if action == "toFinisher" then queenFormValue "finisherId" model else ""
                        , count = count
                        , incubatorBar = queenFormValue "incubatorBar" model
                        }
                    )

                _ ->
                    ( { model | errorMessage = Just "Enter a whole-number count for this transition." }, Cmd.none )

        DeleteRearingBatch batchId ->
            case model.authState of
                LoggedIn user ->
                    ( model, jsDeleteRearingBatch { uid = user.uid, batchId = batchId } )

                _ ->
                    ( model, Cmd.none )

        ApiariesDecoded result ->
            case result of
                Ok list ->
                    ( { model | apiaries = list }, Cmd.none )
                Err err ->
                    ( { model | errorMessage = Just ("Błąd dekodowania pasieczysk: " ++ err) }, Cmd.none )

        NavigateTo state ->
            let
                nextFilter =
                    case state of
                        MatingApiariesView -> "trutowisko"
                        CommercialApiariesView -> "towarowe"
                        _ -> model.apiaryFilter
                cmds =
                    case state of
                        HiveListView { apiaryId } ->
                            jsLoadHives { apiaryId = apiaryId, deepLinkId = "" }
                        UlikListView { apiaryId } ->
                            jsLoadUliki { apiaryId = apiaryId, deepLinkId = "" }
                        HiveDetailView { apiaryId, hiveId } ->
                            jsLoadNotes { apiaryId = apiaryId, hiveId = hiveId }
                        UlikDetailView { apiaryId, ulikId } ->
                            Cmd.none
                        _ ->
                            Cmd.none
            in
            ( { model | apiaries = syncApiaryContents model, viewState = state, apiaryFilter = nextFilter, newApiaryType = nextFilter, ulikFilter = "all", ulikActionRequiredOnly = False, menuExpanded = False, previousPrimaryView = if state == SettingsView then Just model.viewState else Nothing }, cmds )

        NavigateCard state ->
            if model.suppressCardClick then
                ( { model | suppressCardClick = False }, Cmd.none )
            else
                update (NavigateTo state) model

        ResetCardClickSuppression ->
            ( { model | suppressCardClick = False }, Cmd.none )

        OpenNewApiaryModal ->
            ( { model | showNewApiaryModal = True, newApiaryName = "", newApiaryType = if model.viewState == MatingApiariesView then "trutowisko" else if model.viewState == CommercialApiariesView then "towarowe" else if model.enablePasieczyskaTowarowe then "towarowe" else "trutowisko" }, Cmd.none )

        SetApiaryFilter filter ->
            ( { model | apiaryFilter = filter }, Cmd.none )

        SetUlikFilter filter ->
            ( { model | ulikFilter = filter }, Cmd.none )

        ToggleUlikActionRequiredOnly ->
            ( { model | ulikActionRequiredOnly = not model.ulikActionRequiredOnly }, Cmd.none )

        UpdateNewFrameTypeInput val ->
            ( { model | newFrameTypeInput = val }, Cmd.none )

        AddFrameType ft ->
            if String.trim ft /= "" && not (List.member (String.trim ft) model.frameTypes) then
                let
                    updated = model.frameTypes ++ [ String.trim ft ]
                    newModel = { model | frameTypes = updated, newFrameTypeInput = "" }
                    cmd =
                        case model.authState of
                            LoggedIn user ->
                                saveSettings user newModel
                            _ ->
                                Cmd.none
                in
                ( newModel, cmd )
            else
                ( { model | newFrameTypeInput = "" }, Cmd.none )

        RemoveFrameType ft ->
            let
                updated = List.filter (\x -> x /= ft) model.frameTypes
                newModel = { model | frameTypes = updated }
                cmd =
                    case model.authState of
                        LoggedIn user ->
                            saveSettings user newModel
                        _ ->
                            Cmd.none
            in
            ( newModel, cmd )

        UpdateNewUlikTypeInput val ->
            ( { model | newUlikTypeInput = val }, Cmd.none )

        AddUlikType ut ->
            if String.trim ut /= "" && not (List.member (String.trim ut) model.ulikTypes) then
                let
                    updated = model.ulikTypes ++ [ String.trim ut ]
                    newModel = { model | ulikTypes = updated, newUlikTypeInput = "" }
                    cmd =
                        case model.authState of
                            LoggedIn user ->
                                saveSettings user newModel
                            _ ->
                                Cmd.none
                in
                ( newModel, cmd )
            else
                ( { model | newUlikTypeInput = "" }, Cmd.none )

        RemoveUlikType ut ->
            let
                updated = List.filter (\x -> x /= ut) model.ulikTypes
                newModel = { model | ulikTypes = updated }
                cmd =
                    case model.authState of
                        LoggedIn user ->
                            saveSettings user newModel
                        _ ->
                            Cmd.none
            in
            ( newModel, cmd )

        UpdateNewBreedLineInput val ->
            ( { model | newBreedLineInput = val }, Cmd.none )

        AddBreedLine bl ->
            if String.trim bl /= "" && not (List.member (String.trim bl) model.breedLines) then
                let
                    updated = model.breedLines ++ [ String.trim bl ]
                    newModel = { model | breedLines = updated, newBreedLineInput = "" }
                    cmd =
                        case model.authState of
                            LoggedIn user ->
                                saveSettings user newModel
                            _ ->
                                Cmd.none
                in
                ( newModel, cmd )
            else
                ( { model | newBreedLineInput = "" }, Cmd.none )

        RemoveBreedLine bl ->
            let
                updated = List.filter (\x -> x /= bl) model.breedLines
                newModel = { model | breedLines = updated }
                cmd =
                    case model.authState of
                        LoggedIn user ->
                            saveSettings user newModel
                        _ ->
                            Cmd.none
            in
            ( newModel, cmd )

        UpdateHatchingToMatingDaysInput str ->
            let
                val = case String.toInt str of
                    Just n ->
                        if n < 1 then 1 else if n > 30 then 30 else n
                    Nothing ->
                        model.hatchingToMatingDays
                newModel = { model | hatchingToMatingDays = val }
                cmd =
                    case model.authState of
                        LoggedIn user ->
                            saveSettings user newModel
                        _ ->
                            Cmd.none
            in
            ( newModel, cmd )

        UpdateMaxUlikHistoryLimitInput str ->
            let
                val = case String.toInt str of
                    Just n ->
                        if n < 10 then 10 else if n > 60 then 60 else n
                    Nothing ->
                        model.maxUlikHistoryLimit
                newModel = { model | maxUlikHistoryLimit = val }
                cmd =
                    case model.authState of
                        LoggedIn user ->
                            saveSettings user newModel
                        _ ->
                            Cmd.none
            in
            ( newModel, cmd )

        CloseNewApiaryModal ->
            ( { model | showNewApiaryModal = False }, Cmd.none )

        UpdateNewApiaryName name ->
            ( { model | newApiaryName = name }, Cmd.none )

        UpdateNewApiaryType t ->
            ( { model | newApiaryType = t }, Cmd.none )

        SubmitCreateApiary ->
            case model.authState of
                LoggedIn user ->
                    ( { model | showNewApiaryModal = False }
                    , jsCreateApiary { name = model.newApiaryName, apiaryType = model.newApiaryType, uid = user.uid }
                    )
                _ ->
                    ( model, Cmd.none )

        OpenEditApiaryModal apiary ->
            ( { model | showEditApiaryModal = Just apiary, editApiaryNameInput = apiary.name }, Cmd.none )

        CloseEditApiaryModal ->
            ( { model | showEditApiaryModal = Nothing }, Cmd.none )

        UpdateEditApiaryNameInput name ->
            ( { model | editApiaryNameInput = name }, Cmd.none )

        SubmitUpdateApiary ->
            case model.showEditApiaryModal of
                Just apiary ->
                    ( { model | showEditApiaryModal = Nothing }
                    , jsUpdateApiary { apiaryId = apiary.id, name = model.editApiaryNameInput }
                    )
                Nothing ->
                    ( model, Cmd.none )

        OpenDeleteApiaryModal apiary ->
            ( { model | showDeleteApiaryModal = Just apiary }, Cmd.none )

        CloseDeleteApiaryModal ->
            ( { model | showDeleteApiaryModal = Nothing }, Cmd.none )

        SubmitDeleteApiary apiaryId ->
            ( { model | showDeleteApiaryModal = Nothing }
            , jsDeleteApiary { apiaryId = apiaryId }
            )

        HivesDecoded result ->
            case result of
                Ok list ->
                    let
                        updatedApiaries = syncApiaryContents { model | hives = list }
                        (updatedModel, extraCmd) =
                            case model.pendingDeepLink of
                                Just (PendingHive { apiaryId, hiveId }) ->
                                    let
                                        maybeHive = List.head (List.filter (\h -> h.id == hiveId) list)
                                        hiveName = Maybe.withDefault "" (Maybe.map .name maybeHive)
                                        actualApiaryId = case maybeHive of
                                            Just h -> if h.apiaryId /= "" then h.apiaryId else apiaryId
                                            Nothing -> apiaryId
                                    in
                                    ( { model | hives = list, apiaries = updatedApiaries, pendingDeepLink = Nothing, viewState = HiveDetailView { apiaryId = actualApiaryId, hiveId = hiveId, hiveName = hiveName } }
                                    , jsLoadNotes { apiaryId = actualApiaryId, hiveId = hiveId }
                                    )
                                _ ->
                                    ( { model | hives = list, apiaries = updatedApiaries }, Cmd.none )
                    in
                    ( updatedModel, extraCmd )
                Err err ->
                    ( { model | errorMessage = Just ("Błąd dekodowania uli: " ++ err) }, Cmd.none )

        UlikiDecoded result ->
            case result of
                Ok list ->
                    let
                        updatedApiaries = syncApiaryContents { model | uliki = list }
                        (updatedModel, extraCmd) =
                            case model.pendingDeepLink of
                                Just (PendingUlik { apiaryId, ulikId }) ->
                                    let
                                        maybeUlik = List.head (List.filter (\u -> u.id == ulikId) list)
                                        ulikName = Maybe.withDefault "" (Maybe.map .name maybeUlik)
                                        actualApiaryId = case maybeUlik of
                                            Just u -> if u.apiaryId /= "" then u.apiaryId else apiaryId
                                            Nothing -> apiaryId
                                    in
                                    ( { model | uliki = list, apiaries = updatedApiaries, pendingDeepLink = Nothing, viewState = UlikDetailView { apiaryId = actualApiaryId, ulikId = ulikId, ulikName = ulikName } }
                                    , Cmd.none
                                    )
                                _ ->
                                    ( { model | uliki = list, apiaries = updatedApiaries }, Cmd.none )
                    in
                    ( updatedModel, extraCmd )
                Err err ->
                    ( { model | errorMessage = Just ("Błąd dekodowania ulików weselnych: " ++ err) }, Cmd.none )

        OpenNewHiveModal ->
            ( { model
                | showNewHiveModal = True
                , newHiveName = ""
                , newHiveType = "korpusowy"
                , newHiveFrameType = "Wielkopolska"
                , newHiveBroodFrameType = "Wielkopolska"
                , newHiveBroodFrameCount = 10
                , newHiveMaxBroodFrames = 24
                , newHiveHasSuper = False
                , newHiveSuperFrameType = "Wielkopolska 1/2"
                , newHiveSuperCount = 1
                , newHiveSuperFrameCount = 10
                , newHiveMaxSuperFrames = 18
              }
            , Cmd.none
            )

        CloseNewHiveModal ->
            ( { model | showNewHiveModal = False }, Cmd.none )

        UpdateNewHiveName name ->
            ( { model | newHiveName = name }, Cmd.none )

        UpdateNewHiveType ht ->
            ( { model | newHiveType = ht }, Cmd.none )

        UpdateNewHiveFrameType ft ->
            ( { model | newHiveFrameType = ft }, Cmd.none )

        UpdateNewHiveBroodFrameType bft ->
            ( { model | newHiveBroodFrameType = bft }, Cmd.none )

        UpdateNewHiveBroodFrameCount bfc ->
            ( { model | newHiveBroodFrameCount = bfc }, Cmd.none )

        UpdateNewHiveMaxBroodFrames mbf ->
            ( { model | newHiveMaxBroodFrames = mbf }, Cmd.none )

        UpdateNewHiveHasSuper hs ->
            ( { model | newHiveHasSuper = hs }, Cmd.none )

        UpdateNewHiveSuperFrameType sft ->
            ( { model | newHiveSuperFrameType = sft }, Cmd.none )

        UpdateNewHiveSuperCount sc ->
            ( { model | newHiveSuperCount = Basics.max 0 sc }, Cmd.none )

        UpdateNewHiveSuperFrameCount sfc ->
            ( { model | newHiveSuperFrameCount = sfc }, Cmd.none )

        UpdateNewHiveMaxSuperFrames msf ->
            ( { model | newHiveMaxSuperFrames = msf }, Cmd.none )

        SubmitCreateHive apiaryId ->
            ( { model | showNewHiveModal = False }
            , jsCreateHive
                { apiaryId = apiaryId
                , name = model.newHiveName
                , hiveType = model.newHiveType
                , frameType = model.newHiveFrameType
                , broodFrameType = model.newHiveBroodFrameType
                , broodFrameCount = model.newHiveBroodFrameCount
                , maxBroodFrames = model.newHiveMaxBroodFrames
                , hasSuper = model.newHiveHasSuper
                , superFrameType = model.newHiveSuperFrameType
                , superCount = Basics.max 0 model.newHiveSuperCount
                , superFrameCount = model.newHiveSuperFrameCount
                , maxSuperFrames = model.newHiveMaxSuperFrames
                }
            )

        OpenNewUlikModal ->
            ( { model | showNewUlikModal = True, newUlikName = "", newUlikHiveType = Maybe.withDefault "Mini plus" (List.head model.ulikTypes) }, Cmd.none )

        CloseNewUlikModal ->
            ( { model | showNewUlikModal = False }, Cmd.none )

        UpdateNewUlikName name ->
            ( { model | newUlikName = name }, Cmd.none )

        UpdateNewUlikHiveType ht ->
            ( { model | newUlikHiveType = ht }, Cmd.none )

        SubmitCreateUlik apiaryId ->
            ( { model | showNewUlikModal = False }
            , jsCreateUlik { apiaryId = apiaryId, name = model.newUlikName, hiveType = model.newUlikHiveType }
            )

        CurrentDateReceived dateStr ->
            ( { model | currentDate = dateStr }, Cmd.none )

        CurrentEpochReceived epoch ->
            ( { model | currentEpoch = epoch }, Cmd.none )

        UpdateHiveField apiaryId hiveId field value ->
            let
                updateHiveRecord h =
                    if h.id == hiveId then
                        case field of
                            "name" ->
                                { h | name = value }

                            "hiveType" ->
                                { h | hiveType = value }

                            "frameType" ->
                                { h | frameType = value }

                            "broodFrameType" ->
                                { h | broodFrameType = value }

                            "broodFrameCount" ->
                                { h | broodFrameCount = Maybe.withDefault h.broodFrameCount (String.toInt value) }

                            "maxBroodFrames" ->
                                { h | maxBroodFrames = Maybe.withDefault h.maxBroodFrames (String.toInt value) }

                            "hasSuper" ->
                                { h | hasSuper = value == "true" }

                            "superFrameType" ->
                                { h | superFrameType = value }

                            "superCount" ->
                                { h | superCount = Maybe.withDefault h.superCount (String.toInt value) }

                            "superFrameCount" ->
                                { h | superFrameCount = Maybe.withDefault h.superFrameCount (String.toInt value) }

                            "maxSuperFrames" ->
                                { h | maxSuperFrames = Maybe.withDefault h.maxSuperFrames (String.toInt value) }

                            "pollenTrap" ->
                                { h | pollenTrap = value }

                            "queen.hasOpalit" ->
                                let
                                    q = h.queen
                                in
                                { h | queen = { q | hasOpalit = value == "true" } }

                            "queen.color" ->
                                let
                                    q = h.queen
                                in
                                { h | queen = { q | color = value } }

                            "queen.number" ->
                                let
                                    q = h.queen
                                in
                                { h | queen = { q | number = value } }

                            _ ->
                                h

                    else
                        h

                updatedHives =
                    List.map updateHiveRecord model.hives
            in
            ( { model | hives = updatedHives }, jsUpdateHive { apiaryId = apiaryId, hiveId = hiveId, field = field, value = value } )

        AddKorpusAbove apiaryId hiveId korpusId ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
                korpusy = case maybeHive of
                    Just h -> h.korpusy
                    Nothing -> [ { id = "1", hasQueen = False, hasExcluderAbove = False, hasFoilAbove = False, hasOpenEntrance = False } ]
                newKorpusy = addKorpusAbove korpusId korpusy
            in
            updateKorpusyForHive apiaryId hiveId newKorpusy model

        AddKorpusBelow apiaryId hiveId korpusId ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
                korpusy = case maybeHive of
                    Just h -> h.korpusy
                    Nothing -> [ { id = "1", hasQueen = False, hasExcluderAbove = False, hasFoilAbove = False, hasOpenEntrance = False } ]
                newKorpusy = addKorpusBelow korpusId korpusy
            in
            updateKorpusyForHive apiaryId hiveId newKorpusy model

        AddKorpusBetween apiaryId hiveId idx ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
                korpusy = case maybeHive of
                    Just h -> h.korpusy
                    Nothing -> [ { id = "1", hasQueen = False, hasExcluderAbove = False, hasFoilAbove = False, hasOpenEntrance = False } ]
                newKorpusy = addKorpusBetween idx korpusy
            in
            updateKorpusyForHive apiaryId hiveId newKorpusy model

        DeleteKorpus apiaryId hiveId korpusId ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
                korpusy = case maybeHive of
                    Just h -> h.korpusy
                    Nothing -> [ { id = "1", hasQueen = False, hasExcluderAbove = False, hasFoilAbove = False, hasOpenEntrance = False } ]
                newKorpusy = deleteKorpus korpusId korpusy
            in
            updateKorpusyForHive apiaryId hiveId newKorpusy model

        ToggleKorpusQueen apiaryId hiveId korpusId ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
                korpusy = case maybeHive of
                    Just h -> h.korpusy
                    Nothing -> [ { id = "1", hasQueen = False, hasExcluderAbove = False, hasFoilAbove = False, hasOpenEntrance = False } ]
                newKorpusy = toggleKorpusQueen korpusId korpusy
            in
            updateKorpusyForHive apiaryId hiveId newKorpusy model

        ToggleKorpusExcluder apiaryId hiveId korpusId ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
                korpusy = case maybeHive of
                    Just h -> h.korpusy
                    Nothing -> [ { id = "1", hasQueen = False, hasExcluderAbove = False, hasFoilAbove = False, hasOpenEntrance = False } ]
                newKorpusy = toggleKorpusExcluder korpusId korpusy
            in
            updateKorpusyForHive apiaryId hiveId newKorpusy model

        ToggleKorpusFoil apiaryId hiveId korpusId ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
                korpusy = case maybeHive of
                    Just h -> h.korpusy
                    Nothing -> [ { id = "1", hasQueen = False, hasExcluderAbove = False, hasFoilAbove = False, hasOpenEntrance = False } ]
                newKorpusy = toggleKorpusFoil korpusId korpusy
            in
            updateKorpusyForHive apiaryId hiveId newKorpusy model

        ToggleKorpusEntrance apiaryId hiveId korpusId ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
                korpusy = case maybeHive of
                    Just h -> h.korpusy
                    Nothing -> [ { id = "1", hasQueen = False, hasExcluderAbove = False, hasFoilAbove = False, hasOpenEntrance = False } ]
                newKorpusy = toggleKorpusEntrance korpusId korpusy
            in
            updateKorpusyForHive apiaryId hiveId newKorpusy model

        StartKorpusDrag korpusId ->
            ( { model | draggedKorpusId = Just korpusId }, Cmd.none )

        StartOrderDrag collection apiaryId id ->
            ( { model | draggedOrderItem = Just { collection = collection, apiaryId = apiaryId, id = id }, suppressCardClick = False }, Cmd.none )

        OrderDragOver _ _ _ ->
            ( model, Cmd.none )

        EndOrderDrag ->
            ( { model | draggedOrderItem = Nothing }, Cmd.none )

        OrderDropReceived payload ->
            case Decode.decodeValue decodeOrderDrop payload of
                Ok drop ->
                    let
                        dragModel = { model | draggedOrderItem = Just { collection = drop.collection, apiaryId = drop.apiaryId, id = drop.draggedId } }
                    in
                    reorderDraggedItem drop.collection drop.apiaryId drop.targetId drop.after dragModel

                Err _ ->
                    ( { model | draggedOrderItem = Nothing }, Cmd.none )

        DropKorpusOn apiaryId hiveId targetKorpusId ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
            in
            case ( model.draggedKorpusId, maybeHive ) of
                ( Just draggedKorpusId, Just hive ) ->
                    let
                        reordered = moveKorpusBefore draggedKorpusId targetKorpusId hive.korpusy
                        clearedModel = { model | draggedKorpusId = Nothing }
                    in
                    if reordered == hive.korpusy then
                        ( clearedModel, Cmd.none )
                    else
                        updateKorpusyForHive apiaryId hiveId reordered clearedModel

                _ ->
                    ( { model | draggedKorpusId = Nothing }, Cmd.none )

        DropKorpusAfter apiaryId hiveId targetKorpusId ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
            in
            case ( model.draggedKorpusId, maybeHive ) of
                ( Just draggedKorpusId, Just hive ) ->
                    let
                        reordered = moveKorpusAfter draggedKorpusId targetKorpusId hive.korpusy
                        clearedModel = { model | draggedKorpusId = Nothing }
                    in
                    if reordered == hive.korpusy then
                        ( clearedModel, Cmd.none )
                    else
                        updateKorpusyForHive apiaryId hiveId reordered clearedModel

                _ ->
                    ( { model | draggedKorpusId = Nothing }, Cmd.none )

        EndKorpusDrag ->
            ( { model | draggedKorpusId = Nothing }, Cmd.none )

        KorpusDropReceived payload ->
            case Decode.decodeValue
                (Decode.map4 (\apiaryId hiveId korpusId after -> { apiaryId = apiaryId, hiveId = hiveId, korpusId = korpusId, after = after })
                    (Decode.field "apiaryId" Decode.string)
                    (Decode.field "hiveId" Decode.string)
                    (Decode.field "korpusId" Decode.string)
                    (Decode.field "after" Decode.bool)
                )
                payload of
                Ok drop ->
                    update (if drop.after then DropKorpusAfter drop.apiaryId drop.hiveId drop.korpusId else DropKorpusOn drop.apiaryId drop.hiveId drop.korpusId) model

                Err _ ->
                    ( { model | draggedKorpusId = Nothing }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        UpdateUlikField apiaryId ulikId field value ->
            let
                updatedUliki =
                    List.map
                        (\u ->
                            if u.id == ulikId then
                                if field == "expectedHatchDate" then
                                    { u | expectedHatchDate = value, expectedMatingDate = addDaysToDateString model.hatchingToMatingDays value }
                                else if field == "expectedMatingDate" then
                                    { u | expectedMatingDate = value }
                                else if field == "name" then
                                    { u | name = value }
                                else if field == "hiveType" then
                                    { u | hiveType = value }
                                else if field == "hasQueen" then
                                    { u | hasQueen = (String.toLower value == "true") }
                                else if String.startsWith "queen." field then
                                    let
                                        q = u.queen
                                        qField = String.dropLeft 6 field
                                        newQ =
                                            if qField == "breedLine" then { q | breedLine = value }
                                            else if qField == "hasOpalit" then { q | hasOpalit = (String.toLower value == "true") }
                                            else if qField == "color" then { q | color = value }
                                            else if qField == "number" then { q | number = value }
                                            else q
                                    in
                                    { u | queen = newQ }
                                else
                                    u
                            else
                                u
                        )
                        model.uliki

                cmds =
                    if field == "expectedHatchDate" then
                        [ jsUpdateUlik { apiaryId = apiaryId, ulikId = ulikId, field = "expectedHatchDate", value = value }
                        , jsUpdateUlik { apiaryId = apiaryId, ulikId = ulikId, field = "expectedMatingDate", value = addDaysToDateString model.hatchingToMatingDays value }
                        ]
                    else
                        [ jsUpdateUlik { apiaryId = apiaryId, ulikId = ulikId, field = field, value = value }
                        ]
            in
            ( { model | uliki = updatedUliki }, Cmd.batch cmds )

        OpenUlikModal apiaryId ulikId modalType ->
            ( { model
                | activeUlikModal = Just { apiaryId = apiaryId, ulikId = ulikId, modalType = modalType }
                , modalBreedLine = Maybe.withDefault "" (List.head model.breedLines)
                , modalHatchDate = if model.currentDate /= "" then model.currentDate else "2026-11-03"
                , modalIsOpalitkovana = "Nie"
                , modalOpalitColor = "Biały"
                , modalOpalitNumber = ""
              }
            , Cmd.none
            )

        CloseUlikModal ->
            ( { model | activeUlikModal = Nothing }, Cmd.none )

        UpdateModalBreedLine val ->
            ( { model | modalBreedLine = val }, Cmd.none )

        UpdateModalHatchDate val ->
            ( { model | modalHatchDate = val }, Cmd.none )

        UpdateModalIsOpalitkovana val ->
            ( { model | modalIsOpalitkovana = val }, Cmd.none )

        UpdateModalOpalitColor val ->
            ( { model | modalOpalitColor = val }, Cmd.none )

        UpdateModalOpalitNumber val ->
            ( { model | modalOpalitNumber = val }, Cmd.none )

        SubmitUlikModal apiaryId ulikId modalType ->
            let
                maybeUlik = List.head (List.filter (\u -> u.id == ulikId) model.uliki)
            in
            case maybeUlik of
                Just u ->
                    let
                        timestamp = if model.currentDate /= "" then model.currentDate else "2026-11-03"
                        transition =
                            case modalType of
                                ModalPoddajMatecznik ->
                                    { stateStr = "z_matecznikiem", desc = "Poddano matecznik", hasQueen = True, queen = { breedLine = model.modalBreedLine, hasOpalit = False, color = "", number = "" }, expectedHatchDate = model.modalHatchDate, expectedMatingDate = addDaysToDateString model.hatchingToMatingDays model.modalHatchDate }
                                ModalPoddajMatkeNieunasiennioną ->
                                    let
                                        hasOpalit = model.modalIsOpalitkovana == "Tak"
                                    in
                                    { stateStr = "matka_wygryziona", desc = "Poddano matkę nieunasiennioną", hasQueen = True, queen = { breedLine = model.modalBreedLine, hasOpalit = hasOpalit, color = if hasOpalit then model.modalOpalitColor else "", number = if hasOpalit then model.modalOpalitNumber else "" }, expectedHatchDate = model.modalHatchDate, expectedMatingDate = addDaysToDateString model.hatchingToMatingDays model.modalHatchDate }
                                ModalZaopalitkuj ->
                                    { stateStr = u.state, desc = "Zaopalitkowano matkę", hasQueen = True, queen = { breedLine = u.queen.breedLine, hasOpalit = True, color = model.modalOpalitColor, number = model.modalOpalitNumber }, expectedHatchDate = u.expectedHatchDate, expectedMatingDate = u.expectedMatingDate }

                        historyEntry =
                            { timestamp = timestamp
                            , prevState = u.state
                            , state = transition.stateStr
                            , description = transition.desc
                            , breedLine = transition.queen.breedLine
                            , expectedHatchDate = transition.expectedHatchDate
                            , expectedMatingDate = transition.expectedMatingDate
                            , hasOpalit = transition.queen.hasOpalit
                            , color = transition.queen.color
                            , number = transition.queen.number
                            }

                        updatedUlik =
                            { u
                            | state = transition.stateStr
                            , hasQueen = transition.hasQueen
                            , queen = transition.queen
                            , expectedHatchDate = transition.expectedHatchDate
                            , expectedMatingDate = transition.expectedMatingDate
                            , history = List.take model.maxUlikHistoryLimit (historyEntry :: u.history)
                            }

                        updatedUliki =
                            List.map (\x -> if x.id == ulikId then updatedUlik else x) model.uliki
                    in
                    ( { model | uliki = updatedUliki, activeUlikModal = Nothing }
                    , jsUpdateUlikFull { apiaryId = apiaryId, ulikId = ulikId, fields = encodeUlikFields updatedUlik }
                    )
                Nothing ->
                    ( { model | activeUlikModal = Nothing }, Cmd.none )

        TransitionUlikState apiaryId ulikId newState ->
            let
                maybeUlik = List.head (List.filter (\u -> u.id == ulikId) model.uliki)
            in
            case maybeUlik of
                Just u ->
                    let
                        timestamp = if model.currentDate /= "" then model.currentDate else "2026-11-03"
                        newStateStr = ulikStateToString newState
                        isReset = newState == Bezmatek || newState == PustyUlik
                        desc =
                            case newState of
                                Bezmatek -> "Zabrano matkę / zresetowano stan"
                                ZMatecznikiem -> "Poddano matecznik"
                                MatkaWygryziona -> "Matka się wygryzła"
                                MatkaCzerwi -> "Matka się unasienniła (UNC)"
                                PustyUlik -> "Opróżniono ulik (P)"

                        transition =
                            if isReset then
                                { hasQueen = False, queen = { breedLine = "", hasOpalit = False, color = "", number = "" }, expectedHatchDate = "", expectedMatingDate = "" }
                            else
                                { hasQueen = u.hasQueen, queen = u.queen, expectedHatchDate = u.expectedHatchDate, expectedMatingDate = u.expectedMatingDate }

                        historyEntry =
                            { timestamp = timestamp
                            , prevState = u.state
                            , state = newStateStr
                            , description = desc
                            , breedLine = transition.queen.breedLine
                            , expectedHatchDate = transition.expectedHatchDate
                            , expectedMatingDate = transition.expectedMatingDate
                            , hasOpalit = transition.queen.hasOpalit
                            , color = transition.queen.color
                            , number = transition.queen.number
                            }

                        updatedUlik =
                            { u
                            | state = newStateStr
                            , hasQueen = transition.hasQueen
                            , queen = transition.queen
                            , expectedHatchDate = transition.expectedHatchDate
                            , expectedMatingDate = transition.expectedMatingDate
                            , history = List.take model.maxUlikHistoryLimit (historyEntry :: u.history)
                            }

                        updatedUliki =
                            List.map (\x -> if x.id == ulikId then updatedUlik else x) model.uliki
                    in
                    ( { model | uliki = updatedUliki }
                    , jsUpdateUlikFull { apiaryId = apiaryId, ulikId = ulikId, fields = encodeUlikFields updatedUlik }
                    )
                Nothing ->
                    ( model, Cmd.none )

        NotesDecoded result ->
            case result of
                Ok list ->
                    ( { model | notes = list }, Cmd.none )
                Err err ->
                    ( { model | errorMessage = Just ("Błąd dekodowania notatek: " ++ err) }, Cmd.none )

        UpdateNewNoteText text ->
            ( { model | newNoteText = text }, Cmd.none )

        StartSpeechDictation ->
            ( model, jsStartSpeechRecognition () )

        SpeechResultReceived text ->
            ( { model | newNoteText = model.newNoteText ++ " " ++ text }, Cmd.none )

        SubmitSaveNote apiaryId hiveId text authorId authorEmail ->
            if String.isEmpty text then
                ( model, Cmd.none )
            else
                ( { model | newNoteText = "" }
                , jsSaveNote { apiaryId = apiaryId, hiveId = hiveId, text = text, authorId = authorId, authorEmail = authorEmail }
                )

        StartEditNote note ->
            ( { model | editingNoteId = Just note.id, editNoteText = note.text }, Cmd.none )

        CancelEditNote ->
            ( { model | editingNoteId = Nothing, editNoteText = "" }, Cmd.none )

        UpdateEditNoteText text ->
            ( { model | editNoteText = text }, Cmd.none )

        SubmitUpdateNote apiaryId hiveId noteId ->
            if String.isEmpty model.editNoteText then
                ( model, Cmd.none )
            else
                ( { model | editingNoteId = Nothing, editNoteText = "" }
                , jsUpdateNote { apiaryId = apiaryId, hiveId = hiveId, noteId = noteId, text = model.editNoteText }
                )

        SubmitDeleteNote apiaryId hiveId noteId ->
            ( model, jsDeleteNote { apiaryId = apiaryId, hiveId = hiveId, noteId = noteId } )

        OpenRenameHiveModal apiaryId hive ->
            ( { model | showRenameHiveModal = Just { apiaryId = apiaryId, hiveId = hive.id, hiveName = hive.name }, renameHiveInput = hive.name }, Cmd.none )

        CloseRenameHiveModal ->
            ( { model | showRenameHiveModal = Nothing, renameHiveInput = "" }, Cmd.none )

        UpdateRenameHiveInput val ->
            ( { model | renameHiveInput = val }, Cmd.none )

        SubmitRenameHive apiaryId hiveId ->
            ( { model | showRenameHiveModal = Nothing, renameHiveInput = "" }
            , jsUpdateHiveName { apiaryId = apiaryId, hiveId = hiveId, newName = model.renameHiveInput }
            )

        OpenDeleteHiveModal apiaryId hive ->
            ( { model | showDeleteHiveModal = Just { apiaryId = apiaryId, hiveId = hive.id, hiveName = hive.name } }, Cmd.none )

        CloseDeleteHiveModal ->
            ( { model | showDeleteHiveModal = Nothing }, Cmd.none )

        SubmitDeleteHive apiaryId hiveId ->
            ( { model | showDeleteHiveModal = Nothing }
            , jsDeleteHive { apiaryId = apiaryId, hiveId = hiveId }
            )

        OpenRenameUlikModal apiaryId ulik ->
            ( { model | showRenameUlikModal = Just { apiaryId = apiaryId, ulikId = ulik.id, ulikName = ulik.name }, renameUlikInput = ulik.name }, Cmd.none )

        CloseRenameUlikModal ->
            ( { model | showRenameUlikModal = Nothing, renameUlikInput = "" }, Cmd.none )

        UpdateRenameUlikInput val ->
            ( { model | renameUlikInput = val }, Cmd.none )

        SubmitRenameUlik apiaryId ulikId ->
            ( { model | showRenameUlikModal = Nothing, renameUlikInput = "" }
            , jsUpdateUlikName { apiaryId = apiaryId, ulikId = ulikId, newName = model.renameUlikInput }
            )

        OpenDeleteUlikModal apiaryId ulik ->
            ( { model | showDeleteUlikModal = Just { apiaryId = apiaryId, ulikId = ulik.id, ulikName = ulik.name } }, Cmd.none )

        CloseDeleteUlikModal ->
            ( { model | showDeleteUlikModal = Nothing }, Cmd.none )

        SubmitDeleteUlik apiaryId ulikId ->
            ( { model | showDeleteUlikModal = Nothing }
            , jsDeleteUlik { apiaryId = apiaryId, ulikId = ulikId }
            )

        OpenMoveUlikModal sourceApiaryId ulik ->
            let
                otherTrutowiska =
                    List.filter (\a -> a.apiaryType == "trutowisko" && a.id /= sourceApiaryId) model.apiaries
                firstId =
                    case otherTrutowiska of
                        a :: _ -> a.id
                        [] -> ""
            in
            ( { model | showMoveUlikModal = Just { sourceApiaryId = sourceApiaryId, ulikId = ulik.id, ulikName = ulik.name }, moveUlikTargetApiaryId = firstId }, Cmd.none )

        CloseMoveUlikModal ->
            ( { model | showMoveUlikModal = Nothing, moveUlikTargetApiaryId = "" }, Cmd.none )

        SelectMoveUlikTargetApiary targetId ->
            ( { model | moveUlikTargetApiaryId = targetId }, Cmd.none )

        SubmitMoveUlik sourceApiaryId ulikId targetApiaryId ->
            if targetApiaryId == "" then
                ( model, Cmd.none )
            else
                let
                    apiaryName =
                        case List.head (List.filter (\a -> a.id == sourceApiaryId) model.apiaries) of
                            Just a -> a.name
                            Nothing -> "Trutowisko"

                    (updatedModel, navCmd) =
                        update (NavigateTo (UlikListView { apiaryId = sourceApiaryId, apiaryName = apiaryName })) { model | showMoveUlikModal = Nothing, moveUlikTargetApiaryId = "" }
                in
                ( updatedModel
                , Cmd.batch
                    [ navCmd
                    , jsMoveUlik { sourceApiaryId = sourceApiaryId, targetApiaryId = targetApiaryId, ulikId = ulikId }
                    ]
                )

        UpdatePollenTrap apiaryId hiveId trap ->
            let
                updatedHives =
                    List.map (\h -> if h.id == hiveId then { h | pollenTrap = trap } else h) model.hives
            in
            ( { model | hives = updatedHives }, jsUpdateHive { apiaryId = apiaryId, hiveId = hiveId, field = "pollenTrap", value = trap } )

        CopyText text ->
            ( model, jsCopyText text )

        SubmitHiveSnapshot apiaryId hiveId user ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
                snapshotText = case maybeHive of
                    Just hive -> hiveSnapshotText hive
                    Nothing -> "Brak danych ula"
            in
            ( { model | successMessage = Just "📸 Zapisano zrzut ula jako notatkę!" }
            , jsSaveNote
                { apiaryId = apiaryId
                , hiveId = hiveId
                , text = snapshotText
                , authorId = user.uid
                , authorEmail = user.email
                }
            )

        HandleError err ->
            ( { model | errorMessage = Just err }, Cmd.none )

        SuccessMessageReceived successText ->
            ( { model | successMessage = Just successText }, Cmd.none )

        ClearMessages ->
            ( { model | errorMessage = Nothing, successMessage = Nothing }, Cmd.none )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ authStateChanged (\val -> AuthStateUpdated val)
        , apiariesReceived (\val -> ApiariesDecoded (Result.mapError Decode.errorToString (Decode.decodeValue decodeApiaries val)))
        , hivesReceived (\val -> HivesDecoded (Result.mapError Decode.errorToString (Decode.decodeValue decodeHives val)))
        , ulikiReceived (\val -> UlikiDecoded (Result.mapError Decode.errorToString (Decode.decodeValue decodeUliki val)))
        , notesReceived (\val -> NotesDecoded (Result.mapError Decode.errorToString (Decode.decodeValue decodeNotes val)))

        , speechRecognized SpeechResultReceived
        , operationError HandleError
        , accountDeletionResult (\value ->
            case Decode.decodeValue (Decode.field "success" Decode.bool) value of
                Ok True -> AccountDeletionFinished (Ok "success")
                _ -> AccountDeletionFinished (Decode.decodeValue (Decode.field "error" Decode.string) value |> Result.mapError Decode.errorToString |> Result.andThen Err)
          )
        , successMessageReceived SuccessMessageReceived
        , todayReceived CurrentDateReceived
        , currentEpochReceived CurrentEpochReceived
        , userSettingsReceived (\val -> UserSettingsReceived (Result.mapError Decode.errorToString (Decode.decodeValue decodeUserSettings val)))
        , queenRearingReceived (\val -> QueenRearingDataReceived (Result.mapError Decode.errorToString (Decode.decodeValue QR.dataDecoder val)))
        , korpusDropReceived KorpusDropReceived
        , orderDropReceived OrderDropReceived
        ]

-- VIEW

view : Model -> Html Msg
view model =
    let
        t = translationsFor model.language
        bgColor = if model.darkMode then "#121212" else "#f7f9fa"
        textColor = if model.darkMode then "#e0e0e0" else "#333333"
    in
    div [ style "padding" "20px", style "max-width" "800px", style "margin" "0 auto", style "background-color" bgColor, style "color" textColor, style "min-height" "100vh", style "position" "relative" ]
        [ headerView t model
        , notificationsView t model
        , case model.authState of
            LoggedOut ->
                loginView t model

            LoggedIn user ->
                case model.viewState of
                    LoginView ->
                        apiariesView t model

                    ApiariesView ->
                        apiariesView t model

                    MatingApiariesView ->
                        apiariesView t model

                    CommercialApiariesView ->
                        apiariesView t model

                    QueenRearingView ->
                        queenRearingView t user model

                    HiveListView info ->
                        hiveListView t user info model

                    HiveDetailView info ->
                        hiveDetailView t user info model

                    UlikListView info ->
                        ulikListView t user info model

                    UlikDetailView info ->
                        ulikDetailView t user info model

                    SettingsView ->
                        settingsView t user model
        , modalsView t model
        ]

headerView : Translations -> Model -> Html Msg
headerView t model =
    let
        menuItem label action =
            button
                [ onClick action
                , style "display" "block"
                , style "width" "100%"
                , style "padding" "10px 12px"
                , style "text-align" "left"
                , style "background" "none"
                , style "border" "none"
                , style "cursor" "pointer"
                ]
                [ text label ]

        topRow attrs children =
            div ([ style "display" "flex", style "align-items" "center", style "gap" "12px" ] ++ attrs) children
    in
    div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "border-bottom" "1px solid #ddd", style "padding-bottom" "10px", style "margin-bottom" "20px" ]
        [ case model.authState of
            LoggedIn user ->
                topRow []
                    [ div [ style "position" "relative" ]
                        [ button [ onClick ToggleMainMenu, attribute "aria-label" t.menu, attribute "aria-expanded" (if model.menuExpanded then "true" else "false"), attribute "aria-controls" "main-navigation", attribute "data-testid" "main-menu-toggle", style "padding" "8px 12px", style "font-size" "22px", style "cursor" "pointer" ] [ text (t.localize "☰") ]
                        , if model.menuExpanded then
                            nav [ id "main-navigation", attribute "aria-label" t.mainNavigation, style "position" "absolute", style "left" "0", style "top" "44px", style "z-index" "5", style "min-width" "220px", style "padding" "8px", style "background" (if model.darkMode then "#2d2d2d" else "white"), style "box-shadow" "0 2px 8px #0004", style "border-radius" "6px" ]
                                ([ if model.enableQueenRearing then menuItem t.queenRearing (NavigateTo QueenRearingView) else text (t.localize "")
                                 , if model.enableTrutowiska then menuItem t.matingApiaries (NavigateTo MatingApiariesView) else text (t.localize "")
                                 , if model.enablePasieczyskaTowarowe then menuItem t.commercialApiaries (NavigateTo CommercialApiariesView) else text (t.localize "")
                                 , menuItem t.settings (NavigateTo SettingsView)
                                 , menuItem t.logout ClickLogout
                                 ])
                          else
                            text (t.localize "")
                        ]
                    , span [ style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#666") ] [ text user.email ]
                    ]

            LoggedOut ->
                h1 [ style "margin" "0", style "color" (if model.darkMode then "#ffffff" else "#2c3e50") ] [ text (t.localize "BeeLog 🐝") ]
        ]

notificationsView : Translations -> Model -> Html Msg
notificationsView t model =
    div []
        [ case model.errorMessage of
            Just err ->
                div [ style "background-color" "#fadbd8", style "color" "#900c3f", style "padding" "10px", style "border-radius" "4px", style "margin-bottom" "15px", style "display" "flex", style "justify-content" "space-between" ]
                    [ span [] [ text (t.localize err) ]
                    , button [ onClick ClearMessages, style "background" "none", style "border" "none", style "cursor" "pointer" ] [ text (t.localize "✕") ]
                    ]
            Nothing ->
                text (t.localize "")
        , case model.successMessage of
            Just succ ->
                div [ style "background-color" "#d4efdf", style "color" "#145a32", style "padding" "10px", style "border-radius" "4px", style "margin-bottom" "15px", style "display" "flex", style "justify-content" "space-between" ]
                    [ span [] [ text (t.localize succ) ]
                    , button [ onClick ClearMessages, style "background" "none", style "border" "none", style "cursor" "pointer" ] [ text (t.localize "✕") ]
                    ]
            Nothing ->
                text (t.localize "")
        ]

loginView : Translations -> Model -> Html Msg
loginView t model =
    let
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
    in
    div [ style "text-align" "center", style "padding" "40px", style "background" cardBg, style "color" textColor, style "border-radius" "8px", style "box-shadow" "0 2px 4px rgba(0,0,0,0.1)" ]
        [ h2 [ style "color" headingColor ] [ text t.loginTitle ]
        , p [ style "color" (if model.darkMode then "#b0b0b0" else "#666"), style "margin-bottom" "30px" ] [ text t.loginDescription ]
        , button [ onClick ClickLoginGoogle, style "padding" "12px 24px", style "background-color" "#4285F4", style "color" "white", style "border" "none", style "border-radius" "4px", style "font-size" "16px", style "cursor" "pointer" ] [ text t.loginButton ]
        ]

modalsView : Translations -> Model -> Html Msg
modalsView t model =
    let
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"
        typeScoped = model.viewState == MatingApiariesView || model.viewState == CommercialApiariesView
    in
    div []
        [ if model.showNewApiaryModal then
            div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                    [ h3 [ style "color" headingColor ] [ text (t.localize "Nowe Pasieczysko") ]
                    , label [] [ text (t.localize "Nazwa pasieczyska:") ]
                    , input [ type_ "text", placeholder (t.localize "Nazwa pasieczyska"), value model.newApiaryName, onInput UpdateNewApiaryName, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                    , if typeScoped then text (t.localize "") else label [] [ text (t.localize "Typ pasieczyska:") ]
                    , if typeScoped then text (t.localize "") else select [ value (if model.enablePasieczyskaTowarowe && (model.newApiaryType == "towarowe" || not model.enableTrutowiska) then "towarowe" else "trutowisko"), onInput UpdateNewApiaryType, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                        ((if model.enablePasieczyskaTowarowe then
                            [ option [ value "towarowe" ] [ text (t.localize "Pasieczysko towarowe") ] ]
                          else
                            []
                         )
                         ++ (if model.enableTrutowiska then
                                [ option [ value "trutowisko" ] [ text (t.localize "Trutowisko (uliki weselne)") ] ]
                            else
                                []
                            )
                        )
                    , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                        [ button [ onClick CloseNewApiaryModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Anuluj") ]
                        , button [ onClick SubmitCreateApiary, style "padding" "8px 12px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Zapisz") ]
                        ]
                    ]
                ]
          else
            text (t.localize "")
        , case model.showEditApiaryModal of
            Just apiary ->
                div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                    [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                        [ h3 [ style "color" headingColor ] [ text (t.localize "Edytuj Nazwę Pasieczyska") ]
                        , input [ type_ "text", value model.editApiaryNameInput, onInput UpdateEditApiaryNameInput, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseEditApiaryModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Anuluj") ]
                            , button [ onClick SubmitUpdateApiary, style "padding" "8px 12px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Zapisz") ]
                            ]
                        ]
                    ]
            Nothing ->
                text (t.localize "")
        , case model.showDeleteApiaryModal of
            Just apiary ->
                div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                    [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                        [ h3 [ style "color" headingColor ] [ text (t.localize "Usuń Pasieczysko") ]
                        , p [] [ text (t.localize "Czy na pewno chcesz usunąć pasieczysko \"" ++ apiary.name ++ t.localize "\" wraz ze wszystkimi ulami i notatkami?") ]
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseDeleteApiaryModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Anuluj") ]
                            , button [ onClick (SubmitDeleteApiary apiary.id), style "padding" "8px 12px", style "background" "#e74c3c", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Potwierdź usunięcie") ]
                            ]
                        ]
                    ]
            Nothing ->
                text (t.localize "")
        , if model.showNewHiveModal then
            div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center", style "z-index" "1000" ]
                [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "450px", style "max-height" "90vh", style "overflow-y" "auto", style "color" textColor ]
                    [ h3 [ style "color" headingColor ] [ text (t.localize "Nowy Ul") ]
                    , label [] [ text (t.localize "Nazwa / Numer ula:") ]
                    , input [ type_ "text", placeholder (t.localize "np. Ul #04"), value model.newHiveName, onInput UpdateNewHiveName, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                    , label [] [ text (t.localize "Typ ula:") ]
                    , select [ value model.newHiveType, onInput UpdateNewHiveType, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                        [ option [ value "korpusowy", selected (model.newHiveType == "korpusowy") ] [ text (t.localize "Ul korpusowy") ]
                        , option [ value "lezak", selected (model.newHiveType == "lezak") ] [ text (t.localize "Ul leżak") ]
                        , option [ value "kombinowany", selected (model.newHiveType == "kombinowany") ] [ text (t.localize "Ul kombinowany") ]
                        ]
                    , if model.newHiveType == "korpusowy" then
                        div []
                            [ label [] [ text (t.localize "Typ ramki:") ]
                            , select [ value model.newHiveFrameType, onInput UpdateNewHiveFrameType, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                (List.map (\ft -> option [ value ft, selected (model.newHiveFrameType == ft) ] [ text ft ]) model.frameTypes)
                            ]
                      else if model.newHiveType == "lezak" then
                        div []
                            [ label [] [ text (t.localize "Typ ramki gniazdowej:") ]
                            , select [ value model.newHiveBroodFrameType, onInput UpdateNewHiveBroodFrameType, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                (List.map (\ft -> option [ value ft, selected (model.newHiveBroodFrameType == ft) ] [ text ft ]) model.frameTypes)
                            , label [] [ text (t.localize "Maksymalna liczba ramek w gnieździe:") ]
                            , input [ type_ "number", value (String.fromInt model.newHiveMaxBroodFrames), onInput (\val -> UpdateNewHiveMaxBroodFrames (Maybe.withDefault 24 (String.toInt val))), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                            , label [] [ text (t.localize "Początkowa liczba ramek w gnieździe:") ]
                            , input [ type_ "number", value (String.fromInt model.newHiveBroodFrameCount), onInput (\val -> UpdateNewHiveBroodFrameCount (Maybe.withDefault 10 (String.toInt val))), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                            , label [ style "margin-bottom" "10px", style "display" "flex", style "align-items" "center", style "gap" "8px", style "cursor" "pointer", style "font-weight" "bold" ]
                                [ input [ type_ "checkbox", checked model.newHiveHasSuper, onCheck UpdateNewHiveHasSuper, id "newHiveHasSuperCheck" ] []
                                , span [] [ text (t.localize "Czy posiada nadstawkę?") ]
                                ]
                            , if model.newHiveHasSuper then
                                div [ style "padding-left" "10px", style "border-left" "3px solid #3498db", style "margin-bottom" "15px" ]
                                    [ label [] [ text (t.localize "Typ ramki nadstawkowej (nadstawki):") ]
                                    , select [ value model.newHiveSuperFrameType, onInput UpdateNewHiveSuperFrameType, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                        (List.map (\ft -> option [ value ft, selected (model.newHiveSuperFrameType == ft) ] [ text ft ]) model.frameTypes)
                                    , label [] [ text (t.localize "Maksymalna liczba ramek w nadstawce:") ]
                                    , input [ type_ "number", value (String.fromInt model.newHiveMaxSuperFrames), onInput (\val -> UpdateNewHiveMaxSuperFrames (Maybe.withDefault 18 (String.toInt val))), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                                    , label [] [ text (t.localize "Początkowa liczba ramek w nadstawce:") ]
                                    , input [ type_ "number", value (String.fromInt model.newHiveSuperFrameCount), onInput (\val -> UpdateNewHiveSuperFrameCount (Maybe.withDefault 10 (String.toInt val))), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                                    ]
                              else
                                text (t.localize "")
                            ]
                      else
                        div []
                            [ label [] [ text (t.localize "Typ ramki gniazdowej:") ]
                            , select [ value model.newHiveBroodFrameType, onInput UpdateNewHiveBroodFrameType, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                (List.map (\ft -> option [ value ft, selected (model.newHiveBroodFrameType == ft) ] [ text ft ]) model.frameTypes)
                            , label [] [ text (t.localize "Liczba ramek gniazdowych:") ]
                            , input [ type_ "number", value (String.fromInt model.newHiveBroodFrameCount), onInput (\val -> UpdateNewHiveBroodFrameCount (Maybe.withDefault 10 (String.toInt val))), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                            , label [] [ text (t.localize "Typ ramki nadstawkowej (nadstawki):") ]
                            , select [ value model.newHiveSuperFrameType, onInput UpdateNewHiveSuperFrameType, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                (List.map (\ft -> option [ value ft, selected (model.newHiveSuperFrameType == ft) ] [ text ft ]) model.frameTypes)
                            , label [] [ text (t.localize "Początkowa liczba nadstawek:") ]
                            , input [ type_ "number", attribute "min" "0", value (String.fromInt model.newHiveSuperCount), onInput (\val -> UpdateNewHiveSuperCount (Basics.max 0 (Maybe.withDefault 0 (String.toInt val)))), style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                            ]
                    , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                        [ button [ onClick CloseNewHiveModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Anuluj") ]
                        , case model.viewState of
                            HiveListView info ->
                                button [ onClick (SubmitCreateHive info.apiaryId), style "padding" "8px 12px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Zapisz") ]
                            _ ->
                                text (t.localize "")
                        ]
                    ]
                ]
          else
            text (t.localize "")
        , if model.showNewUlikModal then
            div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                    [ h3 [ style "color" headingColor ] [ text (t.localize "Nowy Ulik Weselny") ]
                    , label [] [ text (t.localize "Nazwa / Numer uliku:") ]
                    , input [ type_ "text", placeholder (t.localize "np. Ulik #01"), value model.newUlikName, onInput UpdateNewUlikName, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                    , label [] [ text (t.localize "Typ ula:") ]
                    , select [ value model.newUlikHiveType, onInput UpdateNewUlikHiveType, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                        (List.map (\ut -> option [ value ut, selected (model.newUlikHiveType == ut) ] [ text ut ]) model.ulikTypes)
                    , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                        [ button [ onClick CloseNewUlikModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Anuluj") ]
                        , case model.viewState of
                            UlikListView info ->
                                button [ onClick (SubmitCreateUlik info.apiaryId), style "padding" "8px 12px", style "background" "#8e44ad", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Zapisz") ]
                            _ ->
                                text (t.localize "")
                        ]
                    ]
                ]
          else
            text (t.localize "")
        , case model.showRenameHiveModal of
            Just info ->
                div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                    [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                        [ h3 [ style "color" headingColor ] [ text (t.localize "Zmień nazwę ula") ]
                        , input [ type_ "text", value model.renameHiveInput, onInput UpdateRenameHiveInput, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseRenameHiveModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Anuluj") ]
                            , button [ onClick (SubmitRenameHive info.apiaryId info.hiveId), style "padding" "8px 12px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Zapisz") ]
                            ]
                        ]
                    ]
            Nothing ->
                text (t.localize "")
        , case model.showDeleteHiveModal of
            Just info ->
                div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                    [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                        [ h3 [ style "color" headingColor ] [ text (t.localize "Usuń ul") ]
                        , p [] [ text (t.localize "Czy na pewno chcesz usunąć ul \"" ++ info.hiveName ++ t.localize "\" wraz ze wszystkimi notatkami?") ]
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseDeleteHiveModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Anuluj") ]
                            , button [ attribute "data-testid" "confirm-delete-hive", onClick (SubmitDeleteHive info.apiaryId info.hiveId), style "padding" "8px 12px", style "background" "#e74c3c", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Potwierdź usunięcie") ]
                            ]
                        ]
                    ]
            Nothing ->
                text (t.localize "")
        , case model.showRenameUlikModal of
            Just info ->
                div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                    [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                        [ h3 [ style "color" headingColor ] [ text (t.localize "Zmień nazwę uliku") ]
                        , input [ type_ "text", value model.renameUlikInput, onInput UpdateRenameUlikInput, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseRenameUlikModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Anuluj") ]
                            , button [ onClick (SubmitRenameUlik info.apiaryId info.ulikId), style "padding" "8px 12px", style "background" "#8e44ad", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Zapisz") ]
                            ]
                        ]
                    ]
            Nothing ->
                text (t.localize "")
        , case model.showDeleteUlikModal of
            Just info ->
                div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                    [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                        [ h3 [ style "color" headingColor ] [ text (t.localize "Usuń ulik weselny") ]
                        , p [] [ text (t.localize "Czy na pewno chcesz usunąć ulik \"" ++ info.ulikName ++ t.localize "\" wraz ze wszystkimi notatkami?") ]
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseDeleteUlikModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Anuluj") ]
                            , button [ onClick (SubmitDeleteUlik info.apiaryId info.ulikId), style "padding" "8px 12px", style "background" "#e74c3c", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Potwierdź usunięcie") ]
                            ]
                        ]
                    ]
            Nothing ->
                text (t.localize "")
        , case model.showMoveUlikModal of
            Just info ->
                let
                    otherTrutowiska =
                        List.filter (\a -> a.apiaryType == "trutowisko" && a.id /= info.sourceApiaryId) model.apiaries
                    defaultTargetId =
                        case otherTrutowiska of
                            a :: _ -> a.id
                            [] -> ""
                    targetId =
                        if model.moveUlikTargetApiaryId == "" then
                            defaultTargetId
                        else
                            model.moveUlikTargetApiaryId
                in
                div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center", style "z-index" "1000" ]
                    [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "max-width" "90%", style "color" textColor ]
                        [ h3 [ style "color" headingColor ] [ text (t.localize "Przenieś ulik: " ++ info.ulikName) ]
                        , p [] [ text (t.localize "Wybierz docelowe trutowisko:") ]
                        , if List.isEmpty otherTrutowiska then
                            p [ style "color" "#e74c3c" ] [ text (t.localize "Brak innych trutowisk do wyboru.") ]
                          else
                            select [ onInput SelectMoveUlikTargetApiary, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                (List.map (\a -> option [ value a.id, selected (targetId == a.id) ] [ text a.name ]) otherTrutowiska)
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseMoveUlikModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Anuluj") ]
                            , if not (List.isEmpty otherTrutowiska) then
                                button [ onClick (SubmitMoveUlik info.sourceApiaryId info.ulikId targetId), style "padding" "8px 12px", style "background" "#e67e22", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Przenieś") ]
                              else
                                text (t.localize "")
                            ]
                        ]
                    ]
            Nothing ->
                text (t.localize "")
        , case model.activeUlikModal of
            Just info ->
                div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                    [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                        [ h3 [ style "color" headingColor ]
                            [ text (case info.modalType of
                                ModalPoddajMatecznik -> "Poddaj Matecznik (M)"
                                ModalPoddajMatkeNieunasiennioną -> "Poddaj Matkę Nieunasiennioną (N)"
                                ModalZaopalitkuj -> "Zaopalitkuj Matkę Pszczelą"
                              )
                            ]
                        , if info.modalType == ModalPoddajMatecznik || info.modalType == ModalPoddajMatkeNieunasiennioną then
                            div []
                                [ label [] [ text (t.localize "Rasa i linia matki:") ]
                                , select [ onInput UpdateModalBreedLine, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                    (List.map (\bl -> option [ value bl, selected (model.modalBreedLine == bl) ] [ text bl ]) model.breedLines)
                                , label [] [ text (t.localize "Spodziewany termin wygryzienia:") ]
                                , input [ type_ "date", value model.modalHatchDate, onInput UpdateModalHatchDate, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                                ]
                          else
                            text (t.localize "")
                        , if info.modalType == ModalPoddajMatkeNieunasiennioną then
                            div []
                                [ label [] [ text (t.localize "Czy opalitkowana?") ]
                                , select [ onInput UpdateModalIsOpalitkovana, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                    [ option [ value "Nie", selected (model.modalIsOpalitkovana == "Nie") ] [ text (t.localize "Nie") ]
                                    , option [ value "Tak", selected (model.modalIsOpalitkovana == "Tak") ] [ text (t.localize "Tak") ]
                                    ]
                                ]
                          else
                            text (t.localize "")
                        , if info.modalType == ModalZaopalitkuj || (info.modalType == ModalPoddajMatkeNieunasiennioną && model.modalIsOpalitkovana == "Tak") then
                            div []
                                [ label [] [ text (t.localize "Kolor Opalitka:") ]
                                , select [ onInput UpdateModalOpalitColor, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                    [ option [ value "Biały", selected (model.modalOpalitColor == "Biały") ] [ text (t.localize "Biały") ]
                                    , option [ value "Żółty", selected (model.modalOpalitColor == "Żółty") ] [ text (t.localize "Żółty") ]
                                    , option [ value "Czerwony", selected (model.modalOpalitColor == "Czerwony") ] [ text (t.localize "Czerwony") ]
                                    , option [ value "Zielony", selected (model.modalOpalitColor == "Zielony") ] [ text (t.localize "Zielony") ]
                                    , option [ value "Niebieski", selected (model.modalOpalitColor == "Niebieski") ] [ text (t.localize "Niebieski") ]
                                    ]
                                , label [] [ text (t.localize "Numer Opalitka:") ]
                                , input [ type_ "text", placeholder (t.localize "np. 42"), value model.modalOpalitNumber, onInput UpdateModalOpalitNumber, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                                ]
                          else
                            text (t.localize "")
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseUlikModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Anuluj") ]
                            , button [ onClick (SubmitUlikModal info.apiaryId info.ulikId info.modalType), style "padding" "8px 12px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text (t.localize "Zapisz") ]
                            ]
                        ]
                    ]
            Nothing ->
                text (t.localize "")
        ]

hiveSnapshotText : Hive -> String
hiveSnapshotText hive =
    let
        opalitText = if hive.queen.hasOpalit then "Tak (Kolor: " ++ hive.queen.color ++ ", Nr: " ++ hive.queen.number ++ ")" else "Nie"
        pollenText = case hive.pollenTrap of
            "powałkowy" -> "Powałkowy"
            "dennicowy" -> "Dennicowy"
            _ -> "Brak"
        hiveSpecificText =
            if hive.hiveType == "lezak" then
                [ "Gniazdo: " ++ hive.broodFrameType ++ ", " ++ String.fromInt hive.broodFrameCount ++ " / " ++ String.fromInt hive.maxBroodFrames ++ " ramek"
                , if hive.hasSuper then
                    "Nadstawka: Tak — " ++ hive.superFrameType ++ ", " ++ String.fromInt hive.superFrameCount ++ " / " ++ String.fromInt hive.maxSuperFrames ++ " ramek"
                  else
                    "Nadstawka: Nie"
                ]
            else if hive.hiveType == "kombinowany" then
                [ "Gniazdo: " ++ hive.broodFrameType ++ ", " ++ String.fromInt hive.broodFrameCount ++ " ramek"
                , "Nadstawki: " ++ String.fromInt hive.superCount ++ " (ramka: " ++ hive.superFrameType ++ ")"
                ]
            else if hive.hiveType == "korpusowy" then
                [ "Typ ramki: " ++ hive.frameType, "Korpusy (od góry):" ]
                    ++ List.map snapshotKorpusText hive.korpusy
            else
                [ "Typ ramki: " ++ hive.frameType ]
    in
    String.join "\n"
        ([ "📸 Zrzut Stanu Ula:"
        , "Nazwa: " ++ hive.name
        , "Typ ula: " ++ hive.hiveType
        ]
        ++ hiveSpecificText
        ++ [ "Poławiacz pyłku: " ++ pollenText
        , "Matka pszczela (opalitek): " ++ opalitText
        ])

snapshotKorpusText : Korpus -> String
snapshotKorpusText korpus =
    let
        yesNo value =
            if value then "tak" else "nie"
    in
    "Korpus #" ++ korpus.id
        ++ ": matka " ++ yesNo korpus.hasQueen
        ++ ", krata nad korpusem " ++ yesNo korpus.hasExcluderAbove
        ++ ", folia nad korpusem " ++ yesNo korpus.hasFoilAbove
        ++ ", otwarty wylotek " ++ yesNo korpus.hasOpenEntrance

ulikSnapshotText : UlikWeselny -> String
ulikSnapshotText ulik =
    let
        queenText = if ulik.hasQueen then
                        "Tak (Rasa/Linia: " ++ ulik.queen.breedLine ++ ", Opalit: " ++ (if ulik.queen.hasOpalit then ulik.queen.color ++ " #" ++ ulik.queen.number else "Nie") ++ ")"
                    else
                        "Brak"
    in
    String.join "\n"
        [ "📸 Zrzut Stanu Uliku Weselnego:"
        , "Nazwa: " ++ ulik.name
        , "Typ ula: " ++ ulik.hiveType
        , "Stan: " ++ ulikStateLabel (getUlikState ulik)
        , "Link NFC: " ++ (if ulik.nfcLink == "" then "Brak" else ulik.nfcLink)
        , "Matka pszczela: " ++ queenText
        ]

encodeUlikFields : UlikWeselny -> Encode.Value
encodeUlikFields u =
    Encode.object
        [ ( "state", Encode.string u.state )
        , ( "hasQueen", Encode.bool u.hasQueen )
        , ( "queen", Encode.object
            [ ( "breedLine", Encode.string u.queen.breedLine )
            , ( "hasOpalit", Encode.bool u.queen.hasOpalit )
            , ( "color", Encode.string u.queen.color )
            , ( "number", Encode.string u.queen.number )
            ]
          )
        , ( "expectedHatchDate", Encode.string u.expectedHatchDate )
        , ( "expectedMatingDate", Encode.string u.expectedMatingDate )
        , ( "history", Encode.list encodeUlikHistoryEntry u.history )
        ]

encodeUlikHistoryEntry : UlikHistoryEntry -> Encode.Value
encodeUlikHistoryEntry h =
    Encode.object
        [ ( "timestamp", Encode.string h.timestamp )
        , ( "prevState", Encode.string h.prevState )
        , ( "state", Encode.string h.state )
        , ( "description", Encode.string h.description )
        , ( "breedLine", Encode.string h.breedLine )
        , ( "expectedHatchDate", Encode.string h.expectedHatchDate )
        , ( "expectedMatingDate", Encode.string h.expectedMatingDate )
        , ( "hasOpalit", Encode.bool h.hasOpalit )
        , ( "color", Encode.string h.color )
        , ( "number", Encode.string h.number )
        ]

addKorpusAbove : String -> List Korpus -> List Korpus
addKorpusAbove targetId korpusy =
    let
        newKorpus = createKorpus korpusy
    in
    insertKorpusBefore targetId newKorpus korpusy

addKorpusBelow : String -> List Korpus -> List Korpus
addKorpusBelow targetId korpusy =
    insertKorpusAfter targetId (createKorpus korpusy) korpusy

addKorpusBetween : Int -> List Korpus -> List Korpus
addKorpusBetween idx korpusy =
    let
        maxId = Maybe.withDefault 0 (List.maximum (List.filterMap (\k -> String.toInt k.id) korpusy))
        newId = String.fromInt (maxId + 1)
        newKorpus = { id = newId, hasQueen = False, hasExcluderAbove = False, hasFoilAbove = False, hasOpenEntrance = False }
    in
    List.take (idx + 1) korpusy ++ [ newKorpus ] ++ List.drop (idx + 1) korpusy

createKorpus : List Korpus -> Korpus
createKorpus korpusy =
    let
        maxId = Maybe.withDefault 0 (List.maximum (List.filterMap (\k -> String.toInt k.id) korpusy))
    in
    { id = String.fromInt (maxId + 1), hasQueen = False, hasExcluderAbove = False, hasFoilAbove = False, hasOpenEntrance = False }

insertKorpusBefore : String -> Korpus -> List Korpus -> List Korpus
insertKorpusBefore targetId korpus korpusy =
    case korpusy of
        [] ->
            [ korpus ]

        current :: rest ->
            if current.id == targetId then
                korpus :: current :: rest
            else
                current :: insertKorpusBefore targetId korpus rest

insertKorpusAfter : String -> Korpus -> List Korpus -> List Korpus
insertKorpusAfter targetId korpus korpusy =
    case korpusy of
        [] ->
            [ korpus ]

        current :: rest ->
            if current.id == targetId then
                current :: korpus :: rest
            else
                current :: insertKorpusAfter targetId korpus rest

decodeOrderCollection : Decode.Decoder OrderCollection
decodeOrderCollection =
    Decode.string
        |> Decode.andThen
            (\value ->
                case value of
                    "apiaries" -> Decode.succeed Apiaries
                    "commercial-hives" -> Decode.succeed CommercialHives
                    "mating-hives" -> Decode.succeed MatingHives
                    _ -> Decode.fail "Unknown order collection"
            )


decodeOrderDrop : Decode.Decoder OrderDrop
decodeOrderDrop =
    Decode.map5 OrderDrop
        (Decode.field "collection" decodeOrderCollection)
        (Decode.field "apiaryId" Decode.string)
        (Decode.field "draggedId" Decode.string)
        (Decode.field "targetId" Decode.string)
        (Decode.field "after" Decode.bool)


reorderDraggedItem : OrderCollection -> String -> String -> Bool -> Model -> ( Model, Cmd Msg )
reorderDraggedItem collection apiaryId targetId after model =
    case model.draggedOrderItem of
        Just dragged ->
            if dragged.collection /= collection || dragged.apiaryId /= apiaryId || dragged.id == targetId then
                ( { model | draggedOrderItem = Nothing }, Cmd.none )
            else
                case collection of
                    Apiaries ->
                        let
                            visible = List.filter (isApiaryVisible model) model.apiaries
                            reordered = moveById .id dragged.id targetId after visible
                            merged = replaceVisibleItems .id visible reordered model.apiaries |> normalizeOrder (\item index -> { item | order = index })
                        in
                        if reordered == visible then
                            ( { model | draggedOrderItem = Nothing }, Cmd.none )
                        else
                            ( { model | apiaries = merged, draggedOrderItem = Nothing, suppressCardClick = True }, jsSaveApiaryOrders merged )

                    CommercialHives ->
                        if not (List.all (\hive -> hive.apiaryId == apiaryId) model.hives) then
                            ( { model | draggedOrderItem = Nothing }, Cmd.none )
                        else
                            let
                                reordered = moveById .id dragged.id targetId after model.hives
                                normalized = normalizeOrder (\item index -> { item | order = index }) reordered
                            in
                            if reordered == model.hives then
                                ( { model | draggedOrderItem = Nothing }, Cmd.none )
                            else
                                ( { model | hives = normalized, draggedOrderItem = Nothing, suppressCardClick = True }, jsSaveHiveOrders { apiaryId = apiaryId, hives = normalized } )

                    MatingHives ->
                        if not (List.all (\ulik -> ulik.apiaryId == apiaryId) model.uliki) then
                            ( { model | draggedOrderItem = Nothing }, Cmd.none )
                        else
                            let
                                visible = List.filter (isUlikVisible model) model.uliki
                                reordered = moveById .id dragged.id targetId after visible
                                merged = replaceVisibleItems .id visible reordered model.uliki |> normalizeOrder (\item index -> { item | order = index })
                            in
                            if reordered == visible then
                                ( { model | draggedOrderItem = Nothing }, Cmd.none )
                            else
                                ( { model | uliki = merged, draggedOrderItem = Nothing, suppressCardClick = True }, jsSaveUlikOrders { apiaryId = apiaryId, uliki = merged } )

        Nothing ->
            ( model, Cmd.none )


isUlikVisible : Model -> UlikWeselny -> Bool
isUlikVisible model ulik =
    (model.ulikFilter == "all" || ulik.state == model.ulikFilter)
        && (not model.ulikActionRequiredOnly || not (List.isEmpty (ulikAttentionReasons model.currentDate ulik)))


isApiaryVisible : Model -> Apiary -> Bool
isApiaryVisible model apiary =
    (model.enablePasieczyskaTowarowe || apiary.apiaryType /= "towarowe")
        && (model.enableTrutowiska || apiary.apiaryType /= "trutowisko")
        && (model.apiaryFilter == "all" || apiary.apiaryType == model.apiaryFilter)


moveById : (a -> String) -> String -> String -> Bool -> List a -> List a
moveById getId draggedId targetId after items =
    if draggedId == targetId || not (List.any (\item -> getId item == draggedId) items) || not (List.any (\item -> getId item == targetId) items) then
        items
    else
        let
            dragged = List.filter (\item -> getId item == draggedId) items |> List.head
            remaining = List.filter (\item -> getId item /= draggedId) items
            insert item =
                let
                    ( before, targetAndRest ) = splitBeforeId getId targetId remaining
                in
                if after then
                    case targetAndRest of
                        target :: rest -> before ++ [ target, item ] ++ rest
                        [] -> items
                else
                    before ++ item :: targetAndRest
        in
        Maybe.withDefault items (Maybe.map insert dragged)


splitBeforeId : (a -> String) -> String -> List a -> ( List a, List a )
splitBeforeId getId targetId items =
    case items of
        [] ->
            ( [], [] )

        item :: rest ->
            if getId item == targetId then
                ( [], items )
            else
                let
                    ( before, after ) = splitBeforeId getId targetId rest
                in
                ( item :: before, after )


replaceVisibleItems : (a -> String) -> List a -> List a -> List a -> List a
replaceVisibleItems getId visible reordered allItems =
    let
        isVisible item = List.any (\shown -> getId shown == getId item) visible
        step item (remaining, result) =
            if isVisible item then
                case remaining of
                    next :: rest -> ( rest, result ++ [ next ] )
                    [] -> ( remaining, result ++ [ item ] )
            else
                ( remaining, result ++ [ item ] )
    in
    List.foldl step ( reordered, [] ) allItems |> Tuple.second


normalizeOrder : (a -> Int -> a) -> List a -> List a
normalizeOrder setOrder items =
    List.indexedMap (\index item -> setOrder item index) items


moveKorpusBefore : String -> String -> List Korpus -> List Korpus
moveKorpusBefore draggedId targetId korpusy =
    if draggedId == targetId then
        korpusy
    else
        let
            maybeDragged = List.head (List.filter (\k -> k.id == draggedId) korpusy)
            targetExists = List.any (\k -> k.id == targetId) korpusy
        in
        case maybeDragged of
            Just dragged ->
                if targetExists then
                    insertKorpusBefore targetId dragged (List.filter (\k -> k.id /= draggedId) korpusy)
                else
                    korpusy

            Nothing ->
                korpusy

moveKorpusAfter : String -> String -> List Korpus -> List Korpus
moveKorpusAfter draggedId targetId korpusy =
    if draggedId == targetId then
        korpusy
    else
        let
            maybeDragged = List.head (List.filter (\k -> k.id == draggedId) korpusy)
            targetExists = List.any (\k -> k.id == targetId) korpusy
        in
        case maybeDragged of
            Just dragged ->
                if targetExists then
                    insertKorpusAfter targetId dragged (List.filter (\k -> k.id /= draggedId) korpusy)
                else
                    korpusy

            Nothing ->
                korpusy

deleteKorpus : String -> List Korpus -> List Korpus
deleteKorpus targetId korpusy =
    if List.length korpusy <= 1 then
        korpusy
    else
        List.filter (\k -> k.id /= targetId) korpusy

toggleKorpusQueen : String -> List Korpus -> List Korpus
toggleKorpusQueen targetId korpusy =
    List.map (\k -> if k.id == targetId then { k | hasQueen = not k.hasQueen } else k) korpusy

toggleKorpusExcluder : String -> List Korpus -> List Korpus
toggleKorpusExcluder targetId korpusy =
    List.map (\k -> if k.id == targetId then { k | hasExcluderAbove = not k.hasExcluderAbove } else k) korpusy

toggleKorpusFoil : String -> List Korpus -> List Korpus
toggleKorpusFoil targetId korpusy =
    List.map (\k -> if k.id == targetId then { k | hasFoilAbove = not k.hasFoilAbove } else k) korpusy

toggleKorpusEntrance : String -> List Korpus -> List Korpus
toggleKorpusEntrance targetId korpusy =
    List.map (\k -> if k.id == targetId then { k | hasOpenEntrance = not k.hasOpenEntrance } else k) korpusy

updateKorpusyForHive : String -> String -> List Korpus -> Model -> (Model, Cmd Msg)
updateKorpusyForHive apiaryId hiveId newKorpusy model =
    let
        updatedHives =
            List.map
                (\h ->
                    if h.id == hiveId then
                        { h | korpusy = newKorpusy }
                    else
                        h
                )
                model.hives

        updatedHive =
            List.head (List.filter (\h -> h.id == hiveId) updatedHives)
    in
    case updatedHive of
        Just h ->
            ( { model | hives = updatedHives }
            , jsUpdateHiveFull { apiaryId = apiaryId, hiveId = hiveId, fields = Encode.object [ ("korpusy", encodeKorpusy h.korpusy) ] }
            )
        Nothing ->
            ( { model | hives = updatedHives }, Cmd.none )
