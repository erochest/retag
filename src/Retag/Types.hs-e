{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric      #-}


module Retag.Types where


import           Data.Data
import qualified Data.Set     as S
import qualified Data.Text    as T
import           GHC.Generics


data Actions
    = Report
    | DeNest
    { denestInput   :: !FilePath
    , denestOutput  :: !FilePath
    , denestTagName :: !T.Text
    }
    | CloseTag
    { closeTagInput  :: !FilePath
    , closeTagOutput :: !FilePath
    , closeTagName   :: !T.Text
    } deriving (Show, Eq, Data, Typeable, Generic)

data TagStack a
    = TagStack
    { stack          :: [a]
    , imbalancedTags :: S.Set a
    } deriving (Eq, Show)
