import SwiftUI
@available(iOS 17.0, *)
@main
struct ASDEduplay: App {
    @ObservedObject var router = NavigationRouter()
    let navigationHandler: NavigationHandler
    
    init() {
        self.navigationHandler = NavigationHandler(container: DepedencyContainer.shared)
    }
    
   
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.navigationPath) {
                IntroView()
                    .navigationDestination(for: Destination.self) {
                        navigationHandler.view(for: $0)
                    }
            }
        }
        .environmentObject(router)
        .environmentObject(SensorySettings.shared)
    }
}
