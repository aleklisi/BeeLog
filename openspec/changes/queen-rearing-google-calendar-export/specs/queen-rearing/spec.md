# Spec Delta

## ADDED Requirements

### Requirement: Eksport serii do Google Calendar
Użytkownik SHALL móc połączyć konto Google i wyeksportować harmonogram pojedynczej serii do Google Calendar. Każdy eksportowany termin SHALL mieć powiązane wydarzenie kalendarza oraz zadanie Google Tasks, a ponowny eksport SHALL aktualizować istniejące wpisy zamiast tworzyć duplikaty.

#### Scenario: Połączenie konta Google
- **WHEN** użytkownik wybiera połączenie z Google i zatwierdza wymagane uprawnienia
- **THEN** aplikacja umożliwia eksport serii na wskazane konto Google

#### Scenario: Eksport serii
- **GIVEN** seria ma wyliczone daty transferu do finishera, transferu do cieplarki i przewidywanego wygryzienia
- **WHEN** użytkownik eksportuje tę serię
- **THEN** w Google Calendar powstają trzy wydarzenia, a w Google Tasks trzy odpowiadające im zadania z właściwymi terminami i numerem serii

#### Scenario: Ponowny eksport po zmianie harmonogramu
- **GIVEN** seria została wcześniej wyeksportowana, a jej harmonogram lub dane uległy zmianie
- **WHEN** użytkownik ponownie eksportuje serię
- **THEN** powiązane wydarzenia i zadania są aktualizowane, a dodatkowe duplikaty nie powstają

#### Scenario: Eksport kolejnej serii
- **GIVEN** użytkownik ma już inną serię wyeksportowaną do Google
- **WHEN** eksportuje następną serię
- **THEN** jej wydarzenia i zadania są dodawane niezależnie i powiązane z właściwą serią

#### Scenario: Brak połączenia lub błąd eksportu
- **WHEN** użytkownik eksportuje serię bez aktywnego połączenia Google albo Google odrzuca operację
- **THEN** aplikacja informuje o konieczności połączenia konta lub o błędzie i nie oznacza niepełnego eksportu jako zakończonego

#### Scenario: Częściowe niepowodzenie eksportu
- **GIVEN** część wydarzeń lub zadań została zapisana, a kolejna operacja Google zakończyła się błędem
- **WHEN** eksport serii zostaje przerwany
- **THEN** aplikacja zachowuje identyfikatory pomyślnie zapisanych wpisów, pokazuje niepełny stan eksportu i pozwala bezpiecznie ponowić eksport bez duplikowania tych wpisów

#### Scenario: Odłączenie konta Google
- **GIVEN** konto Google jest połączone z aplikacją
- **WHEN** użytkownik odłącza konto
- **THEN** aplikacja usuwa lokalne poświadczenia i powiązania eksportu oraz nie wykonuje kolejnych operacji Google bez ponownego połączenia

### Requirement: Terminy prac eksportowanej serii
Eksportowany harmonogram SHALL zawierać transfer z etapu startera do finishera, transfer z finishera do cieplarki oraz wyjęcie mateczników z cieplarki w dniu przewidywanego wygryzienia. Każde wydarzenie i zadanie SHALL jasno opisywać czynność oraz wskazywać numer serii.

#### Scenario: Terminy transferu i wyjęcia mateczników
- **GIVEN** seria ma zapisane daty harmonogramu
- **WHEN** aplikacja przygotowuje wpisy do eksportu
- **THEN** termin transferu ze startera przypada na zapisaną datę rozpoczęcia etapu finishera, transfer do cieplarki na datę izolacji, a wyjęcie mateczników na dzień przewidywanego wygryzienia

#### Scenario: Seria bez etapu cieplarki
- **GIVEN** seria kończy się bezpośrednio w finisherze
- **WHEN** użytkownik eksportuje serię
- **THEN** eksportowane są tylko przeniesienie do finishera i termin wyjęcia mateczników w dniu przewidywanego wygryzienia, bez transferu do cieplarki
