# Design

## Context

Lista serii już wyznacza następne działanie na podstawie statusu i zapisanych dat oraz klasyfikuje pilność terminu. Zmiana dodaje czytelny znacznik dla terminów przypadających dzisiaj, które nie są jeszcze przeterminowane według dokładnej godziny.

## Goals / Non-Goals

**Goals:**
- Wyróżnić działania przypadające dziś i zaległe bez zmiany istniejącego porządku listy.
- Zachować zgodność ikony, podpowiedzi i opisu dla technologii asystujących.

**Non-Goals:**
- Zmiana obecnych kolorów pilności, sortowania lub obliczania harmonogramów.
- Alerty dla serii zaplanowanych bez rozpoczętego harmonogramu i serii ukończonych.

## Decisions

- Rozpoznawać alert na podstawie daty następnego działania już wyznaczonej dla bieżącego statusu serii. Dzięki temu ikona nie tworzy równoległych reguł dotyczących transferu, izolacji i wygryzienia.
- Porównywać kalendarzowy dzień terminu z bieżącym dniem: dzień równy dzisiaj lub wcześniejszy wyświetla alert, nawet gdy zaplanowana godzina jeszcze nie nadeszła. Używać daty lokalnej serii zgodnie z jej zapisanym harmonogramem i strefą czasową.
- Umieścić wykrzyknik w nagłówku karty przy numerze serii. Tekst alternatywny i podpowiedź zawierają nazwę działania oraz jego zaplanowaną datę.

## Risks / Trade-offs

- [Karta może zawierać już kolor wskazujący pilność] → Wykrzyknik pełni funkcję szybkiego znacznika przy numerze, a istniejący kolor i opis terminu pozostają bez zmian.
- [Brak poprawnej daty może prowadzić do fałszywego alertu] → Alert jest pomijany, jeśli nie da się wyznaczyć następnego działania lub jego daty.

## Migration Plan

Zmiana nie wymaga migracji danych; starsze serie wykorzystują zapisane daty i harmonogram tak samo jak obecny widok.
