module Routing.Transitions exposing (..)

import Http
import Playlists.Types
import Response
import Routing.Types exposing (..)
import Sources.State as Sources
import Sources.Services
import Sources.Types
import Types as TopLevel exposing (Msg(..))


type alias Response =
    ( TopLevel.Model, Cmd TopLevel.Msg )



-- 🍯


transition : Routing.Types.Msg -> TopLevel.Model -> Response -> Response
transition routingMsg oldModel response =
    let
        modelMapFn =
            case routingMsg of
                SetPage page ->
                    mapModel page

                _ ->
                    identity
    in
        Response.mapModel modelMapFn response



-- Models


{-| Map the (top-level) model based on the next page.
-}
mapModel : Page -> TopLevel.Model -> TopLevel.Model
mapModel nextPage model =
    case nextPage of
        --
        -- When we are going to edit a source,
        -- set the `newPlaylist` attribute.
        --
        Playlists (Playlists.Types.Edit encodedPlaylistName) ->
            let
                playlists =
                    model.playlists

                newPlaylist =
                    playlists.newPlaylist

                updatedNewPlaylist =
                    encodedPlaylistName
                        |> Http.decodeUri
                        |> Maybe.withDefault ""
                        |> (\n -> { newPlaylist | name = n })
            in
                { model | playlists = { playlists | newPlaylist = updatedNewPlaylist } }

        --
        -- When we are going to edit a source,
        -- set the `form` attribute.
        --
        Sources (Sources.Types.Edit sourceId) ->
            let
                sources =
                    Sources.editForm model.sources sourceId
            in
                { model | sources = sources }

        --
        -- When we are going to create a source,
        -- set the `form` attribute.
        --
        Sources Sources.Types.New ->
            case model.sources.form of
                Sources.Types.EditForm _ ->
                    { model | sources = Sources.newForm model.sources }

                _ ->
                    model

        Sources (Sources.Types.NewThroughRedirect service hash) ->
            let
                sources =
                    model.sources

                form =
                    Sources.Services.newFormThroughRedirect service hash
            in
                { model | sources = { sources | form = form } }

        --
        -- Default
        --
        _ ->
            model
