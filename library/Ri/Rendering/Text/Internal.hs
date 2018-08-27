module Ri.Rendering.Text.Internal
where

import Ri.Prelude
import Ri.Data.Types
import qualified Ri.Rendering.TextBuilder.Internal as A
import qualified Text.Builder as B


{-| Render as a Unicode IRI text -}
iri :: Uri -> Text
iri =
  B.run . A.iri

{-| Render as a Unicode IRI text -}
httpIri :: HttpUri -> Text
httpIri =
  B.run . A.httpIri
