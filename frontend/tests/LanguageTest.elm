module LanguageTest exposing (suite)

import Expect
import I18n exposing (..)
import Json.Decode as Decode
import Test exposing (..)
import Types.Core exposing (..)
import Types.Decoders exposing (decodeUserSettings)

suite : Test
suite =
    describe "language selection"
        [ test "both translation tables are complete" <|
            \_ ->
                Expect.all
                    [ \_ -> Expect.equal True (List.all (\value -> String.trim value /= "") (allTranslationValues (translationsFor PL)))
                    , \_ -> Expect.equal True (List.all (\value -> String.trim value /= "") (allTranslationValues (translationsFor EN)))
                    ] ()
        , test "language decoder maps supported values and falls back to Polish" <|
            \_ ->
                let
                    decode json = Decode.decodeString decodeUserSettings ("{\"frameTypes\":[],\"language\":" ++ json ++ "}")
                    language result = Result.map .language result
                in
                Expect.equal
                    [ Ok PL, Ok EN, Ok PL, Ok PL ]
                    [ language (decode "\"pl\""), language (decode "\"en\""), language (decode "\"de\""), language (Decode.decodeString decodeUserSettings "{\"frameTypes\":[]}") ]
        ]
