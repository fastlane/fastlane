import MarathonCore

do {
    try Marathon.run()
} catch let error as ScriptError {
    print(error.hints)
}