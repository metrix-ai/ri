module Ri.Data.Instances.Lift
where

import Ri.Prelude
import Ri.Data.Types
import Language.Haskell.TH.Lift


deriveLift ''Uri

deriveLift ''Scheme

deriveLift ''Hierarchy

deriveLift ''Authority

deriveLift ''UserInfo

deriveLift ''User

deriveLift ''Password

deriveLift ''Host

deriveLift ''RegName

deriveLift ''DomainLabel

deriveLift ''Port

deriveLift ''Path

deriveLift ''PathSegment

deriveLift ''Query

deriveLift ''Fragment

deriveLift ''HttpUri

deriveLift ''Security
