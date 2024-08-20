struct OnboardingStep {
    enum StepType {
        case info
        case restore
    }

    let backgroundImage: String
    let title: String
    let description: String
    let buttonTitle: String
    var stepType: StepType = .info
}
