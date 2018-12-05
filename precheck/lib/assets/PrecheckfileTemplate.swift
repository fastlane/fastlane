// For more information about this configuration visit
// https://docs.fastlane.tools/actions/precheck/#precheckfile

// In general, you can use the options available
// fastlane precheck --help

class Precheckfile: PrecheckfileProtocol {
    //var defaultRuleLevel: String { return "error" }
}

// You have three possible values for defaultRuleLevel
// "skip"
// indicates that your metadata will not be checked by this rule

// "warn"
// when triggered, this rule will warn you of a potential problem

// "error"
// when triggered, this rule will cause an error to be displayed and it will prevent any further fastlane commands from running after precheck finishes
