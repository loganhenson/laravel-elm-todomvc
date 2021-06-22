module Home exposing (..)

import Html exposing (Attribute, Html, a, button, div, footer, h1, header, input, label, li, p, section, span, strong, text, ul)
import Html.Attributes exposing (autofocus, checked, class, classList, for, hidden, href, id, name, placeholder, style, type_, value)
import Html.Events exposing (keyCode, on, onBlur, onClick, onDoubleClick, onInput)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy, lazy2, lazy3)
import Json.Decode as Json exposing (Decoder, Value, bool, decodeValue, int, list, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Json.Encode
import LaravelElm exposing (Page, page)
import Routes


type alias Props =
    { todos : List Todo }


type alias State =
    { field : String
    , visibility : String
    , editingTodoId : Maybe Int
    }


type alias Model =
    { props : Props
    , state : State
    }


type Msg
    = NewProps Value
    | UpdateField String
    | EditingEntry Int Bool
    | UpdateEntry Int String
    | Add
    | Delete Int
    | DeleteComplete
    | Check Int Bool
    | CheckAll Bool
    | ChangeVisibility String
    | NoOp


type alias Todo =
    { description : String
    , completed : Bool
    , id : Int
    }


decodeTodo : Decoder Todo
decodeTodo =
    succeed Todo
        |> required "description" string
        |> required "completed" bool
        |> required "id" int


decodeProps : Decoder Props
decodeProps =
    succeed Props
        |> required "todos" (list decodeTodo)


stateFromProps : Props -> State
stateFromProps props =
    { field = "", visibility = "All", editingTodoId = Nothing }


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

        Delete id ->
            ( { props = props
              , state = state
              }
            , Routes.delete <| Routes.todosDestroy (String.fromInt id)
            )

        Check id completed ->
            ( { props = props
              , state = state
              }
            , Routes.patch <|
                Json.Encode.object
                    [ ( "url", Json.Encode.string <| Routes.todosUpdate (String.fromInt id) )
                    , ( "data"
                      , Json.Encode.object
                            [ ( "completed", Json.Encode.string <| if completed then "1" else "0" )
                            ]
                      )
                    ]
            )

        UpdateField task ->
            ( { props = props
              , state = { state | field = task }
              }
            , Cmd.none
            )

        Add ->
            ( { props = props
              , state = { state | field = "" }
              }
            , Routes.post <|
                Json.Encode.object
                    [ ( "url", Json.Encode.string <| Routes.todosStore )
                    , ( "data"
                      , Json.Encode.object
                            [ ( "description", Json.Encode.string state.field )
                            ]
                      )
                    ]
            )

        NoOp ->
            ( { props = props
              , state = state
              }
            , Cmd.none
            )

        _ ->
            ( { props = props
              , state = state
              }
            , Cmd.none
            )


view : Model -> Html Msg
view { props, state } =
    div
        [ class "todomvc-wrapper"
        , style "visibility" "hidden"
        ]
        [ section
            [ class "todoapp" ]
            [ lazy viewInput state.field
            , lazy3 viewTodos state.editingTodoId state.visibility props.todos
            , lazy2 viewControls state.visibility props.todos
            ]
        , infoFooter
        ]


viewInput : String -> Html Msg
viewInput task =
    header
        [ class "header" ]
        [ h1 [] [ text "todos" ]
        , input
            [ class "new-todo"
            , placeholder "What needs to be done?"
            , autofocus True
            , value task
            , name "newTodo"
            , onInput UpdateField
            , onEnter Add
            ]
            []
        ]


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.succeed msg

            else
                Json.fail "not ENTER"
    in
    on "keydown" (Json.andThen isEnter keyCode)


viewTodos : Maybe Int -> String -> List Todo -> Html Msg
viewTodos editingTodoId visibility todos =
    let
        isVisible todo =
            case visibility of
                "Completed" ->
                    todo.completed

                "Active" ->
                    not todo.completed

                _ ->
                    True

        allCompleted =
            List.all .completed todos

        cssVisibility =
            if List.isEmpty todos then
                "hidden"

            else
                "visible"
    in
    section
        [ class "main"
        , style "visibility" cssVisibility
        ]
        [ input
            [ class "toggle-all"
            , type_ "checkbox"
            , name "toggle"
            , checked allCompleted
            , onClick (CheckAll (not allCompleted))
            ]
            []
        , label
            [ for "toggle-all" ]
            [ text "Mark all as complete" ]
        , Keyed.ul [ class "todo-list" ] <|
            List.map (viewKeyedTodo editingTodoId) (List.filter isVisible todos)
        ]


viewKeyedTodo : Maybe Int -> Todo -> ( String, Html Msg )
viewKeyedTodo editingTodoId todo =
    ( String.fromInt todo.id, lazy2 viewTodo (Maybe.withDefault -1 editingTodoId == todo.id) todo )


viewTodo : Bool -> Todo -> Html Msg
viewTodo editing todo =
    li
        [ classList [ ( "completed", todo.completed ), ( "editing", editing ) ] ]
        [ div
            [ class "view" ]
            [ input
                [ class "toggle"
                , type_ "checkbox"
                , checked todo.completed
                , onClick (Check todo.id (not todo.completed))
                ]
                []
            , label
                [ onDoubleClick (EditingEntry todo.id True) ]
                [ text todo.description ]
            , button
                [ class "destroy"
                , onClick (Delete todo.id)
                ]
                []
            ]
        , input
            [ class "edit"
            , value todo.description
            , name "title"
            , id ("todo-" ++ String.fromInt todo.id)
            , onInput (UpdateEntry todo.id)
            , onBlur (EditingEntry todo.id False)
            , onEnter (EditingEntry todo.id False)
            ]
            []
        ]



-- VIEW CONTROLS AND FOOTER


viewControls : String -> List Todo -> Html Msg
viewControls visibility todos =
    let
        todosCompleted =
            List.length (List.filter .completed todos)

        todosLeft =
            List.length todos - todosCompleted
    in
    footer
        [ class "footer"
        , hidden (List.isEmpty todos)
        ]
        [ lazy viewControlsCount todosLeft
        , lazy viewControlsFilters visibility
        , lazy viewControlsClear todosCompleted
        ]


viewControlsCount : Int -> Html Msg
viewControlsCount todosLeft =
    let
        item_ =
            if todosLeft == 1 then
                " item"

            else
                " items"
    in
    span
        [ class "todo-count" ]
        [ strong [] [ text (String.fromInt todosLeft) ]
        , text (item_ ++ " left")
        ]


viewControlsFilters : String -> Html Msg
viewControlsFilters visibility =
    ul
        [ class "filters" ]
        [ visibilitySwap "#/" "All" visibility
        , text " "
        , visibilitySwap "#/active" "Active" visibility
        , text " "
        , visibilitySwap "#/completed" "Completed" visibility
        ]


visibilitySwap : String -> String -> String -> Html Msg
visibilitySwap uri visibility actualVisibility =
    li
        [ onClick (ChangeVisibility visibility) ]
        [ a [ href uri, classList [ ( "selected", visibility == actualVisibility ) ] ]
            [ text visibility ]
        ]


viewControlsClear : Int -> Html Msg
viewControlsClear todosCompleted =
    button
        [ class "clear-completed"
        , hidden (todosCompleted == 0)
        , onClick DeleteComplete
        ]
        [ text ("Clear completed (" ++ String.fromInt todosCompleted ++ ")")
        ]


infoFooter : Html msg
infoFooter =
    footer [ class "info" ]
        [ p [] [ text "Double-click to edit a todo" ]
        , p []
            [ text "Written by "
            , a [ href "https://github.com/evancz" ] [ text "Evan Czaplicki" ]
            ]
        , p []
            [ text "Part of "
            , a [ href "http://todomvc.com" ] [ text "TodoMVC" ]
            ]
        ]
