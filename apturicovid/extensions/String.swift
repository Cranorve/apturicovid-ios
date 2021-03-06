import Foundation

extension String {
    var translated: String {
        translate(table: "Translations")
    }
    
    func translate(table: String) -> String {
        guard
            let path = Bundle.main.path(forResource: table, ofType: "strings", inDirectory: nil, forLocalization: Language.primary.localization),
            let dict = NSDictionary(contentsOfFile: path), // TODO: cache the file to improve performance
            let translation = dict[self] as? String
            else { return self } // Fallback to the key
        
        return translation
    }
}
