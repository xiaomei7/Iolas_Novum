//
//  EditUserInfo.swift
//  Iolas_Novum
//
//  Created by Iolas on 12/07/2023.
//

import SwiftUI

struct EditUserInfo: View {
    @Environment(\.self) private var env
    @EnvironmentObject var userModel: UserViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Button(action: {
                env.dismiss()
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .tint(Color("DarkOrange"))
            })
            .hSpacing(.leading)
            
            VStack(alignment: .leading, spacing: 8, content: {
                Text("Name")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Name", text: $userModel.name)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(Color("LightBrown").shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: RoundedRectangle(cornerRadius: 10))
            })
            .padding(.top, 5)
            
            VStack(alignment: .leading, spacing: 8, content: {
                Text("Income")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Income", value: $userModel.income, formatter: numberFormatter)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(Color("LightBrown").shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: RoundedRectangle(cornerRadius: 10))
            })
            .padding(.top, 5)
            
            VStack(alignment: .leading, spacing: 8, content: {
                Text("Motto")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Motto", text: $userModel.motto)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(Color("LightBrown").shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: RoundedRectangle(cornerRadius: 10))
            })
            .padding(.top, 5)
            
            Button {
                if userModel.updateUser(context: env.managedObjectContext) {
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
            .disabled(userModel.name == "")
            .opacity(userModel.name == "" ? 0.5 : 1)
            
        }
        .padding()
    }
}

struct EditUserInfo_Previews: PreviewProvider {
    static var previews: some View {
        EditUserInfo()
    }
}

extension EditUserInfo {
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
}
