module Ri.Data.Instances.Hashable
where

import Ri.Prelude
import Ri.Data.Types
import Ri.Data.Instances.Generic
import qualified Net.IPv6 as B


instance Hashable Uri

instance Hashable Scheme

instance Hashable Hierarchy

instance Hashable Authority

instance Hashable UserInfo

instance Hashable User

instance Hashable Password

instance Hashable Host where
  hashWithSalt salt host =
    hashWithSalt salt $
    case host of
      NamedHost regName -> hashWithSalt 0 regName
      IpV4Host ip -> hashWithSalt 1 ip
      IpV6Host (B.IPv6 a b) -> (hashWithSalt (hashWithSalt 2 a) b)

instance Hashable RegName

instance Hashable DomainLabel

instance Hashable Port

instance Hashable Path

instance Hashable PathSegment

instance Hashable Query

instance Hashable Fragment

instance Hashable HttpUri

instance Hashable Security
