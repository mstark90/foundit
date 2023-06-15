import Vapor

struct SubSitesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let mainRoutes: RoutesBuilder = routes.grouped("subsites")
        mainRoutes.get(use: index)
    }

    func index(req: Request) async throws -> [SubSite] {
        try await SubSite.query(on: req.db(.mysql)).all()
    }
}