module Apps.Hebamp.View exposing (view)

import Json.Decode as Json
import Css
import Html exposing (..)
import Html.Attributes exposing (src, type_, controls, style)
import Html.CssHelpers
import Html.Events exposing (on, onClick)
import Utils.Html.Events exposing (onClickMe)
import Apps.Hebamp.Config exposing (..)
import Apps.Hebamp.Messages exposing (Msg(..))
import Apps.Hebamp.Models exposing (..)
import Apps.Hebamp.Shared exposing (..)
import Apps.Hebamp.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view ({ toMsg, draggable, windowMenu } as config) model =
    div
        [ class [ Container ] ]
        [ div [ class [ Header ], draggable, windowMenu ]
            [ text ":"
            , span [ class [ IconClose ], onClickMe <| toMsg <| Close ] []
            ]
        , div [ class [ Player ] ]
            [ div [ class [ Vis ] ] [ text <| viewableTime model.currentTime ]
            , div [ class [ Vis, Title ] ] [ songTitle model.now ]
            , div [ class [ Inf ] ] []
            , div [ class [ Inf, KHz ] ] []
            , div [ class [ MonoStereo ] ] [ text "mono" ]
            , div [ class [ Bar, Volume ] ] []
            , div [ class [ Bar, Balanced ] ] []
            , div [ class [ Btn, Ext, Left ] ] [ text "EQ" ]
            , div [ class [ Btn, Ext ] ] [ text "PL" ]
            , div [ class [ Slidebar ] ]
                [ span
                    [ class [ Pointer ]
                    , sliderStyle model.now model.currentTime
                    ]
                    []
                ]
            , div [ class [ Btn, PlayerB, First ] ]
                [ span [ class [ Icon, IconStepBackward ] ] [] ]
            , div [ class [ Btn, PlayerB ] ]
                [ span [ class [ Icon, IconPlay ], onClick <| toMsg <| Play ] [] ]
            , div [ class [ Btn, PlayerB ] ]
                [ span [ class [ Icon, IconPause ], onClick <| toMsg <| Pause ] [] ]
            , div [ class [ Btn, PlayerB ] ]
                [ span [ class [ Icon, IconStop ], onClick <| toMsg <| Pause ] [] ]
            , div [ class [ Btn, PlayerB ] ]
                [ span [ class [ Icon, IconStepForward ] ] [] ]
            , div [ class [ Btn, PlayerB, First ] ]
                [ span [ class [ Icon, IconEject ], onClick <| toMsg <| Pause ] [] ]
            , div [ class [ Btn, Ext, Left ] ] [ text "SHUFFLE" ]
            , div [ class [ Btn, Ext, Left ] ] [ text "RAND " ]
            ]
        , nativeAudio config model.playerId model.now
        ]


targetCurrentTime : Json.Decoder Float
targetCurrentTime =
    Json.at [ "target", "currentTime" ] Json.float


onTimeUpdate : (Float -> msg) -> Attribute msg
onTimeUpdate msg =
    on "timeupdate" (Json.map msg targetCurrentTime)


atLeastTwoDigits : Int -> String
atLeastTwoDigits val =
    let
        pure =
            toString val

        count =
            String.length pure
    in
        if count >= 2 then
            pure
        else if count == 1 then
            "0" ++ pure
        else
            "00"


viewableTime : Float -> String
viewableTime src =
    let
        min =
            src
                |> (flip (/)) 60
                |> floor
                |> toString

        sec =
            src
                |> floor
                |> (flip (%)) 60
                |> atLeastTwoDigits
    in
        min ++ ":" ++ sec


songTitle : Maybe AudioData -> Html msg
songTitle audioData =
    audioData
        |> Maybe.map .label
        |> Maybe.withDefault "NO SONG LOADED"
        |> text


sliderStyle : Maybe AudioData -> Float -> Attribute msg
sliderStyle audioData currentTime =
    let
        styles =
            case audioData of
                Just audioData ->
                    (220 * currentTime / audioData.duration)
                        |> Css.px
                        |> Css.marginLeft
                        |> List.singleton

                Nothing ->
                    []
    in
        styles |> Css.asPairs |> style


nativeAudio : Config msg -> String -> Maybe AudioData -> Html msg
nativeAudio { toMsg } playerId audioData =
    let
        staticAttr =
            [ id playerId
            , controls False
            ]

        dynamicAttr =
            case audioData of
                Just audioData ->
                    [ src audioData.mediaUrl
                    , type_ audioData.mediaType
                    , onTimeUpdate <| toMsg << TimeUpdate playerId
                    ]

                Nothing ->
                    []
    in
        audio (staticAttr ++ dynamicAttr) []
