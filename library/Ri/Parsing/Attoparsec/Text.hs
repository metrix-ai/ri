module Ri.Parsing.Attoparsec.Text
(
  iri,
  httpIri,
)
where

import Ri.Prelude
import Ri.Data
import Data.Attoparsec.Text hiding (try)
import qualified Data.ByteString as K
import qualified Data.Text as T
import qualified Data.Text.Encoding as B
import qualified Data.Text.Encoding.Error as L
import qualified Data.Vector as S
import qualified VectorBuilder.MonadPlus as E
import qualified Ri.CodePointPredicates.Rfc3987 as C
import qualified Ri.MonadPlus as R
import qualified Text.Builder as J
import qualified Net.IPv4 as M
import qualified Net.IPv6 as N
import qualified Ptr.ByteString as ByteString
import qualified Ptr.Poking as Poking


{-# INLINE labeled #-}
labeled :: String -> Parser a -> Parser a
labeled label parser =
  parser <?> label

{-|
Parser of a well-formed IRI conforming to the RFC3987 standard into 'Uri'.
Performs URL-decoding.
-}
{-# INLINABLE iri #-}
iri :: Parser Uri
iri =
  labeled "IRI" $ do
    parsedScheme <- scheme
    char ':'
    parsedHierarchy <- hierarchy
    parsedQuery <- query
    parsedFragment <- fragment
    return (Uri parsedScheme parsedHierarchy parsedQuery parsedFragment)

{-|
Same as 'iri', but optimized specifially for the case of HTTP IRIs.
-}
{-# INLINABLE httpIri #-}
httpIri :: Parser HttpUri
httpIri =
  labeled "HTTP IRI" $ do
    asciiCI "http"
    secure <- satisfy (\ x -> x == 's' || x == 'S') $> True <|> pure False
    string "://"
    parsedHost <- host
    parsedPort <- PresentPort <$> (char ':' *> port) <|> pure MissingPort
    parsedPath <- ((char '/') *> path) <|> pure (Path mempty)
    parsedQuery <- query
    parsedFragment <- fragment
    return (HttpUri (Security secure) parsedHost parsedPort parsedPath parsedQuery parsedFragment)

{-# INLINE hierarchy #-}
hierarchy :: Parser Hierarchy
hierarchy =
  do
    slashPresent <- (char '/') $> True <|> pure False
    if slashPresent
      then do
        slashPresent <- (char '/') $> True <|> pure False
        if slashPresent
          then authorisedHierarchyBody AuthorisedHierarchy
          else AbsoluteHierarchy <$> path
      else RelativeHierarchy <$> path

{-# INLINE authorisedHierarchyBody #-}
authorisedHierarchyBody :: (Authority -> Path -> body) -> Parser body
authorisedHierarchyBody body =
  do
    parsedUserInfo <- (presentUserInfo PresentUserInfo <* char '@') <|> pure MissingUserInfo
    parsedHost <- host
    parsedPort <- PresentPort <$> (char ':' *> port) <|> pure MissingPort
    parsedPath <- ((char '/') *> path) <|> pure (Path mempty)
    return (body (Authority parsedUserInfo parsedHost parsedPort) parsedPath)

{-# INLINE scheme #-}
scheme :: Parser Scheme
scheme =
  labeled "Scheme" $
  fmap (Scheme . B.encodeUtf8) (takeWhile1 (C.scheme . ord))

{-# INLINABLE presentUserInfo #-}
presentUserInfo :: (User -> Password -> a) -> Parser a
presentUserInfo result =
  labeled "User info" $
  do
    user <- User <$> urlEncodedComponent (C.unencodedUserInfoComponent . ord)
    passwordFollows <- True <$ char ':' <|> pure False
    if passwordFollows
      then do
        password <- PresentPassword <$> urlEncodedComponent (C.unencodedUserInfoComponent . ord)
        return (result user password)
      else return (result user MissingPassword)

{-# INLINE host #-}
host :: Parser Host
host =
  labeled "Host" $
  IpV6Host <$> N.parser <|>
  IpV4Host <$> M.parser <|>
  NamedHost <$> domainName

{-# INLINE domainName #-}
domainName :: Parser RegName
domainName =
  fmap RegName (E.sepBy1 domainLabel (char '.'))

{-|
Domain label with Punycode decoding applied.
-}
{-# INLINE domainLabel #-}
domainLabel :: Parser DomainLabel
domainLabel =
  labeled "Domain label" $
  UnicodeDomainLabel <$> takeWhile1 (C.unencodedRegName . ord)

{-# INLINE port #-}
port :: Parser Word16
port =
  decimal

{-# INLINE path #-}
path :: Parser Path
path =
  do
    segments <- E.sepBy pathSegment (char '/')
    if segmentsAreEmpty segments
      then return (Path mempty)
      else return (Path segments)
  where
    segmentsAreEmpty segments =
      S.length segments == 1 &&
      (case S.unsafeHead segments of PathSegment headSegment -> K.null headSegment)

{-# INLINE pathSegment #-}
pathSegment :: Parser PathSegment
pathSegment =
  fmap PathSegment (urlEncodedComponent (C.unencodedPathSegment . ord))

{-# INLINABLE urlEncodedComponent #-}
urlEncodedComponent :: (Char -> Bool) -> Parser ByteString
urlEncodedComponent unencodedCharPredicate =
  labeled "URL-encoded component" $
  fmap ByteString.poking $
  R.fold $
  (Poking.bytes . B.encodeUtf8 <$> takeWhile1 unencodedCharPredicate) <|> (Poking.word8 <$> urlEncodedByte)

{-# INLINABLE urlEncodedComponentText #-}
urlEncodedComponentText :: (Char -> Bool) -> Parser Text
urlEncodedComponentText unencodedCharPredicate =
  labeled "URL-encoded component" $
  fmap J.run $
  R.foldl mappend mempty $
  (J.text <$> takeWhile1 unencodedCharPredicate) <|> urlEncodedSequenceTextBuilder

{-# INLINABLE urlEncodedSequenceTextBuilder #-}
urlEncodedSequenceTextBuilder :: Parser J.Builder
urlEncodedSequenceTextBuilder =
  labeled "URL-encoded sequence" $ do
    start <- progress (mempty, mempty, B.streamDecodeUtf8) =<< urlEncodedByte
    R.foldlM progress (start) urlEncodedByte >>= finish
  where
    progress (!builder, _ :: ByteString, decode) byte =
      case unsafeDupablePerformIO (try (evaluate (decode (K.singleton byte)))) of
        Right (B.Some decodedChunk undecodedBytes newDecode) ->
          return (builder <> J.text decodedChunk, undecodedBytes, newDecode)
        Left (L.DecodeError error _) ->
          fail (showString "UTF8 decoding: " error)
    finish (builder, undecodedBytes, _) =
      if K.null undecodedBytes
        then return builder
        else fail (showString "UTF8 decoding: Bytes remaining: " (show undecodedBytes))

{-# INLINE urlEncodedByte #-}
urlEncodedByte :: Parser Word8
urlEncodedByte =
  do
    char '%' 
    digit1 <- fromIntegral <$> hexadecimalDigit
    digit2 <- fromIntegral <$> hexadecimalDigit
    return (shiftL digit1 4 .|. digit2)

{-# INLINE hexadecimalDigit #-}
hexadecimalDigit :: Parser Int
hexadecimalDigit =
  do
    c <- anyChar
    let x = ord c
    if x >= 48 && x < 58
      then return (x - 48)
      else if x >= 65 && x < 71
        then return (x - 55)
        else if x >= 97 && x < 103
          then return (x - 97)
          else fail ("Not a hexadecimal digit: " <> show c)

{-# INLINABLE query #-}
query :: Parser Query
query =
  labeled "Query" $
  (char '?' *> queryBody) <|> pure (Query mempty)

{-|
The stuff after the question mark.
-}
{-# INLINABLE queryBody #-}
queryBody :: Parser Query
queryBody =
  fmap Query (urlEncodedComponent (C.unencodedQuery . ord))

{-# INLINABLE fragment #-}
fragment :: Parser Fragment
fragment =
  labeled "Fragment" $
  (char '#' *> (Fragment <$> urlEncodedComponent (C.unencodedFragment . ord))) <|>
  pure (Fragment mempty)
