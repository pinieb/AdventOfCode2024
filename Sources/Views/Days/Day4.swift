import SwiftTUI
import Foundation

struct Day4: View {
  @ObservedObject var viewModel = Day4ViewModel()

  var body: some View {
    VStack(alignment: .leading) {
      NavBar(title: Day.four.rawValue)

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
        options: Day4Input.allCases,
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
      Text("Output")
        .foregroundColor(.red)

      switch viewModel.output {
        case .text(let text):
          DataView(data: text)
        case .data(let data):
          DataView(data: data)
            .background(.black)
            .foregroundColor(.gray)
      }
    }
    .border()
  }
}
