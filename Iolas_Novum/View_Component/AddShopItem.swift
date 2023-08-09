import SwiftUI

struct AddShopItem: View {
    @Environment(\.self) var env
    @EnvironmentObject var shopModel: ShopItemViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 25) {
            HStack(alignment: .center) {
                Button {
                    env.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .tint(Color("DarkOrange"))
                }
                .padding(.top, 15)
                
                Spacer()
                
                Text("Add Item!")
                    .thicccboi(18, .bold)
                    .foregroundColor(Color("Gray"))
                
                Spacer()
                
                Button {
                    if shopModel.deleteShopItem(context: env.managedObjectContext){
                        env.dismiss()
                    }
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
                .opacity(shopModel.editShopItem == nil ? 0 : 1)
            }
            .hSpacing(.leading)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Name of the Item")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Name", text: $shopModel.name)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(Color("LightBrown").shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: RoundedRectangle(cornerRadius: 10))
            }
            .padding(.top, 5)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Item Description")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Description", text: $shopModel.description)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(Color("LightBrown").shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: RoundedRectangle(cornerRadius: 10))
            }
            .padding(.top, 5)
            
            VStack(alignment: .leading, spacing: 8, content: {
                Text("Item Price")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Price", value: $shopModel.price, formatter: numberFormatter)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(Color("LightBrown").shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: RoundedRectangle(cornerRadius: 10))
            })
            .padding(.top, 5)
            
            Button {
                if shopModel.editShopItem != nil {
                    if shopModel.updateShopItem(context: env.managedObjectContext) {
                        env.dismiss()
                    }
                } else if shopModel.createShopItem(context: env.managedObjectContext) {
                    env.dismiss()
                }
            } label: {
                Text("Change")
                    .thicccboi(12, .semibold)
                    .foregroundColor(Color("Black"))
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(Color("CreamGreen"), in: RoundedRectangle(cornerRadius: 10))
            }
            .disabled(shopModel.name == "" || shopModel.price == 0.0)
            .opacity(shopModel.name == "" || shopModel.price == 0.0 ? 0.5 : 1)
            
        }
        .padding()
    }
}

struct AddShopItem_Previews: PreviewProvider {
    static var previews: some View {
        AddShopItem()
    }
}

extension AddShopItem {
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
}
