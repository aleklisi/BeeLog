module UlikDetailTest exposing (suite)

import Expect
import Test exposing (..)
import Types.Core exposing (UlikState(..))
import Views.UlikDetail exposing (statusColors)


suite : Test
suite =
    describe "mating hive status colors"
        [ test "maps B to the timeline red" <|
            \_ ->
                Expect.equal ( "#e74c3c", "#ffffff" ) (statusColors Bezmatek)
        , test "maps M to the timeline light yellow with dark text" <|
            \_ ->
                Expect.equal ( "#f7dc6f", "#422006" ) (statusColors ZMatecznikiem)
        , test "maps N to the timeline dark yellow with dark text" <|
            \_ ->
                Expect.equal ( "#d4ac0d", "#422006" ) (statusColors MatkaWygryziona)
        , test "maps UNC to the timeline green" <|
            \_ ->
                Expect.equal ( "#27ae60", "#ffffff" ) (statusColors MatkaCzerwi)
        ]
