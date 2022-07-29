import FLOAT from 0x2d4c3caffbeab845
import MetadataWrapper from 0x

pub contract FLOATWrapper {

    pub var contractData : NFTContractData
    pub var type: Type
    pub init(){
        self.type = Type<FLOAT.NFT>()
        self.contractData = NFTContractData(
                                name: "FLOAT",
                                address: 0x2d4c3caffbeab845,
                                storage_path: "FLOAT.FLOATCollectionStoragePath",
                                public_path: "FLOAT.FLOATCollectionPublicPath",
                                public_collection_name: "FLOAT.CollectionPublic",
                                external_domain: "https://floats.city/"
        )

        self.account.save(<- create Wrapper(self.account.address, 0), to:StoragePath(identifier:self.contractData.name))
        self.account.link<&MetadataWrapper.WrapperInterface>{(PublicPath(identifier:self.contractData.name), StoragePath(identifier:self.contractData.name))
        self.account.link<&MetadataWrapper.WrapperInterface>(FLOAT.FLOATCollectionPublicPath, StoragePath(identifier:self.contractData.name))
    }

    pub resource Wrapper : MetadataWrapper.WrapperInterface {
        
        pub var address: Address
        pub var id : UInt64
        pub var type: Type
        pub var contractData : NFTContractData
        pub var publicPath : PublicPath


        pub fun getDict(_ nft: &FLOAT.NFT): {String:AnyStruct}{
            return {
                //display
                "_displayName": nft.eventName,
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
            }

        }

        pub fun getRef(): &FLOAT.NFT?{
            if let col = owner.getCapability(self.publicPath).borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>(){
                if let nft = col.borrowFLOAT(id: self.id){
                    return nft
                }
            }
            return nil
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
                
            if let nft = self.getRef(){
                if let nftMetadata = nft as? &AnyResource{MetadataViews.Resolver} {
                     if let resolved = self.NftMetadata.resolveView(view){
                        return resolved
                    }
                }
                var dict = getDict(nft)

                switch view {
                    case Type<MetadataViews.Display>():
                        return MetadataViews.Display(
                            name: dict["_display.name"]!,
                            description: dict["_display.description"]!,
                            thumbnail: HTTPFile(url: dict["_display.thumbnail"]!)
                        )

                    case Type<MetadataViews.Medias>():
                        if let medias = dict["_medias"]{
                            var items:[Media] = []
                            for media in medias {
                                items.append(Media(file:HTTPFile(url: media) , mediaType: "image"))
                            }
                            return MetadataViews.Medias(
                                items:items
                            )
                        }
                        return nil 

                    case Type<MetadataViews.Traits>():
                        var traits:[MetadataViews.Trait] = []
                        for k in dict.keys(){
                            if k[0]!="_"{
                                traits.append(Trait(name:k ,value: dict[k]!, displayType: nil, rarity: nil))
                            }
                        }
                        return MetadataViews.Traits(traits)

                     case Type<MetadataViews.NFTView>():
                        return MetadataViews.NFTView(
                                display: resolveView(Type<MetadataViews.Display>())
                                externalURL: resolveView(Type<MetadataViews.ExternalURL>()),
                                collectionData: resolveView(Type<MetadataViews.NFTCollectionData>()),
                                collectionDisplay: resolveView(Type<MetadataViews.NFTCollectionDisplay>()), 
                                royalties: resolveView(Type<MetadataViews.Royalties>()),
                                traits: resolveView(Type<MetadataViews.Traits>())
                        )
                }
                
            }
                
            return nil
        }

        init(address: address, id: UInt64){
            self.address = address 
            self.id = id 
            self.publicPath = FLOAT.FLOATCollectionPublicPath
            self.contractData = FLOATWrapper.contractData 
        }
            
        pub fun setData(address: address, id: UInt64){
            self.address = address
            self.id = id
            self.type = FLOATWrapper.type
        }

        pub fun getViews(): [Type] {

            if let nft = self.getRef(){
                var views : {Type: String} ={
                    Type<MetadataViews.Display>(): "local"
                }
                if let nftMetadata = nft as? &AnyResource{MetadataViews.Resolver} {
                     if let resolvedTypes = self.nftMetadata.getViews(){
                        for type in resolvedTypes{
                            views[type]="original"
                        }
                    }
                }
                return views.keys()
            }
            return []

        }

        

    }

}

