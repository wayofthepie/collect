{-# LANGUAGE
    OverloadedStrings
    #-}

module Storage.Object.Aws where

import qualified Aws
import qualified Aws.Core as Aws
import qualified Aws.S3 as S3
import Control.Monad.IO.Class
import Control.Monad.Trans.Resource (runResourceT)
import qualified Data.ByteString as S
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Network.HTTP.Conduit (Manager, RequestBody(..))
import System.IO
import System.Posix.Files

import qualified Storage.Object as Obj

data Config = Config
    { awsConfig :: Aws.Configuration
    , awsDomain :: S.ByteString -- Need a good URL lib
    , manager   :: Manager
    }

-- | Aws implementation of Storage.Object.
withHandle :: Config -> Obj.Handle
withHandle cfg = Obj.Handle
        { Obj.store = store cfg
        }

store :: Config -> Obj.Object -> IO Obj.StoreResponse
store cfg obj = do
    let awscfg = awsConfig cfg
    let s3cfg = S3.s3 Aws.HTTP (awsDomain cfg) False
    let mgr = manager cfg
    runResourceT $ do
        let file = Obj.objData obj
        let streamer sink = withFile file ReadMode $ \h -> sink $ S.hGet h 10240
        size <- liftIO (fromIntegral . fileSize <$> getFileStatus file :: IO Integer)
        let body = RequestBodyStream (fromInteger size) streamer
        rsp <- Aws.pureAws awscfg s3cfg mgr $ S3.putObject "riverd" (T.pack file) body
        return $ Obj.Success "Success!" -- Just return success always for now


{-
createFolder :: IO ()
createFolder = do
    cfg <- Aws.dbgConfiguration
    let s3cfg = S3.s3 Aws.HTTP "s3-eu-west-1.amazonaws.com" False
    {- Set up a ResourceT region with an available HTTP manager. -}
    withManager $ \mgr -> do
        rsp <- Aws.pureAws cfg s3cfg mgr $
            (S3.putObject "riverd" "testFolder/" mempty)
        liftIO $ print rsp
-}
