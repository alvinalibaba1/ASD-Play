import Foundation

struct RoutineStep: Identifiable, Equatable {
    let id: String
    let order: Int
    let imageName: String
    let title: String
}

struct RoutineSet: Identifiable {
    let id: Int
    let name: String
    let steps: [RoutineStep]
}
