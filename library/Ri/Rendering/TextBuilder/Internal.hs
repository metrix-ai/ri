module Ri.Rendering.TextBuilder.Internal
(
  iri,
  httpIri,
)
where

import Ri.Prelude hiding (null)
import Ri.Data.Types
import Text.Builder
import qualified Data.Text.Encoding as A
import qualified Data.Text.Encoding.Error as A
import qualified Data.Text.Punycode as B
import qualified Data.Text as C
import qualified Data.HashMap.Strict as G
import qualified Data.Vector as H
import qualified Net.IPv4 as D
import qualified Net.IPv6 as E
import qualified Ri.Vector as F
import qualified Ri.CodePointPredicates.Core as I
import qualified Ri.CodePointPredicates.Rfc3987 as I
import qualified Ri.Utf8CodePoint as K
import qualified Data.ByteString as ByteString


iri :: Uri -> Builder
iri (Uri schemeValue hierarchyValue queryValue fragmentValue) =
  scheme schemeValue <> 
  char ':' <>
  hierarchy hierarchyValue <>
  (prependIfNotNull
    (char '?')
    (query queryValue)) <>
  (prependIfNotNull
    (char '#')
    (fragment fragmentValue))

httpIri :: HttpUri -> Builder
httpIri (HttpUri (Security secure) hostValue portValue pathValue queryValue fragmentValue) =
  (if secure then string "https://" else string "http://") <>
  host hostValue <>
  prependIfNotNull (char ':') (port portValue) <>
  prependIfNotNull (char '/') (path pathValue) <>
  prependIfNotNull (char '?') (query queryValue) <>
  prependIfNotNull (char '#') (fragment fragmentValue)

scheme :: Scheme -> Builder
scheme (Scheme bytes) =
  text (A.decodeUtf8With A.lenientDecode bytes)

hierarchy :: Hierarchy -> Builder
hierarchy =
  \ case
    AuthorisedHierarchy authorityValue pathValue ->
      string "//" <> authority authorityValue <> prependIfNotNull (char '/') (path pathValue)
    AbsoluteHierarchy pathValue ->
      char '/' <> path pathValue
    RelativeHierarchy pathValue ->
      path pathValue

authority :: Authority -> Builder
authority (Authority userInfoValue hostValue portValue) =
  appendIfNotNull (char '@') (userInfo userInfoValue) <>
  host hostValue <>
  prependIfNotNull (char ':') (port portValue)

userInfo :: UserInfo -> Builder
userInfo =
  \ case
    PresentUserInfo (User user) password -> case password of
      PresentPassword password -> userInfoComponent user <> char ':'  <> userInfoComponent password
      MissingPassword -> userInfoComponent user
    MissingUserInfo -> mempty

userInfoComponent :: ByteString -> Builder
userInfoComponent =
  urlEncodedBytesOrText I.unencodedUserInfoComponent

host :: Host -> Builder
host =
  \ case
    NamedHost value -> domainName value
    IpV4Host value -> ipV4 value
    IpV6Host value -> ipV6 value

domainName :: RegName -> Builder
domainName (RegName vector) =
  F.intercalate domainLabel (char '.') vector

domainLabel :: DomainLabel -> Builder
domainLabel =
  \ case
    AsciiDomainLabel x -> asciiByteString x
    UnicodeDomainLabel x -> text x

ipV4 :: IPv4 -> Builder
ipV4 =
  text . D.encode

ipV6 :: IPv6 -> Builder
ipV6 =
  text . E.encode

port :: Port -> Builder
port =
  \ case
    PresentPort value -> unsignedDecimal value
    MissingPort -> mempty

path :: Path -> Builder
path (Path pathSegmentVector) =
  F.intercalate pathSegment (char '/') pathSegmentVector

pathSegment :: PathSegment -> Builder
pathSegment (PathSegment value) =
  urlEncodedBytesOrText I.unencodedPathSegment value

query :: Query -> Builder
query (Query value) =
  urlEncodedBytesOrText I.unencodedQuery value

fragment :: Fragment -> Builder
fragment (Fragment value) =
  urlEncodedBytesOrText I.unencodedFragment value

urlEncodedBytesOrText :: I.Predicate -> ByteString -> Builder
urlEncodedBytesOrText unencodedPredicate bytes =
  case A.decodeUtf8' bytes of
    Right text -> urlEncodedText unencodedPredicate text
    Left _ -> urlEncodedBytes unencodedPredicate bytes

{-| Apply URL-encoding to text -}
urlEncodedBytes :: I.Predicate -> ByteString -> Builder
urlEncodedBytes unencodedPredicate =
  ByteString.foldl'
    (\ builder -> mappend builder . \ byte -> if unencodedPredicate (fromIntegral byte)
      then utf8CodeUnits1 byte
      else urlEncodedByte byte)
    mempty

{-| Apply URL-encoding to text -}
urlEncodedText :: I.Predicate -> Text -> Builder
urlEncodedText unencodedPredicate =
  C.foldl' (\ builder -> mappend builder . urlEncodedUnicodeCodePoint unencodedPredicate . ord) mempty

urlEncodedUnicodeCodePoint :: I.Predicate -> Int -> Builder
urlEncodedUnicodeCodePoint unencodedPredicate codePoint =
  if unencodedPredicate codePoint
    then
      unicodeCodePoint codePoint
    else
      K.unicodeCodePoint codePoint
        (\ b1 -> urlEncodedByte b1)
        (\ b1 b2 -> urlEncodedByte b1 <> urlEncodedByte b2)
        (\ b1 b2 b3 -> urlEncodedByte b1 <> urlEncodedByte b2 <> urlEncodedByte b3)
        (\ b1 b2 b3 b4 -> urlEncodedByte b1 <> urlEncodedByte b2 <> urlEncodedByte b3 <> urlEncodedByte b4)

urlEncodedByte :: Word8 -> Builder
urlEncodedByte x =
  case divMod x 16 of
    (d1, d2) -> char '%' <> hexadecimalDigit d1 <> hexadecimalDigit d2

prependIfNotNull :: Builder -> Builder -> Builder
prependIfNotNull prepended it =
  if null it
    then mempty
    else prepended <> it

appendIfNotNull :: Builder -> Builder -> Builder
appendIfNotNull appended it =
  if null it
    then mempty
    else it <> appended
