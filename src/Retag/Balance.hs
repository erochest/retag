{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}


module Retag.Balance where


import           Conduit
import qualified Data.ByteString       as B
import qualified Data.List             as L
import qualified Data.Set              as S
import qualified Data.Text             as T
import           Data.XML.Types
import           Text.HTML.TagSoup
import           Text.XML.Stream.Parse

import           Debug.Trace

import           Retag.Types


balanceReport :: MonadThrow m => Consumer B.ByteString m (TagStack Name)
balanceReport = decodeUtf8C
                =$= parseText' def
                =$= foldlC trackBalanced (TagStack [] S.empty)

trackBalanced :: TagStack Name -> Event -> TagStack Name

trackBalanced ts@(TagStack s@(top:_) _) (EventContent c)
    | top == "head" = trace (indent s ++ "TITLE " ++ contentStr c) ts
trackBalanced TagStack{..} (EventBeginElement name _) =
    trace (indent stack ++ "START " ++ nameStr name) $
          TagStack (name:stack) imbalancedTags
trackBalanced (TagStack (top:rest) imb) e@(EventEndElement name)
    | top == name = trace (indent rest ++ "END " ++ nameStr name) $
                    TagStack rest imb
    | otherwise   = trace (  indent rest ++ "IMB " ++ nameStr top ++ "/"
                          ++ nameStr name) $
                    trackBalanced (TagStack rest $ top `S.insert` imb) e
trackBalanced ts@(TagStack [] _) (EventEndElement name) =
    trace ("BANG " ++ nameStr name) $
          ts

trackBalanced ts EventBeginDocument  = ts
trackBalanced ts EventEndDocument    = ts
trackBalanced ts EventBeginDoctype{} = ts
trackBalanced ts EventEndDoctype     = ts
trackBalanced ts EventInstruction{}  = ts
trackBalanced ts EventContent{}      = ts
trackBalanced ts EventComment{}      = ts
trackBalanced ts EventCDATA{}        = ts

indent :: [x] -> String
indent xs = T.unpack $ T.replicate (length xs) " "

nameStr :: Name -> String
nameStr = T.unpack . nameLocalName

contentStr :: Content -> String
contentStr (ContentText t)   = T.unpack t
contentStr (ContentEntity e) = T.unpack $ T.concat ["&", e, ";"]

trackTag :: TagStack T.Text -> Tag T.Text -> TagStack T.Text

trackTag ts@(TagStack s@(top:_) _) (TagText c)
    | top == "head" = trace (indent s ++ "TITLE " ++ T.unpack c) ts
trackTag TagStack{..} (TagOpen name _) =
    trace (indent stack ++ "START " ++ T.unpack name) $
          TagStack (name:stack) imbalancedTags
trackTag (TagStack (top:rest) imb) e@(TagClose name)
    | top == name = trace (indent rest ++ "END " ++ T.unpack name) $
                    TagStack rest imb
    | otherwise   = trace (  indent rest ++ "IMB " ++ T.unpack top ++ "/"
                          ++ T.unpack name) $
                    trackTag (TagStack rest $ top `S.insert` imb) e
trackTag ts@(TagStack [] _) (TagClose name) =
    trace ("BANG " ++ T.unpack name) $
          ts

trackTag ts TagText{}     = ts
trackTag ts TagComment{}  = ts
trackTag ts TagWarning{}  = ts
trackTag ts TagPosition{} = ts


denestTag :: T.Text -> [T.Text] -> Tag T.Text -> ([T.Text], [Tag T.Text])

denestTag denest (top:rest) t@(TagOpen name _)
    | denest == name && denest == top = (name:rest, [TagClose top, t])
    | denest == name && denest `L.elem` rest =
        (TagClose top :) <$> denestTag denest rest t
denestTag _ stack t@(TagOpen name _) = (name:stack, [t])

denestTag denest (top:rest) t@(TagClose name)
    | top == name = (rest, [t])
    | otherwise   = (TagClose top :) <$> denestTag denest rest t
denestTag _ [] t@(TagClose _) = ([], [t])

denestTag _ stack t@(TagText{})     = (stack, [t])
denestTag _ stack t@(TagComment{})  = (stack, [t])
denestTag _ stack t@(TagWarning{})  = (stack, [t])
denestTag _ stack t@(TagPosition{}) = (stack, [t])
