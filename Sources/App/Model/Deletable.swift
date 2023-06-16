import Fluent
import Vapor

public protocol Deletable {
    var deletedAt: Date? { get set }
}