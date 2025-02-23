module Juvix.Compiler.Internal.Extra.Base where

import Data.Generics.Uniplate.Data hiding (holes)
import Data.HashMap.Strict qualified as HashMap
import Data.HashSet qualified as HashSet
import Juvix.Compiler.Internal.Data.LocalVars
import Juvix.Compiler.Internal.Extra.Clonable
import Juvix.Compiler.Internal.Language
import Juvix.Prelude

type Rename = HashMap VarName VarName

type Subs = HashMap VarName Expression

data ApplicationArg = ApplicationArg
  { _appArgIsImplicit :: IsImplicit,
    _appArg :: Expression
  }

makeLenses ''ApplicationArg

instance HasLoc ApplicationArg where
  getLoc = getLoc . (^. appArg)

class HasExpressions a where
  leafExpressions :: Traversal' a Expression

instance HasExpressions LambdaClause where
  leafExpressions f l = do
    _lambdaPatterns <- traverse (leafExpressions f) (l ^. lambdaPatterns)
    _lambdaBody <- leafExpressions f (l ^. lambdaBody)
    pure LambdaClause {..}

instance HasExpressions Lambda where
  leafExpressions f l = do
    _lambdaClauses <- traverse (leafExpressions f) (l ^. lambdaClauses)
    _lambdaType <- traverse (leafExpressions f) (l ^. lambdaType)
    pure Lambda {..}

instance HasExpressions Expression where
  leafExpressions f e = case e of
    ExpressionIden {} -> f e
    ExpressionApplication a -> ExpressionApplication <$> leafExpressions f a
    ExpressionFunction fun -> ExpressionFunction <$> leafExpressions f fun
    ExpressionSimpleLambda l -> ExpressionSimpleLambda <$> leafExpressions f l
    ExpressionLambda l -> ExpressionLambda <$> leafExpressions f l
    ExpressionLet l -> ExpressionLet <$> leafExpressions f l
    ExpressionCase c -> ExpressionCase <$> leafExpressions f c
    ExpressionLiteral {} -> f e
    ExpressionUniverse {} -> f e
    ExpressionHole {} -> f e
    ExpressionInstanceHole {} -> f e

instance HasExpressions ConstructorApp where
  leafExpressions f a = do
    let _constrAppConstructor = a ^. constrAppConstructor
    _constrAppType <- traverseOf _Just (leafExpressions f) (a ^. constrAppType)
    _constrAppParameters <- traverseOf each (leafExpressions f) (a ^. constrAppParameters)
    pure ConstructorApp {..}

instance HasExpressions PatternArg where
  leafExpressions f a = do
    let _patternArgIsImplicit = a ^. patternArgIsImplicit
        _patternArgName = a ^. patternArgName
    _patternArgPattern <- leafExpressions f (a ^. patternArgPattern)
    pure PatternArg {..}

instance HasExpressions Pattern where
  leafExpressions f p = case p of
    PatternVariable {} -> pure p
    PatternConstructorApp a -> PatternConstructorApp <$> leafExpressions f a
    PatternWildcardConstructor {} -> pure p

instance HasExpressions CaseBranch where
  leafExpressions f b = do
    _caseBranchPattern <- leafExpressions f (b ^. caseBranchPattern)
    _caseBranchExpression <- leafExpressions f (b ^. caseBranchExpression)
    pure CaseBranch {..}

instance HasExpressions Case where
  leafExpressions f l = do
    _caseBranches :: NonEmpty CaseBranch <- traverse (leafExpressions f) (l ^. caseBranches)
    _caseExpression <- leafExpressions f (l ^. caseExpression)
    _caseExpressionType <- traverse (leafExpressions f) (l ^. caseExpressionType)
    _caseExpressionWholeType <- traverse (leafExpressions f) (l ^. caseExpressionWholeType)
    pure Case {..}
    where
      _caseParens = l ^. caseParens

instance HasExpressions MutualBlock where
  leafExpressions f (MutualBlock defs) =
    MutualBlock <$> traverse (leafExpressions f) defs

instance HasExpressions MutualBlockLet where
  leafExpressions f (MutualBlockLet defs) =
    MutualBlockLet <$> traverse (leafExpressions f) defs

instance HasExpressions LetClause where
  leafExpressions f = \case
    LetFunDef d -> LetFunDef <$> leafExpressions f d
    LetMutualBlock b -> LetMutualBlock <$> leafExpressions f b

instance HasExpressions Let where
  leafExpressions f l = do
    _letClauses :: NonEmpty LetClause <- traverse (leafExpressions f) (l ^. letClauses)
    _letExpression <- leafExpressions f (l ^. letExpression)
    pure Let {..}

instance HasExpressions TypedExpression where
  leafExpressions f a = do
    _typedExpression <- leafExpressions f (a ^. typedExpression)
    _typedType <- leafExpressions f (a ^. typedType)
    pure TypedExpression {..}

instance HasExpressions SimpleBinder where
  leafExpressions f (SimpleBinder v ty) = do
    ty' <- leafExpressions f ty
    pure (SimpleBinder v ty')

instance HasExpressions SimpleLambda where
  leafExpressions f (SimpleLambda bi b) = do
    bi' <- leafExpressions f bi
    b' <- leafExpressions f b
    pure (SimpleLambda bi' b')

instance HasExpressions FunctionParameter where
  leafExpressions f FunctionParameter {..} = do
    ty' <- leafExpressions f _paramType
    pure
      FunctionParameter
        { _paramType = ty',
          _paramName,
          _paramImplicit
        }

instance HasExpressions Function where
  leafExpressions f (Function l r) = do
    l' <- leafExpressions f l
    r' <- leafExpressions f r
    pure (Function l' r')

instance HasExpressions ApplicationArg where
  leafExpressions f ApplicationArg {..} = do
    arg' <- leafExpressions f _appArg
    pure
      ApplicationArg
        { _appArg = arg',
          _appArgIsImplicit
        }

instance (HasExpressions a) => HasExpressions (Maybe a) where
  leafExpressions = _Just . leafExpressions

instance HasExpressions Application where
  leafExpressions f (Application l r i) = do
    l' <- leafExpressions f l
    r' <- leafExpressions f r
    pure (Application l' r' i)

-- | Prism
_ExpressionHole :: Traversal' Expression Hole
_ExpressionHole f e = case e of
  ExpressionHole h -> ExpressionHole <$> f h
  _ -> pure e

holes :: (HasExpressions a) => Traversal' a Hole
holes = leafExpressions . _ExpressionHole

hasHoles :: (HasExpressions a) => a -> Bool
hasHoles = has holes

subsInstanceHoles :: forall r a. (HasExpressions a, Member NameIdGen r) => HashMap InstanceHole Expression -> a -> Sem r a
subsInstanceHoles s = leafExpressions helper
  where
    helper :: Expression -> Sem r Expression
    helper e = case e of
      ExpressionInstanceHole h -> clone (fromMaybe e (s ^. at h))
      _ -> return e

subsHoles :: forall r a. (HasExpressions a, Member NameIdGen r) => HashMap Hole Expression -> a -> Sem r a
subsHoles s = leafExpressions helper
  where
    helper :: Expression -> Sem r Expression
    helper e = case e of
      ExpressionHole h -> clone (fromMaybe e (s ^. at h))
      _ -> return e

instance HasExpressions ArgInfo where
  leafExpressions f ArgInfo {..} = do
    d' <- traverse (leafExpressions f) _argInfoDefault
    return
      ArgInfo
        { _argInfoDefault = d',
          _argInfoName
        }

instance HasExpressions FunctionDef where
  leafExpressions f FunctionDef {..} = do
    body' <- leafExpressions f _funDefBody
    ty' <- leafExpressions f _funDefType
    infos' <- traverse (leafExpressions f) _funDefArgsInfo
    pure
      FunctionDef
        { _funDefBody = body',
          _funDefType = ty',
          _funDefArgsInfo = infos',
          _funDefTerminating,
          _funDefInstance,
          _funDefCoercion,
          _funDefName,
          _funDefBuiltin,
          _funDefPragmas
        }

instance HasExpressions MutualStatement where
  leafExpressions f = \case
    StatementFunction d -> StatementFunction <$> leafExpressions f d
    StatementInductive d -> StatementInductive <$> leafExpressions f d
    StatementAxiom d -> StatementAxiom <$> leafExpressions f d

instance HasExpressions AxiomDef where
  leafExpressions f AxiomDef {..} = do
    ty' <- leafExpressions f _axiomType
    pure
      AxiomDef
        { _axiomType = ty',
          _axiomName,
          _axiomBuiltin,
          _axiomPragmas
        }

instance HasExpressions InductiveParameter where
  leafExpressions _ param@InductiveParameter {} = do
    pure param

instance HasExpressions InductiveDef where
  leafExpressions f InductiveDef {..} = do
    params' <- traverse (leafExpressions f) _inductiveParameters
    constrs' <- traverse (leafExpressions f) _inductiveConstructors
    ty' <- leafExpressions f _inductiveType
    pure
      InductiveDef
        { _inductiveParameters = params',
          _inductiveConstructors = constrs',
          _inductiveType = ty',
          _inductiveName,
          _inductiveBuiltin,
          _inductivePositive,
          _inductiveTrait,
          _inductivePragmas
        }

instance HasExpressions ConstructorDef where
  leafExpressions f ConstructorDef {..} = do
    ty' <- leafExpressions f _inductiveConstructorType
    pure
      ConstructorDef
        { _inductiveConstructorType = ty',
          _inductiveConstructorName,
          _inductiveConstructorPragmas
        }

substituteIndParams :: forall r. (Member NameIdGen r) => [(InductiveParameter, Expression)] -> Expression -> Sem r Expression
substituteIndParams = substitutionE . HashMap.fromList . map (first (^. inductiveParamName))

typeAbstraction :: IsImplicit -> Name -> FunctionParameter
typeAbstraction i var = FunctionParameter (Just var) i (ExpressionUniverse (SmallUniverse (getLoc var)))

mkFunction :: Expression -> Expression -> Function
mkFunction a = Function (unnamedParameter a)

unnamedParameter' :: IsImplicit -> Expression -> FunctionParameter
unnamedParameter' impl ty =
  FunctionParameter
    { _paramName = Nothing,
      _paramImplicit = impl,
      _paramType = ty
    }

unnamedParameter :: Expression -> FunctionParameter
unnamedParameter = unnamedParameter' Explicit

singletonRename :: VarName -> VarName -> Rename
singletonRename = HashMap.singleton

renameKind :: NameKind -> [Name] -> Subs
renameKind k l = HashMap.fromList [(n, toExpression (set nameKind k n)) | n <- l]

renameToSubsE :: Rename -> Subs
renameToSubsE = fmap (ExpressionIden . IdenVar)

inductiveTypeVarsAssoc :: (Foldable f) => InductiveDef -> f a -> HashMap VarName a
inductiveTypeVarsAssoc def l
  | length vars < n = impossible
  | otherwise = HashMap.fromList (zip vars (toList l))
  where
    n = length l
    vars :: [VarName]
    vars = def ^.. inductiveParameters . each . inductiveParamName

substitutionApp :: (Maybe Name, Expression) -> Subs
substitutionApp (mv, ty) = case mv of
  Nothing -> mempty
  Just v -> HashMap.singleton v ty

localsToSubsE :: LocalVars -> Subs
localsToSubsE l = ExpressionIden . IdenVar <$> l ^. localTyMap

subsKind :: [Name] -> NameKind -> Subs
subsKind uids k =
  HashMap.fromList
    [ (s, toExpression s') | s <- uids, let s' = toExpression (set nameKind k s)
    ]

substitutionE :: forall r expr. (Member NameIdGen r, HasExpressions expr) => Subs -> expr -> Sem r expr
substitutionE m
  | null m = pure
  | otherwise = leafExpressions goLeaf
  where
    goLeaf :: Expression -> Sem r Expression
    goLeaf = \case
      ExpressionIden i -> goName (i ^. idenName)
      e -> return e
    goName :: Name -> Sem r Expression
    goName n =
      case HashMap.lookup n m of
        Just e -> clone e
        Nothing -> return (toExpression n)

smallUniverseE :: Interval -> Expression
smallUniverseE = ExpressionUniverse . SmallUniverse

-- | [a, b] c ==> a -> (b -> c)
foldFunType :: [FunctionParameter] -> Expression -> Expression
foldFunType l r = go l
  where
    go :: [FunctionParameter] -> Expression
    go = \case
      [] -> r
      arg : args -> ExpressionFunction (Function arg (go args))

foldFunTypeExplicit :: [Expression] -> Expression -> Expression
foldFunTypeExplicit = foldFunType . map unnamedParameter

viewConstructorType :: Expression -> ([Expression], Expression)
viewConstructorType = first (map (^. paramType)) . unfoldFunType

constructorArgs :: Expression -> [Expression]
constructorArgs = fst . viewConstructorType

unfoldLambdaClauses :: Expression -> Maybe (NonEmpty (NonEmpty PatternArg, Expression))
unfoldLambdaClauses t = do
  ExpressionLambda Lambda {..} <- return t
  let mkClause :: LambdaClause -> (NonEmpty PatternArg, Expression)
      mkClause LambdaClause {..} = first (appendList _lambdaPatterns) (unfoldLambda _lambdaBody)
  return (mkClause <$> _lambdaClauses)

-- Unfolds *single* clause lambdas
unfoldLambda :: Expression -> ([PatternArg], Expression)
unfoldLambda t = case t of
  ExpressionLambda Lambda {..}
    | LambdaClause {..} :| [] <- _lambdaClauses ->
        first (toList _lambdaPatterns <>) (unfoldLambda _lambdaBody)
  _ -> ([], t)

-- | a -> (b -> c)  ==> ([a, b], c)
unfoldFunType :: Expression -> ([FunctionParameter], Expression)
unfoldFunType t = case t of
  ExpressionFunction (Function l r) -> first (l :) (unfoldFunType r)
  _ -> ([], t)

unfoldTypeAbsType :: Expression -> ([VarName], Expression)
unfoldTypeAbsType t = case t of
  ExpressionFunction (Function (FunctionParameter (Just var) _ _) r) ->
    first (var :) (unfoldTypeAbsType r)
  _ -> ([], t)

foldExplicitApplication :: Expression -> [Expression] -> Expression
foldExplicitApplication f = foldApplication f . map (ApplicationArg Explicit)

foldApplication' :: Expression -> NonEmpty ApplicationArg -> Application
foldApplication' f (arg :| args) =
  let ApplicationArg i a = arg
   in go (Application f a i) args
  where
    go :: Application -> [ApplicationArg] -> Application
    go acc = \case
      [] -> acc
      ApplicationArg i a : as -> go (Application (ExpressionApplication acc) a i) as

foldApplication :: Expression -> [ApplicationArg] -> Expression
foldApplication f args = case nonEmpty args of
  Nothing -> f
  Just args' -> ExpressionApplication (foldApplication' f args')

unfoldApplication' :: Application -> (Expression, NonEmpty ApplicationArg)
unfoldApplication' (Application l' r' i') = second (|: (ApplicationArg i' r')) (unfoldExpressionApp l')

-- TODO make it tail recursive
unfoldExpressionApp :: Expression -> (Expression, [ApplicationArg])
unfoldExpressionApp = \case
  ExpressionApplication (Application l r i) ->
    second (`snoc` ApplicationArg i r) (unfoldExpressionApp l)
  e -> (e, [])

unfoldApplication :: Application -> (Expression, NonEmpty Expression)
unfoldApplication = fmap (fmap (^. appArg)) . unfoldApplication'

-- | A fold over all transitive children, including self
patternCosmos :: SimpleFold Pattern Pattern
patternCosmos f p = case p of
  PatternVariable {} -> f p
  PatternWildcardConstructor {} -> f p
  PatternConstructorApp ConstructorApp {..} ->
    f p *> do
      args' <- traverse (traverseOf patternArgPattern (patternCosmos f)) _constrAppParameters
      pure $
        PatternConstructorApp
          ConstructorApp
            { _constrAppParameters = args',
              _constrAppConstructor,
              _constrAppType
            }

patternArgNameFold :: SimpleFold (Maybe Name) Pattern
patternArgNameFold f = \case
  Nothing -> mempty
  Just n -> Const (getConst (f (PatternVariable n)))

-- | A fold over all transitive children, including self
patternArgCosmos :: SimpleFold PatternArg Pattern
patternArgCosmos f p = do
  _patternArgPattern <- patternCosmos f (p ^. patternArgPattern)
  _patternArgName <- patternArgNameFold f (p ^. patternArgName)
  pure PatternArg {..}
  where
    _patternArgIsImplicit = p ^. patternArgIsImplicit

-- | A fold over all transitive children, excluding self
patternSubCosmos :: SimpleFold Pattern Pattern
patternSubCosmos f p = case p of
  PatternVariable {} -> pure p
  PatternWildcardConstructor {} -> pure p
  PatternConstructorApp ConstructorApp {..} -> do
    args' <- traverse (patternArgCosmos f) _constrAppParameters
    pure $
      PatternConstructorApp
        ConstructorApp
          { _constrAppParameters = args',
            _constrAppConstructor,
            _constrAppType
          }

viewAppArgAsPattern :: ApplicationArg -> Maybe PatternArg
viewAppArgAsPattern a = do
  p' <- viewExpressionAsPattern (a ^. appArg)
  return
    ( PatternArg
        { _patternArgIsImplicit = a ^. appArgIsImplicit,
          _patternArgName = Nothing,
          _patternArgPattern = p'
        }
    )

viewApp :: Expression -> (Expression, [ApplicationArg])
viewApp e =
  case e of
    ExpressionApplication (Application l r i) ->
      second (`snoc` ApplicationArg i r) (viewApp l)
    _ -> (e, [])

viewExpressionAsPattern :: Expression -> Maybe Pattern
viewExpressionAsPattern e = case viewApp e of
  (f, args)
    | Just c <- getConstructor f -> do
        args' <- mapM viewAppArgAsPattern args
        Just $ PatternConstructorApp (ConstructorApp c args' Nothing)
  (f, [])
    | Just v <- getVariable f -> Just (PatternVariable v)
  _ -> Nothing
  where
    getConstructor :: Expression -> Maybe ConstructorName
    getConstructor f = case f of
      ExpressionIden (IdenConstructor n) -> Just n
      _ -> Nothing
    getVariable :: Expression -> Maybe VarName
    getVariable f = case f of
      ExpressionIden (IdenVar n) -> Just n
      _ -> Nothing

class IsExpression a where
  toExpression :: a -> Expression

instance IsExpression Iden where
  toExpression = ExpressionIden

instance IsExpression Expression where
  toExpression = id

instance IsExpression Hole where
  toExpression = ExpressionHole

instance IsExpression Name where
  toExpression n = ExpressionIden (mkIden n)
    where
      mkIden = case n ^. nameKind of
        KNameConstructor -> IdenConstructor
        KNameInductive -> IdenInductive
        KNameFunction -> IdenFunction
        KNameAxiom -> IdenAxiom
        KNameLocal -> IdenVar
        KNameLocalModule -> impossible
        KNameTopModule -> impossible
        KNameFixity -> impossible
        KNameAlias -> impossible

instance IsExpression SmallUniverse where
  toExpression = ExpressionUniverse

instance IsExpression Application where
  toExpression = ExpressionApplication

instance IsExpression Function where
  toExpression = ExpressionFunction

instance IsExpression ConstructorApp where
  toExpression (ConstructorApp c args _) =
    foldApplication (toExpression c) (map toApplicationArg args)

instance IsExpression WildcardConstructor where
  toExpression = toExpression . (^. wildcardConstructor)

toApplicationArg :: PatternArg -> ApplicationArg
toApplicationArg p =
  set appArgIsImplicit (p ^. patternArgIsImplicit) (helper (p ^. patternArgPattern))
  where
    helper :: Pattern -> ApplicationArg
    helper = \case
      PatternVariable v -> ApplicationArg Explicit (toExpression v)
      PatternConstructorApp a -> ApplicationArg Explicit (toExpression a)
      PatternWildcardConstructor a -> ApplicationArg Explicit (toExpression a)

expressionArrow :: (IsExpression a, IsExpression b) => IsImplicit -> a -> b -> Expression
expressionArrow isImpl a b =
  ExpressionFunction
    ( Function
        ( FunctionParameter
            { _paramName = Nothing,
              _paramImplicit = isImpl,
              _paramType = toExpression a
            }
        )
        (toExpression b)
    )

infixr 0 <>-->

(<>-->) :: (IsExpression a, IsExpression b) => a -> b -> Expression
(<>-->) = expressionArrow Implicit

infixr 0 -->

(-->) :: (IsExpression a, IsExpression b) => a -> b -> Expression
(-->) = expressionArrow Explicit

infix 4 ===

(===) :: (IsExpression a, IsExpression b) => a -> b -> Bool
a === b = (toExpression a ==% toExpression b) mempty

leftEq :: (IsExpression a, IsExpression b) => a -> b -> HashSet Name -> Bool
leftEq a b free =
  isRight
    . run
    . runError @Text
    . runReader free
    . evalState (mempty @(HashMap Name Name))
    $ matchExpressions (toExpression a) (toExpression b)

clauseLhsAsExpression :: Name -> [PatternArg] -> Expression
clauseLhsAsExpression clName pats =
  foldApplication (toExpression clName) (map toApplicationArg pats)

infix 4 ==%

(==%) :: (IsExpression a, IsExpression b) => a -> b -> HashSet Name -> Bool
(==%) a b free = leftEq a b free || leftEq b a free

infixl 9 @@?

(@@?) :: (IsExpression a, IsExpression b) => a -> b -> IsImplicit -> Expression
a @@? b = toExpression . Application (toExpression a) (toExpression b)

infixl 9 @@

(@@) :: (IsExpression a, IsExpression b) => a -> b -> Expression
a @@ b = toExpression (Application (toExpression a) (toExpression b) Explicit)

freshFunVar :: (Member NameIdGen r) => Interval -> Text -> Sem r VarName
freshFunVar i n = set nameKind KNameFunction <$> freshVar i n

freshVar :: (Member NameIdGen r) => Interval -> Text -> Sem r VarName
freshVar _nameLoc n = do
  uid <- freshNameId
  return
    Name
      { _nameId = uid,
        _nameText = n,
        _nameKind = KNameLocal,
        _namePretty = n,
        _nameFixity = Nothing,
        _nameLoc
      }

genWildcard :: forall r'. (Members '[NameIdGen] r') => Interval -> IsImplicit -> Sem r' PatternArg
genWildcard loc impl = do
  var <- varFromWildcard (Wildcard loc)
  return (PatternArg impl Nothing (PatternVariable var))

freshInstanceHole :: (Members '[NameIdGen] r) => Interval -> Sem r InstanceHole
freshInstanceHole l = mkInstanceHole l <$> freshNameId

freshHole :: (Members '[NameIdGen] r) => Interval -> Sem r Hole
freshHole l = mkHole l <$> freshNameId

mkFreshHole :: (Members '[NameIdGen] r) => Interval -> Sem r Expression
mkFreshHole l = ExpressionHole <$> freshHole l

matchExpressions ::
  forall r.
  (Members '[State (HashMap Name Name), Reader (HashSet VarName), Error Text] r) =>
  Expression ->
  Expression ->
  Sem r ()
matchExpressions = go
  where
    -- Soft free vars are allowed to be matched
    isSoftFreeVar :: VarName -> Sem r Bool
    isSoftFreeVar = asks . HashSet.member
    go :: Expression -> Expression -> Sem r ()
    go a b = case (a, b) of
      (ExpressionIden ia, ExpressionIden ib) -> case (ia, ib) of
        (IdenVar va, IdenVar vb) -> do
          addIfFreeVar va vb
          addIfFreeVar vb va
          unlessM (matchVars va vb) err
        (_, _) -> unless (ia == ib) err
      (ExpressionIden (IdenVar va), ExpressionHole h) -> goHole va h
      (ExpressionHole h, ExpressionIden (IdenVar vb)) -> goHole vb h
      (ExpressionIden {}, _) -> err
      (_, ExpressionIden {}) -> err
      (ExpressionApplication ia, ExpressionApplication ib) ->
        goApp ia ib
      (ExpressionApplication {}, _) -> err
      (_, ExpressionApplication {}) -> err
      (ExpressionLambda ia, ExpressionLambda ib) ->
        goLambda ia ib
      (ExpressionLambda {}, _) -> err
      (_, ExpressionLambda {}) -> err
      (ExpressionCase {}, ExpressionCase {}) -> error "not implemented"
      (ExpressionCase {}, _) -> err
      (_, ExpressionCase {}) -> err
      (ExpressionUniverse ia, ExpressionUniverse ib) ->
        unless (ia == ib) err
      (ExpressionUniverse {}, _) -> err
      (_, ExpressionUniverse {}) -> err
      (ExpressionFunction ia, ExpressionFunction ib) ->
        goFunction ia ib
      (ExpressionFunction {}, _) -> err
      (_, ExpressionFunction {}) -> err
      (ExpressionSimpleLambda {}, ExpressionSimpleLambda {}) -> error "not implemented"
      (ExpressionSimpleLambda {}, _) -> err
      (_, ExpressionSimpleLambda {}) -> err
      (ExpressionLiteral ia, ExpressionLiteral ib) ->
        unless (ia == ib) err
      (ExpressionLiteral {}, _) -> err
      (_, ExpressionLiteral {}) -> err
      (ExpressionLet {}, ExpressionLet {}) -> error "not implemented"
      (_, ExpressionLet {}) -> err
      (ExpressionLet {}, _) -> err
      (ExpressionHole _, ExpressionHole _) -> return ()
      (ExpressionInstanceHole _, ExpressionInstanceHole _) -> return ()
      (_, ExpressionInstanceHole {}) -> err
      (ExpressionInstanceHole {}, _) -> err

    err :: Sem r a
    err = throw @Text "Expression mismatch"

    matchVars :: Name -> Name -> Sem r Bool
    matchVars va vb = do
      let eq = va == vb
      uni <- (== Just vb) <$> gets @(HashMap Name Name) (^. at va)
      return (uni || eq)

    goHole :: Name -> Hole -> Sem r ()
    goHole var h = do
      whenM (gets @(HashMap Name Name) (HashMap.member var)) err
      let vh = varFromHole h
      addName var vh

    addIfFreeVar :: VarName -> VarName -> Sem r ()
    addIfFreeVar va vb = whenM (isSoftFreeVar va) (addName va vb)

    goLambda :: Lambda -> Lambda -> Sem r ()
    goLambda = error "TODO not implemented yet"

    goApp :: Application -> Application -> Sem r ()
    goApp (Application al ar aim) (Application bl br bim) = do
      unless (aim == bim) err
      go al bl
      go ar br

    goFunction :: Function -> Function -> Sem r ()
    goFunction (Function al ar) (Function bl br) = do
      matchFunctionParameter al bl
      matchExpressions ar br

addName :: (Member (State (HashMap Name Name)) r) => Name -> Name -> Sem r ()
addName na nb = modify (HashMap.insert na nb)

matchFunctionParameter ::
  forall r.
  (Members '[State (HashMap Name Name), Reader (HashSet VarName), Error Text] r) =>
  FunctionParameter ->
  FunctionParameter ->
  Sem r ()
matchFunctionParameter pa pb = do
  goParamName (pa ^. paramName) (pb ^. paramName)
  goParamImplicit (pa ^. paramImplicit) (pb ^. paramImplicit)
  goParamType (pa ^. paramType) (pb ^. paramType)
  where
    goParamType :: Expression -> Expression -> Sem r ()
    goParamType ua ub = matchExpressions ua ub
    goParamImplicit :: IsImplicit -> IsImplicit -> Sem r ()
    goParamImplicit ua ub = unless (ua == ub) (throw @Text "implicit mismatch")
    goParamName :: Maybe VarName -> Maybe VarName -> Sem r ()
    goParamName (Just va) (Just vb) = addName va vb
    goParamName _ _ = return ()

isSmallUniverse' :: Expression -> Bool
isSmallUniverse' = \case
  ExpressionUniverse {} -> True
  _ -> False

allTypeSignatures :: (Data a) => a -> [Expression]
allTypeSignatures a =
  [f ^. funDefType | f@FunctionDef {} <- universeBi a]
    <> [f ^. axiomType | f@AxiomDef {} <- universeBi a]
    <> [f ^. inductiveType | f@InductiveDef {} <- universeBi a]

explicitPatternArg :: Pattern -> PatternArg
explicitPatternArg _patternArgPattern =
  PatternArg
    { _patternArgName = Nothing,
      _patternArgIsImplicit = Explicit,
      _patternArgPattern
    }

simpleFunDef :: Name -> Expression -> Expression -> FunctionDef
simpleFunDef funName ty body =
  FunctionDef
    { _funDefName = funName,
      _funDefType = ty,
      _funDefCoercion = False,
      _funDefInstance = False,
      _funDefPragmas = mempty,
      _funDefArgsInfo = mempty,
      _funDefTerminating = False,
      _funDefBuiltin = Nothing,
      _funDefBody = body
    }
