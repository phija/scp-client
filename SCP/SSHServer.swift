struct SSHServer: Codable {
    var name: String
    var host: String
    var port: Int
    var user: String
    var pass: String
    
    var privkey: String
    var pubkey: String
    var prase: String
}
