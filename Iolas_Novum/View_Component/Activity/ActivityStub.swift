import SwiftUI

struct ActivityStub: View {
    let activity: ActivityEntity
    let hasDelete: Bool
    @Binding var activities: Set<ActivityEntity>
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .center, spacing: 5) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 11))
                    .fontWeight(.light)
                    .foregroundColor(Color("Gray"))
                
                Text(activity.name ?? "")
                    .thicccboi(11, .thin)
                    .foregroundColor(Color("Gray"))
            }
            
            if (hasDelete) {
                Button {
                    activities.remove(activity)
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(Color(activity.color ?? "PresetColor-1"))
                }
            }
            
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(activity.color ?? "PresetColor-1").opacity(0.25))
        }
        .contentShape(Rectangle())
    }
}

struct ActivityStub_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
