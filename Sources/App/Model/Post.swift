import Fluent
import Vapor

enum PostType: Int, Codable {
    case POST = 1
    case IMAGE = 2
    case VIDEO = 3
    case LINK = 4
}

final class Post: Model, Content {
    static let schema: String = "posts";

    @ID(custom: "post_id", generatedBy: .database)
    var id: Int64?

    @Field(key: "title")
    var title: String

    @Field(key: "post_type")
    var type: PostType

    @Field(key: "content")
    var content: String

    @Field(key: "creator")
    var creator: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    // Creates a new, empty Planet.
    init() { }

    // Creates a new Planet with all properties set.
    init(id: Int64? = nil, title: String) {
        self.id = id
        self.title = title
    }
}