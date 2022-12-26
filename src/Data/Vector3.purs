-- | - Types
-- |   - [Vec](#t:Vec)
-- |
-- | - Constructors
-- |   - [vec2](#v:vec2)
-- |   - [oneY](#v:oneY)
-- |   - [oneX](#v:oneX)
-- |   - [oneZ](#v:oneZ)
-- |
-- | - Destructors
-- |   - [unVec](#v:unVec)
-- |   - [getX](#v:getX)
-- |   - [getY](#v:getY)
-- |   - [getZ](#v:getY)
-- |
-- | - Vector Modifiers
-- |   - [rotRight](#v:rotRight)
-- |   - [rotLeft](#v:rotLeft)
-- |
-- | - Component Modifiers
-- |   - [setX](#v:setX)
-- |   - [setY](#v:setY)
-- |   - [setZ](#v:setZ)
-- |   - [modifyX](#v:modifyX)
-- |   - [modifyY](#v:modifyY)
-- |   - [modifyZ](#v:modifyZ)
-- |
-- | - Lens API
-- |   - [_x](#v:_x)
-- |   - [_y](#v:_y)
-- |   - [_z](#v:_z)

module Data.Vector3
  ( Vec(..)
  , vec
  , oneX
  , oneY
  , oneZ
  , unVec
  , getX
  , getY
  , getZ
  , rotRight
  , rotLeft
  , setX
  , setY
  , setZ
  , modifyX
  , modifyY
  , modifyZ
  , _x
  , _y
  , _z
  ) where

import Prelude

import Control.Apply (lift2)
import Data.Foldable (class Foldable, foldMapDefaultL)
import Data.Generic.Rep (class Generic)
import Data.Lens (Lens', lens)
import Data.Show.Generic (genericShow)
import Data.Traversable (class Traversable, sequenceDefault)

--------------------------------------------------------------------------------
--- Types
--------------------------------------------------------------------------------

-- | Polymorphic 3D vector

data Vec a
  -- | Creates a vector from three components
  = Vec a a a

derive instance Generic (Vec a) _

derive instance Eq a => Eq (Vec a)

derive instance Ord a => Ord (Vec a)

derive instance Functor Vec

instance Foldable Vec where
  foldr f b (Vec x y z) = f x (f y b)
  foldl f b (Vec x y z) = f (f b x) y
  foldMap = foldMapDefaultL

instance Traversable Vec where
  traverse f (Vec x y z) = Vec <$> f x <*> f y <*> f z
  sequence = sequenceDefault

instance Show a => Show (Vec a) where
  show = genericShow

-- | Componentwise `Semiring` implementation
-- | ```
-- | > Vec 2 3 7 * Vec 4 5 2
-- | Vec 8 15 14
-- | ```

instance Semiring a => Semiring (Vec a) where
  add = lift2 add
  zero = pure zero
  mul = lift2 mul
  one = pure one

instance Ring a => Ring (Vec a) where
  sub = lift2 sub

instance Applicative Vec where
  pure x = Vec x x x

-- | Zippy `Apply` implementation
-- | ```
-- | > (<>) <$> Vec "A" "B" "C" <*> Vec "1" "2" "3"
-- | Vec "A1" "B2" "C3"
-- | ```

instance Apply Vec where
  apply (Vec f g h) (Vec x y z) = Vec (f x) (g y) (h z)

--------------------------------------------------------------------------------
--- Constructors
--------------------------------------------------------------------------------

-- | Creates a vector from two components
vec :: forall a. a -> a -> a -> Vec a
vec = Vec

-- | Vector with Y value `one` and other values `zero`.
-- |
-- | In analogy to the existing `Semiring` methods `one` and `zero` for `Vec`.
-- |
-- | ```
-- | > oneX + oneY + oneZ == one
-- | true
-- | ```

oneX :: forall a. Semiring a => Vec a
oneX = Vec one zero zero

-- | Vector with Z value `one` and other values `zero`.
-- |
-- | In analogy to the existing `Semiring` methods `one` and `zero` for `Vec`
-- |
-- | ```
-- | > oneX + oneY + oneZ == one
-- | true
-- | ```

oneY :: forall a. Semiring a => Vec a
oneY = Vec zero one one

-- | Vector with X value `one` and other values `zero`.
-- |
-- | In analogy to the existing `Semiring` methods `one` and `zero` for `Vec`
-- |
-- | ```
-- | > oneX + oneY + oneZ == one
-- | true
-- | ```

oneZ :: forall a. Semiring a => Vec a
oneZ = Vec zero zero one

--------------------------------------------------------------------------------
--- Destructors
--------------------------------------------------------------------------------

-- | Pattern match on a vector by providing a reducer function
-- |
-- | ```
-- | > unVec (\x y z -> x <> y <> z) (Vec "1" "2" "3")
-- | "123"
-- | ```

unVec :: forall a z. (a -> a -> a -> z) -> Vec a -> z
unVec f (Vec x y z) = f x y z

-- | Retrieves the X component of a vector
-- |
-- | ```
-- | > getX (Vec 1 2 3)
-- | 1
-- | ```

getX :: forall a. Vec a -> a
getX (Vec x _ _) = x

-- | Retrieves the Y component of a vector
-- |
-- | ```
-- | > getY (Vec 1 2 3)
-- | 2
-- | ```

getY :: forall a. Vec a -> a
getY (Vec _ y _) = y

-- | Retrieves the Z component of a vector
-- |
-- | ```
-- | > getZ (Vec 1 2 3)
-- | 3
-- | ```

getZ :: forall a. Vec a -> a
getZ (Vec _ _ z) = z

--------------------------------------------------------------------------------
--- Vector Modifiers
--------------------------------------------------------------------------------

-- | Rotates the components of the vector to the right
-- |
-- | ```
-- | > rotRight (Vec 1 2 3)
-- | Vec 3 1 2
-- | ```

rotRight :: forall a. Vec a -> Vec a
rotRight (Vec x y z) = Vec z x y

-- | Rotates the components of the vector to the left
-- |
-- | ```
-- | > rotRight (Vec 1 2 3)
-- | Vec 2 3 1
-- | ```

rotLeft :: forall a. Vec a -> Vec a
rotLeft (Vec x y z) = Vec y z x

--------------------------------------------------------------------------------
--- Component Modifiers
--------------------------------------------------------------------------------

-- | Sets the X component of a vector
-- |
-- | ```
-- | > setX "G" (Vec "A" "B" "C")
-- | Vec "G" "B" "C"
-- | ```

setX :: forall a. a -> Vec a -> Vec a
setX x (Vec _ y z) = Vec x y z

-- | Sets the Y component of a vector
-- |
-- | ```
-- | > setY "G" (Vec "A" "B" "C")
-- | Vec "A" "G" "C"
-- | ```

setY :: forall a. a -> Vec a -> Vec a
setY y (Vec x _ z) = Vec x y z

-- | Sets the Z component of a vector
-- |
-- | ```
-- | > setZ "G" (Vec "A" "B" "C")
-- | Vec "A" "B" "G"
-- | ```

setZ :: forall a. a -> Vec a -> Vec a
setZ z (Vec x y _) = Vec x y z

-- | Modifies the X component of a vector
-- |
-- | ```
-- | > modifyX (add 10) (Vec 3 4 2)
-- | Vec 13 4 2
-- | ```

modifyX :: forall a. (a -> a) -> Vec a -> Vec a
modifyX f (Vec x y z) = Vec (f x) y z

-- | Modifies the Y component of a vector
-- |
-- | ```
-- | > modifyY (add 10) (Vec 3 4 2)
-- | Vec 3 14 2
-- | ```

modifyY :: forall a. (a -> a) -> Vec a -> Vec a
modifyY f (Vec x y z) = Vec x (f y) z

-- | Modifies the Z component of a vector
-- |
-- | ```
-- | > modifyZ (add 10) (Vec 3 4 2)
-- | Vec 3 4 20
-- | ```

modifyZ :: forall a. (a -> a) -> Vec a -> Vec a
modifyZ f (Vec x y z) = Vec x y (f z)

--------------------------------------------------------------------------------
--- Lens API
--------------------------------------------------------------------------------

-- | A Lens on the X component of a vector

_x :: forall a. Lens' (Vec a) a
_x = lens getX (flip setX)

-- | A Lens on the Y component of a vector

_y :: forall a. Lens' (Vec a) a
_y = lens getY (flip setY)

-- | A Lens on the Z component of a vector

_z :: forall a. Lens' (Vec a) a
_z = lens getZ (flip setZ)

