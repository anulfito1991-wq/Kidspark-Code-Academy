import SwiftUI
import SwiftData

@main
struct Code_app_for_kidsApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .fontDesign(.rounded)     // KidSpark Academy — rounded type globally
        }
        .modelContainer(for: [Learner.self, LessonProgress.self, Challenge.self])
    }
}
