module Juvix.Compiler.Core.Transformation.DisambiguateNames where

import Data.HashSet qualified as HashSet
import Data.List.NonEmpty qualified as NonEmpty
import Juvix.Compiler.Core.Data.BinderList qualified as BL
import Juvix.Compiler.Core.Extra
import Juvix.Compiler.Core.Info.NameInfo (setInfoName)
import Juvix.Compiler.Core.Transformation.Base

disambiguateNodeNames' :: (BinderList Binder -> Text -> Text) -> Module -> Node -> Node
disambiguateNodeNames' disambiguate md = dmapL go
  where
    go :: BinderList Binder -> Node -> Node
    go bl node = case node of
      NVar Var {..} ->
        mkVar (setInfoName (BL.lookup _varIndex bl ^. binderName) _varInfo) _varIndex
      NIdt Ident {..} ->
        mkIdent (setInfoName (identName md _identSymbol) _identInfo) _identSymbol
      NLam lam ->
        NLam (over lambdaBinder (over binderName (disambiguate bl)) lam)
      NLet lt ->
        NLet (over letItem (over letItemBinder (over binderName (disambiguate bl))) lt)
      NRec lt ->
        NRec
          ( set
              letRecValues
              ( NonEmpty.fromList $
                  zipWithExact
                    (set letItemBinder)
                    (disambiguateBinders bl (map (^. letItemBinder) vs))
                    vs
              )
              lt
          )
        where
          vs = toList (lt ^. letRecValues)
      NCase c ->
        NCase (over caseBranches (map (over caseBranchBinders (disambiguateBinders bl))) c)
      NMatch m ->
        NMatch (over matchBranches (map (over matchBranchPatterns (NonEmpty.fromList . snd . disambiguatePatterns bl . toList))) m)
      NTyp TypeConstr {..} ->
        mkTypeConstr (setInfoName (typeName md _typeConstrSymbol) _typeConstrInfo) _typeConstrSymbol _typeConstrArgs
      NPi pi
        | varOccurs 0 (pi ^. piBody) ->
            NPi (over piBinder (over binderName (disambiguate bl)) pi)
      _ -> node

    disambiguateBinders :: BinderList Binder -> [Binder] -> [Binder]
    disambiguateBinders bl = \case
      [] -> []
      b : bs' -> b' : disambiguateBinders (BL.cons b' bl) bs'
        where
          b' = over binderName (disambiguate bl) b

    disambiguatePatterns :: BinderList Binder -> [Pattern] -> (BinderList Binder, [Pattern])
    disambiguatePatterns bl = \case
      [] -> (bl, [])
      pat : pats' -> case pat of
        PatWildcard w -> second (PatWildcard w' :) (disambiguatePatterns (BL.cons b' bl) pats')
          where
            b' = over binderName (disambiguate bl) (w ^. patternWildcardBinder)
            w' = set patternWildcardBinder b' w
        PatConstr c -> second (pat' :) (disambiguatePatterns bl' pats')
          where
            b' = over binderName (disambiguate bl) (c ^. patternConstrBinder)
            (bl', args') = disambiguatePatterns (BL.cons b' bl) (c ^. patternConstrArgs)
            pat' = PatConstr $ set patternConstrBinder b' $ set patternConstrArgs args' c

disambiguateNodeNames :: Module -> Node -> Node
disambiguateNodeNames md = disambiguateNodeNames' disambiguate md
  where
    disambiguate :: BinderList Binder -> Text -> Text
    disambiguate bl name
      | name == "?" || name == "" || name == "_" =
          disambiguate bl "_X"
      | elem name (map (^. binderName) (toList bl))
          || HashSet.member name names =
          disambiguate bl (prime name)
      | otherwise =
          name

    names :: HashSet Text
    names = identNames md

setArgNames :: Module -> Symbol -> Node -> Node
setArgNames md sym node = reLambdas lhs' body
  where
    (lhs, body) = unfoldLambdas node
    ii = lookupIdentifierInfo md sym
    lhs' =
      zipWith
        (\l mn -> over lambdaLhsBinder (over binderName (`fromMaybe` mn)) l)
        lhs
        (ii ^. identifierArgNames ++ repeat Nothing)

disambiguateNames :: Module -> Module
disambiguateNames md =
  let md' = mapT (setArgNames md) md
   in mapAllNodes (disambiguateNodeNames md') md'

disambiguateNames' :: InfoTable -> InfoTable
disambiguateNames' = withInfoTable disambiguateNames
