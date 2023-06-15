import Vapor

final class Main: Content {
    var message: String?

    init() { }

    init(message: String) {
        self.message = message
    }
}