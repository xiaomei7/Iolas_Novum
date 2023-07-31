//
//  AddTag.swift
//  Iolas_Novum
//
//  Created by Iolas on 10/07/2023.
//

import SwiftUI

struct TagManagement: View {
    @FetchRequest(
        entity: TagEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TagEntity.name, ascending: false)],
        predicate: nil,
        animation: .easeInOut)
    var tags: FetchedResults<TagEntity>
    
    @Environment(\.self) var env
    @StateObject var tagModel: TagViewModel = .init()
    
    let isSelectionMode: Bool
    let onTagSelected: (TagEntity) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Tags")
                .thicccboi(22, .thick)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    Button {
                        env.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .tint(.primary)
                }
                .overlay(alignment: .trailing) {
                    Button {
                        tagModel.addorEditTag.toggle()
                    } label: {
                        Label {
                            Text("New")
                        } icon: {
                            Image(systemName: "plus.circle")
                        }
                        .font(.callout.bold())
                        .foregroundColor(.primary)
                    }
                }
                .padding(.bottom, 10)
            
            ScrollView(tags.isEmpty ? .init() : .vertical, showsIndicators: false) {
                VStack {
                    ForEach(tags) { tag in
                        Button {
                            if isSelectionMode {
                                onTagSelected(tag)
                                env.dismiss()
                            }
                        } label: {
                            TagStub(tag: tag, hasDelete: false, tags: .constant(Set<TagEntity>()))
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .sheet(isPresented: $tagModel.addorEditTag) {
            tagModel.resetData()
        } content: {
            addTag
                .presentationDetents([.height(200)])
                .presentationCornerRadius(30)
        }
    }
}

struct TagManagement_Previews: PreviewProvider {
    static var previews: some View {
        Today()
    }
}

extension TagManagement {
    private func InputSection(text: String, bound: Binding<String>) -> some View {
        TextField(text, text: bound)
            .padding(.horizontal)
            .padding(.vertical, 10)
    }
    
    private var ColorSelection: some View {
        HStack(spacing: 0){
            ForEach(1...7, id: \.self) { index in
                let color = "PresetColor-\(index)"
                Circle()
                    .fill(Color(color))
                    .frame(width: 30, height: 30)
                    .overlay(content: {
                        if color == tagModel.color {
                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                    })
                    .onTapGesture {
                        withAnimation{
                            tagModel.color = color
                        }
                    }
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical)
    }
    
    private var addTag: some View {
        VStack {
            InputSection(text: "Tag Name", bound: $tagModel.name)
            
            ColorSelection
            
            Button {
                if tagModel.createTag(context: env.managedObjectContext) {
                    tagModel.addorEditTag.toggle()
                }
            } label: {
                Text("Create Tag")
                    .font(.title3)
                    .foregroundColor(Color("Cream"))
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background {
                        Capsule()
                            .fill(Color("CreamGreen").opacity(0.5).gradient)
                    }
            }
            .disabled(!tagModel.doneStatus())
            .opacity(!tagModel.doneStatus() ? 0.6 : 1)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
