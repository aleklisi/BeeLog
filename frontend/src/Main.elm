port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (Value)
import Json.Encode as Encode
import Types exposing (..)
import Views.ApiaryList exposing (apiariesView)
import Views.PasieczyskoTowarowe exposing (hiveDetailView, hiveListView)
import Views.Settings exposing (settingsView)
import Views.Trutowisko exposing (ulikDetailView, ulikListView)

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
      , uliki = []
      , notes = []
      , errorMessage = Nothing
      , successMessage = Nothing
      , darkMode = flags.darkMode
      , pendingDeepLink = pending
      , currentDate = ""
      , apiaryFilter = "all"
      , ulikFilter = "all"
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
      , showNewApiaryModal = False
      , newApiaryName = ""
      , newApiaryType = "towarowe"
      , showEditApiaryModal = Nothing
      , editApiaryNameInput = ""
      , showDeleteApiaryModal = Nothing
      , showNewHiveModal = False
      , newHiveName = ""
      , newHiveFrameType = "Wielkopolska"
      , showNewUlikModal = False
      , newUlikName = ""
      , newUlikHiveType = "Mini plus"
      , newNoteText = ""
      , editingNoteId = Nothing
      , editNoteText = ""
      , shareEmailInput = ""
      , shareRoleInput = "view"
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

-- PORTS (OUT)

port jsLoginGoogle : () -> Cmd msg
port jsLogout : () -> Cmd msg
port jsLoadApiaries : String -> Cmd msg
port jsCreateApiary : { name : String, apiaryType : String, uid : String } -> Cmd msg
port jsUpdateApiary : { apiaryId : String, name : String } -> Cmd msg
port jsDeleteApiary : { apiaryId : String } -> Cmd msg
port jsLoadHives : { apiaryId : String, deepLinkId : String } -> Cmd msg
port jsCreateHive : { apiaryId : String, name : String, frameType : String } -> Cmd msg
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
port jsShareApiary : { apiaryId : String, email : String, role : String } -> Cmd msg
port jsRemoveMember : { apiaryId : String, memberKey : String } -> Cmd msg
port jsUpdateHiveName : { apiaryId : String, hiveId : String, newName : String } -> Cmd msg
port jsDeleteHive : { apiaryId : String, hiveId : String } -> Cmd msg
port jsCopyText : String -> Cmd msg
port jsSaveApiaryOrders : List Apiary -> Cmd msg
port jsSaveHiveOrders : { apiaryId : String, hives : List Hive } -> Cmd msg
port jsSaveUlikOrders : { apiaryId : String, uliki : List UlikWeselny } -> Cmd msg
port jsLoadUserSettings : { uid : String, email : String } -> Cmd msg
port jsSaveUserSettings : { uid : String, email : String, frameTypes : List String, ulikTypes : List String, breedLines : List String, darkMode : Bool, hatchingToMatingDays : Int, maxUlikHistoryLimit : Int, enableTrutowiska : Bool, enablePasieczyskaTowarowe : Bool } -> Cmd msg

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
port userSettingsReceived : (Value -> msg) -> Sub msg

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
        , hatchingToMatingDays = model.hatchingToMatingDays
        , maxUlikHistoryLimit = model.maxUlikHistoryLimit
        , enableTrutowiska = model.enableTrutowiska
        , enablePasieczyskaTowarowe = model.enablePasieczyskaTowarowe
        }

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

        ToggleEnableTrutowiska ->
            let
                newEnable = not model.enableTrutowiska
                newFilter = if not newEnable && model.apiaryFilter == "trutowisko" then "all" else model.apiaryFilter
                newModel = { model | enableTrutowiska = newEnable, apiaryFilter = newFilter }
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
                newModel = { model | enablePasieczyskaTowarowe = newEnable, apiaryFilter = newFilter }
                cmd =
                    case model.authState of
                        LoggedIn user ->
                            saveSettings user newModel
                        _ ->
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
                , Cmd.batch [ jsLoadApiaries uid, jsLoadUserSettings { uid = uid, email = email } ]
                )

        LoadApiariesData uid ->
            ( model, jsLoadApiaries uid )

        UserSettingsReceived result ->
            case result of
                Ok settings ->
                    ( { model | frameTypes = settings.frameTypes, ulikTypes = settings.ulikTypes, breedLines = settings.breedLines, darkMode = settings.darkMode, hatchingToMatingDays = settings.hatchingToMatingDays, maxUlikHistoryLimit = settings.maxUlikHistoryLimit, enableTrutowiska = settings.enableTrutowiska, enablePasieczyskaTowarowe = settings.enablePasieczyskaTowarowe }, Cmd.none )
                Err _ ->
                    ( model, Cmd.none )

        ApiariesDecoded result ->
            case result of
                Ok list ->
                    ( { model | apiaries = list }, Cmd.none )
                Err err ->
                    ( { model | errorMessage = Just ("Błąd dekodowania pasieczysk: " ++ err) }, Cmd.none )

        NavigateTo state ->
            let
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
            ( { model | viewState = state, ulikFilter = "all" }, cmds )

        OpenNewApiaryModal ->
            ( { model | showNewApiaryModal = True, newApiaryName = "", newApiaryType = if model.enablePasieczyskaTowarowe then "towarowe" else "trutowisko" }, Cmd.none )

        SetApiaryFilter filter ->
            ( { model | apiaryFilter = filter }, Cmd.none )

        SetUlikFilter filter ->
            ( { model | ulikFilter = filter }, Cmd.none )

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
                                    ( { model | hives = list, pendingDeepLink = Nothing, viewState = HiveDetailView { apiaryId = actualApiaryId, hiveId = hiveId, hiveName = hiveName } }
                                    , jsLoadNotes { apiaryId = actualApiaryId, hiveId = hiveId }
                                    )
                                _ ->
                                    ( { model | hives = list }, Cmd.none )
                    in
                    ( updatedModel, extraCmd )
                Err err ->
                    ( { model | errorMessage = Just ("Błąd dekodowania uli: " ++ err) }, Cmd.none )

        UlikiDecoded result ->
            case result of
                Ok list ->
                    let
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
                                    ( { model | uliki = list, pendingDeepLink = Nothing, viewState = UlikDetailView { apiaryId = actualApiaryId, ulikId = ulikId, ulikName = ulikName } }
                                    , Cmd.none
                                    )
                                _ ->
                                    ( { model | uliki = list }, Cmd.none )
                    in
                    ( updatedModel, extraCmd )
                Err err ->
                    ( { model | errorMessage = Just ("Błąd dekodowania ulików weselnych: " ++ err) }, Cmd.none )

        OpenNewHiveModal ->
            ( { model | showNewHiveModal = True, newHiveName = "", newHiveFrameType = "Dadant" }, Cmd.none )

        CloseNewHiveModal ->
            ( { model | showNewHiveModal = False }, Cmd.none )

        UpdateNewHiveName name ->
            ( { model | newHiveName = name }, Cmd.none )

        UpdateNewHiveFrameType ft ->
            ( { model | newHiveFrameType = ft }, Cmd.none )

        SubmitCreateHive apiaryId ->
            ( { model | showNewHiveModal = False }
            , jsCreateHive { apiaryId = apiaryId, name = model.newHiveName, frameType = model.newHiveFrameType }
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

        UpdateHiveField apiaryId hiveId field value ->
            ( model, jsUpdateHive { apiaryId = apiaryId, hiveId = hiveId, field = field, value = value } )

        AddKorpusAbove apiaryId hiveId idx ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
                korpusy = case maybeHive of
                    Just h -> h.korpusy
                    Nothing -> [ { id = "1", hasQueen = False, hasExcluderAbove = False } ]
                newKorpusy = addKorpusAbove idx korpusy
            in
            updateKorpusyForHive apiaryId hiveId newKorpusy model

        AddKorpusBelow apiaryId hiveId idx ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
                korpusy = case maybeHive of
                    Just h -> h.korpusy
                    Nothing -> [ { id = "1", hasQueen = False, hasExcluderAbove = False } ]
                newKorpusy = addKorpusBelow idx korpusy
            in
            updateKorpusyForHive apiaryId hiveId newKorpusy model

        AddKorpusBetween apiaryId hiveId idx ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
                korpusy = case maybeHive of
                    Just h -> h.korpusy
                    Nothing -> [ { id = "1", hasQueen = False, hasExcluderAbove = False } ]
                newKorpusy = addKorpusBetween idx korpusy
            in
            updateKorpusyForHive apiaryId hiveId newKorpusy model

        DeleteKorpus apiaryId hiveId korpusId ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
                korpusy = case maybeHive of
                    Just h -> h.korpusy
                    Nothing -> [ { id = "1", hasQueen = False, hasExcluderAbove = False } ]
                newKorpusy = deleteKorpus korpusId korpusy
            in
            updateKorpusyForHive apiaryId hiveId newKorpusy model

        ToggleKorpusQueen apiaryId hiveId korpusId ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
                korpusy = case maybeHive of
                    Just h -> h.korpusy
                    Nothing -> [ { id = "1", hasQueen = False, hasExcluderAbove = False } ]
                newKorpusy = toggleKorpusQueen korpusId korpusy
            in
            updateKorpusyForHive apiaryId hiveId newKorpusy model

        ToggleKorpusExcluder apiaryId hiveId korpusId ->
            let
                maybeHive = List.head (List.filter (\h -> h.id == hiveId) model.hives)
                korpusy = case maybeHive of
                    Just h -> h.korpusy
                    Nothing -> [ { id = "1", hasQueen = False, hasExcluderAbove = False } ]
                newKorpusy = toggleKorpusExcluder korpusId korpusy
            in
            updateKorpusyForHive apiaryId hiveId newKorpusy model

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

        UpdateShareEmail email ->
            ( { model | shareEmailInput = email }, Cmd.none )

        UpdateShareRole role ->
            ( { model | shareRoleInput = role }, Cmd.none )

        SubmitShareApiary apiaryId email role ->
            ( { model | shareEmailInput = "" }
            , jsShareApiary { apiaryId = apiaryId, email = email, role = role }
            )

        SubmitRemoveMember apiaryId memberKey ->
            ( model, jsRemoveMember { apiaryId = apiaryId, memberKey = memberKey } )

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

        MoveApiaryUp id ->
            let
                newApiaries = moveUp id model.apiaries
            in
            ( { model | apiaries = newApiaries }, jsSaveApiaryOrders newApiaries )

        MoveApiaryDown id ->
            let
                newApiaries = moveDown id model.apiaries
            in
            ( { model | apiaries = newApiaries }, jsSaveApiaryOrders newApiaries )

        MoveHiveUp id ->
            let
                newHives = moveUp id model.hives
                maybeApiaryId = case model.viewState of
                    HiveListView info -> Just info.apiaryId
                    HiveDetailView info -> Just info.apiaryId
                    _ -> Nothing
                cmd = case maybeApiaryId of
                    Just aid -> jsSaveHiveOrders { apiaryId = aid, hives = newHives }
                    Nothing -> Cmd.none
            in
            ( { model | hives = newHives }, cmd )

        MoveHiveDown id ->
            let
                newHives = moveDown id model.hives
                maybeApiaryId = case model.viewState of
                    HiveListView info -> Just info.apiaryId
                    HiveDetailView info -> Just info.apiaryId
                    _ -> Nothing
                cmd = case maybeApiaryId of
                    Just aid -> jsSaveHiveOrders { apiaryId = aid, hives = newHives }
                    Nothing -> Cmd.none
            in
            ( { model | hives = newHives }, cmd )

        MoveUlikUp id ->
            let
                newUliki = moveUp id model.uliki
                maybeApiaryId = case model.viewState of
                    UlikListView info -> Just info.apiaryId
                    UlikDetailView info -> Just info.apiaryId
                    _ -> Nothing
                cmd = case maybeApiaryId of
                    Just aid -> jsSaveUlikOrders { apiaryId = aid, uliki = newUliki }
                    Nothing -> Cmd.none
            in
            ( { model | uliki = newUliki }, cmd )

        MoveUlikDown id ->
            let
                newUliki = moveDown id model.uliki
                maybeApiaryId = case model.viewState of
                    UlikListView info -> Just info.apiaryId
                    UlikDetailView info -> Just info.apiaryId
                    _ -> Nothing
                cmd = case maybeApiaryId of
                    Just aid -> jsSaveUlikOrders { apiaryId = aid, uliki = newUliki }
                    Nothing -> Cmd.none
            in
            ( { model | uliki = newUliki }, cmd )

        UpdatePollenTrap apiaryId hiveId trap ->
            ( model, jsUpdateHive { apiaryId = apiaryId, hiveId = hiveId, field = "pollenTrap", value = trap } )

        CopyUserId uid ->
            ( model, jsCopyText uid )

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
        , successMessageReceived SuccessMessageReceived
        , todayReceived CurrentDateReceived
        , userSettingsReceived (\val -> UserSettingsReceived (Result.mapError Decode.errorToString (Decode.decodeValue decodeUserSettings val)))
        ]

-- VIEW

view : Model -> Html Msg
view model =
    let
        bgColor = if model.darkMode then "#121212" else "#f7f9fa"
        textColor = if model.darkMode then "#e0e0e0" else "#333333"
    in
    div [ style "padding" "20px", style "max-width" "800px", style "margin" "0 auto", style "background-color" bgColor, style "color" textColor, style "min-height" "100vh", style "position" "relative" ]
        [ headerView model
        , notificationsView model
        , case model.authState of
            LoggedOut ->
                loginView model

            LoggedIn user ->
                case model.viewState of
                    LoginView ->
                        apiariesView user model

                    ApiariesView ->
                        apiariesView user model

                    HiveListView info ->
                        hiveListView user info model

                    HiveDetailView info ->
                        hiveDetailView user info model

                    UlikListView info ->
                        ulikListView user info model

                    UlikDetailView info ->
                        ulikDetailView user info model

                    SharingView info ->
                        sharingView user info model

                    SettingsView ->
                        settingsView user model
        , modalsView model
        ]

headerView : Model -> Html Msg
headerView model =
    div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "border-bottom" "1px solid #ddd", style "padding-bottom" "10px", style "margin-bottom" "20px" ]
        [ h1 [ style "margin" "0", style "color" (if model.darkMode then "#ffffff" else "#2c3e50") ] [ text "BeeLog 🐝" ]
        , case model.authState of
            LoggedIn user ->
                div [ style "display" "flex", style "align-items" "center", style "gap" "10px" ]
                    [ button [ onClick (NavigateTo SettingsView), style "padding" "6px 12px", style "background-color" "#7f8c8d", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "⚙️ Ustawienia" ]
                    , span [ style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#666") ] [ text user.email ]
                    , button [ onClick ClickLogout, style "padding" "6px 12px", style "background-color" "#e74c3c", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Wyloguj się" ]
                    ]
            LoggedOut ->
                text ""
        ]

notificationsView : Model -> Html Msg
notificationsView model =
    div []
        [ case model.errorMessage of
            Just err ->
                div [ style "background-color" "#fadbd8", style "color" "#900c3f", style "padding" "10px", style "border-radius" "4px", style "margin-bottom" "15px", style "display" "flex", style "justify-content" "space-between" ]
                    [ span [] [ text err ]
                    , button [ onClick ClearMessages, style "background" "none", style "border" "none", style "cursor" "pointer" ] [ text "✕" ]
                    ]
            Nothing ->
                text ""
        , case model.successMessage of
            Just succ ->
                div [ style "background-color" "#d4efdf", style "color" "#145a32", style "padding" "10px", style "border-radius" "4px", style "margin-bottom" "15px", style "display" "flex", style "justify-content" "space-between" ]
                    [ span [] [ text succ ]
                    , button [ onClick ClearMessages, style "background" "none", style "border" "none", style "cursor" "pointer" ] [ text "✕" ]
                    ]
            Nothing ->
                text ""
        ]

loginView : Model -> Html Msg
loginView model =
    let
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
    in
    div [ style "text-align" "center", style "padding" "40px", style "background" cardBg, style "color" textColor, style "border-radius" "8px", style "box-shadow" "0 2px 4px rgba(0,0,0,0.1)" ]
        [ h2 [ style "color" headingColor ] [ text "Witaj w BeeLog" ]
        , p [ style "color" (if model.darkMode then "#b0b0b0" else "#666"), style "margin-bottom" "30px" ] [ text "Zarządzaj pasieką, ulami i notatkami głosowymi w terenie." ]
        , button [ onClick ClickLoginGoogle, style "padding" "12px 24px", style "background-color" "#4285F4", style "color" "white", style "border" "none", style "border-radius" "4px", style "font-size" "16px", style "cursor" "pointer" ] [ text "Zaloguj przez Google" ]
        ]

sharingView : User -> { apiaryId : String, apiaryName : String } -> Model -> Html Msg
sharingView user info model =
    let
        maybeApiary = List.head (List.filter (\a -> a.id == info.apiaryId) model.apiaries)
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"
        metaBg = if model.darkMode then "#2d2d2d" else "#f1f2f6"
    in
    case maybeApiary of
        Just apiary ->
            div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "color" textColor ]
                [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px" ]
                    [ button [ onClick (NavigateTo ApiariesView), style "padding" "6px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "← Powrót" ]
                    , h2 [ style "margin" "0", style "color" headingColor ] [ text ("Udostępnianie pasieki: " ++ info.apiaryName) ]
                    ]
                , div [ style "margin-bottom" "20px", style "padding" "15px", style "background" metaBg, style "border-radius" "6px" ]
                    [ h3 [ style "margin-top" "0", style "color" headingColor ] [ text "Identyfikator Pasiecznika (Właściciela)" ]
                    , div [ style "display" "flex", style "gap" "10px", style "align-items" "center" ]
                        [ input [ type_ "text", value user.uid, readonly True, style "flex" "1", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                        , button [ onClick (CopyUserId user.uid), style "padding" "8px 12px", style "background" "#2980b9", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "📋 Kopiuj ID" ]
                        ]
                    ]
                , div [ style "margin-bottom" "20px" ]
                    [ h3 [ style "color" headingColor ] [ text "Przyznaj dostęp nowemu użytkownikowi" ]
                    , div [ style "display" "flex", style "gap" "10px" ]
                        [ input [ type_ "email", placeholder "Adres e-mail użytkownika", value model.shareEmailInput, onInput UpdateShareEmail, style "flex" "1", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                        , select [ value model.shareRoleInput, onInput UpdateShareRole, style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                            [ option [ value "edit" ] [ text "Edytor" ]
                            , option [ value "view" ] [ text "Tylko podgląd" ]
                            ]
                        , button [ onClick (SubmitShareApiary info.apiaryId model.shareEmailInput model.shareRoleInput), style "padding" "8px 16px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Przyznaj dostęp" ]
                        ]
                    ]
                , h3 [ style "color" headingColor ] [ text "Aktualni członkowie i uprawnienia" ]
                , ul [ style "list-style" "none", style "padding" "0" ]
                    (List.map (memberItemView model info.apiaryId) apiary.members)
                ]
        _ ->
            div [] [ text "Ładowanie pasieki..." ]

memberItemView : Model -> String -> ( String, String ) -> Html Msg
memberItemView model apiaryId ( email, role ) =
    let
        borderColor = if model.darkMode then "#333" else "#eee"
    in
    li [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "padding" "10px", style "border-bottom" ("1px solid " ++ borderColor) ]
        [ span [] [ text (email ++ " (" ++ role ++ ")") ]
        , if role /= "owner" then
            button [ onClick (SubmitRemoveMember apiaryId email), style "background" "#e74c3c", style "color" "white", style "border" "none", style "padding" "4px 8px", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Cofnij dostęp" ]
          else
            span [ style "font-size" "12px", style "color" (if model.darkMode then "#95a5a6" else "#7f8c8d") ] [ text "Właściciel (stały)" ]
        ]

modalsView : Model -> Html Msg
modalsView model =
    let
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"
    in
    div []
        [ if model.showNewApiaryModal then
            div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                    [ h3 [ style "color" headingColor ] [ text "Nowe Pasieczysko" ]
                    , label [] [ text "Nazwa pasieczyska:" ]
                    , input [ type_ "text", placeholder "Nazwa pasieczyska", value model.newApiaryName, onInput UpdateNewApiaryName, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                    , label [] [ text "Typ pasieczyska:" ]
                    , select [ value (if model.enablePasieczyskaTowarowe && (model.newApiaryType == "towarowe" || not model.enableTrutowiska) then "towarowe" else "trutowisko"), onInput UpdateNewApiaryType, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                        ((if model.enablePasieczyskaTowarowe then
                            [ option [ value "towarowe" ] [ text "Pasieczysko towarowe" ] ]
                          else
                            []
                         )
                         ++ (if model.enableTrutowiska then
                                [ option [ value "trutowisko" ] [ text "Trutowisko (uliki weselne)" ] ]
                            else
                                []
                            )
                        )
                    , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                        [ button [ onClick CloseNewApiaryModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Anuluj" ]
                        , button [ onClick SubmitCreateApiary, style "padding" "8px 12px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Zapisz" ]
                        ]
                    ]
                ]
          else
            text ""
        , case model.showEditApiaryModal of
            Just apiary ->
                div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                    [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                        [ h3 [ style "color" headingColor ] [ text "Edytuj Nazwę Pasieczyska" ]
                        , input [ type_ "text", value model.editApiaryNameInput, onInput UpdateEditApiaryNameInput, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseEditApiaryModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Anuluj" ]
                            , button [ onClick SubmitUpdateApiary, style "padding" "8px 12px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Zapisz" ]
                            ]
                        ]
                    ]
            Nothing ->
                text ""
        , case model.showDeleteApiaryModal of
            Just apiary ->
                div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                    [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                        [ h3 [ style "color" headingColor ] [ text "Usuń Pasieczysko" ]
                        , p [] [ text ("Czy na pewno chcesz usunąć pasieczysko \"" ++ apiary.name ++ "\" wraz ze wszystkimi ulami i notatkami?") ]
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseDeleteApiaryModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Anuluj" ]
                            , button [ onClick (SubmitDeleteApiary apiary.id), style "padding" "8px 12px", style "background" "#e74c3c", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Potwierdź usunięcie" ]
                            ]
                        ]
                    ]
            Nothing ->
                text ""
        , if model.showNewHiveModal then
            div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                    [ h3 [ style "color" headingColor ] [ text "Nowy Ul" ]
                    , label [] [ text "Nazwa / Numer ula:" ]
                    , input [ type_ "text", placeholder "np. Ul #04", value model.newHiveName, onInput UpdateNewHiveName, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                    , label [] [ text "Typ ramki:" ]
                    , select [ value model.newHiveFrameType, onInput UpdateNewHiveFrameType, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                        (List.map (\ft -> option [ value ft, selected (model.newHiveFrameType == ft) ] [ text ft ]) model.frameTypes)
                    , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                        [ button [ onClick CloseNewHiveModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Anuluj" ]
                        , case model.viewState of
                            HiveListView info ->
                                button [ onClick (SubmitCreateHive info.apiaryId), style "padding" "8px 12px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Zapisz" ]
                            _ ->
                                text ""
                        ]
                    ]
                ]
          else
            text ""
        , if model.showNewUlikModal then
            div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                    [ h3 [ style "color" headingColor ] [ text "Nowy Ulik Weselny" ]
                    , label [] [ text "Nazwa / Numer uliku:" ]
                    , input [ type_ "text", placeholder "np. Ulik #01", value model.newUlikName, onInput UpdateNewUlikName, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                    , label [] [ text "Typ ula:" ]
                    , select [ value model.newUlikHiveType, onInput UpdateNewUlikHiveType, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                        (List.map (\ut -> option [ value ut, selected (model.newUlikHiveType == ut) ] [ text ut ]) model.ulikTypes)
                    , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                        [ button [ onClick CloseNewUlikModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Anuluj" ]
                        , case model.viewState of
                            UlikListView info ->
                                button [ onClick (SubmitCreateUlik info.apiaryId), style "padding" "8px 12px", style "background" "#8e44ad", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Zapisz" ]
                            _ ->
                                text ""
                        ]
                    ]
                ]
          else
            text ""
        , case model.showRenameHiveModal of
            Just info ->
                div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                    [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                        [ h3 [ style "color" headingColor ] [ text "Zmień nazwę ula" ]
                        , input [ type_ "text", value model.renameHiveInput, onInput UpdateRenameHiveInput, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseRenameHiveModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Anuluj" ]
                            , button [ onClick (SubmitRenameHive info.apiaryId info.hiveId), style "padding" "8px 12px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Zapisz" ]
                            ]
                        ]
                    ]
            Nothing ->
                text ""
        , case model.showDeleteHiveModal of
            Just info ->
                div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                    [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                        [ h3 [ style "color" headingColor ] [ text "Usuń ul" ]
                        , p [] [ text ("Czy na pewno chcesz usunąć ul \"" ++ info.hiveName ++ "\" wraz ze wszystkimi notatkami?") ]
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseDeleteHiveModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Anuluj" ]
                            , button [ onClick (SubmitDeleteHive info.apiaryId info.hiveId), style "padding" "8px 12px", style "background" "#e74c3c", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Potwierdź usunięcie" ]
                            ]
                        ]
                    ]
            Nothing ->
                text ""
        , case model.showRenameUlikModal of
            Just info ->
                div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                    [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                        [ h3 [ style "color" headingColor ] [ text "Zmień nazwę uliku" ]
                        , input [ type_ "text", value model.renameUlikInput, onInput UpdateRenameUlikInput, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseRenameUlikModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Anuluj" ]
                            , button [ onClick (SubmitRenameUlik info.apiaryId info.ulikId), style "padding" "8px 12px", style "background" "#8e44ad", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Zapisz" ]
                            ]
                        ]
                    ]
            Nothing ->
                text ""
        , case model.showDeleteUlikModal of
            Just info ->
                div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                    [ div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" textColor ]
                        [ h3 [ style "color" headingColor ] [ text "Usuń ulik weselny" ]
                        , p [] [ text ("Czy na pewno chcesz usunąć ulik \"" ++ info.ulikName ++ "\" wraz ze wszystkimi notatkami?") ]
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseDeleteUlikModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Anuluj" ]
                            , button [ onClick (SubmitDeleteUlik info.apiaryId info.ulikId), style "padding" "8px 12px", style "background" "#e74c3c", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Potwierdź usunięcie" ]
                            ]
                        ]
                    ]
            Nothing ->
                text ""
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
                        [ h3 [ style "color" headingColor ] [ text ("Przenieś ulik: " ++ info.ulikName) ]
                        , p [] [ text "Wybierz docelowe trutowisko:" ]
                        , if List.isEmpty otherTrutowiska then
                            p [ style "color" "#e74c3c" ] [ text "Brak innych trutowisk do wyboru." ]
                          else
                            select [ onInput SelectMoveUlikTargetApiary, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                (List.map (\a -> option [ value a.id, selected (targetId == a.id) ] [ text a.name ]) otherTrutowiska)
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseMoveUlikModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Anuluj" ]
                            , if not (List.isEmpty otherTrutowiska) then
                                button [ onClick (SubmitMoveUlik info.sourceApiaryId info.ulikId targetId), style "padding" "8px 12px", style "background" "#e67e22", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Przenieś" ]
                              else
                                text ""
                            ]
                        ]
                    ]
            Nothing ->
                text ""
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
                                [ label [] [ text "Rasa i linia matki:" ]
                                , select [ onInput UpdateModalBreedLine, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                    (List.map (\bl -> option [ value bl, selected (model.modalBreedLine == bl) ] [ text bl ]) model.breedLines)
                                , label [] [ text "Spodziewany termin wygryzienia:" ]
                                , input [ type_ "date", value model.modalHatchDate, onInput UpdateModalHatchDate, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                                ]
                          else
                            text ""
                        , if info.modalType == ModalPoddajMatkeNieunasiennioną then
                            div []
                                [ label [] [ text "Czy opalitkowana?" ]
                                , select [ onInput UpdateModalIsOpalitkovana, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                    [ option [ value "Nie", selected (model.modalIsOpalitkovana == "Nie") ] [ text "Nie" ]
                                    , option [ value "Tak", selected (model.modalIsOpalitkovana == "Tak") ] [ text "Tak" ]
                                    ]
                                ]
                          else
                            text ""
                        , if info.modalType == ModalZaopalitkuj || (info.modalType == ModalPoddajMatkeNieunasiennioną && model.modalIsOpalitkovana == "Tak") then
                            div []
                                [ label [] [ text "Kolor Opalitka:" ]
                                , select [ onInput UpdateModalOpalitColor, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                    [ option [ value "Biały", selected (model.modalOpalitColor == "Biały") ] [ text "Biały" ]
                                    , option [ value "Żółty", selected (model.modalOpalitColor == "Żółty") ] [ text "Żółty" ]
                                    , option [ value "Czerwony", selected (model.modalOpalitColor == "Czerwony") ] [ text "Czerwony" ]
                                    , option [ value "Zielony", selected (model.modalOpalitColor == "Zielony") ] [ text "Zielony" ]
                                    , option [ value "Niebieski", selected (model.modalOpalitColor == "Niebieski") ] [ text "Niebieski" ]
                                    ]
                                , label [] [ text "Numer Opalitka:" ]
                                , input [ type_ "text", placeholder "np. 42", value model.modalOpalitNumber, onInput UpdateModalOpalitNumber, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                                ]
                          else
                            text ""
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseUlikModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Anuluj" ]
                            , button [ onClick (SubmitUlikModal info.apiaryId info.ulikId info.modalType), style "padding" "8px 12px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Zapisz" ]
                            ]
                        ]
                    ]
            Nothing ->
                text ""
        ]

moveUp : String -> List { r | id : String } -> List { r | id : String }
moveUp targetId list =
    let
        helper acc prev rest =
            case rest of
                [] ->
                    List.reverse acc
                x :: y :: xs ->
                    if y.id == targetId then
                        List.reverse acc ++ y :: x :: xs
                    else
                        helper (x :: acc) y (y :: xs)
                [x] ->
                    List.reverse acc ++ [x]
    in
    case list of
        x :: y :: xs ->
            if y.id == targetId then
                y :: x :: xs
            else
                helper [x] y (y :: xs)
        _ ->
            list

moveDown : String -> List { r | id : String } -> List { r | id : String }
moveDown targetId list =
    List.reverse (moveUp targetId (List.reverse list))

hiveSnapshotText : Hive -> String
hiveSnapshotText hive =
    let
        opalitText = if hive.queen.hasOpalit then "Tak (Kolor: " ++ hive.queen.color ++ ", Nr: " ++ hive.queen.number ++ ")" else "Nie"
        pollenText = case hive.pollenTrap of
            "powałkowy" -> "Powałkowy"
            "dennicowy" -> "Dennicowy"
            _ -> "Brak"
    in
    String.join "\n"
        [ "📸 Zrzut Stanu Ula:"
        , "Nazwa: " ++ hive.name
        , "Typ ramki: " ++ hive.frameType
        , "Poławiacz pyłku: " ++ pollenText
        , "Link NFC: " ++ (if hive.nfcLink == "" then "Brak" else hive.nfcLink)
        , "Matka pszczela (opalitek): " ++ opalitText
        ]

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

addKorpusAbove : Int -> List Korpus -> List Korpus
addKorpusAbove idx korpusy =
    let
        maxId = Maybe.withDefault 0 (List.maximum (List.filterMap (\k -> String.toInt k.id) korpusy))
        newId = String.fromInt (maxId + 1)
        newKorpus = { id = newId, hasQueen = False, hasExcluderAbove = False }
    in
    if idx <= 0 then
        newKorpus :: korpusy
    else
        List.take idx korpusy ++ [ newKorpus ] ++ List.drop idx korpusy

addKorpusBelow : Int -> List Korpus -> List Korpus
addKorpusBelow idx korpusy =
    addKorpusBetween idx korpusy

addKorpusBetween : Int -> List Korpus -> List Korpus
addKorpusBetween idx korpusy =
    let
        maxId = Maybe.withDefault 0 (List.maximum (List.filterMap (\k -> String.toInt k.id) korpusy))
        newId = String.fromInt (maxId + 1)
        newKorpus = { id = newId, hasQueen = False, hasExcluderAbove = False }
    in
    List.take (idx + 1) korpusy ++ [ newKorpus ] ++ List.drop (idx + 1) korpusy

deleteKorpus : String -> List Korpus -> List Korpus
deleteKorpus targetId korpusy =
    let
        filtered = List.filter (\k -> k.id /= targetId) korpusy
    in
    if List.isEmpty filtered then
        [ { id = "1", hasQueen = False, hasExcluderAbove = False } ]
    else
        filtered

toggleKorpusQueen : String -> List Korpus -> List Korpus
toggleKorpusQueen targetId korpusy =
    List.map (\k -> if k.id == targetId then { k | hasQueen = not k.hasQueen } else k) korpusy

toggleKorpusExcluder : String -> List Korpus -> List Korpus
toggleKorpusExcluder targetId korpusy =
    List.map (\k -> if k.id == targetId then { k | hasExcluderAbove = not k.hasExcluderAbove } else k) korpusy

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
