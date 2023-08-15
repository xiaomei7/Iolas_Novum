import SwiftUI

struct AddActivity: View {
    @EnvironmentObject var activityModel: ActivityViewModel
    @Environment(\.self) var env
    
    @State private var animateColor: Color = Influence.neutral.color
    @State private var animate: Bool = false
        
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Button {
                        if activityModel.deleteActivity(context: env.managedObjectContext){
                            activityModel.resetData()
                            env.dismiss()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                    .opacity(activityModel.editActivity == nil ? 0 : 1)
                    
                    Text(activityModel.editActivity != nil ? "Edit Activity" : "Create New Activity")
                        .thicccboi(28, .light)
                        .foregroundColor(Color("Cream"))
                        .padding(.vertical, 15)
                }
                
                Name
                
                Description
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(15)
            .background {
                AnimatedBackground
            }
            
            VStack(alignment: .leading, spacing: 10) {
                ColorSelection
                
                InfluenceSection
                
                TagSection
                
                FactorSection
                
                CreateButton
            }
            .padding(15)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            Color("Cream").ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: DismissButton)
    }
}

struct AddActivity_Previews: PreviewProvider {
    static var previews: some View {
        Today()
    }
}

extension AddActivity {
    
    private func Title(_ value: String, _ color: Color = Color("Cream").opacity(0.7)) -> some View {
        Text(value)
            .thicccboi(12, .regular)
            .foregroundColor(color)
    }
    
    private func Underline(color: Color) ->  some View {
        Rectangle()
            .fill(color.opacity(0.7))
            .frame(height: 1)
    }
    
    private var AnimatedBackground: some View {
        ZStack {
            activityModel.influence.color
            
            GeometryReader {
                let size = $0.size
                
                Rectangle()
                    .fill(animateColor)
                    .mask { Circle() }
                    .frame(width: animate ? size.width * 2 : 0, height: animate ? size.height * 2 : 0)
                    .offset(animate ? CGSize(width: -size.width / 2, height: -size.height / 2) : size)
            }
            .clipped()
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var Name: some View {
        Title("NAME")
        
        TextField("Input Activity Name", text: $activityModel.name)
            .foregroundColor(Color("Cream"))
            .thicccboi(16, .regular)
            .tint(Color("Cream"))
            .padding(.top, 2)
        
        Underline(color: Color("Cream"))
    }
    
    
    @ViewBuilder
    private var Description: some View {
        Title("DESCRIPTION", Color("Cream"))
        
        TextField("About Your Activity", text: $activityModel.description)
            .foregroundColor(Color("Cream"))
            .thicccboi(16, .regular)
            .padding(.top, 2)
        
        Underline(color: Color("Cream"))
    }
    
    
    private var ColorSelection: some View {
        HStack(spacing: 0){
            ForEach(1...7, id: \.self) { index in
                let color = "PresetColor-\(index)"
                Circle()
                    .fill(Color(color))
                    .frame(width: 30, height: 30)
                    .overlay(content: {
                        if color == activityModel.color {
                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                    })
                    .onTapGesture {
                        withAnimation{
                            activityModel.color = color
                        }
                    }
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical)
    }
    
    @ViewBuilder
    private var InfluenceSection: some View {
        Title("INFLUENCE", Color("Gray"))
            .padding(.top, 15)
        
        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 20), count: 3), spacing: 15) {
            ForEach(Influence.allCases, id: \.rawValue) { selectedInfluence in
                Text(selectedInfluence.rawValue.uppercased())
                    .thicccboi(12, .regular)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 5)
                    .background {
                        if selectedInfluence == activityModel.influence {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(selectedInfluence.color.opacity(0.25))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .stroke(selectedInfluence.color, lineWidth: 2)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(selectedInfluence.color.opacity(0.25))
                        }
                    }
                    .foregroundColor(selectedInfluence.color)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard !animate else { return } // avoid simultaneous taps
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            animate = false
                            activityModel.influence = selectedInfluence
                        }
                        
                        animateColor = activityModel.influence.color
                    }
            }
        }
        .padding(.top, 5)
    }
    
    @ViewBuilder
    private var TagSection: some View {
        HStack(alignment: .center) {
            Title("TAGS", Color("Gray"))
            
            Spacer()
            
            NavigationLink(destination: TagManagement(isSelectionMode: true) { selectedTag in
                if !activityModel.selectedTags.contains(where: { $0.id == selectedTag.id }) {
                    activityModel.selectedTags.insert(selectedTag)
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 16))
                    .foregroundColor(Color("Gray"))
            }
            .id(UUID())
            
        }
        .padding(.top, 15)
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(activityModel.selectedTags), id: \.id) { tag in
                    TagStub(tag: tag, hasDelete: true, tags: $activityModel.selectedTags)
                }
            }
        }
    }
    
    @ViewBuilder
    private var FactorSection: some View {
        HStack(alignment: .center) {
            Title("FACTOR", Color("Gray"))
            
            Spacer()
            
            Text("\(activityModel.factor * 100, specifier: "%.0f")%")
                .thicccboi(12, .thin)
        }
        .padding(.top, 15)
        
        Slider(value: $activityModel.factor, in: -10...10, step: 0.5)
            .tint(activityModel.influence.color)
    }
    
    private var DismissButton: some View {
        Button {
            activityModel.resetData()
            env.dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .foregroundColor(Color("Cream"))
                .contentShape(Rectangle())
        }
    }
    
    private var CreateButton: some View {
        Button {
            if activityModel.editActivity != nil {
                if activityModel.updateActivity(context: env.managedObjectContext) {
                    activityModel.resetData()
                    env.dismiss()
                }
            } else {
                if activityModel.createActivity(context: env.managedObjectContext) {
                    activityModel.resetData()
                    env.dismiss()
                }
            }
        } label: {
            Text(activityModel.editActivity != nil ? "Edit Done" : "Create Activity")
                .thicccboi(16, .regular)
                .foregroundColor(Color("Cream"))
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity, alignment: .center)
                .background {
                    Capsule()
                        .fill(activityModel.influence.color.gradient)
                }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .disabled(!activityModel.doneStatus())
        .opacity(!activityModel.doneStatus() ? 0.6 : 1)
    }
}
