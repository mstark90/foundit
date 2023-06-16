import Fluent
import Vapor

enum SubSiteType: Int, Codable {
    case REGULAR = 1
    case NSFW = 2
    case OVER_18 = 3
}

enum SubSiteVisibility: Int, Codable {
    case PUBLIC = 1
    case PRIVATE = 2
}

final class SubSite: Model, Content, Deletable {
    static let schema: String = "subsites";

    @ID(custom: "subsite_id", generatedBy: .database)
    var id: Int64?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @Field(key: "visibility")
    var visibility: SubSiteVisibility

    @Field(key: "type")
    var type: SubSiteType

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
}