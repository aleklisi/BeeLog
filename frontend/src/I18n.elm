module I18n exposing (Translations, allTranslationValues, translationsFor)

import Types.Core exposing (Language(..))
import String

type alias Translations =
    { localize : String -> String
    , isEnglish : Bool
    , back : String
    , settings : String
    , general : String
    , language : String
    , polish : String
    , english : String
    , darkMode : String
    , lightMode : String
    , account : String
    , appearance : String
    , signedInEmail : String
    , commercialApiaries : String
    , matingApiaries : String
    , matingApiariesHeading : String
    , commercialApiariesHeading : String
    , apiaries : String
    , addApiary : String
    , noApiaries : String
    , noCommercialApiaries : String
    , noMatingApiaries : String
    , owner : String
    , shared : String
    , hives : String
    , noHives : String
    , matingHives : String
    , addHive : String
    , hive : String
    , queen : String
    , noQueen : String
    , loginTitle : String
    , loginDescription : String
    , loginButton : String
    , logout : String
    , mainNavigation : String
    , menu : String
    , add : String
    , save : String
    , cancel : String
    , delete : String
    , edit : String
    , share : String
    , enabled : String
    , remove : String
    , filterState : String
    , allStates : String
    , addMatingHive : String
    , frameType : String
    , moveUp : String
    , moveDown : String
    , sectionCommercial : String
    , enableCommercial : String
    , commercialHelp : String
    , frameTypes : String
    , frameTypesHelp : String
    , newFrameType : String
    , sectionMating : String
    , enableMating : String
    , matingHelp : String
    , ulikTypes : String
    , ulikTypesHelp : String
    , newUlikType : String
    , breedLines : String
    , breedLinesHelp : String
    , newBreedLine : String
    , hatchingMatingDays : String
    , hatchingMatingHelp : String
    , maxHistory : String
    , maxHistoryHelp : String
    , queenRearing : String
    , enableQueenRearing : String
    , queenRearingDefaults : String
    , graftCount : String
    , starterDuration : String
    , isolationDay : String
    , emergenceDay : String
    , matingHivesTotal : String
    , stateQueenless : String
    , stateCell : String
    , stateEmptyMatingHive : String
    , stateUnmated : String
    , stateMated : String
    , commercialHivesTotal : String
    , noHivesShort : String
    , moveLeft : String
    , moveRight : String
    }

translationsFor : Language -> Translations
translationsFor language =
    case language of
        PL ->
            { localize = localizeText PL, isEnglish = False, back = "← Powrót", settings = "⚙️ Ustawienia", general = "Ogólne", language = "Język", polish = "Polski", english = "English", darkMode = "🌙 Przełącz na Tryb Ciemny", lightMode = "☀️ Przełącz na Tryb Jasny", account = "Konto użytkownika", appearance = "Wygląd i motyw", signedInEmail = "Zalogowany adres e-mail:", commercialApiaries = "Pasieczyska towarowe", matingApiaries = "Trutowiska", matingApiariesHeading = "Trutowiska", commercialApiariesHeading = "Pasieczyska towarowe", apiaries = "Twoje Pasieczyska", addApiary = "+ Dodaj Pasieczysko", noApiaries = "Brak pasieczysk.", noCommercialApiaries = "Brak pasieczysk towarowych. Utwórz pierwsze pasieczysko towarowe.", noMatingApiaries = "Brak trutowisk. Utwórz pierwsze trutowisko.", owner = "Właściciel", shared = "Udostępnione", hives = "Ule towarowe", noHives = "Brak uli", matingHives = "Uliki weselne", addHive = "+ Dodaj Nowy Ul", hive = "Ul", queen = "Matka", noQueen = "Brak matki", loginTitle = "Witaj w BeeLog", loginDescription = "Zarządzaj pasieką, ulami i notatkami głosowymi w terenie.", loginButton = "Zaloguj przez Google", logout = "Wyloguj się", mainNavigation = "Nawigacja główna", menu = "Menu główne", add = "Dodaj", save = "Zapisz", cancel = "Anuluj", delete = "Usuń", edit = "Edytuj", share = "Udostępnij", enabled = "Włączony", remove = "Usuń", filterState = "Filtruj stan:", allStates = "Wszystkie stany", addMatingHive = "+ Dodaj Ulik Weselny", frameType = "Typ ramki:", moveUp = "Przesuń w górę", moveDown = "Przesuń w dół", sectionCommercial = "Pasieczyska towarowe", enableCommercial = "Włącz Pasieczyska Towarowe", commercialHelp = "Włącza lub wyłącza widoczność pasieczysk towarowych na głównej liście oraz w menu nawigacyjnym.", frameTypes = "Rodzaje ramek (Pasieka Towarowa)", frameTypesHelp = "Umożliwia konfigurację listy dostępnych rodzajów ramek (np. Dadant, Wielkopolski) dla uli towarowych.", newFrameType = "Nowy rodzaj ramki (np. Dadant)", sectionMating = "Trutowiska", enableMating = "Włącz Trutowiska", matingHelp = "Włącza lub wyłącza widoczność trutowisk oraz ulików weselnych w aplikacji.", ulikTypes = "Typy ulików weselnych", ulikTypesHelp = "Umożliwia konfigurację listy dostępnych typów ulików weselnych (np. Mini plus, Apidea).", newUlikType = "Nowy typ uliku (np. Apidea)", breedLines = "Rasy i linie matek pszczelich", breedLinesHelp = "Umożliwia konfigurację listy ras i linii matek pszczelich dostępnych przy obsłudze ulików weselnych.", newBreedLine = "Nowa rasa/linia (np. car. Galicja)", hatchingMatingDays = "Liczba dni od spodziewanego wygryzienia do spodziewanego unasiennienia", hatchingMatingHelp = "Określa liczbę dni (1-30) od wygryzienia matki do spodziewanej daty jej unasiennienia.", maxHistory = "Maksymalna liczba wydarzeń w historii ulika weselnego", maxHistoryHelp = "Ustala maksymalną liczbę wpisów historii przechowywanych dla pojedynczego ulika weselnego (10-60).", queenRearing = "Hodowla matek", enableQueenRearing = "Włącz hodowlę matek", queenRearingDefaults = "Wartości domyślne dla nowo rozpoczętych serii. Izolacja musi nastąpić po przeniesieniu do startera, a wygryzienie nie może poprzedzać izolacji.", graftCount = "Domyślna liczba larw do przełożenia", starterDuration = "Czas pracy startera (1–10 dni)", isolationDay = "Dzień izolacji", emergenceDay = "Przewidywany dzień wygryzienia", matingHivesTotal = "Uliki weselne (Razem: ", stateQueenless = "Bezmatek", stateCell = "Matecznik", stateEmptyMatingHive = "Pusty ulik", stateUnmated = "Matka nieunasienniona", stateMated = "Matka unasienniona", commercialHivesTotal = "Ule towarowe (Razem: ", noHivesShort = "Brak uli", moveLeft = "Przesuń w lewo", moveRight = "Przesuń w prawo" }

        EN ->
            { localize = localizeText EN, isEnglish = True, back = "← Back", settings = "⚙️ Settings", general = "General", language = "Language", polish = "Polski", english = "English", darkMode = "🌙 Switch to dark mode", lightMode = "☀️ Switch to light mode", account = "User account", appearance = "Appearance and theme", signedInEmail = "Signed-in email:", commercialApiaries = "Commercial Apiaries", matingApiaries = "Mating Apiaries", matingApiariesHeading = "Mating Apiaries", commercialApiariesHeading = "Commercial Apiaries", apiaries = "Your Apiaries", addApiary = "+ Add Apiary", noApiaries = "No apiaries yet.", noCommercialApiaries = "No commercial apiaries yet. Create a commercial apiary to get started.", noMatingApiaries = "No mating apiaries yet. Create a mating apiary to get started.", owner = "Owner", shared = "Shared", hives = "Commercial hives", noHives = "No hives", matingHives = "Mating hives", addHive = "+ Add New Hive", hive = "Hive", queen = "Queen", noQueen = "No queen", loginTitle = "Welcome to BeeLog", loginDescription = "Manage your apiary, hives and voice notes in the field.", loginButton = "Sign in with Google", logout = "Log out", mainNavigation = "Main navigation", menu = "Main menu", add = "Add", save = "Save", cancel = "Cancel", delete = "Delete", edit = "Edit", share = "Share", enabled = "Enabled", remove = "Remove", filterState = "Filter by state:", allStates = "All states", addMatingHive = "+ Add Mating Hive", frameType = "Frame type:", moveUp = "Move up", moveDown = "Move down", sectionCommercial = "Commercial Apiaries", enableCommercial = "Enable commercial apiaries", commercialHelp = "Show or hide commercial apiaries on the main list and navigation menu.", frameTypes = "Frame types (Commercial apiary)", frameTypesHelp = "Configure available frame types (for example, Dadant or Wielkopolski) for commercial hives.", newFrameType = "New frame type (for example, Dadant)", sectionMating = "Mating Apiaries", enableMating = "Enable mating apiaries", matingHelp = "Show or hide mating apiaries and mating hives in the app.", ulikTypes = "Mating hive types", ulikTypesHelp = "Configure available mating hive types (for example, Mini plus or Apidea).", newUlikType = "New mating hive type (for example, Apidea)", breedLines = "Queen breeds and lines", breedLinesHelp = "Configure queen breeds and lines available when managing mating hives.", newBreedLine = "New breed/line (for example, car. Galicja)", hatchingMatingDays = "Days from expected emergence to expected mating", hatchingMatingHelp = "Number of days (1–30) from queen emergence to the expected mating date.", maxHistory = "Maximum mating hive history events", maxHistoryHelp = "Maximum history entries stored for one mating hive (10–60).", queenRearing = "Queen rearing", enableQueenRearing = "Enable queen rearing", queenRearingDefaults = "Defaults for new batches. Isolating must follow transfer to the starter, and emergence cannot happen before isolation.", graftCount = "Default graft count", starterDuration = "Starter duration (1–10 days)", isolationDay = "Isolation day", emergenceDay = "Expected emergence day", matingHivesTotal = "Mating hives (total: ", stateQueenless = "Queenless", stateCell = "Queen cell", stateEmptyMatingHive = "Empty mating hive", stateUnmated = "Unmated queen", stateMated = "Mated queen", commercialHivesTotal = "Commercial hives (total: ", noHivesShort = "No hives", moveLeft = "Move left", moveRight = "Move right" }

localizeText : Language -> String -> String
localizeText language value =
    case language of
        PL ->
            value

        EN ->
            case value of
                "Nazwa Ula:" -> "Hive name:"
                "Do spodziewanego wygryzienia: matka powinna się wygryźć." -> "Until expected emergence: the queen should emerge."
                "Od wygryzienia do terminu unasiennienia: młoda matka dojrzewa i powinna odbyć loty godowe." -> "From emergence to expected mating: the young queen matures and should take mating flights."
                "Po spodziewanym terminie unasiennienia: matka powinna być już unasienniona." -> "After the expected mating date: the queen should be mated."
                "Po 30 dniach od wygryzienia: matka zbyt długo się nie unasienniła; sprawdź jej stan." -> "More than 30 days after emergence: the queen has not mated for too long; check her status."
                "Niebieska kreska pokazuje dzisiejszą datę." -> "The blue line marks today's date."
                "Wyjaśnienie kolorów osi czasu cyklu matki" -> "Queen cycle timeline color guide"
                "Brak matki w ulu" -> "No queen in the hive"
                "Sprawdź, czy matka się wygryzła" -> "Check whether the queen has emerged"
                "Minął oczekiwany termin unasiennienia matki" -> "The expected queen mating date has passed"
                "Minął deadline 30 dni od wygryzienia – matka nadal nieunasienniona" -> "The 30-day deadline after emergence has passed; the queen is still unmated"
                "Ładowanie uliku..." -> "Loading mating hive..."
                "Pasieka: " -> "Apiary: "
                "Trutowisko: " -> "Mating apiary: "
                "Karta Ula: " -> "Hive details: "
                "Ulik Weselny: " -> "Mating hive: "
                "Matka: " -> "Queen: "
                "Stan: " -> "Status: "
                "Aktualny stan: " -> "Current status: "
                "Teraz: " -> "Now: "
                "Wygryz.: " -> "Emergence: "
                "Unasien.: " -> "Mating: "
                "+30 dni: " -> "+30 days: "
                "Ramka: " -> "Frame: "
                " | Maks. pojemność: " -> " | Max capacity: "
                " ramek" -> " frames"
                "Ramka nadstawki: " -> "Super frame: "
                " | Liczba ramek: " -> " | Frame count: "
                " | Liczba nadstawek: " -> " | Super count: "
                "Korpus #" -> "Body #"
                "Zapisz pełny stan ula jako notatkę" -> "Save the full hive state as a note"
                "Udostępnianie pasieki: " -> "Share apiary: "
                "Czy na pewno chcesz usunąć pasieczysko \"" -> "Are you sure you want to delete apiary \""
                "\" wraz ze wszystkimi ulami i notatkami?" -> "\" and all its hives and notes?"
                "Czy na pewno chcesz usunąć ul \"" -> "Are you sure you want to delete hive \""
                "Czy na pewno chcesz usunąć ulik \"" -> "Are you sure you want to delete mating hive \""
                "Przenieś ulik: " -> "Move mating hive: "
                "Opalitek " -> "Tag "
                "Brak opalitka" -> "No tag"
                "Bez opalitka" -> "No tag"
                "Brak matki" -> "No queen"
                "Opalit " -> "Tag "
                "Dane Techniczne" -> "Technical data"
                "Dane Techniczne:" -> "Technical data:"
                "Technical data" -> "Technical data"
                "Typ ula" -> "Hive type"
                "Matka Pszczela" -> "Queen"
                "Typ ula:" -> "Hive type:"
                "Ul korpusowy" -> "Stacked hive"
                "Ul leżak" -> "Horizontal hive"
                "Ul kombinowany" -> "Combined hive"
                "Typ Ramki:" -> "Frame type:"
                "Typ ramki:" -> "Frame type:"
                "Typ ramki gniazdowej:" -> "Brood frame type:"
                "Typ ramki nadstawkowej (nadstawki):" -> "Super frame type:"
                "Maksymalna liczba ramek w gnieździe:" -> "Maximum brood frames:"
                "Maksymalna liczba ramek w nadstawce:" -> "Maximum super frames:"
                "Liczba ramek gniazdowych:" -> "Number of brood frames:"
                "Liczba ramek:" -> "Frame count:"
                "Liczba ramek w nadstawce:" -> "Frames in super:"
                "Początkowa liczba ramek w gnieździe:" -> "Initial brood frame count:"
                "Początkowa liczba ramek w nadstawce:" -> "Initial super frame count:"
                "Początkowa liczba nadstawek:" -> "Initial number of supers:"
                "Czy jest nadstawka" -> "Has a super"
                "Czy posiada nadstawkę?" -> "Has a super?"
                "Czy jest tam matka:" -> "Is there a queen:"
                "Poławiacz pyłku:" -> "Pollen trap:"
                "Brak" -> "None"
                "Powałkowy" -> "Top-mounted"
                "Dennicowy" -> "Bottom-mounted"
                "Link do NFC:" -> "NFC link:"
                "Brak linku" -> "No link"
                "📋 Kopiuj link do NFC" -> "📋 Copy NFC link"
                "Obecność Opalitka:" -> "Opalite tag:"
                "Tak (Opalitka)" -> "Yes (tagged)"
                "Nie / Czarny opalitek" -> "No / black tag"
                "Kolor Opalitka:" -> "Tag color:"
                "Numer Opalitka:" -> "Tag number:"
                "Biały" -> "White"
                "Żółty" -> "Yellow"
                "Czerwony" -> "Red"
                "Zielony" -> "Green"
                "Niebieski" -> "Blue"
                "Edytor Korpusów (Stan Ula)" -> "Hive body editor (hive state)"
                "Zarządzaj korpusami ula, obecnością matki w poszczególnych korpusach oraz kratami odgrodowymi. " -> "Manage hive bodies, queen location, and queen excluders. "
                "Chwyć korpus i przeciągnij go na inny, aby zmienić kolejność." -> "Drag a hive body to reorder it."
                " Przeciągnij korpus i upuść w górnej strefie, aby przenieść go nad inny, lub w dolnej strefie, aby umieścić go pod nim." -> " Drop it in the upper zone to move it above another body, or in the lower zone to place it below."
                "Konfiguracja Gniazda i Nadstawek" -> "Brood nest and supers"
                "Gniazdo:" -> "Brood nest:"
                "Nadstawka:" -> "Super:"
                "Nadstawki:" -> "Supers:"
                "Brak nadstawki (zaznacz pole „Czy jest nadstawka” w Danych Technicznych powyżej, aby dodać)." -> "No super (select “Has a super” in the technical data above to add one)."
                "➕ Dodaj nadstawkę" -> "➕ Add a super"
                "➖ Zabierz nadstawkę" -> "➖ Remove a super"
                "Notatki" -> "Notes"
                "Wpisz notatkę lub użyj dyktowania głosowego..." -> "Enter a note or use voice dictation..."
                "🎤 Dyktuj" -> "🎤 Dictate"
                "Zapisz Notatkę" -> "Save note"
                "📸 Zrzut Ula" -> "📸 Hive snapshot"
                "🟧 Krata odgrodowa" -> "🟧 Queen excluder"
                "🟦 Szczelna folia nad korpusem" -> "🟦 Sealed film above the body"
                "Krata odgrodowa nad korpusem" -> "Queen excluder above the body"
                "Folia na korpusie" -> "Film on the body"
                "matka jest w tym korpusie" -> "the queen is in this body"
                "Matka" -> "Queen"
                "Otwarty wylotek w korpusie" -> "Open entrance in this body"
                "Otwiera wylotek w tym korpusie i pozwala prowadzić ul dwurodzinny." -> "Opens this body's entrance and allows a two-queen colony."
                "Upuść tutaj, aby przenieść korpus nad ten korpus" -> "Drop here to move the body above this one"
                "Upuść tutaj, aby przenieść korpus pod ten korpus" -> "Drop here to move the body below this one"
                "Dodaj korpus nad" -> "Add body above"
                "Dodaj korpus pod" -> "Add body below"
                "W ulu musi pozostać co najmniej jeden korpus" -> "At least one hive body must remain"
                "Usuń ten korpus" -> "Remove this body"
                "Dane Uliku Weselnego" -> "Mating hive details"
                "Nazwa / Numer uliku:" -> "Mating hive name / number:"
                "🚚 Zmień pasieczysko" -> "🚚 Move apiary"
                "Spodziewany termin wygryzienia:" -> "Expected emergence date:"
                "Spodziewany termin unasiennienia (+10 dni):" -> "Expected mating date (+10 days):"
                "Oczekiwanie na unasiennienie (przed terminem)" -> "Waiting for mating (before expected date)"
                "W terminie (10-21 dni od wygryzienia)" -> "On time (10–21 days after emergence)"
                "✓ W terminie" -> "✓ On time"
                "Przekroczono termin (>21 dni)" -> "Past due (>21 days)"
                "✗ Przekroczony" -> "✗ Overdue"
                "Stan i Matka Pszczela" -> "Status and queen"
                "➕ Poddano matecznik (M)" -> "➕ Queen cell added (M)"
                "➕ Poddano matkę nieunasiennioną (N)" -> "➕ Unmated queen added (N)"
                "🧹 Opróżnij ulik (P)" -> "🧹 Empty mating hive (P)"
                "🦋 Matka się wygryzła (N)" -> "🦋 Queen emerged (N)"
                "❌ Matecznik się nie wygryzł (B)" -> "❌ Queen did not emerge (B)"
                "👑 Matka się unasienniła (UNC)" -> "👑 Queen mated (UNC)"
                "🏷️ Zaopalitkuj" -> "🏷️ Mark queen with tag"
                "⚠️ Matka strutowiała / zniknęła (B)" -> "⚠️ Queen became a drone layer / disappeared (B)"
                "Matka unasienniona / czerwi (pełny sukces uliku weselnego)" -> "Queen mated and laying (mating hive success)"
                "zabieram matkę (B)" -> "Queen removed (B)"
                "➕ Przejdź do Bezmatek (B)" -> "➕ Set as queenless (B)"
                "Tak" -> "Yes"
                "Nie" -> "No"
                "Rasa i linia matki:" -> "Queen breed and line:"
                "Historia zmian uliku" -> "Mating hive history"
                "Brak wpisów w historii" -> "No history entries"
                "Oś czasu: brak daty wygryzienia" -> "Timeline: no emergence date"
                "Oś czasu cyklu matki:" -> "Queen cycle timeline:"
                "Do wygryzienia (jasno żółty)" -> "Until emergence (light yellow)"
                "Wygryzienie do unasiennienia (ciemno żółty)" -> "Emergence to mating (dark yellow)"
                "Okres po unasiennieniu" -> "After mating"
                "Po 30 dniach od wygryzienia (czerwony - deadline)" -> "More than 30 days after emergence (red - deadline)"
                "Wyjaśnij kolory osi czasu" -> "Explain timeline colors"
                "(B) Bezmatek" -> "(B) Queenless"
                "(M) Matecznik" -> "(M) Queen cell"
                "(N) Matka nieunasienniona" -> "(N) Unmated queen"
                "(UNC) Matka unasienniona" -> "(UNC) Mated queen"
                "(P) Pusty ulik" -> "(P) Empty mating hive"
                "Aktualni członkowie i uprawnienia" -> "Current members and permissions"
                "Adres e-mail użytkownika" -> "User email address"
                "Edytor" -> "Editor"
                "Tylko podgląd" -> "View only"
                "Przyznaj dostęp" -> "Grant access"
                "Przyznaj dostęp nowemu użytkownikowi" -> "Grant access to a new user"
                "Ładowanie pasieki..." -> "Loading apiary..."
                "Cofnij dostęp" -> "Revoke access"
                "Właściciel (stały)" -> "Owner (permanent)"
                "Nowe Pasieczysko" -> "New apiary"
                "Nazwa pasieczyska:" -> "Apiary name:"
                "Nazwa pasieczyska" -> "Apiary name"
                "Typ pasieczyska:" -> "Apiary type:"
                "Pasieczysko towarowe" -> "Commercial apiary"
                "Trutowisko (uliki weselne)" -> "Mating apiary (mating hives)"
                "Edytuj Nazwę Pasieczyska" -> "Edit apiary name"
                "Usuń Pasieczysko" -> "Delete apiary"
                "Nowy Ul" -> "New hive"
                "Nazwa / Numer ula:" -> "Hive name / number:"
                "np. Ul #04" -> "e.g. Hive #04"
                "Usuń ul" -> "Delete hive"
                "Zmień nazwę ula" -> "Rename hive"
                "Nowy Ulik Weselny" -> "New mating hive"
                "np. Ulik #01" -> "e.g. Mating hive #01"
                "Usuń ulik weselny" -> "Delete mating hive"
                "Zmień nazwę uliku" -> "Rename mating hive"
                "Wybierz docelowe trutowisko:" -> "Choose destination mating apiary:"
                "Brak innych trutowisk do wyboru." -> "No other mating apiaries available."
                "Przenieś" -> "Move"
                "Czy opalitkowana?" -> "Is the queen marked?"
                "np. 42" -> "e.g. 42"
                "Identyfikator Pasiecznika (Właściciela)" -> "Apiary owner ID"
                "📋 Kopiuj ID" -> "📋 Copy ID"
                "Anuluj" -> "Cancel"
                "Zapisz" -> "Save"
                "Potwierdź usunięcie" -> "Confirm deletion"
                "Edytuj" -> "Edit"
                "Usuń" -> "Delete"
                "← Powrót" -> "← Back"
                "BeeLog 🐝" -> "BeeLog 🐝"
                "✕" -> "✕"
                "!" -> "!"
                "i" -> "i"
                "📸 Zapisano zrzut ula jako notatkę!" -> "📸 Hive snapshot saved as a note!"
                "Błąd dekodowania pasieczysk" -> "Could not read apiaries"
                "Błąd dekodowania uli" -> "Could not read hives"
                "Błąd dekodowania ulików weselnych" -> "Could not read mating hives"
                "Błąd dekodowania notatek" -> "Could not read notes"
                _ -> translateErrorPrefix value


translateErrorPrefix : String -> String
translateErrorPrefix value =
    let
        translatePrefix polish english =
            if String.startsWith polish value then
                english ++ String.dropLeft (String.length polish) value
            else
                ""

        translated =
            [ translatePrefix "Błąd dekodowania pasieczysk: " "Could not read apiaries: "
            , translatePrefix "Błąd dekodowania uli: " "Could not read hives: "
            , translatePrefix "Błąd dekodowania ulików weselnych: " "Could not read mating hives: "
            , translatePrefix "Błąd dekodowania notatek: " "Could not read notes: "
            ]
                |> List.filter ((/=) "")
    in
    List.head translated |> Maybe.withDefault value

allTranslationValues : Translations -> List String
allTranslationValues t =
    [ t.back, t.settings, t.general, t.language, t.polish, t.english, t.darkMode, t.lightMode, t.account, t.appearance, t.signedInEmail, t.commercialApiaries, t.matingApiaries, t.matingApiariesHeading, t.commercialApiariesHeading, t.apiaries, t.addApiary, t.noApiaries, t.noCommercialApiaries, t.noMatingApiaries, t.owner, t.shared, t.hives, t.noHives, t.matingHives, t.addHive, t.hive, t.queen, t.noQueen, t.loginTitle, t.loginDescription, t.loginButton, t.logout, t.mainNavigation, t.menu, t.add, t.save, t.cancel, t.delete, t.edit, t.share, t.enabled, t.remove, t.filterState, t.allStates, t.addMatingHive, t.frameType, t.moveUp, t.moveDown, t.sectionCommercial, t.enableCommercial, t.commercialHelp, t.frameTypes, t.frameTypesHelp, t.newFrameType, t.sectionMating, t.enableMating, t.matingHelp, t.ulikTypes, t.ulikTypesHelp, t.newUlikType, t.breedLines, t.breedLinesHelp, t.newBreedLine, t.hatchingMatingDays, t.hatchingMatingHelp, t.maxHistory, t.maxHistoryHelp, t.queenRearing, t.enableQueenRearing, t.queenRearingDefaults, t.graftCount, t.starterDuration, t.isolationDay, t.emergenceDay, t.matingHivesTotal, t.stateQueenless, t.stateCell, t.stateEmptyMatingHive, t.stateUnmated, t.stateMated, t.commercialHivesTotal, t.noHivesShort, t.moveLeft, t.moveRight ]
