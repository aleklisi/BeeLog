# Zmiana specyfikacji hodowli matek

## MODIFIED Requirements

### Requirement: Inspect starter and finisher calendars
Użytkownik SHALL móc otworzyć szczegóły startera lub finishera z listy zasobów i zobaczyć przedziały zajętości wraz z numerami serii, które używają zasobu. Użytkownik SHALL móc edytować nazwę startera lub finishera.

#### Scenario: Open resource details
- **WHEN** użytkownik kliknie starter lub finisher na liście zasobów
- **THEN** aplikacja pokaże jego nazwę, numer ula oraz kalendarz terminów przypisanych serii

#### Scenario: Rename a colony
- **WHEN** użytkownik zapisze nową nazwę startera lub finishera
- **THEN** nazwa zostanie zachowana po ponownym wczytaniu zasobu

### Requirement: Reserve and release colonies exclusively
Starter lub finisher przypisany do serii SHALL być niedostępny dla innych serii w dniach swojego okresu użycia. Dostępność zasobu SHALL być wyliczana z kalendarza serii używających tego zasobu. Aplikacja SHALL odrzucać przypisanie, którego okres nakłada się na okres innej serii dla tego samego zasobu, z wyjątkiem gdy nowy proponowany okres zaczyna się dokładnie w dniu zakończenia poprzedniej serii. Reguła SHALL dotyczyć zarówno starterów, jak i finisherów. Walidacja, przypisanie zasobu oraz zapis serii SHALL być spójne także przy równoczesnych operacjach. Zasób SHALL być zwalniany po zakończeniu jego etapu, a licznik serii SHALL wzrastać wyłącznie po normalnym zakończeniu etapu.

#### Scenario: Reject overlapping use of a starter
- **GIVEN** starter `S-1` jest używany przez serię w określonym przedziale
- **WHEN** użytkownik proponuje inną serię dla `S-1` z nakładającym się okresem
- **THEN** aplikacja odrzuca przypisanie i nie zapisuje konfliktującej serii

#### Scenario: Reject a colony already reserved by another batch
- **GIVEN** another active batch has reserved starter `S-1`
- **WHEN** a user attempts to start a batch using `S-1`
- **THEN** the action is rejected and no batch or colony state is partially updated

#### Scenario: Allow reuse starting on the previous end date
- **GIVEN** seria używająca startera `S-1` kończy korzystanie z niego w określonym dniu
- **WHEN** nowy proponowany okres użycia `S-1` zaczyna się dokładnie w tym dniu
- **THEN** przypisanie jest dozwolone

#### Scenario: Apply calendar conflict rule to finishers
- **GIVEN** finisher `F-1` jest używany przez serię w określonym przedziale
- **WHEN** użytkownik proponuje inną serię dla `F-1` z nakładającym się okresem, który nie zaczyna się w dniu zakończenia poprzedniej serii
- **THEN** aplikacja odrzuca przypisanie i nie zapisuje konfliktującej serii

#### Scenario: Update availability after changing a batch
- **GIVEN** seria rezerwuje starter lub finisher w swoim kalendarzu
- **WHEN** użytkownik zmienia daty serii, przypisany zasób albo usuwa serię
- **THEN** kalendarz odzwierciedla nowe terminy i dostępność zasobu

#### Scenario: Move an accepted batch to a finisher
- **GIVEN** a batch is in `W_STARTERZE` and has at least one accepted cell
- **WHEN** the user selects a free finisher
- **THEN** the batch enters `W_FINISHERZE`, the starter is released and its series counter increases by one, and the finisher is reserved

#### Scenario: Release resources when deleting an active batch
- **GIVEN** a batch in `W_STARTERZE` or `W_FINISHERZE` is deleted
- **WHEN** the deletion completes
- **THEN** its assigned colony is released and its completed-series counter remains unchanged

#### Scenario: Reject concurrent conflicting reservations
- **GIVEN** dwie operacje próbują przypisać ten sam starter lub finisher do nakładających się okresów
- **WHEN** operacje zapisują serie równocześnie
- **THEN** najwyżej jedna operacja zostaje zapisana, a druga otrzymuje informację o braku dostępności
