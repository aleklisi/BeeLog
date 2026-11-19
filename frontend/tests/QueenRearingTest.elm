module QueenRearingTest exposing (suite)

import Expect
import QueenRearing.Domain as Domain
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)
import String
import Types.QueenRearing as Records


suite : Test
suite =
    describe "Queen rearing domain"
        [ test "provides the approved defaults" <|
            \_ ->
                Expect.equal { graftCount = 24, starterDurationDays = 2, isolationDay = 10, emergenceDay = 11 } Domain.defaultSettings
        , test "validates schedule bounds and ordering" <|
            \_ ->
                Expect.all
                    [ \_ -> Expect.equal True (Domain.validDefaults Domain.defaultSettings)
                    , \_ -> Expect.equal False (Domain.validDefaults { graftCount = 0, starterDurationDays = 2, isolationDay = 10, emergenceDay = 11 })
                    , \_ -> Expect.equal False (Domain.validDefaults { graftCount = 24, starterDurationDays = 11, isolationDay = 12, emergenceDay = 13 })
                    , \_ -> Expect.equal False (Domain.validDefaults { graftCount = 24, starterDurationDays = 2, isolationDay = 2, emergenceDay = 11 })
                    , \_ -> Expect.equal False (Domain.validDefaults { graftCount = 24, starterDurationDays = 2, isolationDay = 10, emergenceDay = 9 })
                    ]
                    ()
        , test "adds local calendar days across month and leap-year boundaries" <|
            \_ ->
                Expect.all
                    [ \_ -> Expect.equal "2026-03-30T10:00" (Domain.addCalendarDays 2 "2026-03-28T10:00")
                    , \_ -> Expect.equal "2024-03-01T08:30" (Domain.addCalendarDays 1 "2024-02-29T08:30")
                    ]
                    ()
        , test "calculates all saved schedule dates while keeping wall time" <|
            \_ ->
                case Domain.calculateSchedule Domain.defaultSettings "2026-05-10T10:00" of
                    Just schedule ->
                        Expect.equal ( "2026-05-12T10:00", "2026-05-20T10:00", "2026-05-21T10:00" )
                            ( schedule.starterTransferAt, schedule.isolationAt, schedule.emergenceAt )

                    Nothing ->
                        Expect.fail "valid defaults should calculate a schedule"
        , test "validates acceptance and emergence counts" <|
            \_ ->
                Expect.all
                    [ \_ -> Expect.equal True (Domain.validAcceptedCount 24 0)
                    , \_ -> Expect.equal True (Domain.validAcceptedCount 24 24)
                    , \_ -> Expect.equal False (Domain.validAcceptedCount 24 25)
                    , \_ -> Expect.equal False (Domain.validAcceptedCount 24 -1)
                    , \_ -> Expect.equal True (Domain.validEmergenceCount 8 0)
                    , \_ -> Expect.equal False (Domain.validEmergenceCount 8 9)
                    ]
                    ()
        , test "permits only lifecycle transitions and zero acceptance completion" <|
            \_ ->
                Expect.all
                    [ \_ -> Expect.equal True (Domain.eligibleTransition Domain.Planned 24 Domain.InStarter)
                    , \_ -> Expect.equal True (Domain.eligibleTransition Domain.InStarter 1 Domain.InFinisher)
                    , \_ -> Expect.equal False (Domain.eligibleTransition Domain.InStarter 0 Domain.InFinisher)
                    , \_ -> Expect.equal True (Domain.eligibleTransition Domain.InStarter 0 Domain.Completed)
                    , \_ -> Expect.equal False (Domain.eligibleTransition Domain.Completed 2 Domain.InStarter)
                    ]
                    ()
        , test "classifies deadline exactly now as overdue and 24 hours as due soon" <|
            \_ ->
                Expect.all
                    [ \_ -> Expect.equal Domain.Overdue (Domain.classifyUrgency 1000 (Just 1000))
                    , \_ -> Expect.equal Domain.DueWithin24Hours (Domain.classifyUrgency 0 (Just (24 * 60 * 60 * 1000)))
                    , \_ -> Expect.equal Domain.Later (Domain.classifyUrgency 0 (Just (24 * 60 * 60 * 1000 + 1)))
                    , \_ -> Expect.equal Domain.NoDeadline (Domain.classifyUrgency 0 Nothing)
                    ]
                    ()
        , test "sorts overdue and upcoming before planned and completed batches" <|
            \_ ->
                let
                    batches =
                        [ { number = "2026/04", status = Domain.Completed, nextActionAt = Nothing }
                        , { number = "2026/03", status = Domain.Planned, nextActionAt = Nothing }
                        , { number = "2026/02", status = Domain.InStarter, nextActionAt = Just 3000 }
                        , { number = "2026/01", status = Domain.InFinisher, nextActionAt = Just 900 }
                        ]
                in
                Expect.equal [ "2026/01", "2026/02", "2026/03", "2026/04" ]
                    (List.map .number (Domain.sortBatches 1000 batches))
        , test "decodes legacy colonies with available defaults and encodes owned records" <|
            \_ ->
                case Decode.decodeString Records.colonyDecoder "{\"id\":\"starter-1\",\"hiveNumber\":\"S-1\"}" of
                    Ok colony ->
                        Expect.equal "{\"id\":\"starter-1\",\"hiveNumber\":\"S-1\",\"availability\":\"PUSTY\",\"completedSeries\":0,\"activeBatchId\":null}"
                            (Encode.encode 0 (Records.colonyEncoder colony))

                    Err error ->
                        Expect.fail (Decode.errorToString error)
        , test "round trips batch status, saved schedule, and time zone" <|
            \_ ->
                let
                    batchJson = "{\"id\":\"batch-1\",\"number\":\"2026/01\",\"status\":\"W_STARTERZE\",\"breederQueenId\":\"queen-1\",\"starterColonyId\":\"starter-1\",\"graftCount\":24,\"acceptedCount\":20,\"graftedAt\":\"2026-05-10T10:00\",\"timeZone\":\"Europe/Warsaw\",\"starterDurationDays\":2,\"isolationDay\":10,\"emergenceDay\":11,\"starterTransferAt\":\"2026-05-12T10:00\",\"isolationAt\":\"2026-05-20T10:00\",\"emergenceAt\":\"2026-05-21T10:00\"}"
                in
                case Decode.decodeString Records.batchDecoder batchJson of
                    Ok batch ->
                        Expect.all
                            [ \_ -> Expect.equal Domain.InStarter batch.status
                            , \_ -> Expect.equal "Europe/Warsaw" batch.timeZone
                            , \_ -> Expect.equal (Just "2026-05-21T10:00") batch.emergenceAt
                            , \_ -> Expect.equal True (String.contains "\"starterColonyId\":\"starter-1\"" (Encode.encode 0 (Records.batchEncoder batch)))
                            , \_ -> Expect.equal True (String.contains "\"timeZone\":\"Europe/Warsaw\"" (Encode.encode 0 (Records.batchEncoder batch)))
                            ]
                            ()

                    Err error ->
                        Expect.fail (Decode.errorToString error)
        ]
