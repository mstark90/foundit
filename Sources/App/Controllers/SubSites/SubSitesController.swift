import Vapor
import Fluent

struct SubSitesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let mainRoutes: RoutesBuilder = routes.grouped("subsites")
        mainRoutes.get(use: index)
        mainRoutes.get(":name", use: getByName)
        mainRoutes.post(use: create)
    }

    func index(req: Request) async throws -> [SubSite] {
        try await SubSite.query(on: req.db(.mysql)).all()
    }

    func getByName(req: Request) async throws -> SubSite {
        guard let name: String = req.parameters.get("name") else {
            throw Abort(.badRequest)
        }

        let subSite: SubSite? = try await SubSite.query(on: req.db(.mysql))
            .filter(\.$name == name.lowercased()) .first()

        if (subSite == nil) {
            throw Abort(.notFound)
        }

        return subSite!
    }

    func create(req: Request) async throws -> SubSite {
        guard let decodedRequest: SubSiteRequest? = try req.content.decode(SubSiteRequest.self) else {
            throw Abort(.badRequest)
        }

        let createRequest: SubSiteRequest = decodedRequest!;

        let subSiteCheck: SubSite? = try await SubSite.query(on: req.db(.mysql))
            .filter(\.$name == createRequest.name) .first()

        if (subSiteCheck != nil) {
            throw Abort(.conflict)
        }

        let subSite: SubSite = SubSite()

        subSite.name = createRequest.name.lowercased();
        subSite.description = createRequest.description;

        switch(createRequest.visibility.lowercased()) {
            case "private":
                subSite.visibility = .PRIVATE;
                break;
            default:
                subSite.visibility = .PUBLIC;
                break;
        }

        switch(createRequest.type.lowercased()) {
            case "nsfw":
                subSite.type = .NSFW;
                break;
            case "over_18":
                subSite.type = .OVER_18;
                break;
            default:
                subSite.type = .REGULAR;
                break;
        }

        subSite.creator = "test";
        
        try await subSite.save(on: req.db(.mysql))

        return subSite
    }
}