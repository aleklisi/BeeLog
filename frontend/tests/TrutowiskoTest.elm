module TrutowiskoTest exposing (suite)

import Expect
import Test exposing (..)
import Views.Trutowisko exposing (attentionReason, attentionReasons)


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
        , test "dates due today or in the future do not require attention" <|
            \_ ->
                Expect.equal [ Nothing, Nothing, Nothing, Nothing ]
                    [ attentionReason "z_matecznikiem" "2026-11-19" "" "2026-11-19"
                    , attentionReason "z_matecznikiem" "2026-11-20" "" "2026-11-19"
                    , attentionReason "matka_wygryziona" "" "2026-11-19" "2026-11-19"
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
        ]
