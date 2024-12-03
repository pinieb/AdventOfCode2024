import SwiftTUI

@preconcurrency
struct DismissAction {
  private let action: (() -> Void)?

  init(action: (() -> Void)? = nil) {
    self.action = action
  }

  func callAsFunction() {
    action?()
  }
}

@preconcurrency
struct DismissEnvironmentKey: EnvironmentKey {
  static let defaultValue: DismissAction = DismissAction()
}

extension EnvironmentValues {
  var dismiss: DismissAction {
    get { self[DismissEnvironmentKey.self] }
    set { self[DismissEnvironmentKey.self] = newValue }
  }
}

extension View {
  func dismissAction(action: @escaping () -> Void) -> some View {
    environment(\.dismiss, DismissAction(action: action))
  }
}
