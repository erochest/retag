module Retag.Types where


import qualified Data.Set       as S
import           Data.XML.Types


data TagStack
    = TagStack
    { stack          :: [Name]
    , imbalancedTags :: S.Set Name
    } deriving (Eq, Show)
