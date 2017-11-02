module Apps.LogViewer.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Data as Game
import Utils.Update as Update
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Messages as LogViewer exposing (Msg(..))
import Apps.LogViewer.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd LogViewer.Msg, Dispatch )
actionHandler data action ({ app } as model) =
    case action of
        NormalEntryEdit logId ->
            enterEditing data logId model
                |> Update.fromModel

        EdittingEntryApply logId ->
            let
                edited =
                    getEdit logId app

                dispatch =
                    case edited of
                        Just edited ->
                            edited
                                |> Servers.UpdateLog logId
                                |> Dispatch.logs (Game.getActiveCId data)

                        Nothing ->
                            Dispatch.none

                model_ =
                    { model | app = leaveEditing logId app }
            in
                ( model_, Cmd.none, dispatch )

        EdittingEntryCancel logId ->
            let
                app_ =
                    leaveEditing logId app

                model_ =
                    { model | app = app_ }
            in
                Update.fromModel model_
