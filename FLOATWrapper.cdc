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

        self.account.save(Wrapper(self.account.address, 0), to:StoragePath(identifier:self.contractData.name))
        self.account.link(PublicPath(identifier:self.contractData.name), StoragePath(identifier:self.contractData.name))
        self.account.link(FLOAT.FLOATCollectionPublicPath, StoragePath(identifier:self.contractData.name))
    }

    pub struct Wrapper : MetadataWrapper.WrapperInterface {
        
        pub var address: Address
        pub var id : UInt64
        pub var type: Type
        pub var contractData : NFTContractData
        pub var publicPath : PublicPath

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

                switch view {
                    case Type<MetadataViews.Display>():
                        return MetadataViews.Display(
                            name: nft.eventName,
                            description: nft.eventDescription,
                            thumbnail: HTTPFile(url: nft.eventImage)
                        )

                    case Type<MetadataViews.Medias>():
                        return MetadataViews.Medias(
                            items:[Media(file:HTTPFile(url: nft.eventImage) , mediaType: "image")]
                        )

                    case Type<MetadataViews.Traits>():

                        var traits:[MetadataViews.Trait] = []
                        
                        traits.append(Trait(name:"eventName" ,value: nft.eventName, displayType: nil, rarity: nil))
                        traits.append(Trait(name:"eventDescription" ,value: nft.eventDescription, displayType: nil, rarity: nil))
                        traits.append(Trait(name:"eventHost" ,value: nft.eventHost, displayType: nil, rarity: nil))
                        traits.append(Trait(name:"eventId" ,value: nft.eventId, displayType: nil, rarity: nil))
                        traits.append(Trait(name:"eventImage" ,value: nft.eventImage, displayType: nil, rarity: nil))
                        traits.append(Trait(name:"serial" ,value: nft.serial, displayType: nil, rarity: nil))
                        traits.append(Trait(name:"dateReceived" ,value: nft.dateReceived, displayType: nil, rarity: nil))
                        traits.append(Trait(name:"royaltyAddress" ,value: Address(0x5643fd47a29770e7), displayType: nil, rarity: nil))
                        traits.append(Trait(name:"royaltyPercentage" ,value: 5.0 , displayType: nil, rarity: nil))

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
                     if let resolvedTypes = self.NftMetadata.getViews(){
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

