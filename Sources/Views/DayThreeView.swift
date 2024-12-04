import SwiftTUI
import Foundation

struct DayThreeView: View {
  @ObservedObject var viewModel = Day3ViewModel()

  var body: some View {
    VStack(alignment: .leading) {
      NavBar(title: Day.three.rawValue)

      HStack(alignment: .top, spacing: 1) {
        subproblemPicker
        inputPicker
      }
      .frame(height: 5)

      contentView
    }
  }

  @ViewBuilder
  private var subproblemPicker: some View {
    HStack(alignment: .center) {
      Text("Subproblem: ")

      SegmentedButton(
        options: Subproblem.allCases, 
        selection: Binding(
          get: { viewModel.selectedPart },
          set: { viewModel.selectedPart = $0 }
        )
      )
    }
    .padding(.horizontal, 1)
    .border()
  }

  @ViewBuilder
  private var inputPicker: some View {
    HStack(alignment: .center) {
      Text("Input: ")

      SegmentedButton(
        options: Day3InputOption.allCases,
        selection: Binding(
          get: { viewModel.selectedInput }, 
          set: { viewModel.selectedInput = $0 }
        )
      )
    }
    .padding(.horizontal, 1)
    .border()
  }

  @ViewBuilder
  private var contentView: some View {
    HStack(alignment: .top) {
      stepsView
      dataView
    }
    .frame(maxHeight: .infinity, alignment: .top)
  }

  @ViewBuilder
  private var stepsView: some View {
    VStack(alignment: .leading, spacing: 1) {
      Text("Steps")
        .foregroundColor(.red)

      ForEach(viewModel.steps) { step in 
        StepButton(
          id: step.id, 
          stepNumber: step.number, 
          title: step.title, 
          state: step.state
        ) { id in 
          viewModel.runStep(id: id)
        }
      }
    }
    .border()
  }

  @ViewBuilder
  private var dataView: some View {
    VStack(alignment: .leading, spacing: 1) {
      Text("Data")
        .foregroundColor(.red)

      switch viewModel.dataState {
        case .unloaded:
          VStack(alignment: .center) {
              Text("🧝")
              Text("There doesn't seem to be anything here!")
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let text), .sumProducts(let text):
          DataView(line: text)
        case .enabledAreas(let lines):
          DataView(lines: lines)
        case .validCommands(let lines, _):
          DataView(lines: lines)
        case .runCommands(let lines, _):
          DataView(lines: lines)
      }
    }
    .border()
  }
}
