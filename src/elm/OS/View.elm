module OS.View exposing (view)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.CssHelpers
import Router.Router exposing (Route(..))
import Core.Models exposing (CoreModel)
import Core.Messages exposing (CoreMsg(..))
import Core.Dispatcher exposing (callAccount)
import Game.Account.Messages exposing (AccountMsg(Logout))
import OS.WindowManager.View
import OS.Dock.View


{ id, class, classList } =
    Html.CssHelpers.withNamespace "dreamwriter"


view : CoreModel -> Html CoreMsg
view model =
    case model.route of
        RouteNotFound ->
            viewNotFound

        _ ->
            viewDashboard model


viewDashboard : CoreModel -> Html CoreMsg
viewDashboard model =
    div [ id "view-dashboard" ]
        [ viewHeader model
        , viewSidebar model
        , viewMain model
        , viewFooter model
        ]


viewHeader : CoreModel -> Html CoreMsg
viewHeader model =
    header []
        [ div [ id "header-left" ]
            []
        , div [ id "header-mid" ]
            []
        , div [ id "header-right" ]
            [ button [ onClick (callAccount Logout) ]
                [ text "logout" ]
            ]
        ]


viewSidebar : CoreModel -> Html CoreMsg
viewSidebar model =
    nav []
        [ text "nav" ]


viewMain : CoreModel -> Html CoreMsg
viewMain model =
    main_ []
        [ OS.WindowManager.View.renderWindows model
        ]


viewFooter : CoreModel -> Html CoreMsg
viewFooter model =
    footer []
        [ OS.Dock.View.view model ]


viewNotFound : Html CoreMsg
viewNotFound =
    div []
        [ text "Not found"
        ]
