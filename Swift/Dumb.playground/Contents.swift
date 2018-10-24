import UIKit


class CoolCalculator {
    static func calculate(withCool cool: Int, age: Int) -> String {
        let coolLevel = cool * age
        if coolLevel < 100 {
            return "not very cool bud"
        } else if coolLevel >= 100 && coolLevel < 250 {
            return "dumb nobi sometim wiins"
        } else if coolLevel >= 250 && coolLevel < 500 {
            return "maby cool"
        } else if coolLevel >= 500 && coolLevel < 1000 {
            return "big cool"
        }
        
        return "ultra swag"
    }
}

if let cool = cool, let age = age {
    print(CoolCalculator.calculate(withCool: cool, age: age))
}
