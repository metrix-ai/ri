module Ri.Data.Functions
where

import Ri.Prelude
import Ri.Data.Types


{-| Try to specialize a general IRI to HTTP -}
httpUriFromUri :: Uri -> Either Text HttpUri
httpUriFromUri (Uri (Scheme scheme) hierarchy query fragment) =
  do
    security <- case scheme of
      "http" -> Right (Security False)
      "https" -> Right (Security True)
      _ -> Left ("Not an HTTP scheme: " <> (fromString . show) scheme)
    case hierarchy of
      AuthorisedHierarchy (Authority userInfo host port) path -> case userInfo of
        MissingUserInfo -> Right (HttpUri security host port path query fragment)
        PresentUserInfo (User user) _ -> Left ("User Info is present")
      _ -> Left ("Not an authorised hierarchy")

{-| Generalize an HTTP IRI to IRI -}
uriFromHttpUri :: HttpUri -> Uri
uriFromHttpUri (HttpUri (Security secure) host port path query fragment) =
  Uri scheme hierarchy query fragment
  where
    scheme =
      Scheme (if secure then "https" else "http")
    hierarchy =
      AuthorisedHierarchy (Authority MissingUserInfo host port) path
