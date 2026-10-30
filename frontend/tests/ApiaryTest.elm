module ApiaryTest exposing (suite)

import Test exposing (..)
import Expect
import Json.Decode as Decode
import Main exposing (..) -- We need to expose types or just use the decoders if they were exposed

-- Note: Since Main is a port module and we're importing it, 
-- we should ensure the types and decoders are testable.
-- For now, I'll copy the decoders or assume they are exposed if I modify Main.elm to expose them.

suite : Test
suite =
    describe "BeeLog Frontend Decoders"
        [ describe "Queen Decoder"
            [ test "decodes a valid queen" <|
                \() ->
                    let
                        json = "{\"hasOpalit\": true, \"color\": \"żółty\", \"number\": \"42\"}"
                    in
                    case Decode.decodeString decodeQueen json of
                        Ok queen ->
                            Expect.all
                                [ \q -> Expect.equal True q.hasOpalit
                                , \q -> Expect.equal "żółty" q.color
                                , \q -> Expect.equal "42" q.number
                                ]
                                queen
                        Err _ ->
                            Expect.fail "Failed to decode queen"
            ]
        , describe "Hive Decoder"
            [ test "decodes a list of hives" <|
                \() ->
                    let
                        json = "[{\"id\": \"h1\", \"name\": \"Ul 1\", \"frameType\": \"Dadant\", \"nfcTagId\": \"123\", \"queen\": {\"hasOpalit\": false, \"color\": \"biały\", \"number\": \"\"}}]"
                    in
                    case Decode.decodeString decodeHives json of
                        Ok hives ->
                            case List.head hives of
                                Just hive ->
                                    Expect.equal "Ul 1" hive.name
                                Nothing ->
                                    Expect.fail "Empty list"
                        Err err ->
                            Expect.fail ("Failed to decode hives: " ++ Decode.errorToString err)
            ]
        , describe "Apiary Decoder"
            [ test "decodes apiaries with members" <|
                \() ->
                    let
                        json = "[{\"id\": \"a1\", \"name\": \"Pasieka\", \"adminId\": \"u1\", \"members\": {\"user@test.com\": \"edit\"}}]"
                    in
                    case Decode.decodeString decodeApiaries json of
                        Ok apiaries ->
                            case List.head apiaries of
                                Just apiary ->
                                    Expect.equal "Pasieka" apiary.name
                                Nothing ->
                                    Expect.fail "Empty list"
                        Err err ->
                            Expect.fail ("Failed to decode apiaries: " ++ Decode.errorToString err)
            ]
        ]

-- Helper decoders copied from Main.elm (since it's a port module, direct import might be tricky for internals)
-- In a real scenario, we'd move decoders to a separate module.

decodeQueen =
    Decode.map3 (\h c n -> { hasOpalit = h, color = c, number = n })
        (Decode.field "hasOpalit" Decode.bool)
        (Decode.field "color" Decode.string)
        (Decode.field "number" Decode.string)

decodeHives =
    Decode.list
        (Decode.map5 (\i n f nf q -> { id = i, name = n, frameType = f, nfcTagId = nf, queen = q })
            (Decode.field "id" Decode.string)
            (Decode.field "name" Decode.string)
            (Decode.field "frameType" Decode.string)
            (Decode.field "nfcTagId" Decode.string)
            (Decode.field "queen" decodeQueen)
        )

decodeApiaries =
    Decode.list
        (Decode.map4 (\i n a m -> { id = i, name = n, adminId = a, members = m })
            (Decode.field "id" Decode.string)
            (Decode.field "name" Decode.string)
            (Decode.field "adminId" Decode.string)
            (Decode.field "members" (Decode.keyValuePairs Decode.string))
        )
