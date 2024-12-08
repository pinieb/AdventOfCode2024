import Foundation

@resultBuilder
struct PipelineBuilder<NodeIdentifier: Hashable> {
  typealias NodeType = NodeProtocol<NodeIdentifier>

    static func buildBlock(_ components: [any NodeType]...) -> [any NodeType] {
      components.flatMap { $0 }
    }

    static func buildExpression(_ expression: any NodeType) -> [any NodeType] {
        buildBlock([expression])
    }

    static func buildExpression(_ expression: [any NodeType]) -> [any NodeType] {
        buildBlock(expression)
    }

    static func buildOptional(_ components: [any NodeType]?) -> [any NodeType] {
        buildBlock(components ?? [])
    }

    static func buildEither(first components: [any NodeType]) -> [any NodeType] {
      components
    }

    static func buildEither(second components: [any NodeType]) -> [any NodeType] {
      components
    }

    static func buildArray(_ components: [[any NodeType]]) -> [any NodeType] {
      components.flatMap { $0 }
    }
}

@resultBuilder
struct DisplayablePipelineBuilder<NodeIdentifier: Hashable> {
  typealias NodeType = DisplayableNodeProtocol<NodeIdentifier>

    static func buildBlock(_ components: [any NodeType]...) -> [any NodeType] {
      components.flatMap { $0 }
    }

    static func buildExpression(_ expression: any NodeType) -> [any NodeType] {
        buildBlock([expression])
    }

    static func buildExpression(_ expression: [any NodeType]) -> [any NodeType] {
        buildBlock(expression)
    }

    static func buildOptional(_ components: [any NodeType]?) -> [any NodeType] {
        buildBlock(components ?? [])
    }

    static func buildEither(first components: [any NodeType]) -> [any NodeType] {
      components
    }

    static func buildEither(second components: [any NodeType]) -> [any NodeType] {
      components
    }

    static func buildArray(_ components: [[any NodeType]]) -> [any NodeType] {
      components.flatMap { $0 }
    }
}

@resultBuilder
struct DisplayablePipelineBuilder2<NodeIdentifier: Hashable> {
  typealias NodeType = DisplayableNodeProtocol<NodeIdentifier>

  static func buildBlock<T0: NodeType>(_ n0: T0) -> [any NodeType] 
    where T0.Input == None
  {
    [n0]
  }

  static func buildBlock<
    T0: NodeType,
    T1: NodeType
  >(
    _ n0: T0,
    _ n1: T1
  ) -> [any NodeType] 
  where 
    T0.Input == None,
    T1.Input == T0.Output
  {
    n0.nextNode = n1

    return [n0, n1]
  }

  static func buildBlock<
    T0: NodeType,
    T1: NodeType,
    T2: NodeType
  >(
    _ n0: T0,
    _ n1: T1,
    _ n2: T2
  ) -> [any NodeType] 
  where 
    T0.Input == None,
    T1.Input == T0.Output,
    T2.Input == T1.Output
  {
    n0.nextNode = n1
    n1.nextNode = n2

    return [n0, n1, n2]
  }

  static func buildBlock<
    T0: NodeType,
    T1: NodeType,
    T2: NodeType,
    T3: NodeType
  >(
    _ n0: T0,
    _ n1: T1,
    _ n2: T2,
    _ n3: T3
  ) -> [any NodeType] 
  where 
    T0.Input == None,
    T1.Input == T0.Output,
    T2.Input == T1.Output,
    T3.Input == T2.Output
  {
    n0.nextNode = n1
    n1.nextNode = n2
    n2.nextNode = n3

    return [n0, n1, n2, n3]
  }

  static func buildBlock<
    T0: NodeType,
    T1: NodeType,
    T2: NodeType,
    T3: NodeType,
    T4: NodeType
  >(
    _ n0: T0,
    _ n1: T1,
    _ n2: T2,
    _ n3: T3,
    _ n4: T4
  ) -> [any NodeType] 
  where 
    T0.Input == None,
    T1.Input == T0.Output,
    T2.Input == T1.Output,
    T3.Input == T2.Output,
    T4.Input == T3.Output
  {
    n0.nextNode = n1
    n1.nextNode = n2
    n2.nextNode = n3
    n3.nextNode = n4

    return [n0, n1, n2, n3, n4]
  }

  static func buildBlock<
    T0: NodeType,
    T1: NodeType,
    T2: NodeType,
    T3: NodeType,
    T4: NodeType,
    T5: NodeType
  >(
    _ n0: T0,
    _ n1: T1,
    _ n2: T2,
    _ n3: T3,
    _ n4: T4,
    _ n5: T5
  ) -> [any NodeType] 
  where 
    T0.Input == None,
    T1.Input == T0.Output,
    T2.Input == T1.Output,
    T3.Input == T2.Output,
    T4.Input == T3.Output,
    T5.Input == T4.Output
  {
    n0.nextNode = n1
    n1.nextNode = n2
    n2.nextNode = n3
    n3.nextNode = n4
    n4.nextNode = n5

    return [n0, n1, n2, n3, n4, n5]
  }

  static func buildBlock<
    T0: NodeType,
    T1: NodeType,
    T2: NodeType,
    T3: NodeType,
    T4: NodeType,
    T5: NodeType,
    T6: NodeType
  >(
    _ n0: T0,
    _ n1: T1,
    _ n2: T2,
    _ n3: T3,
    _ n4: T4,
    _ n5: T5,
    _ n6: T6
  ) -> [any NodeType] 
  where 
    T0.Input == None,
    T1.Input == T0.Output,
    T2.Input == T1.Output,
    T3.Input == T2.Output,
    T4.Input == T3.Output,
    T5.Input == T4.Output,
    T6.Input == T5.Output
  {
    n0.nextNode = n1
    n1.nextNode = n2
    n2.nextNode = n3
    n3.nextNode = n4
    n4.nextNode = n5
    n5.nextNode = n6

    return [n0, n1, n2, n3, n4, n5, n6]
  }
}
