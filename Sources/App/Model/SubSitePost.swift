import Fluent
import Vapor

final class SubSitePost: Model, Content {
    static let schema: String = "subsite_posts";

    @ID(custom: "subsite_post_id", generatedBy: .database)
    var id: Int64?

    @Parent(key: "subsite_id")
    var subsite: SubSite;

    @Parent(key: "post_id")
    var post: Post;

    // Creates a new, empty Planet.
    init() { }
}