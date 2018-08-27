{-|
References:

* <https://tools.ietf.org/rfc/rfc3986.txt URI RFC>
* <https://tools.ietf.org/rfc/rfc3987.txt IRI RFC>
-}
module Ri.Data
(
  module Ri.Data.Types,
  module Ri.Data.Functions,
)
where

import Ri.Data.Types
import Ri.Data.Functions
import Ri.Data.Instances.Lift
import Ri.Data.Instances.Eq
import Ri.Data.Instances.Show
import Ri.Data.Instances.Ord
import Ri.Data.Instances.Hashable
import Ri.Data.Instances.Generic

