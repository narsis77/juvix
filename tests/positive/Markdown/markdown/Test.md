# Example

A Juvix Markdown file name ends with `.juvix.md`. This kind of file must contain
a module declaration at the top, as shown below ---in the first code block.

<pre class="highlight"><code class="juvix"><pre class="src-content"><span class="ju-keyword">module</span> <span id="YTest:0"><span class="annot"><a href="X#YTest:0"><span class="annot"><a href="X#YTest:0"><span class="ju-var">Test</span></a></span></a></span></span><span class="ju-delimiter">;</span><br/></pre></code></pre>

Certain blocks can be hidden from the output by adding the `hide` attribute, as shown below.



<pre class="highlight"><code class="juvix"><pre class="src-content"><span id="YTest:1"><span class="annot"><a href="X#YTest:1"><span class="annot"><a href="X#YTest:1"><span class="ju-function">fib</span></a></span></a></span></span> <span class="ju-keyword">:</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:1"><span class="ju-inductive">Nat</span></a></span> <span class="ju-keyword">→</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:1"><span class="ju-inductive">Nat</span></a></span> <span class="ju-keyword">→</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:1"><span class="ju-inductive">Nat</span></a></span> <span class="ju-keyword">→</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:1"><span class="ju-inductive">Nat</span></a></span><br/>  <span class="ju-keyword">|</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:2"><span class="ju-constructor">zero</span></a></span> <span id="YTest:3"><span class="annot"><a href="X#YTest:3"><span class="annot"><a href="X#YTest:3"><span class="ju-var">x1</span></a></span></a></span></span> <span class="ju-keyword">_</span> <span class="ju-keyword">:=</span> <span class="annot"><a href="X#YTest:3"><span class="ju-var">x1</span></a></span><br/>  <span class="ju-keyword">|</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:3"><span class="ju-constructor"><span class="ju-delimiter">(</span>suc</span></a></span> <span id="YTest:4"><span class="annot"><a href="X#YTest:4"><span class="annot"><a href="X#YTest:4"><span class="ju-var">n</span></a></span></a></span></span><span class="ju-delimiter">)</span> <span id="YTest:5"><span class="annot"><a href="X#YTest:5"><span class="annot"><a href="X#YTest:5"><span class="ju-var">x1</span></a></span></a></span></span> <span id="YTest:6"><span class="annot"><a href="X#YTest:6"><span class="annot"><a href="X#YTest:6"><span class="ju-var">x2</span></a></span></a></span></span> <span class="ju-keyword">:=</span> <span class="annot"><a href="X#YTest:1"><span class="ju-function">fib</span></a></span> <span class="annot"><a href="X#YTest:4"><span class="ju-var">n</span></a></span> <span class="annot"><a href="X#YTest:6"><span class="ju-var">x2</span></a></span> <span class="annot"><a href="X#YTest:5"><span class="ju-var"><span class="ju-delimiter">(</span>x1</span></a></span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Trait.Natural:7"><span class="ju-function">+</span></a></span> <span class="annot"><a href="X#YTest:6"><span class="ju-var">x2</span></a></span><span class="ju-delimiter">)</span><span class="ju-delimiter">;</span><br/><br/><span id="YTest:2"><span class="annot"><a href="X#YTest:2"><span class="annot"><a href="X#YTest:2"><span class="ju-function">fibonacci</span></a></span></a></span></span> <span class="ju-delimiter">(</span><span class="annot"><a href="X#YTest:7"><span class="ju-var">n</span></a></span> <span class="ju-keyword">:</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:1"><span class="ju-inductive">Nat</span></a></span><span class="ju-delimiter">)</span> <span class="ju-keyword">:</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:1"><span class="ju-inductive">Nat</span></a></span> <span class="ju-keyword">:=</span> <span class="annot"><a href="X#YTest:1"><span class="ju-function">fib</span></a></span> <span class="annot"><a href="X#YTest:7"><span class="ju-var">n</span></a></span> <span class="ju-number">0</span> <span class="ju-number">1</span><span class="ju-delimiter">;</span></pre></code></pre>

The `extract-module-statements` attribute can be used to display only the statements contained in a module in the output.

<pre class="highlight"><code class="juvix"><pre class="src-content"><span class="ju-keyword">type</span> <span id="YTest:8"><span class="annot"><a href="X#YTest:8"><span class="annot"><a href="X#YTest:8"><span class="ju-inductive">T</span></a></span></a></span></span> <span class="ju-keyword">:=</span> <span id="YTest:9"><span class="annot"><a href="X#YTest:9"><span class="annot"><a href="X#YTest:9"><span class="ju-constructor">t</span></a></span></a></span></span><span class="ju-delimiter">;</span></pre></code></pre>

You can pass a number to the `extract-module-statements` attribute to drop that number of statements from the start of the module.

<pre class="highlight"><code class="juvix"><pre class="src-content"><span id="YTest:15"><span class="annot"><a href="X#YTest:15"><span class="annot"><a href="X#YTest:15"><span class="ju-function">a</span></a></span></a></span></span> <span class="ju-keyword">:</span> <span class="annot"><a href="X#YTest:12"><span class="ju-inductive">T</span></a></span> <span class="ju-keyword">:=</span> <span class="annot"><a href="X#YTest:13"><span class="ju-constructor">t</span></a></span><span class="ju-delimiter">;</span></pre></code></pre>

Commands like `typecheck` and `compile` can be used with Juvix Markdown files.

<pre class="highlight"><code class="juvix"><pre class="src-content"><span id="YTest:17"><span class="annot"><a href="X#YTest:17"><span class="annot"><a href="X#YTest:17"><span class="ju-function">main</span></a></span></a></span></span> <span class="ju-keyword">:</span> <span class="annot"><a href="X#YStdlib.System.IO.Base:1"><span class="ju-axiom">IO</span></a></span> <span class="ju-keyword">:=</span> <span class="annot"><a href="X#YStdlib.System.IO.String:2"><span class="ju-axiom">readLn</span></a></span> <span class="annot"><a href="X#YStdlib.System.IO.Nat:2"><span class="ju-function"><span class="ju-delimiter">(</span>printNatLn</span></a></span> <span class="annot"><a href="X#YStdlib.Function:1"><span class="ju-function">∘</span></a></span> <span class="annot"><a href="X#YTest:2"><span class="ju-function">fibonacci</span></a></span> <span class="annot"><a href="X#YStdlib.Function:1"><span class="ju-function">∘</span></a></span> <span class="annot"><a href="X#YStdlib.Data.Nat:2"><span class="ju-axiom">stringToNat</span></a></span><span class="ju-delimiter">)</span><span class="ju-delimiter">;</span></pre></code></pre>

Other code blocks are not touched, e.g:

```text
This is a text block
```


```haskell
module Test where
```

Blocks indented.

  ```haskell
    module Test where
  ```

Empty blocks:

```
```

We also use other markup for documentation such as:

!!! note

    We use this kind of markup for notes, solutions, and other stuff

    1. More text

        ```text
        f {n : Nat := 0} {m : Nat := n + 1} ....
        ```

    2. Second text


??? info "Solution"

    Initial function arguments that match variables or wildcards in all clauses can
    be moved to the left of the colon in the function definition. For example,

    <pre class="highlight"><code class="juvix"><pre class="src-content"><span class="ju-keyword">module</span> <span id="YTest:21"><span class="annot"><a href="X#YTest:21"><span class="annot"><a href="X#YTest:21"><span class="ju-var">move-to-left</span></a></span></a></span></span><span class="ju-delimiter">;</span><br/>  <span class="ju-keyword">import</span> <span id="YStdlib.Data.Nat:0"><span class="annot"><a href="X#YStdlib.Data.Nat:0"><span class="annot"><a href="X#YStdlib.Data.Nat:0"><span class="ju-var">Stdlib<span class="ju-delimiter">.</span>Data<span class="ju-delimiter">.</span>Nat</span></a></span></a></span></span> <span class="ju-keyword">open</span><span class="ju-delimiter">;</span><br/>  <span id="YTest:18"><span class="annot"><a href="X#YTest:18"><span class="annot"><a href="X#YTest:18"><span class="ju-function"><br/>  add</span></a></span></a></span></span> <span class="ju-delimiter">(</span><span class="annot"><a href="X#YTest:19"><span class="ju-var">n</span></a></span> <span class="ju-keyword">:</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:1"><span class="ju-inductive">Nat</span></a></span><span class="ju-delimiter">)</span> <span class="ju-keyword">:</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:1"><span class="ju-inductive">Nat</span></a></span> <span class="ju-keyword">-&gt;</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:1"><span class="ju-inductive">Nat</span></a></span><br/>    <span class="ju-keyword">|</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:2"><span class="ju-constructor">zero</span></a></span> <span class="ju-keyword">:=</span> <span class="annot"><a href="X#YTest:19"><span class="ju-var">n</span></a></span><br/>    <span class="ju-keyword">|</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:3"><span class="ju-constructor"><span class="ju-delimiter">(</span>suc</span></a></span> <span id="YTest:20"><span class="annot"><a href="X#YTest:20"><span class="annot"><a href="X#YTest:20"><span class="ju-var">m</span></a></span></a></span></span><span class="ju-delimiter">)</span> <span class="ju-keyword">:=</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:3"><span class="ju-constructor">suc</span></a></span> <span class="annot"><a href="X#YTest:18"><span class="ju-function"><span class="ju-delimiter">(</span>add</span></a></span> <span class="annot"><a href="X#YTest:19"><span class="ju-var">n</span></a></span> <span class="annot"><a href="X#YTest:20"><span class="ju-var">m</span></a></span><span class="ju-delimiter">)</span><span class="ju-delimiter">;</span><br/><span class="ju-keyword">end</span><span class="ju-delimiter">;</span></pre></code></pre>

    is equivalent to

    <pre class="highlight"><code class="juvix"><pre class="src-content"><span class="ju-keyword">module</span> <span id="YTest:26"><span class="annot"><a href="X#YTest:26"><span class="annot"><a href="X#YTest:26"><span class="ju-var">example-add</span></a></span></a></span></span><span class="ju-delimiter">;</span><br/>  <span class="ju-keyword">import</span> <span id="YStdlib.Data.Nat:0"><span class="annot"><a href="X#YStdlib.Data.Nat:0"><span class="annot"><a href="X#YStdlib.Data.Nat:0"><span class="ju-var">Stdlib<span class="ju-delimiter">.</span>Data<span class="ju-delimiter">.</span>Nat</span></a></span></a></span></span> <span class="ju-keyword">open</span><span class="ju-delimiter">;</span><br/>  <span id="YTest:22"><span class="annot"><a href="X#YTest:22"><span class="annot"><a href="X#YTest:22"><span class="ju-function"><br/>  add</span></a></span></a></span></span> <span class="ju-keyword">:</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:1"><span class="ju-inductive">Nat</span></a></span> <span class="ju-keyword">-&gt;</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:1"><span class="ju-inductive">Nat</span></a></span> <span class="ju-keyword">-&gt;</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:1"><span class="ju-inductive">Nat</span></a></span><br/>    <span class="ju-keyword">|</span> <span id="YTest:23"><span class="annot"><a href="X#YTest:23"><span class="annot"><a href="X#YTest:23"><span class="ju-var">n</span></a></span></a></span></span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:2"><span class="ju-constructor">zero</span></a></span> <span class="ju-keyword">:=</span> <span class="annot"><a href="X#YTest:23"><span class="ju-var">n</span></a></span><br/>    <span class="ju-keyword">|</span> <span id="YTest:24"><span class="annot"><a href="X#YTest:24"><span class="annot"><a href="X#YTest:24"><span class="ju-var">n</span></a></span></a></span></span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:3"><span class="ju-constructor"><span class="ju-delimiter">(</span>suc</span></a></span> <span id="YTest:25"><span class="annot"><a href="X#YTest:25"><span class="annot"><a href="X#YTest:25"><span class="ju-var">m</span></a></span></a></span></span><span class="ju-delimiter">)</span> <span class="ju-keyword">:=</span> <span class="annot"><a href="X#YJuvix.Builtin.V1.Nat.Base:3"><span class="ju-constructor">suc</span></a></span> <span class="annot"><a href="X#YTest:22"><span class="ju-function"><span class="ju-delimiter">(</span>add</span></a></span> <span class="annot"><a href="X#YTest:24"><span class="ju-var">n</span></a></span> <span class="annot"><a href="X#YTest:25"><span class="ju-var">m</span></a></span><span class="ju-delimiter">)</span><span class="ju-delimiter">;</span><br/><span class="ju-keyword">end</span><span class="ju-delimiter">;</span></pre></code></pre>
