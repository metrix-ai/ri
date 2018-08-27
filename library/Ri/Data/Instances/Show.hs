module Ri.Data.Instances.Show
where

import Ri.Prelude
import Ri.Data.Types
import qualified Ri.Rendering.Text.Internal as A
import qualified Data.Text as B


instance Show Uri where
  show =
    B.unpack . A.iri

instance Show HttpUri where
  show =
    B.unpack . A.httpIri

deriving instance Show Scheme

deriving instance Show Hierarchy

deriving instance Show Authority

deriving instance Show UserInfo

deriving instance Show User

deriving instance Show Password

deriving instance Show Host

deriving instance Show RegName

deriving instance Show DomainLabel

deriving instance Show Port

deriving instance Show Path

deriving instance Show PathSegment

deriving instance Show Query

deriving instance Show Fragment

deriving instance Show Security

