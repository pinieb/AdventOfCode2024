import Foundation
import Combine

protocol InputProtocol:
  RawRepresentable<String>, 
  CaseIterable, 
  Identifiable,
  Hashable, 
  Equatable, 
  SelectionItem {
  var inputValue: String { get }
}

extension InputProtocol {
  var id: String { self.rawValue }
  var label: String { self.rawValue }
}

enum StepOutput {
  case text(_ text: String)
  case data(_ data: DisplayableData)
}

protocol DayViewModel<DayInput, StepID>: ObservableObject {
  associatedtype DayInput: InputProtocol
  associatedtype StepID: Hashable & Equatable

  var title: String { get }

  var selectedPart: Subproblem { get set }
  var selectedInput: DayInput { get set }

  var steps: [Step<StepID>] { get }
  var output: StepOutput { get }

  func runStep(id: StepID)
}
