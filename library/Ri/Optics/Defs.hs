module Ri.Optics.Defs
where

import Ri.Prelude
import Ri.Data
import Ri.Optics.Basics
import qualified Ri.Rendering.ByteString as A
import qualified Ri.Parsing.ByteString as B
import qualified Ri.Rendering.Text as C
import qualified Ri.Parsing.Text as D
import qualified Data.Text.Encoding as Text


-- * Definitions by source
-------------------------

-- ** Text
-------------------------

textIriUri :: Prism' Text Uri
textIriUri =
  prism C.iri (\ text -> either (const (Left text)) Right (D.iri text))

textIriHttpUri :: Prism' Text HttpUri
textIriHttpUri =
  textIriUri . uriHttpUri

-- ** ByteString
-------------------------

byteStringUri :: Prism' ByteString Uri
byteStringUri =
  prism A.uri (\ bytes -> either (const (Left bytes)) Right (B.uri bytes))

byteStringHttpUri :: Prism' ByteString HttpUri
byteStringHttpUri =
  byteStringUri . uriHttpUri

byteStringUriQuery :: Lens' ByteString Query
byteStringUriQuery = undefined

byteStringTextInUtf8 :: Prism' ByteString Text
byteStringTextInUtf8 = prism' Text.encodeUtf8 (either (const Nothing) Just . Text.decodeUtf8')

-- ** URI
-------------------------

uriHttpUri :: Prism' Uri HttpUri
uriHttpUri = prism' uriFromHttpUri (either (const Nothing) Just . httpUriFromUri)

uriScheme :: Lens' Uri Scheme
uriScheme = lens (\ (Uri x _ _ _) -> x) (\ (Uri _ hierarchy query fragment) x -> Uri x hierarchy query fragment)

uriHierarchy :: Lens' Uri Hierarchy
uriHierarchy = lens (\ (Uri _ x _ _) -> x) (\ (Uri scheme _ query fragment) x -> Uri scheme x query fragment)

uriQuery :: Lens' Uri Query
uriQuery = lens (\ (Uri _ _ x _) -> x) (\ (Uri scheme hierarchy _ fragment) x -> Uri scheme hierarchy x fragment)

uriParametricQuery :: Traversal' Uri ParametricQuery
uriParametricQuery = uriQuery . queryParametricQuery

uriUnicodeParametricQueryInUtf8 :: Traversal' Uri UnicodeParametricQuery
uriUnicodeParametricQueryInUtf8 = uriQuery . queryUnicodeParametricQueryInUtf8

uriFragment :: Lens' Uri Fragment
uriFragment = lens (\ (Uri _ _ _ x) -> x) (\ (Uri scheme hierarchy query _) x -> Uri scheme hierarchy query x)

-- ** Scheme
-------------------------

schemeByteString :: Lens' Scheme ByteString
schemeByteString = lens (\ (Scheme x) -> x) (const Scheme)

-- ** Query
-------------------------

queryParametricQuery :: Prism' Query ParametricQuery
queryParametricQuery = undefined

queryUnicodeParametricQueryInUtf8 :: Prism' Query UnicodeParametricQuery
queryUnicodeParametricQueryInUtf8 = queryParametricQuery . parametricQueryUnicodeParametricQueryInUtf8

-- ** Parametric query
-------------------------

parametricQueryUnicodeParametricQueryInUtf8 :: Prism' ParametricQuery UnicodeParametricQuery
parametricQueryUnicodeParametricQueryInUtf8 = undefined

-- ** Fragment
-------------------------

fragmentByteString :: Lens' Fragment ByteString
fragmentByteString = lens (\ (Fragment x) -> x) (const Fragment)
