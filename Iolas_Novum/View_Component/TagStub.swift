//
//  TagStub.swift
//  Iolas_Novum
//
//  Created by Iolas on 10/07/2023.
//

import SwiftUI

struct TagStub: View {
    
    let tag: TagEntity
    let hasDelete: Bool
    @Binding var tags: [TagEntity]
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .center, spacing: 5) {
                Image(systemName: "tag")
                    .font(.system(size: 12))
                    .fontWeight(.light)
                    .foregroundColor(Color("Gray"))
                
                Text(tag.name ?? "")
                    .foregroundColor(Color("Gray"))
            }
            
            if (hasDelete) {
                
                Button {
                    withAnimation {
                        self.tags.removeAll(where: { $0.id == self.tag.id })
                    }
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(Color(tag.color ?? "PresetColor-1"))
                }
            }
            
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(tag.color ?? "PresetColor-1").opacity(0.25))
        }
        .contentShape(Rectangle())
    }
}

struct TagStub_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
