module Types.QueenRearing exposing
    ( BreederQueen
    , Colony
    , QueenRearingData
    , RepeatingBatch
    , batchDecoder
    , batchEncoder
    , breederQueenDecoder
    , breederQueenEncoder
    , colonyDecoder
    , colonyEncoder
    , dataDecoder
    )

import Json.Decode as Decode
import Json.Encode as Encode
import QueenRearing.Domain as Domain


type alias BreederQueen =
    { id : String
    , breed : String
    , line : String
    , markingColor : String
    , markingCode : String
    , hiveNumber : Int
    , active : Bool
    }


type alias Colony =
    { id : String
    , name : String
    , hiveNumber : Int
    , availability : Domain.ColonyAvailability
    , completedSeries : Int
    , activeBatchId : Maybe String
    }


type alias RepeatingBatch =
    { id : String
    , number : String
    , status : Domain.BatchStatus
    , breederQueenId : String
    , starterColonyId : Maybe String
    , finisherColonyId : Maybe String
    , graftCount : Int
    , acceptedCount : Maybe Int
    , emergedCount : Maybe Int
    , incubatorBar : Maybe String
    , graftedAt : String
    , timeZone : String
    , starterDurationDays : Int
    , isolationDay : Int
    , emergenceDay : Int
    , starterTransferAt : Maybe String
    , isolationAt : Maybe String
    , emergenceAt : Maybe String
    , deadlineEpoch : Maybe Int
    }


type alias QueenRearingData =
    { breederQueens : List BreederQueen
    , starterColonies : List Colony
    , finisherColonies : List Colony
    , rearingBatches : List RepeatingBatch
    }


andMap : Decode.Decoder a -> Decode.Decoder (a -> b) -> Decode.Decoder b
andMap value function =
    Decode.map2 (\f a -> f a) function value


breederQueenDecoder : Decode.Decoder BreederQueen
breederQueenDecoder =
    Decode.succeed BreederQueen
        |> andMap (fieldDefault "id" Decode.string "")
        |> andMap (fieldDefault "breed" Decode.string "")
        |> andMap (fieldDefault "line" Decode.string "")
        |> andMap (fieldDefault "markingColor" Decode.string "")
        |> andMap (fieldDefault "markingCode" Decode.string "")
        |> andMap (fieldDefault "hiveNumber" hiveNumberDecoder 0)
        |> andMap (fieldDefault "active" Decode.bool True)


breederQueenEncoder : BreederQueen -> Encode.Value
breederQueenEncoder queen =
    Encode.object
        [ ( "id", Encode.string queen.id )
        , ( "breed", Encode.string queen.breed )
        , ( "line", Encode.string queen.line )
        , ( "markingColor", Encode.string queen.markingColor )
        , ( "markingCode", Encode.string queen.markingCode )
        , ( "hiveNumber", Encode.int queen.hiveNumber )
        , ( "active", Encode.bool queen.active )
        ]


colonyDecoder : Decode.Decoder Colony
colonyDecoder =
    Decode.succeed Colony
        |> andMap (fieldDefault "id" Decode.string "")
        |> andMap (fieldDefault "name" Decode.string "")
        |> andMap (fieldDefault "hiveNumber" hiveNumberDecoder 0)
        |> andMap
            (fieldDefault "availability" Decode.string "PUSTY"
                |> Decode.map
                    (\value ->
                        if value == "ZAJETY" then
                            Domain.Reserved

                        else
                            Domain.Available
                    )
            )
        |> andMap (fieldDefault "completedSeries" Decode.int 0)
        |> andMap (optionalField "activeBatchId" Decode.string)


colonyEncoder : Colony -> Encode.Value
colonyEncoder colony =
    Encode.object
        [ ( "id", Encode.string colony.id )
        , ( "name", Encode.string colony.name )
        , ( "hiveNumber", Encode.int colony.hiveNumber )
        , ( "availability"
          , Encode.string
                (if colony.availability == Domain.Reserved then
                    "ZAJETY"

                 else
                    "PUSTY"
                )
          )
        , ( "completedSeries", Encode.int colony.completedSeries )
        , ( "activeBatchId", maybeString colony.activeBatchId )
        ]


dataDecoder : Decode.Decoder QueenRearingData
dataDecoder =
    Decode.map4 QueenRearingData
        (fieldDefault "breederQueens" (Decode.list breederQueenDecoder) [])
        (fieldDefault "starterColonies" (Decode.list colonyDecoder) [])
        (fieldDefault "finisherColonies" (Decode.list colonyDecoder) [])
        (fieldDefault "rearingBatches" (Decode.list batchDecoder) [])


hiveNumberDecoder : Decode.Decoder Int
hiveNumberDecoder =
    Decode.oneOf
        [ Decode.int
        , Decode.string |> Decode.map (String.toInt >> Maybe.withDefault 0)
        ]


batchDecoder : Decode.Decoder RepeatingBatch
batchDecoder =
    Decode.succeed RepeatingBatch
        |> andMap (fieldDefault "id" Decode.string "")
        |> andMap (fieldDefault "number" Decode.string "")
        |> andMap (fieldDefault "status" Decode.string "ZAPLANOWANA" |> Decode.map decodeStatus)
        |> andMap (fieldDefault "breederQueenId" Decode.string "")
        |> andMap (optionalField "starterColonyId" Decode.string)
        |> andMap (optionalField "finisherColonyId" Decode.string)
        |> andMap (fieldDefault "graftCount" Decode.int 24)
        |> andMap (optionalField "acceptedCount" Decode.int)
        |> andMap (optionalField "emergedCount" Decode.int)
        |> andMap (optionalField "incubatorBar" Decode.string)
        |> andMap (fieldDefault "graftedAt" Decode.string "")
        |> andMap (fieldDefault "timeZone" Decode.string "UTC")
        |> andMap (fieldDefault "starterDurationDays" Decode.int 1)
        |> andMap (fieldDefault "isolationDay" Decode.int 10)
        |> andMap (fieldDefault "emergenceDay" Decode.int 12)
        |> andMap (optionalField "starterTransferAt" Decode.string)
        |> andMap (optionalField "isolationAt" Decode.string)
        |> andMap (optionalField "emergenceAt" Decode.string)
        |> andMap (optionalField "deadlineEpoch" Decode.int)


batchEncoder : RepeatingBatch -> Encode.Value
batchEncoder batch =
    Encode.object
        [ ( "id", Encode.string batch.id )
        , ( "number", Encode.string batch.number )
        , ( "status", Encode.string (encodeStatus batch.status) )
        , ( "breederQueenId", Encode.string batch.breederQueenId )
        , ( "starterColonyId", maybeString batch.starterColonyId )
        , ( "finisherColonyId", maybeString batch.finisherColonyId )
        , ( "graftCount", Encode.int batch.graftCount )
        , ( "acceptedCount", maybeInt batch.acceptedCount )
        , ( "emergedCount", maybeInt batch.emergedCount )
        , ( "incubatorBar", maybeString batch.incubatorBar )
        , ( "graftedAt", Encode.string batch.graftedAt )
        , ( "timeZone", Encode.string batch.timeZone )
        , ( "starterDurationDays", Encode.int batch.starterDurationDays )
        , ( "isolationDay", Encode.int batch.isolationDay )
        , ( "emergenceDay", Encode.int batch.emergenceDay )
        , ( "starterTransferAt", maybeString batch.starterTransferAt )
        , ( "isolationAt", maybeString batch.isolationAt )
        , ( "emergenceAt", maybeString batch.emergenceAt )
        , ( "deadlineEpoch", maybeInt batch.deadlineEpoch )
        ]


fieldDefault : String -> Decode.Decoder a -> a -> Decode.Decoder a
fieldDefault name decoder fallback =
    Decode.oneOf [ Decode.field name decoder, Decode.succeed fallback ]


optionalField : String -> Decode.Decoder a -> Decode.Decoder (Maybe a)
optionalField name decoder =
    Decode.oneOf [ Decode.field name (Decode.nullable decoder), Decode.succeed Nothing ]


maybeString : Maybe String -> Encode.Value
maybeString value =
    Maybe.withDefault Encode.null (Maybe.map Encode.string value)


maybeInt : Maybe Int -> Encode.Value
maybeInt value =
    Maybe.withDefault Encode.null (Maybe.map Encode.int value)


decodeStatus : String -> Domain.BatchStatus
decodeStatus value =
    case value of
        "W_STARTERZE" ->
            Domain.InStarter

        "W_FINISHERZE" ->
            Domain.InFinisher

        "W_CIEPLARCE" ->
            Domain.InIncubator

        "ZAKONCZONA" ->
            Domain.Completed

        _ ->
            Domain.Planned


encodeStatus : Domain.BatchStatus -> String
encodeStatus status =
    case status of
        Domain.Planned ->
            "ZAPLANOWANA"

        Domain.InStarter ->
            "W_STARTERZE"

        Domain.InFinisher ->
            "W_FINISHERZE"

        Domain.InIncubator ->
            "W_CIEPLARCE"

        Domain.Completed ->
            "ZAKONCZONA"
