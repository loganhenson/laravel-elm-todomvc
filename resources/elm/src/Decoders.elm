module Decoders exposing (..)

import Json.Decode exposing (Decoder, int, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Types exposing (User)


decodeUser : Decoder User
decodeUser =
    succeed User
        |> required "id" int
        |> required "name" string
