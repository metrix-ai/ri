module Ri.Data.Instances.Eq
where

import Ri.Prelude
import Ri.Data.Types


deriving instance Eq Uri

deriving instance Eq Scheme

deriving instance Eq Hierarchy

deriving instance Eq Authority

deriving instance Eq UserInfo

deriving instance Eq User

deriving instance Eq Password

deriving instance Eq Host

deriving instance Eq RegName

deriving instance Eq DomainLabel

deriving instance Eq Port

deriving instance Eq Path

deriving instance Eq PathSegment

deriving instance Eq Query

deriving instance Eq Fragment

deriving instance Eq HttpUri

deriving instance Eq Security
