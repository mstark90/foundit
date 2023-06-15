import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: MainController())
    try app.register(collection: SubSitesController())
}
