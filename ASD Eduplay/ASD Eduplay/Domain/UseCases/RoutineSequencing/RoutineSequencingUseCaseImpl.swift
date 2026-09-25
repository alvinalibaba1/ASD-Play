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
        ]),
        RoutineSet(id: 4, name: "Brushing Teeth", steps: [
            RoutineStep(id: "teeth-1", order: 1, imageName: "wet_toothbrush", title: "Wet Toothbrush"),
            RoutineStep(id: "teeth-2", order: 2, imageName: "toothpaste", title: "Add Toothpaste"),
            RoutineStep(id: "teeth-3", order: 3, imageName: "brush_teeth", title: "Brush Teeth"),
            RoutineStep(id: "teeth-4", order: 4, imageName: "rinse_mouth", title: "Rinse Mouth")
        ]),
        RoutineSet(id: 5, name: "Getting Ready to Go Out", steps: [
            RoutineStep(id: "goout-1", order: 1, imageName: "put_on_shoes", title: "Put on Shoes"),
            RoutineStep(id: "goout-2", order: 2, imageName: "put_on_jacket", title: "Put on Jacket"),
            RoutineStep(id: "goout-3", order: 3, imageName: "grab_bag", title: "Grab Bag"),
            RoutineStep(id: "goout-4", order: 4, imageName: "open_door", title: "Open Door")
        ])
    ]

    func getRoutineSets() -> [RoutineSet] {
        routineSets
    }
}
