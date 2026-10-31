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

type alias User =
    { uid : String
    , email : String
    }

type AuthState
    = LoggedOut
    | LoggedIn User

type ViewState
    = LoginView
    | ApiariesView
    | HiveListView { apiaryId : String, apiaryName : String }
    | HiveDetailView { apiaryId : String, hiveId : String, hiveName : String }
    | SharingView { apiaryId : String, apiaryName : String }

type alias Queen =
    { hasOpalit : Bool
    , color : String
    , number : String
    }

type alias HiveBody =
    { frameCount : Int
    , hasQueen : Bool
    , hasExcluderAbove : Bool
    }

type alias Hive =
    { id : String
    , name : String
    , frameType : String
    , nfcTagId : String
    , queen : Queen
    , pollenTrap : String
    , bodies : List HiveBody
    }

type alias Note =
    { id : String
    , text : String
    , authorId : String
    , authorEmail : String
    , timestamp : String
    }

type alias Apiary =
    { id : String
    , name : String
    , adminId : String
    , members : List ( String, String )
    }

type alias Model =
    { authState : AuthState
    , viewState : ViewState
    , apiaries : List Apiary
    , hives : List Hive
    , notes : List Note
    , errorMessage : Maybe String
    , successMessage : Maybe String
    , darkMode : Bool
    -- Modals & Inputs
    , showNewApiaryModal : Bool
    , newApiaryName : String
    , showEditApiaryModal : Maybe Apiary
    , editApiaryNameInput : String
    , showDeleteApiaryModal : Maybe Apiary
    , showNewHiveModal : Bool
    , newHiveName : String
    , newHiveFrameType : String
    , newNoteText : String
    , editingNoteId : Maybe String
    , editNoteText : String
    , shareEmailInput : String
    , shareRoleInput : String
    , showRenameHiveModal : Maybe { apiaryId : String, hiveId : String, hiveName : String }
    , renameHiveInput : String
    , showDeleteHiveModal : Maybe { apiaryId : String, hiveId : String, hiveName : String }
    }

init : () -> ( Model, Cmd Msg )
init _ =
    ( { authState = LoggedOut
      , viewState = LoginView
      , apiaries = []
      , hives = []
      , notes = []
      , errorMessage = Nothing
      , successMessage = Nothing
      , darkMode = False
      , showNewApiaryModal = False
      , newApiaryName = ""
      , showEditApiaryModal = Nothing
      , editApiaryNameInput = ""
      , showDeleteApiaryModal = Nothing
      , showNewHiveModal = False
      , newHiveName = ""
      , newHiveFrameType = "Wielkopolskie"
      , newNoteText = ""
      , editingNoteId = Nothing
      , editNoteText = ""
      , shareEmailInput = ""
      , shareRoleInput = "view"
      , showRenameHiveModal = Nothing
      , renameHiveInput = ""
      , showDeleteHiveModal = Nothing
      }
    , Cmd.none
    )

-- PORTS (OUT)

port jsLoginGoogle : () -> Cmd msg
port jsLogout : () -> Cmd msg
port jsLoadApiaries : String -> Cmd msg
port jsCreateApiary : { name : String, uid : String } -> Cmd msg
port jsUpdateApiary : { apiaryId : String, name : String } -> Cmd msg
port jsDeleteApiary : { apiaryId : String } -> Cmd msg
port jsLoadHives : { apiaryId : String } -> Cmd msg
port jsCreateHive : { apiaryId : String, name : String, frameType : String } -> Cmd msg
port jsUpdateHive : { apiaryId : String, hiveId : String, field : String, value : String } -> Cmd msg
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
port jsUpdateHiveBodies : { apiaryId : String, hiveId : String, bodies : List HiveBody } -> Cmd msg

-- PORTS (IN)

port authStateChanged : ({ uid : String, email : String } -> msg) -> Sub msg
port apiariesReceived : (Value -> msg) -> Sub msg
port hivesReceived : (Value -> msg) -> Sub msg
port notesReceived : (Value -> msg) -> Sub msg
port nfcScanned : (String -> msg) -> Sub msg
port speechRecognized : (String -> msg) -> Sub msg
port operationError : (String -> msg) -> Sub msg

-- MESSAGES

type Msg
    = ClickLoginGoogle
    | ClickLogout
    | ToggleDarkMode
    | AuthStateUpdated { uid : String, email : String }
    | LoadApiariesData String
    | ApiariesDecoded (Result String (List Apiary))
    | NavigateTo ViewState
    -- Apiary actions
    | OpenNewApiaryModal
    | CloseNewApiaryModal
    | UpdateNewApiaryName String
    | SubmitCreateApiary
    | OpenEditApiaryModal Apiary
    | CloseEditApiaryModal
    | UpdateEditApiaryNameInput String
    | SubmitUpdateApiary
    | OpenDeleteApiaryModal Apiary
    | CloseDeleteApiaryModal
    | SubmitDeleteApiary String
    -- Hive actions
    | HivesDecoded (Result String (List Hive))
    | OpenNewHiveModal
    | CloseNewHiveModal
    | UpdateNewHiveName String
    | UpdateNewHiveFrameType String
    | SubmitCreateHive String
    | UpdateHiveField String String String String -- apiaryId, hiveId, field, value
    | StartNfcScan
    | NfcResultReceived String
    -- Notes actions
    | NotesDecoded (Result String (List Note))
    | UpdateNewNoteText String
    | StartSpeechDictation
    | SpeechResultReceived String
    | SubmitSaveNote String String String String String -- apiaryId, hiveId, text, authorId, authorEmail
    | StartEditNote Note
    | CancelEditNote
    | UpdateEditNoteText String
    | SubmitUpdateNote String String String -- apiaryId, hiveId, noteId
    | SubmitDeleteNote String String String -- apiaryId, hiveId, noteId
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
    | MoveApiaryUp String
    | MoveApiaryDown String
    | MoveHiveUp String
    | MoveHiveDown String
    -- Hive Body & Pollen Trap actions
    | UpdatePollenTrap String String String
    | AddBodyAbove Int String String
    | AddBodyBelow Int String String
    | RemoveBody Int String String
    | UpdateBodyFrames Int String String String
    | ToggleBodyQueen Int String String
    | ToggleBodyExcluder Int String String
    -- Feedback
    | HandleError String
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
                , jsLoadApiaries uid
                )

        LoadApiariesData uid ->
            ( model, jsLoadApiaries uid )

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
                        HiveDetailView { apiaryId, hiveId } ->
                            jsLoadNotes { apiaryId = apiaryId, hiveId = hiveId }
                        _ ->
                            Cmd.none
            in
            ( { model | viewState = state }, cmds )

        OpenNewApiaryModal ->
            ( { model | showNewApiaryModal = True, newApiaryName = "" }, Cmd.none )

        CloseNewApiaryModal ->
            ( { model | showNewApiaryModal = False }, Cmd.none )

        UpdateNewApiaryName name ->
            ( { model | newApiaryName = name }, Cmd.none )

        SubmitCreateApiary ->
            case model.authState of
                LoggedIn user ->
                    ( { model | showNewApiaryModal = False }
                    , jsCreateApiary { name = model.newApiaryName, uid = user.uid }
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

        UpdateHiveField apiaryId hiveId field value ->
            ( model, jsUpdateHive { apiaryId = apiaryId, hiveId = hiveId, field = field, value = value } )

        StartNfcScan ->
            ( model, jsStartNfcScan () )

        NfcResultReceived tagId ->
            case model.viewState of
                HiveDetailView info ->
                    ( { model | successMessage = Just ("Zeskanowano tag NFC: " ++ tagId) }
                    , jsUpdateHive { apiaryId = info.apiaryId, hiveId = info.hiveId, field = "nfcTagId", value = tagId }
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

        MoveApiaryUp id ->
            ( { model | apiaries = moveUp id model.apiaries }, Cmd.none )

        MoveApiaryDown id ->
            ( { model | apiaries = moveDown id model.apiaries }, Cmd.none )

        MoveHiveUp id ->
            ( { model | hives = moveUp id model.hives }, Cmd.none )

        MoveHiveDown id ->
            ( { model | hives = moveDown id model.hives }, Cmd.none )

        UpdatePollenTrap apiaryId hiveId trap ->
            ( model, jsUpdateHive { apiaryId = apiaryId, hiveId = hiveId, field = "pollenTrap", value = trap } )

        AddBodyAbove idx apiaryId hiveId ->
            let
                updatedHives =
                    List.map
                        (\h ->
                            if h.id == hiveId then
                                let
                                    newBody = { frameCount = 10, hasQueen = False, hasExcluderAbove = False }
                                    newBodies = insertAt idx newBody h.bodies
                                in
                                { h | bodies = newBodies }
                            else
                                h
                        )
                        model.hives
                targetHive = List.head (List.filter (\h -> h.id == hiveId) updatedHives)
                cmd = case targetHive of
                    Just h -> jsUpdateHiveBodies { apiaryId = apiaryId, hiveId = hiveId, bodies = h.bodies }
                    Nothing -> Cmd.none
            in
            ( { model | hives = updatedHives }, cmd )

        AddBodyBelow idx apiaryId hiveId ->
            let
                updatedHives =
                    List.map
                        (\h ->
                            if h.id == hiveId then
                                let
                                    newBody = { frameCount = 10, hasQueen = False, hasExcluderAbove = False }
                                    newBodies = insertAt (idx + 1) newBody h.bodies
                                in
                                { h | bodies = newBodies }
                            else
                                h
                        )
                        model.hives
                targetHive = List.head (List.filter (\h -> h.id == hiveId) updatedHives)
                cmd = case targetHive of
                    Just h -> jsUpdateHiveBodies { apiaryId = apiaryId, hiveId = hiveId, bodies = h.bodies }
                    Nothing -> Cmd.none
            in
            ( { model | hives = updatedHives }, cmd )

        RemoveBody idx apiaryId hiveId ->
            let
                updatedHives =
                    List.map
                        (\h ->
                            if h.id == hiveId then
                                let
                                    newBodies = removeAt idx h.bodies
                                    finalBodies = if List.isEmpty newBodies then [ { frameCount = 10, hasQueen = False, hasExcluderAbove = False } ] else newBodies
                                in
                                { h | bodies = finalBodies }
                            else
                                h
                        )
                        model.hives
                targetHive = List.head (List.filter (\h -> h.id == hiveId) updatedHives)
                cmd = case targetHive of
                    Just h -> jsUpdateHiveBodies { apiaryId = apiaryId, hiveId = hiveId, bodies = h.bodies }
                    Nothing -> Cmd.none
            in
            ( { model | hives = updatedHives }, cmd )

        UpdateBodyFrames idx frames apiaryId hiveId ->
            let
                fCount = Maybe.withDefault 10 (String.toInt frames)
                updatedHives =
                    List.map
                        (\h ->
                            if h.id == hiveId then
                                let
                                    newBodies = updateAt idx (\b -> { b | frameCount = fCount }) h.bodies
                                in
                                { h | bodies = newBodies }
                            else
                                h
                        )
                        model.hives
                targetHive = List.head (List.filter (\h -> h.id == hiveId) updatedHives)
                cmd = case targetHive of
                    Just h -> jsUpdateHiveBodies { apiaryId = apiaryId, hiveId = hiveId, bodies = h.bodies }
                    Nothing -> Cmd.none
            in
            ( { model | hives = updatedHives }, cmd )

        ToggleBodyQueen idx apiaryId hiveId ->
            let
                updatedHives =
                    List.map
                        (\h ->
                            if h.id == hiveId then
                                let
                                    newBodies = updateAt idx (\b -> { b | hasQueen = not b.hasQueen }) h.bodies
                                in
                                { h | bodies = newBodies }
                            else
                                h
                        )
                        model.hives
                targetHive = List.head (List.filter (\h -> h.id == hiveId) updatedHives)
                cmd = case targetHive of
                    Just h -> jsUpdateHiveBodies { apiaryId = apiaryId, hiveId = hiveId, bodies = h.bodies }
                    Nothing -> Cmd.none
            in
            ( { model | hives = updatedHives }, cmd )

        ToggleBodyExcluder idx apiaryId hiveId ->
            let
                updatedHives =
                    List.map
                        (\h ->
                            if h.id == hiveId then
                                let
                                    newBodies = updateAt idx (\b -> { b | hasExcluderAbove = not b.hasExcluderAbove }) h.bodies
                                in
                                { h | bodies = newBodies }
                            else
                                h
                        )
                        model.hives
                targetHive = List.head (List.filter (\h -> h.id == hiveId) updatedHives)
                cmd = case targetHive of
                    Just h -> jsUpdateHiveBodies { apiaryId = apiaryId, hiveId = hiveId, bodies = h.bodies }
                    Nothing -> Cmd.none
            in
            ( { model | hives = updatedHives }, cmd )

        HandleError err ->
            ( { model | errorMessage = Just err }, Cmd.none )

        ClearMessages ->
            ( { model | errorMessage = Nothing, successMessage = Nothing }, Cmd.none )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ authStateChanged (\val -> AuthStateUpdated val)
        , apiariesReceived (\val -> ApiariesDecoded (Result.mapError Decode.errorToString (Decode.decodeValue decodeApiaries val)))
        , hivesReceived (\val -> HivesDecoded (Result.mapError Decode.errorToString (Decode.decodeValue decodeHives val)))
        , notesReceived (\val -> NotesDecoded (Result.mapError Decode.errorToString (Decode.decodeValue decodeNotes val)))
        , nfcScanned NfcResultReceived
        , speechRecognized SpeechResultReceived
        , operationError HandleError
        ]

-- DECODERS

decodeApiaries : Decode.Decoder (List Apiary)
decodeApiaries =
    Types.decodeApiaries

decodeHives : Decode.Decoder (List Hive)
decodeHives =
    Types.decodeHives

decodeQueen : Decode.Decoder Queen
decodeQueen =
    Types.decodeQueen

decodeNotes : Decode.Decoder (List Note)
decodeNotes =
    Types.decodeNotes

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
                loginView

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

                    SharingView info ->
                        sharingView user info model
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
        [ h1 [ style "margin" "0", style "color" " #2c3e50" ] [ text "BeeLog 🐝" ]
        , case model.authState of
            LoggedIn user ->
                div [ style "display" "flex", style "align-items" "center", style "gap" "10px" ]
                    [ span [ style "font-size" "14px", style "color" "#666" ] [ text user.email ]
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

loginView : Html Msg
loginView =
    div [ style "text-align" "center", style "padding" "40px", style "background" "white", style "border-radius" "8px", style "box-shadow" "0 2px 4px rgba(0,0,0,0.1)" ]
        [ h2 [] [ text "Witaj w BeeLog" ]
        , p [ style "color" "666", style "margin-bottom" "30px" ] [ text "Zarządzaj pasieką, ulami i notatkami głosowymi w terenie." ]
        , button [ onClick ClickLoginGoogle, style "padding" "12px 24px", style "background-color" "#4285F4", style "color" "white", style "border" "none", style "border-radius" "4px", style "font-size" "16px", style "cursor" "pointer" ] [ text "Zaloguj przez Google" ]
        ]

apiariesView : User -> Model -> Html Msg
apiariesView user model =
    div []
        [ div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-bottom" "20px" ]
            [ h2 [ style "margin" "0" ] [ text "Twoje Pasieczyska" ]
            , button [ onClick OpenNewApiaryModal, style "padding" "10px 16px", style "background-color" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "+ Dodaj Pasieczysko" ]
            ]
        , div [ style "display" "grid", style "grid-template-columns" "repeat(auto-fill, minmax(250px, 1fr))", style "gap" "15px" ]
            (List.map (apiaryCardView user) model.apiaries)
        ]

apiaryCardView : User -> Apiary -> Html Msg
apiaryCardView user apiary =
    let
        isAdmin = apiary.adminId == user.uid
    in
    div [ style "background" "white", style "padding" "15px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "cursor" "pointer", style "color" "#333" ]
        [ div [ onClick (NavigateTo (HiveListView { apiaryId = apiary.id, apiaryName = apiary.name })) ]
            [ h3 [ style "margin-top" "0", style "color" "#2c3e50" ] [ text apiary.name ]
            , p [ style "font-size" "12px", style "color" "#7f8c8d" ] [ text (if isAdmin then "Właściciel" else "Udostępnione") ]
            ]
        , div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-top" "10px", style "border-top" "1px solid #eee", style "padding-top" "10px" ]
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
            , h2 [ style "margin" "0" ] [ text ("Pasieka: " ++ info.apiaryName) ]
            ]
        , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "20px" ]
            [ button [ onClick OpenNewHiveModal, style "padding" "10px 16px", style "background-color" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "+ Dodaj Nowy Ul" ]
            , button [ onClick StartNfcScan, style "padding" "10px 16px", style "background-color" "#2980b9", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "📶 Skanuj NFC" ]
            ]
        , div [ style "display" "grid", style "grid-template-columns" "repeat(auto-fill, minmax(220px, 1fr))", style "gap" "15px" ]
            (List.map (hiveCardView info.apiaryId) model.hives)
        ]

hiveCardView : String -> Hive -> Html Msg
hiveCardView apiaryId hive =
    div [ style "background" "white", style "padding" "15px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "cursor" "pointer", style "color" "#333"
        , onClick (NavigateTo (HiveDetailView { apiaryId = apiaryId, hiveId = hive.id, hiveName = hive.name }))
        ]
        [ h3 [ style "margin-top" "0", style "color" "#2c3e50" ] [ text hive.name ]
        , p [ style "margin" "5px 0", style "font-size" "14px", style "color" "#555" ] [ text ("Typ ramki: " ++ hive.frameType) ]
        , p [ style "margin" "5px 0", style "font-size" "14px", style "color" "#555" ] [ text ("Tag NFC: " ++ (if hive.nfcTagId == "" then "Brak" else hive.nfcTagId)) ]
        , div [ style "margin-top" "10px", style "font-size" "12px", style "background" "#f1f2f6", style "padding" "5px", style "border-radius" "4px", style "color" "#333" ]
            [ text ("Matka: " ++ (if hive.queen.hasOpalit then "Opalitek " ++ hive.queen.color ++ " #" ++ hive.queen.number else "Brak opalitka")) ]
        , div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-top" "10px", style "border-top" "1px solid #eee", style "padding-top" "10px" ]
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
    in
    case maybeHive of
        Just hive ->
            div [ style "background" "white", style "padding" "20px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "color" "#333" ]
                [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px" ]
                    [ button [ onClick (NavigateTo (HiveListView { apiaryId = info.apiaryId, apiaryName = "Pasieka" })), style "padding" "6px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "← Powrót" ]
                    , h2 [ style "margin" "0" ] [ text ("Karta Ula: " ++ hive.name) ]
                    ]
                , div [ style "display" "grid", style "grid-template-columns" "1fr 1fr", style "gap" "20px", style "margin-bottom" "20px" ]
                    [ div []
                        [ h3 [] [ text "Dane Techniczne" ]
                        , label [] [ text "Nazwa Ula:" ]
                        , input [ type_ "text", value hive.name, onInput (\val -> UpdateHiveField info.apiaryId hive.id "name" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px" ] []
                        , label [] [ text "Typ Ramki:" ]
                        , select [ onInput (\val -> UpdateHiveField info.apiaryId hive.id "frameType" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px" ]
                            [ option [ value "Wielkopolskie", selected (hive.frameType == "Wielkopolskie") ] [ text "Wielkopolskie" ]
                            , option [ value "Wielkopolskie 18", selected (hive.frameType == "Wielkopolskie 18") ] [ text "Wielkopolskie 18" ]
                            , option [ value "Wielkopolskie 1/2", selected (hive.frameType == "Wielkopolskie 1/2") ] [ text "Wielkopolskie 1/2" ]
                            ]
                        , label [] [ text "Poławiacz pyłku:" ]
                        , select [ onInput (\val -> UpdatePollenTrap info.apiaryId hive.id val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px" ]
                            [ option [ value "brak", selected (hive.pollenTrap == "brak") ] [ text "Brak" ]
                            , option [ value "powałkowy", selected (hive.pollenTrap == "powałkowy") ] [ text "Powałkowy" ]
                            , option [ value "dennicowy", selected (hive.pollenTrap == "dennicowy") ] [ text "Dennicowy" ]
                            ]
                        , label [] [ text "Tag NFC:" ]
                        , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "10px" ]
                            [ input [ type_ "text", value hive.nfcTagId, placeholder "Brak przypisanego tagu", readonly True, style "flex" "1", style "padding" "8px" ] []
                            , button [ onClick StartNfcScan, style "padding" "8px 12px", style "background" "#2980b9", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "🔗 Przypisz NFC" ]
                            ]
                        ]
                    , div []
                        [ h3 [] [ text "Matka Pszczela" ]
                        , label [] [ text "Obecność Opalitka:" ]
                        , select [ onInput (\val -> UpdateHiveField info.apiaryId hive.id "queen.hasOpalit" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px" ]
                            [ option [ value "true", selected hive.queen.hasOpalit ] [ text "Tak (Opalitka)" ]
                            , option [ value "false", selected (not hive.queen.hasOpalit) ] [ text "Nie / Czarny opalitek" ]
                            ]
                        , label [] [ text "Kolor Opalitka:" ]
                        , select [ onInput (\val -> UpdateHiveField info.apiaryId hive.id "queen.color" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px" ]
                            [ option [ value "Biały", selected (hive.queen.color == "Biały") ] [ text "Biały" ]
                            , option [ value "Żółty", selected (hive.queen.color == "Żółty") ] [ text "Żółty" ]
                            , option [ value "Czerwony", selected (hive.queen.color == "Czerwony") ] [ text "Czerwony" ]
                            , option [ value "Zielony", selected (hive.queen.color == "Zielony") ] [ text "Zielony" ]
                            , option [ value "Niebieski", selected (hive.queen.color == "Niebieski") ] [ text "Niebieski" ]
                            ]
                        , label [] [ text "Numer Opalitka:" ]
                        , input [ type_ "text", value hive.queen.number, onInput (\val -> UpdateHiveField info.apiaryId hive.id "queen.number" val), style "width" "100%", style "padding" "8px", style "margin-bottom" "10px" ] []
                        ]
                    ]
                , hiveBodiesEditorView info.apiaryId hive.id hive.bodies
                , hr [] []
                , h3 [] [ text "Notatki" ]
                , div [ style "margin-bottom" "15px" ]
                    [ textarea [ value model.newNoteText, onInput UpdateNewNoteText, placeholder "Wpisz notatkę lub użyj dyktowania głosowego...", style "width" "100%", style "height" "80px", style "padding" "8px" ] []
                    , div [ style "display" "flex", style "gap" "10px", style "margin-top" "10px" ]
                        [ button [ onClick StartSpeechDictation, style "padding" "8px 14px", style "background" "#e67e22", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "🎤 Dyktuj" ]
                        , button [ onClick (SubmitSaveNote info.apiaryId hive.id model.newNoteText user.uid user.email), style "padding" "8px 14px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Zapisz Notatkę" ]
                        ]
                    ]
                , div []
                    (List.map (noteItemView info.apiaryId info.hiveId model) model.notes)
                ]
        _ ->
            div [] [ text "Ładowanie ula..." ]

noteItemView : String -> String -> Model -> Note -> Html Msg
noteItemView apiaryId hiveId model note =
    let
        isEditing = model.editingNoteId == Just note.id
    in
    div [ style "background" "#f8f9f9", style "padding" "10px", style "border-radius" "4px", style "margin-bottom" "10px", style "border-left" "4px solid #27ae60", style "color" "#333" ]
        (if isEditing then
            [ textarea [ value model.editNoteText, onInput UpdateEditNoteText, style "width" "100%", style "height" "60px", style "padding" "6px", style "margin-bottom" "8px" ] []
            , div [ style "display" "flex", style "gap" "8px" ]
                [ button [ onClick (SubmitUpdateNote apiaryId hiveId note.id), style "padding" "4px 10px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Zapisz" ]
                , button [ onClick CancelEditNote, style "padding" "4px 10px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Anuluj" ]
                ]
            ]
         else
            [ p [ style "margin" "0 0 5px 0" ] [ text note.text ]
            , div [ style "font-size" "11px", style "color" "#7f8c8d", style "display" "flex", style "justify-content" "space-between", style "align-items" "center" ]
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
    in
    case maybeApiary of
        Just apiary ->
            div [ style "background" "white", style "padding" "20px", style "border-radius" "8px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)" ]
                [ div [ style "display" "flex", style "align-items" "center", style "gap" "15px", style "margin-bottom" "20px" ]
                    [ button [ onClick (NavigateTo ApiariesView), style "padding" "6px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "← Powrót" ]
                    , h2 [ style "margin" "0" ] [ text ("Udostępnianie pasieki: " ++ info.apiaryName) ]
                    ]
                , div [ style "margin-bottom" "20px" ]
                    [ h3 [] [ text "Przyznaj dostęp nowemu użytkownikowi" ]
                    , div [ style "display" "flex", style "gap" "10px" ]
                        [ input [ type_ "email", placeholder "Adres e-mail użytkownika", value model.shareEmailInput, onInput UpdateShareEmail, style "flex" "1", style "padding" "8px" ] []
                        , select [ value model.shareRoleInput, onInput UpdateShareRole, style "padding" "8px" ]
                            [ option [ value "edit" ] [ text "Edytor" ]
                            , option [ value "view" ] [ text "Tylko podgląd" ]
                            ]
                        , button [ onClick (SubmitShareApiary info.apiaryId model.shareEmailInput model.shareRoleInput), style "padding" "8px 16px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Przyznaj dostęp" ]
                        ]
                    ]
                , h3 [] [ text "Aktualni członkowie i uprawnienia" ]
                , ul [ style "list-style" "none", style "padding" "0" ]
                    (List.map (memberItemView info.apiaryId) apiary.members)
                ]
        _ ->
            div [] [ text "Ładowanie pasieki..." ]

memberItemView : String -> ( String, String ) -> Html Msg
memberItemView apiaryId ( email, role ) =
    li [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "padding" "10px", style "border-bottom" "1px solid #eee" ]
        [ span [] [ text (email ++ " (" ++ role ++ ")") ]
        , button [ onClick (SubmitRemoveMember apiaryId email), style "background" "#e74c3c", style "color" "white", style "border" "none", style "padding" "4px 8px", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Cofnij dostęp" ]
        ]

modalsView : Model -> Html Msg
modalsView model =
    div []
        [ if model.showNewApiaryModal then
            div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                [ div [ style "background" "white", style "padding" "20px", style "border-radius" "8px", style "width" "400px" ]
                    [ h3 [] [ text "Nowe Pasieczysko" ]
                    , input [ type_ "text", placeholder "Nazwa pasieczyska", value model.newApiaryName, onInput UpdateNewApiaryName, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box" ] []
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
                    [ div [ style "background" "white", style "padding" "20px", style "border-radius" "8px", style "width" "400px" ]
                        [ h3 [] [ text "Edytuj Nazwę Pasieczyska" ]
                        , input [ type_ "text", value model.editApiaryNameInput, onInput UpdateEditApiaryNameInput, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box" ] []
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
                    [ div [ style "background" "white", style "padding" "20px", style "border-radius" "8px", style "width" "400px" ]
                        [ h3 [] [ text "Usuń Pasieczysko" ]
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
                [ div [ style "background" "white", style "padding" "20px", style "border-radius" "8px", style "width" "400px" ]
                    [ h3 [] [ text "Nowy Ul" ]
                    , label [] [ text "Nazwa / Numer ula:" ]
                    , input [ type_ "text", placeholder "np. Ul #04", value model.newHiveName, onInput UpdateNewHiveName, style "width" "100%", style "padding" "8px", style "margin-bottom" "10px", style "box-sizing" "border-box" ] []
                    , label [] [ text "Typ ramki:" ]
                    , select [ value model.newHiveFrameType, onInput UpdateNewHiveFrameType, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box" ]
                        [ option [ value "Dadant" ] [ text "Dadant" ]
                        , option [ value "Wielkopolski" ] [ text "Wielkopolski" ]
                        , option [ value "Langstroth" ] [ text "Langstroth" ]
                        , option [ value "Warszawski" ] [ text "Warszawski poszerzany" ]
                        ]
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
        , case model.showRenameHiveModal of
            Just info ->
                div [ style "position" "fixed", style "top" "0", style "left" "0", style "width" "100%", style "height" "100%", style "background" "rgba(0,0,0,0.5)", style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
                    [ div [ style "background" "white", style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" "#333" ]
                        [ h3 [] [ text "Zmień nazwę ula" ]
                        , input [ type_ "text", value model.renameHiveInput, onInput UpdateRenameHiveInput, style "width" "100%", style "padding" "8px", style "margin-bottom" "15px", style "box-sizing" "border-box" ] []
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
                    [ div [ style "background" "white", style "padding" "20px", style "border-radius" "8px", style "width" "400px", style "color" "#333" ]
                        [ h3 [] [ text "Usuń ul" ]
                        , p [] [ text ("Czy na pewno chcesz usunąć ul \"" ++ info.hiveName ++ "\" wraz ze wszystkimi notatkami?") ]
                        , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "10px" ]
                            [ button [ onClick CloseDeleteHiveModal, style "padding" "8px 12px", style "background" "#bdc3c7", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Anuluj" ]
                            , button [ onClick (SubmitDeleteHive info.apiaryId info.hiveId), style "padding" "8px 12px", style "background" "#e74c3c", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Potwierdź usunięcie" ]
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


updateAt : Int -> (a -> a) -> List a -> List a
updateAt targetIndex updateFn list =
    List.indexedMap
        (\i item ->
            if i == targetIndex then
                updateFn item
            else
                item
        )
        list


removeAt : Int -> List a -> List a
removeAt targetIndex list =
    List.indexedMap (\i item -> (i, item)) list
        |> List.filter (\(i, _) -> i /= targetIndex)
        |> List.map Tuple.second


insertAt : Int -> a -> List a -> List a
insertAt targetIndex newItem list =
    let
        indexed = List.indexedMap (\i item -> (i, item)) list
        before = List.filter (\(i, _) -> i < targetIndex) indexed |> List.map Tuple.second
        after = List.filter (\(i, _) -> i >= targetIndex) indexed |> List.map Tuple.second
    in
    before ++ [newItem] ++ after


hiveBodiesEditorView : String -> String -> List HiveBody -> Html Msg
hiveBodiesEditorView apiaryId hiveId bodies =
    div [ style "margin-top" "20px", style "padding" "15px", style "background" "#fdfbf7", style "border-radius" "8px", style "border" "1px solid #e0d8c3", style "color" "#333" ]
        [ h3 [ style "margin-top" "0", style "color" "#d35400" ] [ text "Edytor Korpusów (Schemat Ula)" ]
        , p [ style "font-size" "13px", style "color" "#666" ] [ text "Układaj korpusy od góry do dołu. Możesz dodawać/usuwać korpusy, zmieniać liczbę ramek (0-10), oznaczać obecność matki (👑) oraz dodawać kratę odgrodową (⊞)." ]
        , div [ style "display" "flex", style "flex-direction" "column", style "gap" "10px", style "align-items" "center", style "margin-top" "15px" ]
            (List.indexedMap (hiveBodyView apiaryId hiveId (List.length bodies)) bodies)
        ]


hiveBodyView : String -> String -> Int -> Int -> HiveBody -> Html Msg
hiveBodyView apiaryId hiveId totalCount idx body =
    let
        korpusNr = totalCount - idx
    in
    div [ style "width" "100%", style "max-width" "500px", style "display" "flex", style "flex-direction" "column", style "align-items" "center" ]
        [ if body.hasExcluderAbove then
            div [ style "width" "100%", style "text-align" "center", style "padding" "4px 0", style "font-weight" "bold", style "color" "#e67e22", style "border-bottom" "2px dashed #e67e22", style "margin-bottom" "5px" ]
                [ text "⊞ Krata Odgrodowa" ]
          else
            text ""
        , div [ style "width" "100%", style "background" (if body.hasQueen then "#fef9e7" else "white"), style "border" (if body.hasQueen then "2px solid #f1c40f" else "2px solid #bdc3c7"), style "border-radius" "6px", style "padding" "12px", style "box-shadow" "0 1px 3px rgba(0,0,0,0.1)", style "color" "#333" ]
            [ div [ style "display" "flex", style "justify-content" "space-between", style "align-items" "center", style "margin-bottom" "8px" ]
                [ span [ style "font-weight" "bold", style "color" "#2c3e50" ] [ text ("Korpus " ++ String.fromInt korpusNr) ]
                , div [ style "display" "flex", style "gap" "6px" ]
                    [ button [ onClick (ToggleBodyQueen idx apiaryId hiveId), style "background" (if body.hasQueen then "#f1c40f" else "#ecf0f1"), style "border" "1px solid #d35400", style "border-radius" "4px", style "padding" "2px 6px", style "cursor" "pointer", title "Obecność matki" ] [ text "👑 Matka" ]
                    , button [ onClick (ToggleBodyExcluder idx apiaryId hiveId), style "background" (if body.hasExcluderAbove then "#e67e22" else "#ecf0f1"), style "border" "1px solid #d35400", style "border-radius" "4px", style "padding" "2px 6px", style "cursor" "pointer", title "Krata nad korpusem" ] [ text "⊞ Krata" ]
                    ]
                ]
            , div [ style "display" "flex", style "align-items" "center", style "gap" "10px", style "margin-bottom" "8px" ]
                [ span [ style "font-size" "13px" ] [ text "Ramek:" ]
                , input [ type_ "number", Html.Attributes.min "0", Html.Attributes.max "10", value (String.fromInt body.frameCount), onInput (\val -> UpdateBodyFrames idx val apiaryId hiveId), style "width" "60px", style "padding" "4px" ] []
                , span [ style "font-size" "13px", style "color" "#666" ] [ text "/ 10" ]
                ]
            , div [ style "display" "flex", style "justify-content" "flex-end", style "gap" "6px" ]
                [ button [ onClick (AddBodyAbove idx apiaryId hiveId), style "padding" "2px 6px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "font-size" "12px" ] [ text "+ Dodaj wyżej" ]
                , button [ onClick (AddBodyBelow idx apiaryId hiveId), style "padding" "2px 6px", style "background" "#27ae60", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "font-size" "12px" ] [ text "+ Dodaj niżej" ]
                , button [ onClick (RemoveBody idx apiaryId hiveId), style "padding" "2px 6px", style "background" "#e74c3c", style "color" "white", style "border" "none", style "border-radius" "4px", style "cursor" "pointer", style "font-size" "12px" ] [ text "🗑️ Usuń" ]
                ]
            ]
        ]
