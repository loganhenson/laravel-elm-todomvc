module Todos exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (Decoder, Value, decodeValue, field, int, string, bool)
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import LaravelElm exposing (Errors, Page, decodeErrors, page)
import Routes


-- TYPES


type alias Todo =
    { id : Int
    , text : String
    , completed : Bool
    }


type alias Props =
    { todos : List Todo
    , errors : Errors
    }


type Filter
    = All
    | Active
    | Completed


type alias State =
    { newTodo : String
    , filter : Filter
    , editingTodo : Maybe Int
    , editText : String
    }


type alias Model =
    { props : Props
    , state : State
    }


type Msg
    = NewProps Value
    | NoOp
    | UpdateNewTodo String
    | CreateTodo
    | ToggleTodo Todo
    | DeleteTodo Todo
    | StartEditing Todo
    | UpdateEditText String
    | FinishEditing Todo
    | CancelEditing
    | ToggleAll
    | ClearCompleted
    | SetFilter Filter


-- MAIN


main : Page Model Msg
main =
    page
        { decodeProps = decodeProps
        , stateFromProps = stateFromProps
        , update = update
        , view = view
        , newPropsMsg = NewProps
        }


-- DECODERS


decodeProps : Decoder Props
decodeProps =
    Decode.succeed Props
        |> Pipeline.required "todos" (Decode.list decodeTodo)
        |> Pipeline.required "errors" decodeErrors


decodeTodo : Decoder Todo
decodeTodo =
    Decode.succeed Todo
        |> Pipeline.required "id" int
        |> Pipeline.required "text" string
        |> Pipeline.required "completed" bool


-- STATE


stateFromProps : Props -> State
stateFromProps props =
    { newTodo = ""
    , filter = All
    , editingTodo = Nothing
    , editText = ""
    }


-- UPDATE


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
            ( { props = props, state = state }, Cmd.none )

        UpdateNewTodo text ->
            ( { props = props, state = { state | newTodo = text } }, Cmd.none )

        CreateTodo ->
            if String.trim state.newTodo == "" then
                ( { props = props, state = state }, Cmd.none )

            else
                ( { props = props, state = { state | newTodo = "" } }
                , Routes.post
                    (Encode.object
                        [ ( "url", Encode.string Routes.todos )
                        , ( "data"
                          , Encode.object
                                [ ( "text", Encode.string (String.trim state.newTodo) )
                                ]
                          )
                        ]
                    )
                )

        ToggleTodo todo ->
            ( { props = props, state = state }
            , Routes.patch
                (Encode.object
                    [ ( "url", Encode.string (Routes.todosUpdate (String.fromInt todo.id)) )
                    , ( "data"
                      , Encode.object
                            [ ( "completed", Encode.bool (not todo.completed) )
                            ]
                      )
                    ]
                )
            )

        DeleteTodo todo ->
            ( { props = props, state = state }
            , Routes.delete (Routes.todosDestroy (String.fromInt todo.id))
            )

        StartEditing todo ->
            ( { props = props
              , state = 
                  { state 
                  | editingTodo = Just todo.id
                  , editText = todo.text 
                  }
              }
            , Cmd.none
            )

        UpdateEditText text ->
            ( { props = props, state = { state | editText = text } }, Cmd.none )

        FinishEditing todo ->
            if String.trim state.editText == "" then
                ( { props = props, state = { state | editingTodo = Nothing, editText = "" } }
                , Routes.delete (Routes.todosDestroy (String.fromInt todo.id))
                )

            else if String.trim state.editText == todo.text then
                ( { props = props, state = { state | editingTodo = Nothing, editText = "" } }
                , Cmd.none
                )

            else
                ( { props = props, state = { state | editingTodo = Nothing, editText = "" } }
                , Routes.patch
                    (Encode.object
                        [ ( "url", Encode.string (Routes.todosUpdate (String.fromInt todo.id)) )
                        , ( "data"
                          , Encode.object
                                [ ( "text", Encode.string (String.trim state.editText) )
                                ]
                          )
                        ]
                    )
                )

        CancelEditing ->
            ( { props = props, state = { state | editingTodo = Nothing, editText = "" } }
            , Cmd.none
            )

        ToggleAll ->
            let
                allCompleted = List.all .completed props.todos
            in
            ( { props = props, state = state }
            , Routes.post
                (Encode.object
                    [ ( "url", Encode.string Routes.todosToggleAll )
                    , ( "data"
                      , Encode.object
                            [ ( "completed", Encode.bool (not allCompleted) )
                            ]
                      )
                    ]
                )
            )

        ClearCompleted ->
            ( { props = props, state = state }
            , Routes.delete Routes.todosClearCompleted
            )

        SetFilter filter ->
            ( { props = props, state = { state | filter = filter } }, Cmd.none )


-- VIEW


view : Model -> Html Msg
view { props, state } =
    div []
        [ section [ class "todoapp" ]
            [ h1 [] [ text "todos" ]
            , viewNewTodoInput state.newTodo
            , if not (List.isEmpty props.todos) then
                div []
                    [ viewTodoList props.todos state
                    , viewControls props.todos state
                    ]
              else
                text ""
            ]
        , viewInfo
        ]


viewNewTodoInput : String -> Html Msg
viewNewTodoInput newTodo =
    input
        [ class "new-todo"
        , placeholder "What needs to be done?"
        , value newTodo
        , onInput UpdateNewTodo
        , onEnter CreateTodo
        , autofocus True
        ]
        []


viewTodoList : List Todo -> State -> Html Msg
viewTodoList todos state =
    let
        filteredTodos =
            case state.filter of
                All ->
                    todos

                Active ->
                    List.filter (not << .completed) todos

                Completed ->
                    List.filter .completed todos

        allCompleted =
            List.all .completed todos
    in
    section [ class "main" ]
        [ input
            [ class "toggle-all"
            , type_ "checkbox"
            , checked allCompleted
            , onClick ToggleAll
            ]
            []
        , label [ for "toggle-all" ] [ text "Mark all as complete" ]
        , ul [ class "todo-list" ]
            (List.map (viewTodoItem state) filteredTodos)
        ]


viewTodoItem : State -> Todo -> Html Msg
viewTodoItem state todo =
    li
        [ classList
            [ ( "completed", todo.completed )
            , ( "editing", state.editingTodo == Just todo.id )
            ]
        ]
        [ div [ class "view" ]
            [ input
                [ class "toggle"
                , type_ "checkbox"
                , checked todo.completed
                , onClick (ToggleTodo todo)
                ]
                []
            , label [ onDoubleClick (StartEditing todo) ] [ text todo.text ]
            , button [ class "destroy", onClick (DeleteTodo todo) ] []
            ]
        , input
            [ class "edit"
            , value state.editText
            , onInput UpdateEditText
            , onEnter (FinishEditing todo)
            , onBlur (FinishEditing todo)
            , onEscape CancelEditing
            ]
            []
        ]


viewControls : List Todo -> State -> Html Msg
viewControls todos state =
    let
        activeTodos =
            List.filter (not << .completed) todos

        completedTodos =
            List.filter .completed todos

        itemsLeft =
            List.length activeTodos
    in
    footer [ class "footer" ]
        [ span [ class "todo-count" ]
            [ strong [] [ text (String.fromInt itemsLeft) ]
            , text (if itemsLeft == 1 then " item left" else " items left")
            ]
        , ul [ class "filters" ]
            [ li [] [ viewFilterButton "All" All (state.filter == All) ]
            , li [] [ viewFilterButton "Active" Active (state.filter == Active) ]
            , li [] [ viewFilterButton "Completed" Completed (state.filter == Completed) ]
            ]
        , if List.isEmpty completedTodos then
            text ""
          else
            button
                [ class "clear-completed"
                , onClick ClearCompleted
                ]
                [ text "Clear completed" ]
        ]


viewFilterButton : String -> Filter -> Bool -> Html Msg
viewFilterButton label filter isActive =
    a
        [ classList [ ( "selected", isActive ) ]
        , onClick (SetFilter filter)
        , href "#"
        ]
        [ text label ]


viewInfo : Html msg
viewInfo =
    footer [ class "info" ]
        [ p [] [ text "Double-click to edit a todo" ]
        , p []
            [ text "Created with "
            , a [ href "https://github.com/tightenco/laravel-elm" ] [ text "Laravel Elm" ]
            ]
        , p []
            [ text "Part of "
            , a [ href "http://todomvc.com" ] [ text "TodoMVC" ]
            ]
        ]


-- HELPERS


onEnter : Msg -> Attribute Msg
onEnter msg =
    on "keydown" (Decode.andThen (enterDecoder msg) (field "key" string))


onEscape : Msg -> Attribute Msg  
onEscape msg =
    on "keydown" (Decode.andThen (escapeDecoder msg) (field "key" string))


enterDecoder : Msg -> String -> Decoder Msg
enterDecoder msg key =
    if key == "Enter" then
        Decode.succeed msg

    else
        Decode.fail "Not Enter"


escapeDecoder : Msg -> String -> Decoder Msg
escapeDecoder msg key =
    if key == "Escape" then
        Decode.succeed msg

    else
        Decode.fail "Not Escape"