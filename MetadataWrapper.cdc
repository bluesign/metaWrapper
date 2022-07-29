pub contract MetadataWrapper {

    pub fun baseViews(): [Type]{
        return [
            Type<MetadataViews.Display>(),
            Type<MetadataViews.Medias>(),
            Type<MetadataViews.Traits>(),
            Type<MetadataViews.NFTView>()
        ]
    }
    pub fun buildView(_ view: Type, attributes: {String:AnyStruct}): AnyStruct?{
        switch view {
                    case Type<MetadataViews.Display>():
                        return MetadataViews.Display(
                            name: attributes["_display.name"]!,
                            description: attributes["_display.description"]!,
                            thumbnail: HTTPFile(url: attributes["_display.thumbnail"]!)
                        )

                    case Type<MetadataViews.Medias>():
                        if let medias = attributes["_medias"]{
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
                                traits.append(Trait(name:k ,value: attributes[k]!, displayType: nil, rarity: nil))
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
        return nil 
    }

    pub resource interface WrapperInterface(){
        pub var address: Address
        pub var id : UInt64
        pub var type: Type
        pub var publicPath : PublicPath
        pub var contractData {String:AnyStruct}
        pub var attributes: {String:AnyStruct}

        pub fun getViews(): [Type] 
        pub fun resolveView(_ view: Type): AnyStruct?
    }

    pub fun resolveViewsByPath(_ path: PublicPath, address: address, ids: [UInt64], views: [Type]): {UInt64, [AnyStruct]]{
        var res: {UInt64, [AnyStruct]] = {}

        if let wrapper = acct.borrow<&{MetadataWrapperInterface}>(from: path){
            for id in ids{
                wrapper.setData(address: address, id: id)
                v: [AnyStruct]= []
                for view in views{
                    if let resolved = wrapper.resolveView(view){
                        v.append(resolved)
                    }
                }
                res[id]=v
            }
        }

        return res
    }

    pub fun resolveViews(_ type: String,  address: address, ids: [UInt64], views: [Type]): {UInt64, [AnyStruct]]{
        var res: {UInt64, [AnyStruct]] = {}

        if let wrapper = acct.borrow<&{MetadataWrapperInterface}>(from: PublicPath(identifier:type)){
            for id in ids{
                wrapper.setData(address: address, id: id)
                v: [AnyStruct]= []
                for view in views{
                    if let resolved = wrapper.resolveView(view){
                        v.append(resolved)
                    }
                }
                res[id]=v
            }
        }

        return res
    }
}




