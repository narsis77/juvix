module Juvix.Compiler.Store.Scoped.Language
  ( module Juvix.Compiler.Store.Scoped.Data.SymbolEntry,
    module Juvix.Compiler.Store.Scoped.Language,
  )
where

import Data.HashSet qualified as HashSet
import Juvix.Compiler.Concrete.Data.Name qualified as C
import Juvix.Compiler.Concrete.Data.ScopedName qualified as S
import Juvix.Compiler.Store.Scoped.Data.InfoTable
import Juvix.Compiler.Store.Scoped.Data.SymbolEntry
import Juvix.Extra.Serialize
import Juvix.Prelude

-- | Symbols that a module exports
data ExportInfo = ExportInfo
  { _exportSymbols :: HashMap C.Symbol PreSymbolEntry,
    _exportModuleSymbols :: HashMap C.Symbol ModuleSymbolEntry,
    _exportFixitySymbols :: HashMap C.Symbol FixitySymbolEntry
  }
  deriving stock (Show, Eq, Ord, Generic)

instance Serialize ExportInfo

instance NFData ExportInfo

data ScopedModule = ScopedModule
  { _scopedModuleId :: ModuleId,
    _scopedModulePath :: S.TopModulePath,
    _scopedModuleName :: S.Name,
    _scopedModuleFilePath :: Path Abs File,
    _scopedModuleExportInfo :: ExportInfo,
    _scopedModuleLocalModules :: HashMap S.NameId ScopedModule,
    _scopedModuleInfoTable :: InfoTable
  }
  deriving stock (Generic)

instance Serialize ScopedModule

instance NFData ScopedModule

newtype ScopedModuleTable = ScopedModuleTable
  { _scopedModuleTable :: HashMap C.TopModulePath ScopedModule
  }

makeLenses ''ExportInfo
makeLenses ''ScopedModule
makeLenses ''ScopedModuleTable

exportAllNames :: SimpleFold ExportInfo S.Name
exportAllNames =
  exportSymbols
    . each
    . preSymbolName
    <> exportModuleSymbols
      . each
      . moduleEntry
    <> exportFixitySymbols
      . each
      . fixityEntry

createExportsTable :: ExportInfo -> HashSet NameId
createExportsTable = HashSet.fromList . (^.. exportAllNames . S.nameId)

getScopedModuleNameId :: ScopedModule -> S.NameId
getScopedModuleNameId m = m ^. scopedModuleName . S.nameId

getCombinedInfoTable :: ScopedModule -> InfoTable
getCombinedInfoTable sm = sm ^. scopedModuleInfoTable <> mconcatMap getCombinedInfoTable (sm ^. scopedModuleLocalModules)

computeCombinedInfoTable :: ScopedModuleTable -> InfoTable
computeCombinedInfoTable stab = mconcatMap getCombinedInfoTable (stab ^. scopedModuleTable)
