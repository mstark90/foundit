import Fluent
import Vapor

struct Initial: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("posts")
            .field("post_id", .int64, .identifier(auto: true))
            .field("title", .sql(raw: "VARCHAR(1024)"), .required)
            .field("post_type", .int32, .required)
            .field("content", .sql(raw: "LONGTEXT"), .required)
            .field("creator", .sql(raw: "VARCHAR(100)"), .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .field("deleted_at", .datetime, .required)
            .create()

        try await database.schema("subsites")
            .field("subsite_id", .int64, .identifier(auto: true))
            .field("name", .sql(raw: "VARCHAR(1024)"), .required)
            .field("description", .sql(raw: "TEXT"), .required)
            .field("visibility", .int32, .required)
            .field("type", .int32, .required)
            .field("creator", .sql(raw: "VARCHAR(100)"), .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .field("deleted_at", .datetime, .required)
            .create()

        try await database.schema("subsite_posts")
            .field("subsite_post_id", .int64, .identifier(auto: true))
            .field("subsite_id", .int64, .required)
            .field("post_id", .int64, .required)
            .foreignKey("subsite_id", references: "subsites", "subsite_id")
            .foreignKey("post_id", references: "posts", "post_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("subsite_posts").delete()
        try await database.schema("subsites").delete()
        try await database.schema("posts").delete()
    }
}