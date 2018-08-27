module Ri.Parsing.Text
(
  iri,
  httpIri,
)
where

import Ri.Prelude
import Ri.Data
import qualified Ri.Parsing.Attoparsec.Text as A
import qualified Data.Attoparsec.Text as B


{-|
Parser of a well-formed IRI conforming to the RFC3987 standard into 'Uri'.
Performs URL-decoding.
-}
iri :: Text -> Either Text Uri
iri =
  either (Left . fromString) Right .
  B.parseOnly (A.iri <* B.endOfInput)

{-|
Same as 'iri', but optimized specifially for the case of HTTP IRIs.
-}
httpIri :: Text -> Either Text HttpUri
httpIri =
  either (Left . fromString) Right .
  B.parseOnly (A.httpIri <* B.endOfInput)
