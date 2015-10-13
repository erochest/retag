module Retag.Types where


import qualified Data.Set as S


data TagStack a
    = TagStack
    { stack          :: [a]
    , imbalancedTags :: S.Set a
    } deriving (Eq, Show)
