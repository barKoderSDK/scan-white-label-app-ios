import Foundation
import UIKit

struct ChangelogItem : Codable {
	let version : String
	let changes : [String]

	enum CodingKeys: String, CodingKey {

		case version = "version"
		case changes = "changes"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
        version = try values.decodeIfPresent(String.self, forKey: .version) ?? "N/A"
		changes = try values.decodeIfPresent([String].self, forKey: .changes) ?? [String]()
	}

    var attributedString : NSAttributedString {
        let titleString = NSAttributedString(string: version, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        let mutableAttributedString = NSMutableAttributedString(attributedString: titleString)
        
        for change in changes {
            let detailsString = NSAttributedString(string: "\n - " + change, attributes: [.font: UIFont.systemFont(ofSize: 14)])
            mutableAttributedString.append(detailsString)
        }
        
        return mutableAttributedString as NSAttributedString
    }
    
}
