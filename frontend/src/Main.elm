port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (Value)
import Types exposing (..)

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

-- MODEL

type AuthState
    = LoggedOut
    | LoggedIn User

type ViewState
    = LoginView
    | ApiariesView
    | HiveListView { apiaryId : String, apiaryName : String }
    | HiveDetailView { apiaryId : String, hiveId : String, hiveName : String }
    | UlikListView { apiaryId : String, apiaryName : String }
    | UlikDetailView { apiaryId : String, ulikId : String, ulikName : String }
    | SharingView { apiaryId : String, apiaryName : String }
    | SettingsView

type alias Model =
    { authState : AuthState
    , viewState : ViewState
    , apiaries : List Apiary
    , hives : List Hive
    , uliki : List UlikWeselny
    , notes : List Note
    , errorMessage : Maybe String
    , successMessage : Maybe String
    , darkMode : Bool
    -- Modals & Inputs
    , showNewApiaryModal : Bool
    , newApiaryName : String
    , newApiaryType : String
    , showEditApiaryModal : Maybe Apiary
    , editApiaryNameInput : String
    , showDeleteApiaryModal : Maybe Apiary
    , showNewHiveModal : Bool
    , newHiveName : String
    , newHiveFrameType : String
    , showNewUlikModal : Bool
    , newUlikName : String
    , newUlikHiveType : String
    , newNoteText : String
    , editingNoteId : Maybe String
    , editNoteText : String
    , shareEmailInput : String
    , shareRoleInput : String
    , showRenameHiveModal : Maybe { apiaryId : String, hiveId : String, hiveName : String }
    , renameHiveInput : String
    , showDeleteHiveModal : Maybe { apiaryId : String, hiveId : String, hiveName : String }
    , showRenameUlikModal : Maybe { apiaryId : String, ulikId : String, ulikName : String }
    , renameUlikInput : String
    , showDeleteUlikModal : Maybe { apiaryId : String, ulikId : String, ulikName : String }
    , currentDate : String
    , apiaryFilter : String
    , ulikFilter : String
    , frameTypes : List String
    , newFrameTypeInput : String
    }

init : () -> ( Model, Cmd Msg )
init _ =
    ( { authState = LoggedOut
      , viewState = LoginView
      , apiaries = []
      , hives = []
      , uliki = []
      , notes = []
      , errorMessage = Nothing
      , successMessage = Nothing
      , darkMode = False
      , currentDate = ""
      , apiaryFilter = "all"
      , ulikFilter = "all"
      , frameTypes = [ "Wielkopolska", "Wielkopolska 18", "Wielkopolska 1/2", "Warszawska zwykła", "MiniPlus", "Dadant" ]
      , newFrameTypeInput = ""
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
      }
    , Cmd.none
    )

-- PORTS (OUT)

port jsLoginGoogle : () -> Cmd msg
port jsLogout : () -> Cmd msg
port jsLoadApiaries : String -> Cmd msg
port jsCreateApiary : { name : String, apiaryType : String, uid : String } -> Cmd msg
port jsUpdateApiary : { apiaryId : String, name : String } -> Cmd msg
port jsDeleteApiary : { apiaryId : String } -> Cmd msg
port jsLoadHives : { apiaryId : String } -> Cmd msg
port jsCreateHive : { apiaryId : String, name : String, frameType : String } -> Cmd msg
port jsUpdateHive : { apiaryId : String, hiveId : String, field : String, value : String } -> Cmd msg
port jsLoadUliki : { apiaryId : String } -> Cmd msg
port jsCreateUlik : { apiaryId : String, name : String, hiveType : String } -> Cmd msg
port jsUpdateUlik : { apiaryId : String, ulikId : String, field : String, value : String } -> Cmd msg
port jsUpdateUlikName : { apiaryId : String, ulikId : String, newName : String } -> Cmd msg
port jsDeleteUlik : { apiaryId : String, ulikId : String } -> Cmd msg
port jsStartNfcScan : () -> Cmd msg
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
port jsLoadUserSettings : { uid : String } -> Cmd msg
port jsSaveUserSettings : { uid : String, frameTypes : List String } -> Cmd msg

-- PORTS (IN)

port authStateChanged : ({ uid : String, email : String } -> msg) -> Sub msg
port apiariesReceived : (Value -> msg) -> Sub msg
port hivesReceived : (Value -> msg) -> Sub msg
port ulikiReceived : (Value -> msg) -> Sub msg
port notesReceived : (Value -> msg) -> Sub msg
port nfcScanned : (String -> msg) -> Sub msg
port speechRecognized : (String -> msg) -> Sub msg
port operationError : (String -> msg) -> Sub msg
port successMessageReceived : (String -> msg) -> Sub msg
port todayReceived : (String -> msg) -> Sub msg
port userSettingsReceived : (Value -> msg) -> Sub msg

-- MESSAGES

type Msg
    = ClickLoginGoogle
    | ClickLogout
    | ToggleDarkMode
    | AuthStateUpdated { uid : String, email : String }
    | CurrentDateReceived String
    | UserSettingsReceived (Result String (List String))
    | LoadApiariesData String
    | ApiariesDecoded (Result String (List Apiary))
    | NavigateTo ViewState
    -- Apiary actions
    | OpenNewApiaryModal
    | CloseNewApiaryModal
    | UpdateNewApiaryName String
    | UpdateNewApiaryType String
    | SubmitCreateApiary
    | OpenEditApiaryModal Apiary
    | CloseEditApiaryModal
    | UpdateEditApiaryNameInput String
    | SubmitUpdateApiary
    | OpenDeleteApiaryModal Apiary
    | CloseDeleteApiaryModal
    | SubmitDeleteApiary String
    | SetApiaryFilter String
    | SetUlikFilter String
    | UpdateNewFrameTypeInput String
    | AddFrameType String
    | RemoveFrameType String
    -- Hive actions
    | HivesDecoded (Result String (List Hive))
    | OpenNewHiveModal
    | CloseNewHiveModal
    | UpdateNewHiveName String
    | UpdateNewHiveFrameType String
    | SubmitCreateHive String
    | UpdateHiveField String String String String
    -- Ulik actions
    | UlikiDecoded (Result String (List UlikWeselny))
    | OpenNewUlikModal
    | CloseNewUlikModal
    | UpdateNewUlikName String
    | UpdateNewUlikHiveType String
    | SubmitCreateUlik String
    | UpdateUlikField String String String String
    | TransitionUlikState String String UlikState
    -- NFC & Notes
    | StartNfcScan
    | NfcResultReceived String
    | NotesDecoded (Result String (List Note))
    | UpdateNewNoteText String
    | StartSpeechDictation
    | SpeechResultReceived String
    | SubmitSaveNote String String String String String
    | StartEditNote Note
    | CancelEditNote
    | UpdateEditNoteText String
    | SubmitUpdateNote String String String
    | SubmitDeleteNote String String String
    -- Sharing actions
    | UpdateShareEmail String
    | UpdateShareRole String
    | SubmitShareApiary String String String
    | SubmitRemoveMember String String
    -- Hive Management actions
    | OpenRenameHiveModal String Hive
    | CloseRenameHiveModal
    | UpdateRenameHiveInput String
    | SubmitRenameHive String String
    | OpenDeleteHiveModal String Hive
    | CloseDeleteHiveModal
    | SubmitDeleteHive String String
    -- Ulik Management actions
    | OpenRenameUlikModal String UlikWeselny
    | CloseRenameUlikModal
    | UpdateRenameUlikInput String
    | SubmitRenameUlik String String
    | OpenDeleteUlikModal String UlikWeselny
    | CloseDeleteUlikModal
    | SubmitDeleteUlik String String
    | MoveApiaryUp String
    | MoveApiaryDown String
    | MoveHiveUp String
    | MoveHiveDown String
    | MoveUlikUp String
    | MoveUlikDown String
    -- Pollen Trap & Snapshots
    | UpdatePollenTrap String String String
    | CopyUserId String
    | SubmitHiveSnapshot String String User
    | SubmitUlikSnapshot String String User
    -- Feedback
    | HandleError String
    | SuccessMessageReceived String
    | ClearMessages

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
            ( { model | darkMode = not model.darkMode }, Cmd.none )

        AuthStateUpdated { uid, email } ->
            if uid == "" then
                ( { model | authState = LoggedOut, viewState = LoginView }, Cmd.none )
            else
                let
                    user = { uid = uid, email = email }
                in
                ( { model | authState = LoggedIn user, viewState = ApiariesView }
                , Cmd.batch [ jsLoadApiaries uid, jsLoadUserSettings { uid = uid } ]
                )

        LoadApiariesData uid ->
            ( model, jsLoadApiaries uid )

        UserSettingsReceived result ->
            case result of
                Ok list ->
                    ( { model | frameTypes = list }, Cmd.none )
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
                            jsLoadHives { apiaryId = apiaryId }
                        UlikListView { apiaryId } ->
                            jsLoadUliki { apiaryId = apiaryId }
                        HiveDetailView { apiaryId, hiveId } ->
                            jsLoadNotes { apiaryId = apiaryId, hiveId = hiveId }
                        UlikDetailView { apiaryId, ulikId } ->
                            jsLoadNotes { apiaryId = apiaryId, hiveId = ulikId }
                        _ ->
                            Cmd.none
            in
            ( { model | viewState = state, ulikFilter = "all" }, cmds )

        OpenNewApiaryModal ->
            ( { model | showNewApiaryModal = True, newApiaryName = "", newApiaryType = "towarowe" }, Cmd.none )

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
                    cmd =
                        case model.authState of
                            LoggedIn user ->
                                jsSaveUserSettings { uid = user.uid, frameTypes = updated }
                            _ ->
                                Cmd.none
                in
                ( { model | frameTypes = updated, newFrameTypeInput = "" }, cmd )
            else
                ( { model | newFrameTypeInput = "" }, Cmd.none )

        RemoveFrameType ft ->
            let
                updated = List.filter (\x -> x /= ft) model.frameTypes
                cmd =
                    case model.authState of
                        LoggedIn user ->
                            jsSaveUserSettings { uid = user.uid, frameTypes = updated }
                        _ ->
                            Cmd.none
            in
            ( { model | frameTypes = updated }, cmd )

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
                    ( { model | hives = list }, Cmd.none )
                Err err ->
                    ( { model | errorMessage = Just ("Błąd dekodowania uli: " ++ err) }, Cmd.none )

        UlikiDecoded result ->
            case result of
                Ok list ->
                    ( { model | uliki = list }, Cmd.none )
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
            ( { model | showNewUlikModal = True, newUlikName = "", newUlikHiveType = "Mini plus" }, Cmd.none )

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

        UpdateUlikField apiaryId ulikId field value ->
            let
                updatedUliki =
                    List.map
                        (\u ->
                            if u.id == ulikId then
                                if field == "expectedHatchDate" then
                                    { u | expectedHatchDate = value, expectedMatingDate = addDaysToDateString 10 value }
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
                        , jsUpdateUlik { apiaryId = apiaryId, ulikId = ulikId, field = "expectedMatingDate", value = addDaysToDateString 10 value }
                        ]
                    else
                        [ jsUpdateUlik { apiaryId = apiaryId, ulikId = ulikId, field = field, value = value }
                        ]
            in
            ( { model | uliki = updatedUliki }, Cmd.batch cmds )

        TransitionUlikState apiaryId ulikId newState ->
            ( model, jsUpdateUlik { apiaryId = apiaryId, ulikId = ulikId, field = "state", value = ulikStateToString newState } )

        StartNfcScan ->
            ( model, jsStartNfcScan () )

        NfcResultReceived tagId ->
            case model.viewState of
                HiveDetailView info ->
                    ( { model | successMessage = Just ("Zeskanowano tag NFC: " ++ tagId) }
                    , jsUpdateHive { apiaryId = info.apiaryId, hiveId = info.hiveId, field = "nfcTagId", value = tagId }
                    )
                UlikDetailView info ->
                    ( { model | successMessage = Just ("Zeskanowano tag NFC: " ++ tagId) }
                    , jsUpdateUlik { apiaryId = info.apiaryId, ulikId = info.ulikId, field = "nfcTagId", value = tagId }
                    )
                _ ->
                    ( { model | successMessage = Just ("Zeskanowano tag NFC: " ++ tagId) }, Cmd.none )

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

        SubmitUlikSnapshot apiaryId ulikId user ->
            let
                maybeUlik = List.head (List.filter (\u -> u.id == ulikId) model.uliki)
                snapshotText = case maybeUlik of
                    Just ulik -> ulikSnapshotText ulik
                    Nothing -> "Brak danych uliku"
            in
            ( { model | successMessage = Just "📸 Zapisano zrzut uliku weselnego jako notatkę!" }
            , jsSaveNote
                { apiaryId = apiaryId
                , hiveId = ulikId
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
        , nfcScanned NfcResultReceived
        , speechRecognized SpeechResultReceived
        , operationError HandleError
        , successMessageReceived SuccessMessageReceived
        , todayReceived CurrentDateReceived
        , userSettingsReceived (\val -> UserSettingsReceived (Result.mapError Decode.errorToString (Decode.decodeValue (Decode.field "frameTypes" (Decode.list Decode.string)) val)))
        ]

-- VIEW

view : Model -> Html Msg
view model =
    let
        bgColor = if model.darkMode then "#121212" else "#f7f9fa"
        textColor = if model.darkMode then "#e0e0e0" else "#333333"
    in
    div [ style "padding" "20px", style "max-width" "800px", style "margin" "0 auto", style "background-color" bgColor, style "color" textColor, style "min-height" "100vh", style "position" "relative" ]
        [ darkModeToggleView model.darkMode
        , headerView model
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

darkModeToggleView : Bool -> Html Msg
darkModeToggleView darkMode =
    button
        [ onClick ToggleDarkMode
        , style "position" "fixed"
        , style "top" "20px"
        , style "right" "20px"
        , style "z-index" "9999"
        , style "padding" "8px 14px"
        , style "background-color" (if darkMode then "#f1c40f" else "#2c3e50")
        , style "color" (if darkMode then "#121212" else "#ffffff")
        , style "border" "none"
        , style "border-radius" "20px"
        , style "cursor" "pointer"
        , style "font-size" "14px"
        , style "box-shadow" "0 2px 6px rgba(0,0,0,0.3)"
        ]
        [ text (if darkMode then "☀️ Tryb Jasny" else "🌙 Tryb Ciemny") ]

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
            , h2 [ style "margin" "0", style "color" headingColor ] [ text "⚙️ Ustawienia aplikacji" ]
            ]
        , div [ style "display" "flex", style "flex-direction" "column", style "gap" "20px" ]
            [ div []
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
            ]
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

apiariesView : User -> Model -> Html Msg
apiariesView user model =
    let
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"
        filteredApiaries =
            List.filter
                (\a ->
                    if model.apiaryFilter == "towarowe" then
                        a.apiaryType == "towarowe"
                    else if model.apiaryFilter == "trutowisko" then
                        a.apiaryType == "trutowisko"
                    else
                        True
                )
                model.apiaries
    in
    div []
        [ div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-bottom" "15px" ]
            [ h2 [ style "margin" "0", style "color" (if model.darkMode then "#ffffff" else "inherit") ] [ text "Twoje Pasieczyska" ]
            , button [ onClick OpenNewApiaryModal, style "padding" "10px 16px", style "background-color" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "+ Dodaj Pasieczysko" ]
            ]
        , div [ style "display" "flex", style "gap" "10px", style "align-items" "center", style "margin-bottom" "20px" ]
            [ span [ style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#555") ] [ text "Filtruj typ:" ]
            , select [ onInput SetApiaryFilter, style "padding" "6px 10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ]
                [ option [ value "all", selected (model.apiaryFilter == "all") ] [ text "Wszystkie pasieczyska" ]
                , option [ value "towarowe", selected (model.apiaryFilter == "towarowe") ] [ text "Towarowe" ]
                , option [ value "trutowisko", selected (model.apiaryFilter == "trutowisko") ] [ text "Trutowiska" ]
                ]
            ]
        , div [ style "display" "flex", style "flex-direction" "column", style "gap" "15px" ]
            (List.map (apiaryCardView user model) filteredApiaries)
        ]

apiaryCardView : User -> Model -> Apiary -> Html Msg
apiaryCardView user model apiary =
    let
        isAdmin = apiary.adminId == user.uid
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        borderColor = if model.darkMode then "#333" else "#eee"
        isTrutowisko = apiary.apiaryType == "trutowisko"
        typeLabel = if isTrutowisko then "Trutowisko" else "Pasieczysko Towarowe"
        typeBadgeBg = if isTrutowisko then "#8e44ad" else "#2980b9"
        navTarget = if isTrutowisko then
                        UlikListView { apiaryId = apiary.id, apiaryName = apiary.name }
                    else
                        HiveListView { apiaryId = apiary.id, apiaryName = apiary.name }
    in
    div [ style "background" cardBg, style "padding" "15px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "cursor" "pointer", style "color" textColor ]
        [ div [ onClick (NavigateTo navTarget) ]
            [ div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-bottom" "8px" ]
                [ h3 [ style "margin" "0", style "color" headingColor ] [ text apiary.name ]
                , span [ style "background" typeBadgeBg, style "color" "white", style "padding" "2px 8px", style "border-radius" "12px", style "font-size" "11px" ] [ text typeLabel ]
                ]
            , p [ style "font-size" "12px", style "color" (if model.darkMode then "#95a5a6" else "#7f8c8d"), style "margin" "0" ] [ text (if isAdmin then "Właściciel" else "Udostępnione") ]
            ]
        , div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-top" "10px", style "border-top" ("1px solid " ++ borderColor), style "padding-top" "10px" ]
            [ div [ style "display" "flex", style "gap" "4px" ]
                [ button [ stopPropagationOn "click" (Decode.succeed (MoveApiaryUp apiary.id, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Przesuń w lewo" ] [ text "⬅️" ]
                , button [ stopPropagationOn "click" (Decode.succeed (MoveApiaryDown apiary.id, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Przesuń w prawo" ] [ text "➡️" ]
                ]
            , div [ style "display" "flex", style "gap" "8px" ]
                [ button [ onClick (NavigateTo (SharingView { apiaryId = apiary.id, apiaryName = apiary.name })), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Udostępnij" ] [ text "👥" ]
                , if isAdmin then
                    div [ style "display" "flex", style "gap" "8px" ]
                        [ button [ onClick (OpenEditApiaryModal apiary), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px" ] [ text "✏️" ]
                        , button [ onClick (OpenDeleteApiaryModal apiary), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px" ] [ text "🗑️" ]
                        ]
                  else
                    text ""
                ]
            ]
        ]

hiveListView : User -> { apiaryId : String, apiaryName : String } -> Model -> Html Msg
hiveListView user info model =
    div []
        [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px" ]
            [ button [ onClick (NavigateTo ApiariesView), style "padding" "6px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "← Powrót" ]
            , h2 [ style "margin" "0", style "color" (if model.darkMode then "#ffffff" else "inherit") ] [ text ("Pasieka: " ++ info.apiaryName) ]
            ]
        , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "20px" ]
            [ button [ onClick OpenNewHiveModal, style "padding" "10px 16px", style "background-color" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "+ Dodaj Nowy Ul" ]
            ]
        , div [ style "display" "grid", style "grid-template-columns" "repeat(auto-fill, minmax(220px, 1fr))", style "gap" "15px" ]
            (List.map (hiveCardView info.apiaryId model) model.hives)
        ]

ulikListView : User -> { apiaryId : String, apiaryName : String } -> Model -> Html Msg
ulikListView user info model =
    let
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        borderColor = if model.darkMode then "#333" else "#eee"
        metaBg = if model.darkMode then "#2d2d2d" else "#f1f2f6"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"

        filteredUliki =
            List.filter
                (\u ->
                    if model.ulikFilter == "all" then
                        True
                    else
                        u.state == model.ulikFilter
                )
                model.uliki
    in
    div []
        [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px" ]
            [ button [ onClick (NavigateTo ApiariesView), style "padding" "6px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "← Powrót" ]
            , h2 [ style "margin" "0", style "color" headingColor ] [ text ("Trutowisko: " ++ info.apiaryName) ]
            ]
        , div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-bottom" "20px" ]
            [ div [ style "display" "flex", style "gap" "10px" ]
                [ button [ onClick OpenNewUlikModal, style "padding" "10px 16px", style "background-color" "#8e44ad", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "+ Dodaj Ulik Weselny" ]
                ]
            , div [ style "display" "flex", style "align-items" "center", style "gap" "8px" ]
                [ span [ style "color" textColor, style "font-size" "14px" ] [ text "Filtruj stan:" ]
                , select [ onInput SetUlikFilter, style "padding" "6px 10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder, style "border-radius" "4px" ]
                    [ option [ value "all", selected (model.ulikFilter == "all") ] [ text "Wszystkie stany" ]
                    , option [ value "bezmatek", selected (model.ulikFilter == "bezmatek") ] [ text "(B) Bezmatek" ]
                    , option [ value "z_matecznikiem", selected (model.ulikFilter == "z_matecznikiem") ] [ text "(M) Matecznik" ]
                    , option [ value "matka_wygryziona", selected (model.ulikFilter == "matka_wygryziona") ] [ text "(N) Matka nieunasienniona" ]
                    , option [ value "matka_czerwi", selected (model.ulikFilter == "matka_czerwi") ] [ text "(UNC) Matka unasienniona" ]
                    ]
                ]
            ]
        , div [ style "display" "grid", style "grid-template-columns" "repeat(auto-fill, minmax(240px, 1fr))", style "gap" "15px" ]
            (List.map (ulikCardView info.apiaryId model) filteredUliki)
        ]

ulikCardView : String -> Model -> UlikWeselny -> Html Msg
ulikCardView apiaryId model ulik =
    let
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        borderColor = if model.darkMode then "#333" else "#eee"
        metaBg = if model.darkMode then "#2d2d2d" else "#f1f2f6"
    in
    div [ style "background" cardBg, style "padding" "15px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "cursor" "pointer", style "color" textColor
        , onClick (NavigateTo (UlikDetailView { apiaryId = apiaryId, ulikId = ulik.id, ulikName = ulik.name }))
        ]
        [ h3 [ style "margin-top" "0", style "color" headingColor ] [ text ulik.name ]
        , p [ style "margin" "5px 0", style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#555") ] [ text ("Typ ula: " ++ ulik.hiveType) ]
        , p [ style "margin" "5px 0", style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#555") ] [ text ("Stan: " ++ ulikStateLabel (getUlikState ulik)) ]
        , div [ style "margin-top" "10px", style "font-size" "12px", style "background" metaBg, style "padding" "5px", style "border-radius" "4px", style "color" textColor ]
            [ text ("Matka: " ++ (if ulik.hasQueen then (if ulik.queen.hasOpalit then "Opalit " ++ ulik.queen.color ++ " #" ++ ulik.queen.number else "Bez opalitka") ++ (if ulik.queen.breedLine /= "" then " (" ++ ulik.queen.breedLine ++ ")" else "") else "Brak matki")) ]
        , div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-top" "10px", style "border-top" ("1px solid " ++ borderColor), style "padding-top" "10px" ]
            [ div [ style "display" "flex", style "gap" "4px" ]
                [ button [ stopPropagationOn "click" (Decode.succeed (MoveUlikUp ulik.id, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Przesuń w lewo" ] [ text "⬅️" ]
                , button [ stopPropagationOn "click" (Decode.succeed (MoveUlikDown ulik.id, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Przesuń w prawo" ] [ text "➡️" ]
                ]
            , div [ style "display" "flex", style "gap" "8px" ]
                [ button [ stopPropagationOn "click" (Decode.succeed (OpenRenameUlikModal apiaryId ulik, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Zmień nazwę uliku" ] [ text "✏️" ]
                , button [ stopPropagationOn "click" (Decode.succeed (OpenDeleteUlikModal apiaryId ulik, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Usuń ulik" ] [ text "🗑️" ]
                ]
            ]
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
    div [ style "background" cardBg, style "padding" "15px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "cursor" "pointer", style "color" textColor
        , onClick (NavigateTo (HiveDetailView { apiaryId = apiaryId, hiveId = hive.id, hiveName = hive.name }))
        ]
        [ h3 [ style "margin-top" "0", style "color" headingColor ] [ text hive.name ]
        , p [ style "margin" "5px 0", style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#555") ] [ text ("Typ ramki: " ++ hive.frameType) ]
        , p [ style "margin" "5px 0", style "font-size" "14px", style "color" (if model.darkMode then "#b0b0b0" else "#555") ] [ text ("Tag NFC: " ++ (if hive.nfcTagId == "" then "Brak" else hive.nfcTagId)) ]
        , div [ style "margin-top" "10px", style "font-size" "12px", style "background" metaBg, style "padding" "5px", style "border-radius" "4px", style "color" textColor ]
            [ text ("Matka: " ++ (if hive.queen.hasOpalit then "Opalitek " ++ hive.queen.color ++ " #" ++ hive.queen.number else "Brak opalitka")) ]
        , div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-top" "10px", style "border-top" ("1px solid " ++ borderColor), style "padding-top" "10px" ]
            [ div [ style "display" "flex", style "gap" "4px" ]
                [ button [ stopPropagationOn "click" (Decode.succeed (MoveHiveUp hive.id, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Przesuń w lewo" ] [ text "⬅️" ]
                , button [ stopPropagationOn "click" (Decode.succeed (MoveHiveDown hive.id, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Przesuń w prawo" ] [ text "➡️" ]
                ]
            , div [ style "display" "flex", style "gap" "8px" ]
                [ button [ stopPropagationOn "click" (Decode.succeed (OpenRenameHiveModal apiaryId hive, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Zmień nazwę ula" ] [ text "✏️" ]
                , button [ stopPropagationOn "click" (Decode.succeed (OpenDeleteHiveModal apiaryId hive, True)), style "background" "none", style "border" "none", style "cursor" "pointer", style "font-size" "14px", title "Usuń ul" ] [ text "🗑️" ]
                ]
            ]
        ]

hiveDetailView : User -> { apiaryId : String, hiveId : String, hiveName : String } -> Model -> Html Msg
hiveDetailView user info model =
    let
        maybeHive = List.head (List.filter (\h -> h.id == info.hiveId) model.hives)
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"
    in
    case maybeHive of
        Just hive ->
            div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "color" textColor ]
                [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px" ]
                    [ button [ onClick (NavigateTo (HiveListView { apiaryId = info.apiaryId, apiaryName = "Pasieka" })), style "padding" "6px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "← Powrót" ]
                    , h2 [ style "margin" "0", style "color" headingColor ] [ text ("Karta Ula: " ++ hive.name) ]
                    ]
                , div [ style "display" "flex", style "flex-direction" "column", style "gap" "20px", style "margin-bottom" "20px" ]
                    [ div []
                        [ h3 [ style "color" headingColor ] [ text "Dane Techniczne" ]
                        , label [] [ text "Nazwa Ula:" ]
                        , input [ type_ "text", value hive.name, onInput (\val -> UpdateHiveField info.apiaryId hive.id "name" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                        , label [] [ text "Typ Ramki:" ]
                        , select [ onInput (\val -> UpdateHiveField info.apiaryId hive.id "frameType" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                            (List.map (\ft -> option [ value ft, selected (hive.frameType == ft) ] [ text ft ]) model.frameTypes)
                        , label [] [ text "Poławiacz pyłku:" ]
                        , select [ onInput (\val -> UpdatePollenTrap info.apiaryId hive.id val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                            [ option [ value "brak", selected (hive.pollenTrap == "brak") ] [ text "Brak" ]
                            , option [ value "powałkowy", selected (hive.pollenTrap == "powałkowy") ] [ text "Powałkowy" ]
                            , option [ value "dennicowy", selected (hive.pollenTrap == "dennicowy") ] [ text "Dennicowy" ]
                            ]
                        , label [] [ text "Tag NFC:" ]
                        , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "10px" ]
                            [ input [ type_ "text", value hive.nfcTagId, placeholder "Brak przypisanego tagu", readonly True, style "flex" "1", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                            , button [ onClick StartNfcScan, style "padding" "8px 12px", style "background" "#2980b9", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "🔗 Przypisz NFC" ]
                            ]
                        ]
                    , div []
                        [ h3 [ style "color" headingColor ] [ text "Matka Pszczela" ]
                        , label [] [ text "Obecność Opalitka:" ]
                        , select [ onInput (\val -> UpdateHiveField info.apiaryId hive.id "queen.hasOpalit" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                            [ option [ value "true", selected hive.queen.hasOpalit ] [ text "Tak (Opalitka)" ]
                            , option [ value "false", selected (not hive.queen.hasOpalit) ] [ text "Nie / Czarny opalitek" ]
                            ]
                        , if hive.queen.hasOpalit then
                            div []
                                [ label [] [ text "Kolor Opalitka:" ]
                                , select [ onInput (\val -> UpdateHiveField info.apiaryId hive.id "queen.color" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                    [ option [ value "Biały", selected (hive.queen.color == "Biały") ] [ text "Biały" ]
                                    , option [ value "Żółty", selected (hive.queen.color == "Żółty") ] [ text "Żółty" ]
                                    , option [ value "Czerwony", selected (hive.queen.color == "Czerwony") ] [ text "Czerwony" ]
                                    , option [ value "Zielony", selected (hive.queen.color == "Zielony") ] [ text "Zielony" ]
                                    , option [ value "Niebieski", selected (hive.queen.color == "Niebieski") ] [ text "Niebieski" ]
                                    ]
                                , label [] [ text "Numer Opalitka:" ]
                                , input [ type_ "text", value hive.queen.number, onInput (\val -> UpdateHiveField info.apiaryId hive.id "queen.number" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                                ]
                          else
                            text ""
                        ]
                    ]
                , hr [] []
                , h3 [ style "color" headingColor ] [ text "Notatki" ]
                , div [ style "margin-bottom" "15px" ]
                    [ textarea [ value model.newNoteText, onInput UpdateNewNoteText, placeholder "Wpisz notatkę lub użyj dyktowania głosowego...", style "width" "100%", style "height" "80px", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                    , div [ style "display" "flex", style "gap" "10px", style "margin-top" "10px" ]
                        [ button [ onClick StartSpeechDictation, style "padding" "8px 14px", style "background" "#e67e22", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "🎤 Dyktuj" ]
                        , button [ onClick (SubmitSaveNote info.apiaryId info.hiveId model.newNoteText user.uid user.email), style "padding" "8px 14px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Zapisz Notatkę" ]
                        , button [ onClick (SubmitHiveSnapshot info.apiaryId info.hiveId user), style "padding" "8px 14px", style "background" "#8e44ad", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", title "Zapisz pełny stan ula jako notatkę" ] [ text "📸 Zrzut Ula" ]
                        ]
                    ]
                , div []
                    (List.map (noteItemView info.apiaryId info.hiveId model) model.notes)
                ]
        _ ->
            div [] [ text "Ładowanie ula..." ]

ulikDetailView : User -> { apiaryId : String, ulikId : String, ulikName : String } -> Model -> Html Msg
ulikDetailView user info model =
    let
        maybeUlik = List.head (List.filter (\u -> u.id == info.ulikId) model.uliki)
        cardBg = if model.darkMode then "#1e1e1e" else "white"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        headingColor = if model.darkMode then "#ffffff" else "#2c3e50"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"
    in
    case maybeUlik of
        Just ulik ->
            div [ style "background" cardBg, style "padding" "20px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "color" textColor ]
                [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px" ]
                    [ button [ onClick (NavigateTo (UlikListView { apiaryId = info.apiaryId, apiaryName = "Trutowisko" })), style "padding" "6px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "← Powrót" ]
                    , h2 [ style "margin" "0", style "color" headingColor ] [ text ("Ulik Weselny: " ++ ulik.name) ]
                    ]
                , div [ style "display" "flex", style "flex-direction" "column", style "gap" "20px", style "margin-bottom" "20px" ]
                    [ div []
                        [ h3 [ style "color" headingColor ] [ text "Dane Uliku Weselnego" ]
                        , label [] [ text "Nazwa / Numer uliku:" ]
                        , input [ type_ "text", value ulik.name, onInput (\val -> UpdateUlikField info.apiaryId ulik.id "name" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                        , label [] [ text "Typ ula:" ]
                        , select [ onInput (\val -> UpdateUlikField info.apiaryId ulik.id "hiveType" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                            [ option [ value "Mini plus", selected (ulik.hiveType == "Mini plus") ] [ text "Mini plus" ]
                            , option [ value "Odkład wielkopolski", selected (ulik.hiveType == "Odkład wielkopolski") ] [ text "Odkład wielkopolski" ]
                            , option [ value "Apidea", selected (ulik.hiveType == "Apidea") ] [ text "Apidea" ]
                            ]
                        , label [] [ text "Tag NFC:" ]
                        , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "10px" ]
                            [ input [ type_ "text", value ulik.nfcTagId, placeholder "Brak przypisanego tagu", readonly True, style "flex" "1", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                            , button [ onClick StartNfcScan, style "padding" "8px 12px", style "background" "#2980b9", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "🔗 Przypisz NFC" ]
                            ]
                        , label [] [ text "Spodziewany termin wygryzienia:" ]
                        , input [ type_ "date", value ulik.expectedHatchDate, onInput (\val -> UpdateUlikField info.apiaryId ulik.id "expectedHatchDate" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                        , label [] [ text "Spodziewany termin unasiennienia (+10 dni):" ]
                        , div [ style "display" "flex", style "align-items" "center", style "gap" "10px", style "margin-bottom" "10px" ]
                            [ input [ type_ "date", value ulik.expectedMatingDate, readonly True, style "flex" "1", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                            , if getUlikState ulik == MatkaWygryziona && ulik.expectedHatchDate /= "" && model.currentDate /= "" then
                                let
                                    hatchParsed = parseDate ulik.expectedHatchDate
                                    todayParsed = parseDate model.currentDate
                                in
                                case (hatchParsed, todayParsed) of
                                    (Just (hy, hm, hd), Just (ty, tm, td)) ->
                                        let
                                            hDays = dateToDays hy hm hd
                                            tDays = dateToDays ty tm td
                                            diff = tDays - hDays
                                        in
                                        if diff < 10 then
                                            span [ title "Oczekiwanie na unasiennienie (przed terminem)", style "font-size" "18px" ] [ text "❓" ]
                                        else if diff >= 10 && diff <= 21 then
                                            span [ style "background" "#27ae60", style "color" "white", style "padding" "4px 8px", style "border-radius" "4px", style "font-size" "12px", style "font-weight" "bold", title "W terminie (10-21 dni od wygryzienia)" ] [ text "✓ W terminie" ]
                                        else
                                            span [ style "background" "#e74c3c", style "color" "white", style "padding" "4px 8px", style "border-radius" "4px", style "font-size" "12px", style "font-weight" "bold", title "Przekroczono termin (>21 dni)" ] [ text "✗ Przekroczony" ]
                                    _ ->
                                        text ""
                              else
                                text ""
                            ]
                        ]
                    , div []
                        [ h3 [ style "color" headingColor ] [ text "Stan i Matka Pszczela" ]
                        , p [ style "font-weight" "bold" ] [ text ("Aktualny stan: " ++ ulikStateLabel (getUlikState ulik)) ]
                        , div [ style "display" "flex", style "flex-wrap" "wrap", style "gap" "8px", style "margin-bottom" "15px" ]
                            (case getUlikState ulik of
                                Bezmatek ->
                                    [ button [ onClick (TransitionUlikState info.apiaryId ulik.id ZMatecznikiem), style "padding" "6px 12px", style "background" "#2980b9", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "➕ Poddano matecznik (M)" ]
                                    , button [ onClick (TransitionUlikState info.apiaryId ulik.id MatkaWygryziona), style "padding" "6px 12px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "➕ Poddano matkę nieunasiennioną (N)" ]
                                    ]
                                ZMatecznikiem ->
                                    [ button [ onClick (TransitionUlikState info.apiaryId ulik.id MatkaWygryziona), style "padding" "6px 12px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "🦋 Matka się wygryzła (N)" ]
                                    , button [ onClick (TransitionUlikState info.apiaryId ulik.id Bezmatek), style "padding" "6px 12px", style "background" "#e74c3c", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "❌ Matecznik się nie wygryzł (B)" ]
                                    ]
                                MatkaWygryziona ->
                                    [ button [ onClick (TransitionUlikState info.apiaryId ulik.id MatkaCzerwi), style "padding" "6px 12px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "👑 Matka się unasienniła (UNC)" ]
                                    , button [ onClick (TransitionUlikState info.apiaryId ulik.id Bezmatek), style "padding" "6px 12px", style "background" "#e74c3c", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "⚠️ Matka strutowiała / zniknęła (B)" ]
                                    ]
                                MatkaCzerwi ->
                                    [ span [ style "color" "#27ae60", style "font-style" "italic", style "display" "block", style "margin-bottom" "10px" ] [ text "Matka unasienniona / czerwi (pełny sukces uliku weselnego)" ]
                                    , button [ onClick (TransitionUlikState info.apiaryId ulik.id Bezmatek), style "padding" "6px 12px", style "background" "#e74c3c", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "zabieram matkę (B)" ]
                                    ]
                            )
                        , label [] [ text "Czy jest tam matka:" ]
                        , select [ onInput (\val -> UpdateUlikField info.apiaryId ulik.id "hasQueen" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                            [ option [ value "true", selected ulik.hasQueen ] [ text "Tak" ]
                            , option [ value "false", selected (not ulik.hasQueen) ] [ text "Nie" ]
                            ]
                        , if ulik.hasQueen then
                            div []
                                [ label [] [ text "Nazwa rasy i linii matki:" ]
                                , input [ type_ "text", value ulik.queen.breedLine, placeholder "np. Buckfast GEMA", onInput (\val -> UpdateUlikField info.apiaryId ulik.id "queen.breedLine" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                                , label [] [ text "Obecność Opalitka:" ]
                                , select [ onInput (\val -> UpdateUlikField info.apiaryId ulik.id "queen.hasOpalit" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                    [ option [ value "true", selected ulik.queen.hasOpalit ] [ text "Tak (Opalitka)" ]
                                    , option [ value "false", selected (not ulik.queen.hasOpalit) ] [ text "Nie" ]
                                    ]
                                , if ulik.queen.hasOpalit then
                                    div []
                                        [ label [] [ text "Kolor Opalitka:" ]
                                        , select [ onInput (\val -> UpdateUlikField info.apiaryId ulik.id "queen.color" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                                            [ option [ value "Biały", selected (ulik.queen.color == "Biały") ] [ text "Biały" ]
                                            , option [ value "Żółty", selected (ulik.queen.color == "Żółty") ] [ text "Żółty" ]
                                            , option [ value "Czerwony", selected (ulik.queen.color == "Czerwony") ] [ text "Czerwony" ]
                                            , option [ value "Zielony", selected (ulik.queen.color == "Zielony") ] [ text "Zielony" ]
                                            , option [ value "Niebieski", selected (ulik.queen.color == "Niebieski") ] [ text "Niebieski" ]
                                            ]
                                        , label [] [ text "Numer Opalitka:" ]
                                        , input [ type_ "text", value ulik.queen.number, onInput (\val -> UpdateUlikField info.apiaryId ulik.id "queen.number" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                                        ]
                                  else
                                    text ""
                                ]
                          else
                            text ""
                        ]
                    ]
                , hr [] []
                , h3 [ style "color" headingColor ] [ text "Notatki" ]
                , div [ style "margin-bottom" "15px" ]
                    [ textarea [ value model.newNoteText, onInput UpdateNewNoteText, placeholder "Wpisz notatkę lub użyj dyktowania głosowego...", style "width" "100%", style "height" "80px", style "padding" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
                    , div [ style "display" "flex", style "gap" "10px", style "margin-top" "10px" ]
                        [ button [ onClick StartSpeechDictation, style "padding" "8px 14px", style "background" "#e67e22", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "🎤 Dyktuj" ]
                        , button [ onClick (SubmitSaveNote info.apiaryId ulik.id model.newNoteText user.uid user.email), style "padding" "8px 14px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Zapisz Notatkę" ]
                        , button [ onClick (SubmitUlikSnapshot info.apiaryId ulik.id user), style "padding" "8px 14px", style "background" "#8e44ad", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", title "Zapisz pełny stan uliku jako notatkę" ] [ text "📸 Zrzut Uliku" ]
                        ]
                    ]
                , div []
                    (List.map (noteItemView info.apiaryId ulik.id model) model.notes)
                ]
        _ ->
            div [] [ text "Ładowanie uliku..." ]

noteItemView : String -> String -> Model -> Note -> Html Msg
noteItemView apiaryId hiveId model note =
    let
        isEditing = model.editingNoteId == Just note.id
        cardBg = if model.darkMode then "#242424" else "#f8f9f9"
        textColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBg = if model.darkMode then "#2a2a2a" else "white"
        inputColor = if model.darkMode then "#e0e0e0" else "#333"
        inputBorder = if model.darkMode then "1px solid #444" else "1px solid #ccc"
    in
    div [ style "background" cardBg, style "padding" "10px", style "border-radius" "4px", style "margin-bottom" "10px", style "border-left" "4px solid #27ae60", style "color" textColor ]
        (if isEditing then
            [ textarea [ value model.editNoteText, onInput UpdateEditNoteText, style "width" "100%", style "height" "60px", style "padding" "6px", style "margin-bottom" "8px", style "background" inputBg, style "color" inputColor, style "border" inputBorder ] []
            , div [ style "display" "flex", style "gap" "8px" ]
                [ button [ onClick (SubmitUpdateNote apiaryId hiveId note.id), style "padding" "4px 10px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Zapisz" ]
                , button [ onClick CancelEditNote, style "padding" "4px 10px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Anuluj" ]
                ]
            ]
         else
            [ p [ style "margin" "0 0 5px 0" ] [ text note.text ]
            , div [ style "font-size" "11px", style "color" (if model.darkMode then "#95a5a6" else "#7f8c8d"), style "display" "flex", style "justify-content" "space-between", style "align-items" "center" ]
                [ div []
                    [ span [ style "margin-right" "10px" ] [ text ("Autor: " ++ note.authorEmail) ]
                    , span [] [ text note.timestamp ]
                    ]
                , div [ style "display" "flex", style "gap" "6px" ]
                    [ button [ onClick (StartEditNote note), style "background" "none", style "border" "none", style "cursor" "pointer", title "Edytuj" ] [ text "✏️" ]
                    , button [ onClick (SubmitDeleteNote apiaryId hiveId note.id), style "background" "none", style "border" "none", style "cursor" "pointer", title "Usuń" ] [ text "🗑️" ]
                    ]
                ]
            ]
        )

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
                    , select [ value model.newApiaryType, onInput UpdateNewApiaryType, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box", style "background" inputBg, style "color" inputColor, style "border" inputBorder ]
                        [ option [ value "towarowe" ] [ text "Pasieczysko towarowe" ]
                        , option [ value "trutowisko" ] [ text "Trutowisko (uliki weselne)" ]
                        ]
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
                        [ option [ value "Mini plus" ] [ text "Mini plus" ]
                        , option [ value "Odkład wielkopolski" ] [ text "Odkład wielkopolski" ]
                        , option [ value "Apidea" ] [ text "Apidea" ]
                        ]
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
        , "Tag NFC: " ++ (if hive.nfcTagId == "" then "Brak" else hive.nfcTagId)
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
        , "Tag NFC: " ++ (if ulik.nfcTagId == "" then "Brak" else ulik.nfcTagId)
        , "Matka pszczela: " ++ queenText
        ]
