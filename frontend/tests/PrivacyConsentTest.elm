module PrivacyConsentTest exposing (suite)

import Expect
import I18n exposing (translationsFor)
import Test exposing (..)
import Types.Core exposing (Language(..))


suite : Test
suite =
    describe "privacy and consent translations"
        [ test "privacy controls have Polish labels" <|
            \_ ->
                let
                    t = translationsFor PL
                in
                Expect.equal
                    [ "Prywatność i zgody", "Polityka prywatności", "Zawsze aktywne" ]
                    [ t.localize "Prywatność i zgody", t.localize "Polityka prywatności", t.localize "Zawsze aktywne" ]
        , test "privacy controls have English labels" <|
            \_ ->
                let
                    t = translationsFor EN
                in
                Expect.equal
                    [ "Privacy & Consent", "Privacy policy", "Always active" ]
                    [ t.localize "Prywatność i zgody", t.localize "Polityka prywatności", t.localize "Zawsze aktywne" ]
        ]
