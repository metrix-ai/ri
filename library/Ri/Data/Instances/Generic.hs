module Ri.Data.Instances.Generic
where

import Ri.Prelude
import Ri.Data.Types


deriving instance Generic Uri

deriving instance Generic Scheme

deriving instance Generic Hierarchy

deriving instance Generic Authority

deriving instance Generic UserInfo

deriving instance Generic User

deriving instance Generic Password

deriving instance Generic Host

deriving instance Generic RegName

deriving instance Generic DomainLabel

deriving instance Generic Port

deriving instance Generic Path

deriving instance Generic PathSegment

deriving instance Generic Query

deriving instance Generic Fragment

deriving instance Generic HttpUri

deriving instance Generic Security
