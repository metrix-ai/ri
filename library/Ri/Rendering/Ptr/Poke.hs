module Ri.Rendering.Ptr.Poke
where

import Ri.Prelude
import Ri.Data
import Ptr.Poke


{-# NOINLINE urlEncodedByte #-}
urlEncodedByte :: Poke Word8
urlEncodedByte =
  divide (\byte -> ('%', byte))
    asciiChar
    (divide (flip divMod 16) asciiHexDigit asciiHexDigit)
