import FLOAT from 0x2d4c3caffbeab845
import MetadataWrapper from 0x

pub contract FLOATWrapper {

    pub fun getContractAttributes(){
        return {
            "_contract.type":  Type<FLOAT.NFT>()
            "_contract.name": "FLOAT",
            "_contract.address": Address(0x2d4c3caffbeab845),
            "_contract.storage_path": FLOAT.FLOATCollectionStoragePath,
            "_contract.public_path": FLOAT.FLOATCollectionPublicPath,
            "_contract.public_collection_name" "FLOAT.CollectionPublic",
            "_contract.external_domain": "https://floats.city/"
        }
    }

     pub fun getNFTAttributes(_ nft: &FLOAT.NFT): {String:AnyStruct}{
            return {
                //display
                "_displayName": nft.eventName,
                "_display.description": nft.eventDescription
                "_display.thumbnail": nft.eventImage,
                //medias 
                "_medias": [nft.eventImage],
                //other traits 
                "type": nft.GetType(),
                "eventName": nft.eventName,
                "eventDescription" : nft.eventDescription,
                "eventHost": nft.eventHost,
                "eventId": nft.eventId,
                "eventImage": nft.eventImage, 
                "serial": nft.serial, 
                "dateReceived": nft.dateReceived, 
                "royaltyAddress": Address(0x5643fd47a29770e7),
                "royaltyPercentage": 5.0 
            }
    }
    
    pub init(){
        var data = self.getContractAttributes()
        self.account.save(<- create Wrapper(contractData: self.data), to:StoragePath(identifier:data["_contract.name"]!))
        self.account.link<&MetadataWrapper.WrapperInterface>{(PublicPath(identifier:data["_contract.name"]!), StoragePath(identifier:data["_contract.name"]!))
        self.account.link<&MetadataWrapper.WrapperInterface>(data["_contract.public_path"]!, StoragePath(identifier:data["_contract.name"]!))
    }

    pub resource Wrapper : MetadataWrapper.WrapperInterface {
        
        pub fun getNFTAttributes(_ nft: &FLOAT.NFT): {String:AnyStruct}{
            return FLOATWrapper.getNFTAttributes(nft)
        }
       
        pub fun getRef(): &FLOAT.NFT?{
            if let col = owner.getCapability(self.contractData["_contract.public_path"]!).borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>(){
                if let nft = col.borrowFLOAT(id: self.id){
                    return nft
                }
            }
            return nil
        }


        //////// END OF CONFIG ////////

        pub var address: Address
        pub var type: Type
        pub var id : UInt64

        pub var contractData: {String:AnyStruct}
        pub var attributes: {String:AnyStruct}
        pub var views: {Type: String}


        pub fun resolveView(_ view: Type): AnyStruct? {                
            
            if let viewLocation = self.views[view] {
                if let nftMetadata = nft as? &AnyResource{MetadataViews.Resolver}
                    if viewLocation=="original"{
                        if let resolved = self.NftMetadata.resolveView(view){
                            return resolved
                        }
                    }
                    else{
                        return MetadataWrapper.buildView(view: view, attributes: self.attributes)
                    }
                }
            }
            return nil 
        }

        pub fun setData(address: address, id: UInt64){
            self.address = address
            self.id = id
            self.views = {}
            self.attributes = {}

            if let nft = self.getRef(){
                self.attributes = self.getNFTAttributes(nft)
                for view in MetadataWrapper.baseViews(){
                    self.views[view] = "generated"
                    if let nftMetadata = nft as? &AnyResource{MetadataViews.Resolver} {
                        if let resolvedTypes = self.nftMetadata.getViews(){
                            for type in resolvedTypes{
                                views[type]="original"
                            }
                        }
                    }
                }
            }
        }

        pub fun getViews(): [Type] {
            return self.views.keys()
        }

        init(contractData: address){
            self.id = 0
            self.address = self.account.address 
            self.type =  contractData["_contract.type"]!
            self.contractData = contractData
            self.attributes = {}
            self.views = {}
        }
        

    }

}

