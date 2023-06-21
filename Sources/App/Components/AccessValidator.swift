import Vapor

struct AccessValidator {
    static func validateRead(req: Request, subsite: SubSite) throws -> Void {
        if(req.headers.first(name:"x-over-18") != "1" && subsite.type == .OVER_18) {
            throw Abort(.forbidden)
        }
    }
}