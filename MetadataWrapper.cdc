


pub contract MetadataWrapper {

    pub struct interface WrapperInterface(){
        pub var address: Address
        pub var id : UInt64
        pub var type: Type
        pub var contract : NFTContractData
        pub var publicPath : PublicPath
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




