import SwiftUI

struct UserPreference: View {
    @EnvironmentObject var userModel: UserViewModel
    
    @State private var editMode: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            Image("avatar")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .background(
                    Circle()
                        .stroke(Color("DarkGreen"), lineWidth: 5)
                )
                .onTapGesture {
                    withAnimation {
                        editMode.toggle()
                    }
                }
            
            HStack {
                Image(systemName: "lasso.and.sparkles")
                                
                Text(userModel.name)
                    .thicccboi(16, .bold)
                    .foregroundColor(Color("Gray"))
            }
            
            Text(userModel.motto)
                .thicccboi(16, .regular)
                .foregroundColor(Color("Gray"))
            
            HStack {
                Image(systemName: "sparkles")
                
                Text("Current Poins: ")
                    .thicccboi(16, .thin)
                
                Text("\(userModel.points.mostTwoDigitsAsNumberString())")
                    .thicccboi(16, .regular)
                    .foregroundColor(Color("Gray"))
            }
            
            HStack {
                Image(systemName: "moon.stars")
                
                Text("Income (Baseline): ")
                    .thicccboi(16, .thin)
                
                Text("\(userModel.income.mostTwoDigitsAsNumberString())")
                    .thicccboi(16, .regular)
                    .foregroundColor(Color("Gray"))
            }
        }
        .sheet(isPresented: $editMode, content: {
            EditUserInfo()
                .environmentObject(userModel)
                .presentationDetents([.height(400)])
                .presentationCornerRadius(30)
        })
    }
}

struct UserPreference_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
