module App.Login.Update exposing (..)

import App.Login.Models exposing (Model)
import App.Login.Messages exposing (Msg(..))
import App.Login.Requests exposing (responseHandler
                                    , requestLogin
                                    -- , requestUsernameExists
                                    )



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of

        SubmitLogin ->
            let
                cmd = requestLogin model.username model.password
            in
                (model, cmd)

        SetUsername username ->
            ({model | username = username}, Cmd.none)

        ValidateUsername ->
            (model, Cmd.none)

        SetPassword password ->
            ({model | password = password}, Cmd.none)

        ValidatePassword ->
            (model, Cmd.none)

        Event event ->
            (model, Cmd.none)

        Request _ ->
            (model, Cmd.none)

        Response request data ->
            responseHandler request data model


