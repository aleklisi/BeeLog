module TrutowiskoTest exposing (suite)

import Expect
import I18n exposing (translationsFor)
import Test exposing (..)
import Types.Core exposing (Language(..), UlikWeselny)
import Views.Trutowisko exposing (attentionReason, attentionReasons, attentionSummaryText, attentionUlikNames, ulikAttentionReasons)


makeUlik : String -> String -> String -> String -> UlikWeselny
makeUlik name state expectedHatchDate expectedMatingDate =
    { id = name
    , apiaryId = "apiary-1"
    , name = name
    , hiveType = "Mini plus"
    , hasQueen = state /= "bezmatek" && state /= "pusty"
    , queen = { hasOpalit = False, color = "", number = "", breedLine = "" }
    , state = state
    , expectedHatchDate = expectedHatchDate
    , expectedMatingDate = expectedMatingDate
    , nfcLink = ""
    , order = 0
    , history = []
    }


suite : Test
suite =
    describe "mating hive attention reasons"
        [ test "Bezmatek always requires attention" <|
            \_ ->
                Expect.equal (Just "Brak matki w ulu") (attentionReason "bezmatek" "" "" "2026-11-19")
        , test "overdue expected emergence requires attention" <|
            \_ ->
                Expect.equal (Just "Sprawdź, czy matka się wygryzła") (attentionReason "z_matecznikiem" "2026-11-18" "" "2026-11-19")
        , test "overdue expected mating requires attention" <|
            \_ ->
                Expect.equal (Just "Minął oczekiwany termin unasiennienia matki") (attentionReason "matka_wygryziona" "" "2026-11-18" "2026-11-19")
        , test "dates due today require attention" <|
            \_ ->
                Expect.equal
                    [ Just "Sprawdź, czy matka się wygryzła"
                    , Just "Minął oczekiwany termin unasiennienia matki"
                    ]
                    [ attentionReason "z_matecznikiem" "2026-11-19" "" "2026-11-19"
                    , attentionReason "matka_wygryziona" "" "2026-11-19" "2026-11-19"
                    ]
        , test "dates due strictly in the future do not require attention" <|
            \_ ->
                Expect.equal [ Nothing, Nothing ]
                    [ attentionReason "z_matecznikiem" "2026-11-20" "" "2026-11-19"
                    , attentionReason "matka_wygryziona" "" "2026-11-20" "2026-11-19"
                    ]
        , test "missing or invalid dates suppress date-based attention" <|
            \_ ->
                Expect.equal [ Nothing, Nothing, Nothing, Nothing ]
                    [ attentionReason "z_matecznikiem" "" "" "2026-11-19"
                    , attentionReason "z_matecznikiem" "not-a-date" "" "2026-11-19"
                    , attentionReason "z_matecznikiem" "2026-02-31" "" "2026-11-19"
                    , attentionReason "matka_wygryziona" "" "2026-11-18" "invalid"
                    ]
        , test "other states do not require attention" <|
            \_ ->
                Expect.equal Nothing (attentionReason "matka_czerwi" "2026-11-01" "2026-11-02" "2026-11-19")
        , test "state M past 30-day deadline from hatch triggers overdue insemination alert" <|
            \_ ->
                Expect.equal True
                    (List.member "Minął deadline 30 dni od wygryzienia – matka nadal nieunasienniona"
                        (attentionReasons "z_matecznikiem" "2026-10-01" "" "2026-11-19")
                    )
        , test "state N past 30-day deadline from hatch triggers overdue insemination alert" <|
            \_ ->
                Expect.equal True
                    (List.member "Minął deadline 30 dni od wygryzienia – matka nadal nieunasienniona"
                        (attentionReasons "matka_wygryziona" "2026-10-01" "2026-10-15" "2026-11-19")
                    )
        , test "state M within 30-day deadline does not trigger overdue insemination alert" <|
            \_ ->
                Expect.equal False
                    (List.member "Minął deadline 30 dni od wygryzienia – matka nadal nieunasienniona"
                        (attentionReasons "z_matecznikiem" "2026-11-18" "" "2026-11-19")
                    )
        , test "state UNC does not trigger overdue insemination alert even past 30 days" <|
            \_ ->
                Expect.equal False
                    (List.member "Minął deadline 30 dni od wygryzienia – matka nadal nieunasienniona"
                        (attentionReasons "matka_czerwi" "2026-10-01" "2026-10-15" "2026-11-19")
                    )
        , test "multiple conditions return all reasons" <|
            \_ ->
                let
                    reasons = attentionReasons "matka_wygryziona" "2026-10-01" "2026-10-15" "2026-11-19"
                in
                Expect.all
                    [ \r -> Expect.equal True (List.member "Minął oczekiwany termin unasiennienia matki" r)
                    , \r -> Expect.equal True (List.member "Minął deadline 30 dni od wygryzienia – matka nadal nieunasienniona" r)
                    , \r -> Expect.equal True (List.length r >= 2)
                    ]
                    reasons
        , describe "ulikAttentionReasons and attentionUlikNames"
            [ test "ulikAttentionReasons matches attentionReasons on a UlikWeselny" <|
                \_ ->
                    let
                        ulik = makeUlik "Ulik #01" "bezmatek" "" ""
                    in
                    Expect.equal (attentionReasons "bezmatek" "" "" "2026-11-19")
                        (ulikAttentionReasons "2026-11-19" ulik)
            , test "attentionUlikNames returns empty list when uliki list is empty" <|
                \_ ->
                    Expect.equal [] (attentionUlikNames "2026-11-19" [])
            , test "attentionUlikNames returns empty list when no ulik requires attention" <|
                \_ ->
                    let
                        uliki =
                            [ makeUlik "Ulik 1" "pusty" "" ""
                            , makeUlik "Ulik 2" "matka_czerwi" "2026-10-01" "2026-10-15"
                            , makeUlik "Ulik 3" "z_matecznikiem" "2026-11-21" ""
                            , makeUlik "Ulik 4" "matka_wygryziona" "" "2026-11-20"
                            ]
                    in
                    Expect.equal [] (attentionUlikNames "2026-11-19" uliki)
            , test "attentionUlikNames includes hives with dates due today" <|
                \_ ->
                    let
                        uliki =
                            [ makeUlik "Ulik Wygryzienie Dzisiaj" "z_matecznikiem" "2026-11-19" ""
                            , makeUlik "Ulik Spokojny" "pusty" "" ""
                            , makeUlik "Ulik Unasiennienie Dzisiaj" "matka_wygryziona" "" "2026-11-19"
                            ]
                    in
                    Expect.equal [ "Ulik Wygryzienie Dzisiaj", "Ulik Unasiennienie Dzisiaj" ] (attentionUlikNames "2026-11-19" uliki)
            , test "attentionUlikNames returns single affected hive name" <|
                \_ ->
                    let
                        uliki =
                            [ makeUlik "Ulik Spokojny" "matka_czerwi" "" ""
                            , makeUlik "Ulik Pilny" "bezmatek" "" ""
                            , makeUlik "Ulik Pusty" "pusty" "" ""
                            ]
                    in
                    Expect.equal [ "Ulik Pilny" ] (attentionUlikNames "2026-11-19" uliki)
            , test "attentionUlikNames preserves order and filters multiple affected hives across different states and dates" <|
                \_ ->
                    let
                        uliki =
                            [ makeUlik "Ulik 1 Bezmatek" "bezmatek" "" ""
                            , makeUlik "Ulik 2 W normie" "matka_czerwi" "2026-10-01" "2026-10-15"
                            , makeUlik "Ulik 3 Wygryzienie" "z_matecznikiem" "2026-11-18" ""
                            , makeUlik "Ulik 4 Przyszłość" "z_matecznikiem" "2026-11-25" ""
                            , makeUlik "Ulik 5 Unasiennienie" "matka_wygryziona" "" "2026-11-18"
                            , makeUlik "Ulik 6 Deadline30" "matka_wygryziona" "2026-10-01" "2026-11-25"
                            , makeUlik "Ulik 7 Czerwi" "matka_czerwi" "" ""
                            ]
                    in
                    Expect.equal
                        [ "Ulik 1 Bezmatek", "Ulik 3 Wygryzienie", "Ulik 5 Unasiennienie", "Ulik 6 Deadline30" ]
                        (attentionUlikNames "2026-11-19" uliki)
            , test "attentionSummaryText formats single and multiple names in Polish" <|
                \_ ->
                    let
                        t = translationsFor PL
                    in
                    Expect.all
                        [ \_ -> Expect.equal "Uliki wymagające akcji: Ulik A" (attentionSummaryText t [ "Ulik A" ])
                        , \_ -> Expect.equal "Uliki wymagające akcji: Ulik A, Ulik B" (attentionSummaryText t [ "Ulik A", "Ulik B" ])
                        ]
                        ()
            , test "attentionSummaryText formats names in English" <|
                \_ ->
                    let
                        t = translationsFor EN
                    in
                    Expect.equal "Hives requiring action: Hive 1, Hive 2" (attentionSummaryText t [ "Hive 1", "Hive 2" ])
            ]
        ]
