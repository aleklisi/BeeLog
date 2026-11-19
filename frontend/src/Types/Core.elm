module Types.Core exposing (..)

import Json.Decode as Decode
import Dict exposing (Dict)
import Types.QueenRearing as QR

type alias User =
    { uid : String
    , email : String
    }

type Language
    = PL
    | EN

languageFromString : String -> Language
languageFromString value =
    if String.toLower value == "en" then EN else PL

languageToString : Language -> String
languageToString language =
    case language of
        PL -> "pl"
        EN -> "en"

type alias Queen =
    { hasOpalit : Bool
    , color : String
    , number : String
    }

type alias Korpus =
    { id : String
    , hasQueen : Bool
    , hasExcluderAbove : Bool
    , hasFoilAbove : Bool
    , hasOpenEntrance : Bool
    }

type alias Hive =
    { id : String
    , apiaryId : String
    , name : String
    , hiveType : String
    , frameType : String
    , broodFrameType : String
    , broodFrameCount : Int
    , maxBroodFrames : Int
    , hasSuper : Bool
    , superFrameType : String
    , superCount : Int
    , superFrameCount : Int
    , maxSuperFrames : Int
    , nfcLink : String
    , queen : Queen
    , pollenTrap : String
    , order : Int
    , korpusy : List Korpus
    }

type UlikState
    = Bezmatek
    | ZMatecznikiem
    | MatkaWygryziona
    | MatkaCzerwi
    | PustyUlik

type alias UlikQueen =
    { breedLine : String
    , hasOpalit : Bool
    , color : String
    , number : String
    }

type alias UlikHistoryEntry =
    { timestamp : String
    , prevState : String
    , state : String
    , description : String
    , breedLine : String
    , expectedHatchDate : String
    , expectedMatingDate : String
    , hasOpalit : Bool
    , color : String
    , number : String
    }

type alias UlikWeselny =
    { id : String
    , apiaryId : String
    , name : String
    , hiveType : String
    , hasQueen : Bool
    , queen : UlikQueen
    , state : String
    , expectedHatchDate : String
    , expectedMatingDate : String
    , nfcLink : String
    , order : Int
    , history : List UlikHistoryEntry
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
    , apiaryType : String
    , adminId : String
    , members : List ( String, String )
    , order : Int
    , uliki : List UlikWeselny
    , hives : List Hive
    }

type alias UserSettings =
    { frameTypes : List String
    , ulikTypes : List String
    , breedLines : List String
    , darkMode : Bool
    , hatchingToMatingDays : Int
    , maxUlikHistoryLimit : Int
    , enableTrutowiska : Bool
    , enablePasieczyskaTowarowe : Bool
    , enableQueenRearing : Bool
    , defaultGraftCount : Int
    , starterDurationDays : Int
    , isolationDay : Int
    , emergenceDay : Int
    , language : Language
    }

type AuthState
    = LoggedOut
    | LoggedIn User

type ViewState
    = LoginView
    | ApiariesView
    | MatingApiariesView
    | CommercialApiariesView
    | QueenRearingView
    | HiveListView { apiaryId : String, apiaryName : String }
    | HiveDetailView { apiaryId : String, hiveId : String, hiveName : String }
    | UlikListView { apiaryId : String, apiaryName : String }
    | UlikDetailView { apiaryId : String, ulikId : String, ulikName : String }
    | SharingView { apiaryId : String, apiaryName : String }
    | SettingsView

type UlikModalType
    = ModalPoddajMatecznik
    | ModalPoddajMatkeNieunasiennioną
    | ModalZaopalitkuj

type PendingDeepLink
    = PendingHive { apiaryId : String, hiveId : String }
    | PendingUlik { apiaryId : String, ulikId : String }

type SettingsSection
    = SectionOgolne
    | SectionPasieczyskaTowarowe
    | SectionTrutowiska
    | SectionQueenRearing

type alias Model =
    { authState : AuthState
    , viewState : ViewState
    , apiaries : List Apiary
    , hives : List Hive
    , draggedKorpusId : Maybe String
    , uliki : List UlikWeselny
    , notes : List Note
    , errorMessage : Maybe String
    , successMessage : Maybe String
    , darkMode : Bool
    , language : Language
    , pendingDeepLink : Maybe PendingDeepLink
    , showNewApiaryModal : Bool
    , newApiaryName : String
    , newApiaryType : String
    , showEditApiaryModal : Maybe Apiary
    , editApiaryNameInput : String
    , showDeleteApiaryModal : Maybe Apiary
    , showNewHiveModal : Bool
    , newHiveName : String
    , newHiveType : String
    , newHiveFrameType : String
    , newHiveBroodFrameType : String
    , newHiveBroodFrameCount : Int
    , newHiveMaxBroodFrames : Int
    , newHiveHasSuper : Bool
    , newHiveSuperFrameType : String
    , newHiveSuperCount : Int
    , newHiveSuperFrameCount : Int
    , newHiveMaxSuperFrames : Int
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
    , showMoveUlikModal : Maybe { sourceApiaryId : String, ulikId : String, ulikName : String }
    , moveUlikTargetApiaryId : String
    , currentDate : String
    , currentEpoch : Int
    , apiaryFilter : String
    , ulikFilter : String
    , frameTypes : List String
    , newFrameTypeInput : String
    , ulikTypes : List String
    , newUlikTypeInput : String
    , breedLines : List String
    , newBreedLineInput : String
    , hatchingToMatingDays : Int
    , maxUlikHistoryLimit : Int
    , enableTrutowiska : Bool
    , enablePasieczyskaTowarowe : Bool
    , enableQueenRearing : Bool
    , defaultGraftCount : Int
    , starterDurationDays : Int
    , isolationDay : Int
    , emergenceDay : Int
    , menuExpanded : Bool
    , previousPrimaryView : Maybe ViewState
    , queenRearingData : QR.QueenRearingData
    , queenRearingForm : Dict String String
    , editingQueenResource : Maybe { kind : String, id : String }
    , expandedSettingsSections : List SettingsSection
    , activeUlikModal : Maybe { apiaryId : String, ulikId : String, modalType : UlikModalType }
    , modalBreedLine : String
    , modalHatchDate : String
    , modalIsOpalitkovana : String
    , modalOpalitColor : String
    , modalOpalitNumber : String
    }

type Msg
    = ClickLoginGoogle
    | ClickLogout
    | ToggleDarkMode
    | ChangeLanguage Language
    | ToggleEnableTrutowiska
    | ToggleEnablePasieczyskaTowarowe
    | ToggleEnableQueenRearing
    | ToggleMainMenu
    | QueenRearingDataReceived (Result String QR.QueenRearingData)
    | QueenRearingInput String String
    | SaveQueenResource String
    | EditQueenResource String String
    | RetireBreederQueen String
    | DeleteQueenResource String String
    | CreatePlannedRearingBatch
    | StartRearingBatch String
    | TransitionRearingBatch String String
    | DeleteRearingBatch String
    | ToggleSettingsSection SettingsSection
    | UpdateQueenSetting String String
    | AuthStateUpdated { uid : String, email : String }
    | CurrentDateReceived String
    | CurrentEpochReceived Int
    | UserSettingsReceived (Result String UserSettings)
    | LoadApiariesData String
    | ApiariesDecoded (Result String (List Apiary))
    | NavigateTo ViewState
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
    | UpdateNewUlikTypeInput String
    | AddUlikType String
    | RemoveUlikType String
    | UpdateNewBreedLineInput String
    | AddBreedLine String
    | RemoveBreedLine String
    | UpdateHatchingToMatingDaysInput String
    | UpdateMaxUlikHistoryLimitInput String
    | HivesDecoded (Result String (List Hive))
    | OpenNewHiveModal
    | CloseNewHiveModal
    | UpdateNewHiveName String
    | UpdateNewHiveType String
    | UpdateNewHiveFrameType String
    | UpdateNewHiveBroodFrameType String
    | UpdateNewHiveBroodFrameCount Int
    | UpdateNewHiveMaxBroodFrames Int
    | UpdateNewHiveHasSuper Bool
    | UpdateNewHiveSuperFrameType String
    | UpdateNewHiveSuperCount Int
    | UpdateNewHiveSuperFrameCount Int
    | UpdateNewHiveMaxSuperFrames Int
    | SubmitCreateHive String
    | UpdateHiveField String String String String
    | AddKorpusAbove String String String
    | AddKorpusBelow String String String
    | AddKorpusBetween String String Int
    | DeleteKorpus String String String
    | ToggleKorpusQueen String String String
    | ToggleKorpusExcluder String String String
    | ToggleKorpusFoil String String String
    | ToggleKorpusEntrance String String String
    | StartKorpusDrag String
    | DropKorpusOn String String String
    | DropKorpusAfter String String String
    | EndKorpusDrag
    | KorpusDropReceived Decode.Value
    | NoOp
    | UlikiDecoded (Result String (List UlikWeselny))
    | OpenNewUlikModal
    | CloseNewUlikModal
    | UpdateNewUlikName String
    | UpdateNewUlikHiveType String
    | SubmitCreateUlik String
    | UpdateUlikField String String String String
    | OpenUlikModal String String UlikModalType
    | CloseUlikModal
    | UpdateModalBreedLine String
    | UpdateModalHatchDate String
    | UpdateModalIsOpalitkovana String
    | UpdateModalOpalitColor String
    | UpdateModalOpalitNumber String
    | SubmitUlikModal String String UlikModalType
    | TransitionUlikState String String UlikState
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
    | UpdateShareEmail String
    | UpdateShareRole String
    | SubmitShareApiary String String String
    | SubmitRemoveMember String String
    | OpenRenameHiveModal String Hive
    | CloseRenameHiveModal
    | UpdateRenameHiveInput String
    | SubmitRenameHive String String
    | OpenDeleteHiveModal String Hive
    | CloseDeleteHiveModal
    | SubmitDeleteHive String String
    | OpenRenameUlikModal String UlikWeselny
    | CloseRenameUlikModal
    | UpdateRenameUlikInput String
    | SubmitRenameUlik String String
    | OpenDeleteUlikModal String UlikWeselny
    | CloseDeleteUlikModal
    | SubmitDeleteUlik String String
    | OpenMoveUlikModal String UlikWeselny
    | CloseMoveUlikModal
    | SelectMoveUlikTargetApiary String
    | SubmitMoveUlik String String String
    | MoveApiaryUp String
    | MoveApiaryDown String
    | MoveHiveUp String
    | MoveHiveDown String
    | MoveUlikUp String
    | MoveUlikDown String
    | UpdatePollenTrap String String String
    | CopyUserId String
    | CopyText String
    | SubmitHiveSnapshot String String User
    | HandleError String
    | SuccessMessageReceived String
    | ClearMessages
