import Foundation

final class RoutineSequencingUseCaseImpl: RoutineSequencingUseCase {
    // Illustrated art (generated via Gemini, placed under
    // Assets.xcassets/Image/My Routine) instead of SF Symbols - concrete,
    // distinct pictures are easier to correctly guess/choose than abstract
    // line icons, which was the whole point of adding them.
    private let routineSets: [RoutineSet] = [
        RoutineSet(id: 1, name: "Morning Routine", steps: [
            RoutineStep(id: "morning-1", order: 1, imageName: "wake_up", title: "Wake Up"),
            RoutineStep(id: "morning-2", order: 2, imageName: "clothes", title: "Get Dressed"),
            RoutineStep(id: "morning-3", order: 3, imageName: "breakfast", title: "Eat Breakfast"),
            RoutineStep(id: "morning-4", order: 4, imageName: "backpack", title: "Go to School")
        ]),
        RoutineSet(id: 2, name: "Bedtime Routine", steps: [
            RoutineStep(id: "bedtime-1", order: 1, imageName: "bathtub", title: "Take a Bath"),
            RoutineStep(id: "bedtime-2", order: 2, imageName: "book", title: "Read a Book"),
            RoutineStep(id: "bedtime-3", order: 3, imageName: "light_off", title: "Turn off Light"),
            RoutineStep(id: "bedtime-4", order: 4, imageName: "sleep", title: "Go to Sleep")
        ]),
        RoutineSet(id: 3, name: "Handwashing", steps: [
            RoutineStep(id: "wash-1", order: 1, imageName: "water_on", title: "Turn on Water"),
            RoutineStep(id: "wash-2", order: 2, imageName: "soap", title: "Soap Hands"),
            RoutineStep(id: "wash-3", order: 3, imageName: "rinse", title: "Rinse"),
            RoutineStep(id: "wash-4", order: 4, imageName: "towel", title: "Dry Hands")
        ])
    ]

    func getRoutineSets() -> [RoutineSet] {
        routineSets
    }
}
