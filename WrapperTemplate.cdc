import {{_contract.name}} from {{_contract.address}}
import MetadataWrapper from 0x

pub contract {{_contract.name}}Wrapper {

    pub fun getRef(account: Address, id: UInt64): &{{_contract.name}}.NFT?{
        if let collection = getAccount(account).getCapability(self.contractData["_contract.public_path"]!)
                                               .borrow<&{{_contract.name}}.Collection{{{_contract.name}}.{{_contract.public_iface}}}>(){
            if let nft = collection.{{_contract.borrow_func}}(id: id){
                return nft
            }
        }
        return nil
    }

    pub fun getContractAttributes(){
        return {
            "_contract.name":            "FLOAT",
            "_contract.borrow_func":     "borrowFLOAT",
            "_contract.public_iface":    "CollectionPublic",
            "_contract.address":         0x2d4c3caffbeab845,
            "_contract.storage_path":    FLOAT.FLOATCollectionStoragePath,
            "_contract.public_path":     FLOAT.FLOATCollectionPublicPath,
            "_contract.external_domain": "https://floats.city/"
            "_contract.type":            Type<{{_contract.name}}.NFT>()
        }
    }

     pub fun getNFTAttributes(_ nft: &{{_contract.name}}.NFT): {String:AnyStruct}{
            return {
                //display
                "_displayName": nft.eventName
                "_display.description": nft.eventDescription
                "_display.thumbnail": nft.eventImage,
                //medias 
                "_medias": [nft.eventImage],
                //other traits 
                "eventName": nft.eventName,
                "eventDescription" : nft.eventDescription,
                "eventHost": nft.eventHost,
                "eventId": nft.eventId,
                "eventImage": nft.eventImage, 
                "serial": nft.serial, 
                "dateReceived": nft.dateReceived, 
                "royaltyAddress": Address(0x5643fd47a29770e7),
                "royaltyPercentage": 5.0 
                //generated
                "type": nft.GetType(),
            }
    }
    
    pub var contractData: {String:AnyStruct}

    pub fun setup(){
        self.contractData = self.getContractAttributes()
        destroy self.account.load<@AnyResource>(from: )StoragePath(identifier:self.contractData["_contract.name"]!))
        self.account.save(<- create Wrapper(contractData: self.contractData), to:StoragePath(identifier:self.contractData["_contract.name"]!))

        self.account.unlink(PublicPath(identifier:data["_contract.name"]!))
        self.account.link<&MetadataWrapper.WrapperInterface>{PublicPath(identifier:data["_contract.name"]!), StoragePath(identifier:self.contractData["_contract.name"]!))
        
        self.account.unlink(PublicPath(identifier:data["_contract.public_path"]!))
        self.account.link<&MetadataWrapper.WrapperInterface>(self.contractData["_contract.public_path"]!, StoragePath(identifier:self.contractData["_contract.name"]!))
    }

    pub init(){
        self.setup()
    }

    pub resource Wrapper : MetadataWrapper.WrapperInterface {
       
        pub fun setData(address: address, id: UInt64){
            self.address = address
            self.id = id
            self.attributes = {}
            self.views = {}
            
            for view in MetadataWrapper.baseViews(){
                self.views[view] = "generated"
            }

            if let nft = {{_contract.name}}Wrapper.getRef(self.account, self.id){
                self.attributes = {{_contract.name}}Wrapper.getNFTAttributes(nft)
                if let nftMetadata = nft as? &AnyResource{MetadataViews.Resolver} {
                    if let resolvedTypes = self.nftMetadata.getViews(){
                        for type in resolvedTypes{
                            views[type]="original"
                        }
                    }
                }
            }
        }
        
        pub var address: Address
        pub var type: Type
        pub var id : UInt64

        pub var contractData: {String:AnyStruct}
        pub var attributes: {String:AnyStruct}
        pub var views: {Type: String}
    
        pub fun resolveView(_ view: Type): AnyStruct? {                
            if let viewLocation = self.views[view] {
                if viewLocation=="generated"{
                    return MetadataWrapper.buildView(view: view, attributes: self.attributes)
                }
                if let nftMetadata = nft as? &AnyResource{MetadataViews.Resolver} {
                    if let resolved = self.NftMetadata.resolveView(view){
                        return resolved
                    }
                }
            }
            return nil 
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

