import Vapor

struct MainController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let mainRoutes: RoutesBuilder = routes
        mainRoutes.get(use: index)
    }

    func index(req: Request) async throws -> Main {
        let main = Main(message: "Hello World!")

        return main
    }
}