
final class SubSiteRequest: Codable {

    var id: Int64?;

    var name: String;

    var description: String;

    var visibility: String = "PUBLIC";

    var type: String = "REGULAR";

    init(_ name: String, _ description: String) {
        self.name = name;
        self.description = description;
        
    }

    init(_ name: String, _ description: String, _ visibility: String = "PUBLIC", _ type: String = "REGULAR") {
        self.name = name;
        self.description = description;

        self.visibility = visibility;
        self.type = type;
    }
}