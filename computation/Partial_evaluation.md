Partial evalutation: program optimization by specialization

```
program(static, dynamic) = output
PE(program, static) = program\*
program\*(dynamic) = output
```
(program\* is called residual)

Likewise, we can think of interpreter.
```
interpreter(source, input) = output
PE(interpreter, source) = target
target(input) = output
```
This implies that if we can achieve partial evaluation with given interpreter and source,
we can `compile` _source_ to _target_.

We can go further with respect to PE and interpreter.
```
PE(interpreter, source) = target
PE\*(PE, interpreter) = compiler
compiler(source) = target
```
By applying partial evaluation again, we are able to make compiler from PE and interpreter.

We can achieve even further by applying PE again.
```
PE\*(PE, interpreter) = compiler
PE\*\*(PE\*, PE) = compiler-generator
compiler-generator(interpreter) = compiler
```
In short, we can make compiler and compiler generator from interpreter.

Summary, Futamura projections are
```
interpreter(source_static, input_dynamic) = output
PE(interpreter, source) = target, target(input) = output
PE\*(PE, interpreter) = compiler, compiler(source) = target
PE\*\*(PE\*, PE) = compiler-generator, compiler-generator(interpreter) = compiler
```

- https://en.wikipedia.org/wiki/Partial_evaluation
- https://kldp.org/node/105142
- https://gist.github.com/tomykaira/3159910
- PyPy project
- Futamura projection
