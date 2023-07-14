//
//  Shop.swift
//  Iolas_Novum
//
//  Created by Iolas on 14/07/2023.
//

import SwiftUI
import PopupView

struct Shop: View {
    @FetchRequest(
        entity: ShopItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ShopItem.name, ascending: false)],
        predicate: nil,
        animation: .easeInOut)
    var shopItems: FetchedResults<ShopItem>
    
    @Environment(\.self) var env
    @EnvironmentObject var userModel: UserViewModel
    @StateObject var shopModel: ShopItemViewModel = .init()
    
    @State private var showPopupError: Bool = false
    @State private var showPopupSuccess: Bool = false
    
    var body: some View {
        ZStack {
            Color("Cream").ignoresSafeArea()
            
            VStack {
                Text("Shop")
                    .thicccboi(18, .bold)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)
                
                ScrollView(shopItems.isEmpty ? .init() : .vertical, showsIndicators: false) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 20), count: 3), spacing: 15) {
                        ForEach(shopItems, id: \.id) { shopItem in
                            ShopItemCard(shopItem)
                                .padding(.vertical, 15)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: {
                shopModel.addorEditShopItem.toggle()
            }, label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundColor(Color("Cream"))
                    .frame(width: 55, height: 55)
                    .background(Color("DarkGreen").shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: Circle())
            })
            .padding(15)
        })
        .sheet(isPresented: $shopModel.addorEditShopItem, onDismiss: {
        }) {
            AddShopItem()
                .environmentObject(userModel)
                .environmentObject(shopModel)
                .presentationDetents([.height(400)])
                .interactiveDismissDisabled()
                .presentationCornerRadius(30)
                .presentationBackground(Color("LightBrown"))
        }
        .popup(isPresented: $showPopupError) {
            Text("Not Enough Points...")
                .thicccboi(16, .regular)
                .foregroundColor(Color("Black"))
                .frame(width: UIScreen.main.bounds.width * 2/3, height: 60)
                .background(Color("DarkOrange"))
                .cornerRadius(15)
        } customize: {
            $0
                .type(.floater())
                .position(.top)
                .animation(.spring())
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(0.5))
        }
        .popup(isPresented: $showPopupSuccess) {
            Text("Purchase Success...!")
                .thicccboi(16, .regular)
                .foregroundColor(Color("Black"))
                .frame(width: UIScreen.main.bounds.width * 2/3, height: 60)
                .background(Color("CreamGreen"))
                .cornerRadius(15)
        } customize: {
            $0
                .type(.floater())
                .position(.top)
                .animation(.spring())
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(0.5))
        }
    }
}

struct Shop_Previews: PreviewProvider {
    static var previews: some View {
        Shop()
    }
}

extension Shop {
    private func ShopItemCard(_ item: ShopItem) -> some View {
        VStack {
            Text(item.name ?? "Item Name")
                .thicccboi(16, .regular)
            
            Text(item.describe ?? "Item Description")
                .thicccboi(12, .thin)
            
            Text("\(item.price.mostTwoDigitsAsNumberString())")
                .thicccboi(12, .bold)
                .foregroundColor(Color("Orange"))
            
            Button {
                if userModel.points < item.price {
                    showPopupError.toggle()
                } else {
                    userModel.points -= item.price
                    if userModel.updatePoints(context: env.managedObjectContext) {
                        showPopupSuccess.toggle()
                    }
                }
            } label: {
                Text("Buy")
                    .thicccboi(12, .semibold)
                    .foregroundColor(Color("Black"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color("CreamGreen"), in: RoundedRectangle(cornerRadius: 10))
            }
            
        }
        .padding()
        .background (
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("Gray"), lineWidth: 4)
                    .blur(radius: 4)
                    .mask(RoundedRectangle(cornerRadius: 10).fill(LinearGradient(gradient: Gradient(colors: [Color.clear, Color("Gray")]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("CreamGreen").opacity(0.7), lineWidth: 2)
            }
        )
    }
}
