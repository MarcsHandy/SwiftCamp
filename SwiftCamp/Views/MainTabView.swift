import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            CourseListView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
            
            ProfileView(lessonManager: LessonManager())
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
