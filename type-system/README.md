## Type Systems

Many compilers/IDE of modern languages use type system to infer the type.

These are based on [Hindley-Milner type system](https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system).

### [Mathematical (and logical) explanation](https://legacy-blog.akgupta.ca/blog/2014/07/19/is-math-programming-youre-asking-the-wrong-question-part-1/)

based on lambda calculus, and syllogism.

### [Swift](https://github.com/apple/swift/)

[Swift uses bi-directional type inference using a constraint-based type checker](https://github.com/apple/swift/blob/master/docs/TypeChecker.rst)

Swift's type system consists of 3 phase.

- Constraint Generation
Given an input expression and (possibly) additional contextual information, generate a set of type constraints that describes the relationships among the types of the various subexpressions. The generated constraints may contain unknown types, represented by type variables, which will be determined by the solver.

- Constraint Solving
Solve the system of constraints by assigning concrete types to each of the type variables in the constraint system. The constraint solver should provide the most specific solution possible among different alternatives.

Sometimes, it can be exponential in the worst case. [Some of the techniques are used](https://github.com/apple/swift/blob/master/docs/TypeChecker.rst#performance) to improve the performance of the solvers.

For example, make a [multigraph](https://en.wikipedia.org/wiki/Multigraph) from the variables and constraints, variables be vertiecs, and constraints be edges of the graph. Then it can calculate connected components from the graph, and reduce the time complexity.

Also, the solver proceeds through the solution space in a depth-first manner, and all of major data structures used by the solver have reversible operations, allowing the solver to easily backtrack.

In addtion, [online scoring](https://github.com/apple/swift/blob/master/docs/TypeChecker.rst#online-scoring) is applied to find the best possible solutions.

If it fails to find a solution, the solver backtraces it and makes some useful error message to developers.

- Solution Application
Given the input expression, the set of type constraints generated from that expression, and the set of assignments of concrete types to each of the type variables, produce a well-typed expression that makes all implicit conversions (and other transformations) explicit and resolves all unknown types and overloads. This step cannot fail.

### References

- [Apple Swift Type Checker](https://github.com/apple/swift/tree/master/lib/Sema)
- [Type checking with examples](https://swift.org/blog/new-diagnostic-arch-overview/)
