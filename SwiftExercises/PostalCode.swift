import Cocoa
import Foundation

public enum PostalCode {
    case US( Int, Int )
    case UK( String )
    case CA( String )
    
    func asString() -> String {
        switch( self ) {
        case US( let primary, let secondary ): return "\(primary)-\(secondary)"
        case UK( let(s) ): return s;
        case CA( let(s) ): return s;
        }
    }
}

public enum Country: String {
    case USA = "United States"
    case UK  = "United Kingdom"
    case CA  = "Canada"

    func getPostalCode( primary:Int, _ secondary:Int ) -> PostalCode? {
        switch self {
        case USA where (1...99999 ~= primary) && (1...9999 ~= secondary):
            return PostalCode.US(primary, secondary)
        default:
            return nil;
        }
    }
    
    func getPostalCode( value:String ) -> PostalCode? {
        // Candadian postal codes take the form "AdA dAd" where A is alphabetic and d is a digit
        // UK postal codes are arbitrary strings are between 6 and 8 characters taking one of
        // the forms:
        // AA0A dAA
        // AdA dAA
        // Ad dAA
        // Add dAA
        // AAd dAA
        // AAdd dAA
        
        let candidate = toCharArray(value)
        
        switch self {
        case CA where matches("AdA dAd", candidate):
            return PostalCode.CA(value)
            
        case UK where matches("AAdA dAA", candidate): fallthrough
        case UK where matches("AdA dAA",  candidate): fallthrough
        case UK where matches("Ad dAA",   candidate): fallthrough
        case UK where matches("Add dAA",  candidate): fallthrough
        case UK where matches("AAd dAA",  candidate): fallthrough
        case UK where matches("AAdd dAA", candidate):
            return PostalCode.UK(value)
            
        default:
            return nil;
        }
    }
    
    private func toCharArray( s: String ) -> [Character] {
        var characters:[Character] = []
        for c in s.characters {
            characters.append(c)
        }
        return characters
    }
    
    private func matches( template: String, _ candidate: [Character] ) -> Bool {
        
        if template.characters.count != candidate.count {
            return false
        }

        var i = 0;
        for current in template.characters {
            print("comparing template(\(current)) to candidate(\(candidate[i]))" )
            switch (current, candidate[i++]) {
            case (" ", let c) where " " ~= c        : continue
            case ("d", let c) where "0"..."9" ~=  c : continue
            case ("A", let c) where "A"..."Z" ~=  c : continue
            default: print("mismatch"); return false
            }
        }
        return true;
    }
}