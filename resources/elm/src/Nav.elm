module Nav exposing (NavMsg, update, view)

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Encode
import Routes
import Types exposing (User)


type NavMsg
    = Home
    | Login
    | Register
    | Logout


update : model -> NavMsg -> ( model, Cmd msg )
update model msg =
    case msg of
        Home ->
            ( model
            , Routes.get Routes.home
            )

        Login ->
            ( model
            , Routes.get Routes.login
            )

        Register ->
            ( model
            , Routes.get Routes.register
            )

        Logout ->
            ( model
            , Routes.post <|
                Json.Encode.object
                    [ ( "url", Json.Encode.string Routes.logout )
                    ]
            )


view : String -> Maybe User -> Html NavMsg
view route maybeUser =
    div [ class "hidden fixed top-0 right-0 px-6 py-4 sm:block" ]
        (case maybeUser of
            Just _ ->
                if route == Routes.welcome then
                    [ a [ class "text-sm text-gray-700 underline cursor-pointer", onClick Home ]
                        [ text "Home" ]
                    ]

                else
                    [ a [ class "text-sm text-gray-700 underline cursor-pointer", onClick Logout ]
                        [ text "Logout" ]
                    ]

            Nothing ->
                [ a [ class "text-sm text-gray-700 underline cursor-pointer", onClick Login ]
                    [ text "Log in" ]
                , a [ class "ml-4 text-sm text-gray-700 underline cursor-pointer", onClick Register ]
                    [ text "Register" ]
                ]
        )
