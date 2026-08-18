import Foundation

final class RoutineSequencingUseCaseImpl: RoutineSequencingUseCase {
    // SF Symbols instead of illustration assets, same reasoning as
    // EmotionMatching's emoji faces - no new art dependency, nothing to go
    // missing. Each step still carries its own text label, so the icon only
    // has to be a loose visual hint, not carry the meaning alone.
    private let routineSets: [RoutineSet] = [
        RoutineSet(id: 1, name: "Morning Routine", steps: [
            RoutineStep(id: "morning-1", order: 1, icon: "sunrise.fill", title: "Wake Up"),
            RoutineStep(id: "morning-2", order: 2, icon: "tshirt.fill", title: "Get Dressed"),
            RoutineStep(id: "morning-3", order: 3, icon: "fork.knife", title: "Eat Breakfast"),
            RoutineStep(id: "morning-4", order: 4, icon: "backpack.fill", title: "Go to School")
        ]),
        RoutineSet(id: 2, name: "Bedtime Routine", steps: [
            RoutineStep(id: "bedtime-1", order: 1, icon: "shower.fill", title: "Take a Bath"),
            RoutineStep(id: "bedtime-2", order: 2, icon: "book.fill", title: "Read a Book"),
            RoutineStep(id: "bedtime-3", order: 3, icon: "moon.stars.fill", title: "Turn off Light"),
            RoutineStep(id: "bedtime-4", order: 4, icon: "bed.double.fill", title: "Go to Sleep")
        ]),
        RoutineSet(id: 3, name: "Handwashing", steps: [
            RoutineStep(id: "wash-1", order: 1, icon: "drop.fill", title: "Turn on Water"),
            RoutineStep(id: "wash-2", order: 2, icon: "hands.sparkles.fill", title: "Soap Hands"),
            RoutineStep(id: "wash-3", order: 3, icon: "arrow.triangle.2.circlepath", title: "Rinse"),
            RoutineStep(id: "wash-4", order: 4, icon: "wind", title: "Dry Hands")
        ])
    ]

    func getRoutineSets() -> [RoutineSet] {
        routineSets
    }
}
