
module Storage.Object where

import qualified Data.Text as T

-- | For now an Object is just a file.
data Object = Object
    { objData :: FilePath
    }

data StoreResponse = Success T.Text | Failure T.Text
    deriving (Eq, Show)

data Handle = Handle
    { store :: Object -> IO (StoreResponse)
    }
