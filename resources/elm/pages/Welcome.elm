module Welcome exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, Value, decodeValue, string, succeed)
import Json.Decode.Pipeline exposing (required)
import LaravelElm exposing (Page, page)


type alias Props =
    { name : String }


type alias State =
    {}


type alias Model =
    { props : Props
    , state : State
    }


type Msg
    = NewProps Value
    | NoOp


decodeProps : Decoder Props
decodeProps =
    succeed Props
        |> required "name" string


stateFromProps : Props -> State
stateFromProps props =
    {}


main : Page Model Msg
main =
    page
        { decodeProps = decodeProps
        , stateFromProps = stateFromProps
        , update = update
        , view = view
        , newPropsMsg = NewProps
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg { props, state } =
    case msg of
        NewProps newProps ->
            ( { props = Result.withDefault props (decodeValue decodeProps newProps)
              , state = state
              }
            , Cmd.none
            )

        NoOp ->
            ( { props = props
              , state = state
              }
            , Cmd.none
            )


view : Model -> Html Msg
view { props, state } =
    div [ class "container mx-auto m-4 p-4" ]
        [ text <| "Hello, " ++ props.name ++ "!" ]
