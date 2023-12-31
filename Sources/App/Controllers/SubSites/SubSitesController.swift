import Vapor
import Fluent

struct SubSitesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let mainRoutes: RoutesBuilder = routes.grouped("subsites")
        mainRoutes.get(use: index)
        mainRoutes.get(":name", use: getByName)
        mainRoutes.get(":name", "posts", use: getPostsForSubSite)
        mainRoutes.post(":name", "posts", use: createPostForSubSite)
        mainRoutes.post(use: create)
    }

    func getSiteByName(req: Request, name: String) async throws -> SubSite? {
        return try await SubSite.query(on: req.db(.mysql))
            .group(.and) {
                $0.filter(\.$name == name.lowercased()).filter(\.$deletedAt == nil)
            }
            .first()
    }

    func index(req: Request) async throws -> [SubSite] {
        try await SubSite.query(on: req.db(.mysql)).all()
    }

    func getByName(req: Request) async throws -> SubSite {
        guard let name: String = req.parameters.get("name") else {
            throw Abort(.badRequest)
        }

        let subSite: SubSite? = try await self.getSiteByName(req: req, name: name)

        if (subSite == nil) {
            throw Abort(.notFound)
        }

        return subSite!
    }

    func getPostsForSubSite(req: Request) async throws -> [Post] {
        let subSite: SubSite = try await self.getByName(req: req)

        try AccessValidator.validateRead(req: req, subsite: subSite)

        let posts: [Post] = try await Post.query(on: req.db(.mysql))
            .join(SubSitePost.self, on: \Post.$id == \SubSitePost.$post.$id)
            .filter(SubSitePost.self, \SubSitePost.$subsite.$id == subSite.id!)
            .filter(Post.self, \.$deletedAt == nil)
            .sort(Post.self, \.$id, .descending)
            .all()

        return posts;
    }

    func createPostForSubSite(req: Request) async throws -> Post {
        if(req.headers.contentType == HTTPMediaType.formData) {
            return try await self.createFilePost(req: req);
        } else {
            return try await self.createTextPost(req: req);
        }
    }

    private func getFileExtension(_ name: String) -> String {
        let start: String.Index? = name.lastIndex(of: ".");

        if(start == nil) {
            return "";
        }

        return String(name[start!...]);
    }

    private func createFilePost(req: Request)  async throws -> Post {
        guard let decodedRequest: PlayablePostRequest? = try req.content.decode(PlayablePostRequest.self) else {
            throw Abort(.badRequest)
        }

        let createRequest: PlayablePostRequest = decodedRequest!;

        let subSite: SubSite = try await self.getByName(req: req)

        let post: Post = Post()

        let fileExt: String = self.getFileExtension(createRequest.content.filename);

        let fileName: String = UUID().uuidString + fileExt

        let path: String = Environment.get("STORAGE_LOCATION")! + "/" + fileName

        req.application.fileio.openFile(path: path,
                                           mode: .write,
                                           flags: .allowFileCreation(posixMode: 0x744),
                                           eventLoop: req.eventLoop)
                .flatMap { handle in
                    req.application.fileio.write(fileHandle: handle,
                                                buffer: createRequest.content.data,
                                                eventLoop: req.eventLoop)
                        .flatMapThrowing { _ in
                            try handle.close()
                        }
                }

        try await req.db.transaction { database in

            let url: String = (Environment.get("STORAGE_URL_BASE") ?? "") + "/" + fileName
            post.content = url
            post.title = createRequest.title
            
            switch(createRequest.content.contentType) {
                case HTTPMediaType.jpeg, HTTPMediaType.gif, HTTPMediaType.png:
                    post.type = .IMAGE;
                    break;
                case HTTPMediaType.mpeg, HTTPMediaType.avi:
                    post.type = .VIDEO;
                    break;
                default:
                    throw Abort(.badRequest)
            }

            post.creator = "test"
            
            try await post.save(on: database)

            let subSitePost: SubSitePost = SubSitePost()

            subSitePost.$post.id = post.id!;
            subSitePost.$subsite.id = subSite.id!;

            try await subSitePost.save(on: database)
        }

        return post
    }

    private func createTextPost(req: Request) async throws -> Post {
        guard let decodedRequest: PostRequest? = try req.content.decode(PostRequest.self) else {
            throw Abort(.badRequest)
        }

        let createRequest: PostRequest = decodedRequest!;

        let subSite: SubSite = try await self.getByName(req: req)

        let post: Post = Post()

        try await req.db.transaction { database in
            post.content = createRequest.content
            post.title = createRequest.title
            
            switch(createRequest.type.lowercased()) {
                case "image":
                    post.type = .IMAGE;
                    break;
                case "video":
                    post.type = .VIDEO;
                    break;
                case "link":
                    post.type = .LINK;
                    break;
                default:
                    post.type = .POST;
                    break;
            }

            post.creator = "test"
            
            try await post.save(on: database)

            let subSitePost: SubSitePost = SubSitePost()

            subSitePost.$post.id = post.id!;
            subSitePost.$subsite.id = subSite.id!;

            try await subSitePost.save(on: database)
        }

        return post
    }

    func create(req: Request) async throws -> SubSite {
        guard let decodedRequest: SubSiteRequest? = try req.content.decode(SubSiteRequest.self) else {
            throw Abort(.badRequest)
        }

        let createRequest: SubSiteRequest = decodedRequest!;

        let subSiteCheck: SubSite? = try await self.getSiteByName(req: req, name: createRequest.name)

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