# Design

## Context

`Views.ApiaryList` renderuje karty pasiek i ma dostęp do pełnych list `apiary.uliki`, natomiast `Views.Trutowisko` posiada obecnie reguły wyliczania alertów dla pojedynczego uliku. Lista pasiek musi użyć tych samych reguł i bieżącej daty z modelu, aby alert na poziomie pasieki nie rozjechał się z alertem na poziomie uliku.

## Goals / Non-Goals

**Goals:**

- Wyliczać na poziomie trutowiska uporządkowaną listę nazw ulików, dla których istnieje co najmniej jeden aktywny alert.
- Pokazać jeden czerwony, fokusable wykrzyknik przy karcie trutowiska z listą nazw w `title` i etykiecie dostępności.
- Zachować kolejność ulików z modelu oraz brak zmian w danych zapisywanych w Firestore.

**Non-Goals:**

- Nie tworzyć nowych reguł biznesowych ani osobnych alertów dla pasiek towarowych.
- Nie zastępować ani nie usuwać wykrzykników przy pojedynczych ulikach.
- Nie zmieniać nawigacji karty pasieki ani otwierać dodatkowego panelu po aktywacji alertu.

## Decisions

- **Współdzielona logika alertów:** wyodrębnić lub udostępnić czystą funkcję, która dla uliku i bieżącej daty zwraca listę powodów. `ApiaryList` odfiltruje uliki z niepustą listą powodów, a `Trutowisko` zachowa dotychczasowe zachowanie. Dzięki temu nowe i istniejące wskaźniki korzystają z identycznych warunków. Alternatywą byłoby powielenie warunków w `ApiaryList`, ale groziłoby to niespójnością po kolejnych zmianach.
- **Jedno źródło treści tooltipu:** nazwy alertowych ulików połączyć w jeden czytelny komunikat, np. `Uliki wymagające akcji: Ulik A, Ulik B`. Ten sam tekst umieścić w `title` i `aria-label`, zamiast pokazywać tylko liczbę, aby spełnić wymaganie wskazania konkretnych ulików.
- **Ochrona nawigacji:** wykrzyknik umieścić jako osobny element fokusable i zatrzymać propagację jego kliknięcia, jeśli kontener karty nadal reaguje na kliknięcia. Sam alert nie powinien prowadzić do widoku uliku ani zmieniać bieżącej trasy.
- **Zakres typu pasieki:** obliczenia i marker wykonywać tylko dla `apiaryType == "trutowisko"`; istniejąca prezentacja pasiek towarowych pozostaje bez zmian.
- **Weryfikacja:** dodać testy Elm dla filtrowania i kolejności nazw oraz test e2e obejmujący jeden alert, wiele alertów, brak alertu i dostępność klawiaturową. Uruchamiać je przez odpowiednie cele `make` zgodnie z instrukcjami repozytorium.

## Risks / Trade-offs

- [Zmiana wspólnej funkcji może naruszyć istniejące testy lub zachowanie alertu uliku] → zachować obecny kontrakt `attentionReason` jako wrapper, jeśli będzie potrzebny, i uruchomić testy Elm oraz e2e.
- [Długi komunikat może wykraczać poza kartę] → użyć natywnego tooltipu oraz krótkiego, jednoznacznego formatu tekstu; nie dodawać stałego panelu do karty.
- [Nazwa uliku może być pusta lub powtarzalna] → użyć wartości `name` z danych, zachować kolejność modelu i nie wprowadzać nowego mechanizmu identyfikacji w ramach tej zmiany.

## Migration Plan

Brak migracji danych. Zmiana jest wyłącznie po stronie widoku i logiki pochodnej; wdrożenie włącza marker od razu, a wycofanie frontendu usuwa go bez wpływu na zapisane pasieki i uliki.
