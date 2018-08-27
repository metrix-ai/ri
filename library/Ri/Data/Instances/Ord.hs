module Ri.Data.Instances.Ord
where

import Ri.Prelude
import Ri.Data.Types
import Ri.Data.Instances.Eq


deriving instance Ord Uri

deriving instance Ord Scheme

deriving instance Ord Hierarchy

deriving instance Ord Authority

deriving instance Ord UserInfo

deriving instance Ord User

deriving instance Ord Password

deriving instance Ord Host

deriving instance Ord RegName

deriving instance Ord DomainLabel

deriving instance Ord Port

deriving instance Ord Path

deriving instance Ord PathSegment

deriving instance Ord Query

deriving instance Ord Fragment

deriving instance Ord HttpUri

deriving instance Ord Security
