import Foundation

open class Label: NSObject, Codable {
    @objc open var url: URL?
    @objc open var name: String?
    @objc open var color: String?
}
