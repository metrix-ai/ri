module Ri.Rendering.ByteString
where

import Ri.Prelude
import Ri.Data
import qualified Ri.Rendering.Ptr.Poking as A
import qualified Ptr.ByteString as F


{-| Render as URI ASCII bytes -}
uri :: Uri -> ByteString
uri =
  F.poking . A.uri

{-| Render as URI ASCII bytes -}
httpUri :: HttpUri -> ByteString
httpUri =
  F.poking . A.httpUri
