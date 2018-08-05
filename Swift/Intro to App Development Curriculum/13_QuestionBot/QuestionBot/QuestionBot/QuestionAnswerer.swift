struct MyQuestionAnswerer {
    func responseTo(question: String) -> String {
        let lowerQuestion = question.lowercased()
        if lowerQuestion == "where are the cookies?" {
            return "In the cookie jar!"
        } else if lowerQuestion.hasPrefix("hello") {
            return "Why, hello there!"
        } else if lowerQuestion.hasPrefix("where") {
            return "To the North!"
        } else {
            // number choosing generic response based on character count
            let number = lowerQuestion.count % 4
            
            if number == 0 {
                return "I'm not quite sure I understand the question."
            } else if number == 1 {
                return "idk what u askd man but just dab on them h8rs"
            } else if number == 2 {
                return "Ask me l8r"
            } else {
                return "What do YOU think?"
            }
        }
    }
}
