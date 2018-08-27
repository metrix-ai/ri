module Ri.QuasiQuoter
(
  uri,
  httpUri,
)
where

import Ri.Prelude hiding (exp)
import Ri.Data
import Language.Haskell.TH.Syntax
import Language.Haskell.TH.Quote
import qualified Ri.Parsing.Attoparsec.ByteString as A
import qualified Data.Attoparsec.ByteString as B
import qualified Data.Attoparsec.Text as C
import qualified Ri.Parsing.Attoparsec.Text as D


exp :: (String -> Q Exp) -> QuasiQuoter
exp exp =
  QuasiQuoter exp unsupported unsupported unsupported
  where
    unsupported _ =
      fail "Not supported"

{-|
'Uri' literal from ASCII representation.
-}
uri :: QuasiQuoter
uri =
  exp $ \ string ->
  case B.parseOnly (A.uri <* B.endOfInput) (fromString string) of
    Right uri -> lift uri
    Left error -> fail (showString "URI parsing: " error)

{-|
'HttpUri' literal from ASCII representation.
-}
httpUri :: QuasiQuoter
httpUri =
  exp $ \ string ->
  case B.parseOnly (A.httpUri <* B.endOfInput) (fromString string) of
    Right uri -> lift uri
    Left error -> fail (showString "HTTP URI parsing: " error)

{-|
'Uri' literal from IRI representation.
-}
iri :: QuasiQuoter
iri =
  exp $ \ string ->
  case C.parseOnly (D.iri <* C.endOfInput) (fromString string) of
    Right uri -> lift uri
    Left error -> fail (showString "IRI parsing: " error)

{-|
'HttpUri' literal from IRI representation.
-}
httpIri :: QuasiQuoter
httpIri =
  exp $ \ string ->
  case C.parseOnly (D.httpIri <* C.endOfInput) (fromString string) of
    Right uri -> lift uri
    Left error -> fail (showString "HTTP IRI parsing: " error)
