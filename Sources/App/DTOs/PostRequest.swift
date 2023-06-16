import Vapor

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

final class PlayablePostRequest: Codable {

    var title: String;

    var content: File;

    var type: String = "POST";

    init(_ title: String, _ content: File) {
        self.title = title;
        self.content = content;
        
    }

    init(_ title: String, _ content: File, _ type: String = "POST") {
        self.title = title;
        self.content = content;

        self.type = type;
    }
}