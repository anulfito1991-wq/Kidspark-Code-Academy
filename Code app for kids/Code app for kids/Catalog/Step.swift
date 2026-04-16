import Foundation

enum Step: Codable, Hashable, Sendable {
    case explainer(ExplainerStep)
    case mcq(MCQStep)
    case codeFill(CodeFillStep)

    private enum Kind: String, Codable { case explainer, mcq, codeFill }

    private enum CodingKeys: String, CodingKey { case kind, payload }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .kind)
        switch kind {
        case .explainer: self = .explainer(try c.decode(ExplainerStep.self, forKey: .payload))
        case .mcq: self = .mcq(try c.decode(MCQStep.self, forKey: .payload))
        case .codeFill: self = .codeFill(try c.decode(CodeFillStep.self, forKey: .payload))
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .explainer(let s):
            try c.encode(Kind.explainer, forKey: .kind)
            try c.encode(s, forKey: .payload)
        case .mcq(let s):
            try c.encode(Kind.mcq, forKey: .kind)
            try c.encode(s, forKey: .payload)
        case .codeFill(let s):
            try c.encode(Kind.codeFill, forKey: .kind)
            try c.encode(s, forKey: .payload)
        }
    }
}

struct ExplainerStep: Codable, Hashable, Sendable {
    let title: String
    let body: String
    let codeSample: String?
}

struct MCQStep: Codable, Hashable, Sendable {
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String?
}

struct CodeFillStep: Codable, Hashable, Sendable {
    let prompt: String
    let codeBefore: String
    let codeAfter: String
    let choices: [String]
    let correctIndex: Int
    let explanation: String?
}
