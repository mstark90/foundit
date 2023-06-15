
final class PostRequest: Codable {

    var title: String;

    var content: String;

    var type: String = "POST";

    init(_ title: String, _ content: String) {
        self.title = title;
        self.content = content;
        
    }

    init(_ title: String, _ content: String, _ type: String = "POST") {
        self.title = title;
        self.content = content;

        self.type = type;
    }
}