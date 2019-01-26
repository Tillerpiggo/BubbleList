//
//  File.swift
//  SkillsUSAContest
//
//  Created by Tyler Gee on 1/17/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import Foundation

class Student {
    var name: String
    var grades: [String: Grade]
    
    init(name: String, grades: [String: Grade]) {
        self.name = name
        self.grades = grades
    }
}

class Grade {
    var persistence: Float?
    var quality: Float?
    var teamwork: Float?
    var creativity: Float?
    
    var programming: Float?
    var art: Float?
    var science: Float?
    var crafting: Float?
    var language: Float?
    var history: Float?
    
    init(persistence: Float? = nil, quality: Float? = nil, teamwork: Float? = nil, creativity: Float? = nil, programming: Float? = nil, art: Float? = nil,
         science: Float? = nil, crafting: Float? = nil, language: Float? = nil, history: Float? = nil) {
        self.persistence = persistence
        self.quality = quality
        self.teamwork = teamwork
        self.creativity = creativity
        self.programming = programming
        self.art = art
        self.science = science
        self.crafting = crafting
        self.language = language
        self.history = history
    }
    
    var weightedScore: Float {
        let programming = self.programming ?? 0.0
        let art = self.art ?? 0.0
        let science = self.science ?? 0.0
        let crafting = self.crafting ?? 0.0
        let language = self.language ?? 0.0
        let history = self.history ?? 0.0
        let quality = self.quality ?? 0.0
        let persistence = self.persistence ?? 0.0
        let teamwork = self.teamwork ?? 0.0
        let creativity = self.creativity ?? 0.0
        
        let technicalSkills1 = (programming + art + science)
        let technicalSkills2 = (crafting + language + history)
        let technicalSkills = technicalSkills1 + technicalSkills2
        let softSkills1 = (3.0 * quality + persistence)
        let softSkills2 = (2.0 * teamwork + 2 * creativity)
        let softSkills = softSkills1 + softSkills2
        
        let weightedScore = technicalSkills * 2/3 + softSkills
        return weightedScore
    }
}

class Project {
    var students: [Student]
    var name: String
    
    var weightedScores: [Float]? {
        var weightedScores: [Float] = []
        // Calculate here
        for student in students {
            guard let grade = student.grades[name] else { return nil }
            
            weightedScores.append(grade.weightedScore)
        }
        
        return weightedScores
    }
    var averageScore: Float? {
        guard let weightedScores = weightedScores else { return nil }
        
        var average: Float = 0.0
        
        for score in weightedScores {
            average += score
        }
        
        return average / Float(weightedScores.count)
    }
    var highScore: Float? {
        guard let weightedScores = weightedScores else { return nil }
        
        return weightedScores.max(by: { $0 > $1 })
    }
    var lowScore: Float? {
        guard let weightedScores = weightedScores else { return nil }
        
        return weightedScores.min(by: { $0 < $1 })
    }
    
    init(name: String, students: [Student]) {
        self.students = students
        self.name = name
    }
}
