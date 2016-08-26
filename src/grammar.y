# 前の章で書いたように、パースの規則は文法の中で定義されます。
# As mention earlier in this chapter, parsing rules are defined inside a grammar.
class Parser

# 私たちは、どのようなトークンが予期されるのかをパーサーに伝えるする必要があります。
# We need to tell the parser what tokens to expect.
# ここでは、それぞれLexerにより作成されるトークンをここでは宣言しています。
# So each type of token produced by our lexer needs to be declared here.
token IF
token DEF
token CLASS
token NEWLINE
token NUMBER
token STRING
token TRUE FALSE NIL
token IDENTIFIER
token CONSTANT
token INDENT DEDENT

# 以下は演算子の優先順位表(OPT)です。
# Here is the Operator Precedence Table.
# 前で紹介されたように、この表はどの順番で演算子を含む式をパースしていくかをパーサーに教えます。
# As presented before, it tells the parser in which order to parse expressions containing operators.
# この表はC/C++の演算子優先順位表に基づいています。
# This table is based on the C and C++ Operator Precedence Table.
# https://ja.wikipedia.org/wiki/CとC++の演算子#.E6.BC.94.E7.AE.97.E5.AD.90.E3.81.AE.E5.84.AA.E5.85.88.E9.A0.86.E4.BD.8D
prechigh
  left  '.'
  right '!'
  left  '*' '/'
  left  '+' '-'
  left  '>' '>=' '<' '<='
  left  '==' '!='
  left  '&&'
  left  '||'
  right '='
  left  ','
preclow

# これより以下の節では、パースするための規則を定義しています。
# In the following rule section, we define the parsing rules.
# 全ての規則は以下のようなフォーマットに基づいて宣言されます。
# All rules are declared using the following format:
#  RuleName:
#    OtherRule TOKEN AnotherRule       { result = Node.new}
#  | OtherRule                         { ... }
# 右辺にある{}で囲まれたactionの節では、以下のようなことが出来ます:
# In the action section (inside the {...} on the right), you can do the following:
# resultに規則に基づいて返された値を指定できる。通常規則はASTのノードとなる。
#  * Assign to result the value returned by the rule, usually a node for the AST.
# 左辺の式でマッチした結果の部分を、val[添字]を用いて使える。
#  * Use val[index of expression] to get the result of a matched expressions on the left.

rule
# 最初に、私たちのパーサーは愚かなので、空のプログラムの処理についてを明確にする必要があります。
# First, parsers, are dumb, we need to explicitly tell it how to handle empty programs.
# 以下が最初の規則が為すことです。
# This is what the first rule does.
# 注釈:/*...*/はコメントアウトです。
# Note that everything between /* ... */ is a comment.
  Program:
    /* nothing */                      { result = Nodes.new([]) }
  | Expressions                        { result = val[0] }
  ;

# 次に、式のリストが何を表すのかを定義します。
# Next, we define what a list of expressions is.
# 簡単に言って、式のリストはターミネータによって区切られます。(ターミネータについては後述されます)
# Simply put, it's series of expressions separated by a terminator (a new line or ; as defined later).
# しかしここでも再び、我々はどうやって後端や、周りから孤立している改行を処理するかを明確に定義する必要があります。
# But once again, we need to explicitly define how to handle trailing and orphans line breaks (the last two lines).
#
# ある変数を定義する時に使える強力な策略、それもどんな数のトークンでもマッチ出来るような規則として、左再帰が挙げられます。
# One very powerful trick we'll use to define variable rules like this one (rules which can match any number of tokens) is left-recursion.
# これが意味するのは、ある式は、左辺「のみ」で、自身を直接参照するという事です。
# Which means we reference the rule itself, directly, on the left side *only*.
# 今回のようなLR方式が用いられているパーサーに、左再帰を利用して規則を記述するのは適しています。
# This is true for the current type of parser we're using (LR).
# 他にも、ANTLRのようなLL方式を用いたものは、対照的に右再帰のみしか使う事が出来ません。
# For other types of parsers like ANTLR (LL), it's the opposite, you can only use right-recursion.
#
# 以下に見られるように、式の規則は式自身を参照します。
# As you'll see below, the Expressions rule references Expressions itself.
# 言い換えると、式のリストはもう一つの式に引き続き、他の式のリストに置き換えられるという事です。
# In other words, a list of expressions can be another list of expressions followed by another expression.
  Expressions:
    Expression                         { result = Nodes.new(val) }
  | Expressions Terminator Expression  { result = val[0] << val[2] }
  | Expressions Terminator             { result = val[0] }
  | Terminator                         { result = Nodes.new([]) }
  ;

# 全ての式の型はここで定義されます。
# Every type of expression supported by our language is defined here.
  Expression:
    Literal
  | Call
  | Operator
  | GetConstant
  | SetConstant
  | GetLocal
  | SetLocal
  | Def
  | Class
  | If
  | '(' Expression ')'    { result = val[1] }
  ;

# 以下は前の規則を用いて丸括弧のサポートを実装する場合についての注意書きになります。
# Notice how we implement support for parentheses using the previous rule.
# '(' "Expression" ')'は、強制的にExpressionを他より一番最初にパースします。
# '(' "Expression" ')' will force the parsing of "Expression" in its entirety first.
# 丸括弧はパースされた式のみを残して、捨てられます。
# Parentheses will then be discarded leaving only the fully parsed expression.
#
# ターミネータとは、式を終わらせることの出来るトークンの事です。
# Terminators are tokens that can terminate an expression.
# ルールを定義するためにトークンを使う時、
# When using tokens to define rules,
# 我々は単純にターミネータをlexerで定義された型に基づいて参照します。
# we simply reference them by their type which we defined in the lexer.
  Terminator:
    NEWLINE
  | ";"
  ;

# リテラルはプログラムの内部にある変更出来ない値です。
# Literals are the hard-coded values inside the program.
# もし他のリテラルの型、配列やハッシュ、を扱いたい場合は、この項目が変更すべき項目になるでしょう。
# If you want to add support for other literal types, such as arrays, or hashes, this it where you'd do it.
  Literal:
    NUMBER                        { result = NumberNode.new(val[0]) }
  | STRING                        { result = StringNode.new(val[0]) }
  | TRUE                          { result = TrueNode.new }
  | FALSE                         { result = FalseNode.new }
  | NIL                           { result = NilNode.new }
  ;

# 関数呼び出しは三つの形態を取ります。
# Method call can take three forms:
#  receiver無し("self"だと仮定): method(arguments)
#  * Without a receiver ("self" is assumed): method(arguments).
#  receiver有り: receiver.method(arguments)
#  * With a receiver: receiver.method(arguments).
#  引数無しの場合は()を省略できるような糖衣構文を暗示する: receiver.method
#  * And a hint of syntactic sugar so that we can drop the () if no arguments are given: receiver.method.
# 上に挙げた各々の項目は以下のルールに則って処理されます。
# Each one of those is handled by the following tule.
  Call:
    IDENTIFIER Arguments          { result = CallNode.new(nil, val[0], val[1]) }
  | Expression "." IDENTIFIER
      Arguments                   { result = CallNode.new(val[0], val[2], val[3]) }
  | Expression "." IDENTIFIER     { result = CallNode.new(val[0], val[2], []) }
  ;

  Arguments:
    "(" ")"                       { result = [] }
  | "(" ArgList ")"               { result = val[1] }
  ;

  ArgList:
    Expression                    { result = val }
  | ArgList "," Expression        { result = val[0] << val[2] }
  ;

# Rubyのように、我々の言語Awesomeでは、演算子はメソッド呼び出しへと変換されます。
# In our language, like in Ruby, operators are converted to method calls.
# つまり、1+2は1.+(2)へと変換され、これはreceiverが+で、引数に2を持つ関数呼び出しになっています。
# So 1 + 2 will be converted to 1.+(2) is the receiver of the + method call, passing 2 as an argument.
# 演算子は演算子の優先順位表OPTに則り、独立に定義される必要があります。
# Operators need to be defined individually for the Operator Precedence Table to take again.
  Operator:
    Expression '||' Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '&&' Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '==' Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '!=' Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>'  Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>=' Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<'  Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<=' Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '+'  Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '-'  Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '*'  Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '/'  Expression  { result = CallNode.new(val[0], val[1], [val[2]]) }
  ;

# そして、ここではローカル変数と定数の値を取得、または値の代入を行うルールを記述します。
# Then we have rules for getting and setting values of constants and local variables.
  GetConstant:
    CONSTANT                      { result = GetConstantNode.new(val[0]) }
  ;

  SetConstant:
    CONSTANT "=" Expression       { result = SetConstantNode.new(val[0], val[2]) }
  ;

  GetLocal:
    IDENTIFIER                    { result = GetLocalNode.new(val[0]) }
  ;

  SetLocal:
    IDENTIFIER "=" Expression     { result = SetLocalNode.new(val[0], val[2]) }
  ;

# Awesomeでは、コード内のブロックを分ける為にインデントを利用します。
# Our language uses indentation to separate blocks of code.
# しかしながら、Lexerが全ての複雑な処理を行い、また全てのブロックをINDENTとDEDENTでラップしています。
# But the lexer took care of all that complexity for us and wrapped all blocks in INDENT...DEDENT.
# ブロックは単純にあるコードに続いてインデントを増加させ、また等しくインデントを減少させることで閉じます。
# A block is simply an increment in indentation followed by some code and closing with an equivalent decrement in indentation.
#
# もし、インデントベースの代わりに中カッコや"end"キーワードをブロックの境界として使いたい場合は、
# 単純にここのルールを変更すれば良いでしょう。
# If you'd like to use curly brackets or "end" to delimit blocks instead, you'd simply need to modify this one rule.
# もし変更する場合、同様にLexerからもインデントベースのロジックを削除する必要があります。
# You'll also need to remove the indentation logic from the lexer.
  Block:
    INDENT Expressions DEDENT     { result = val[1] }
  ;

# "def"キーワードは関数の定義に使われます。
# The "def" keyword is used for defining methods.
# ここで再び、関数が引数無しの時には、関数の末尾の丸括弧を省略出来るようにする為に1つ糖衣構文を導入します。
# (def hoge() は def hogeでも問題無し)
# Once again we're introducing a bit of syntactic sugar here to allow skipping the parentheses when there are no parameters.
  Def:
    DEF IDENTIFIER Block          { result = DefNode.new(val[1], [], val[2]) }
  | DEF IDENTIFIER
      "(" ParamList ")" Block     { result = DefNode.new(val[1], val[3], val[5]) }
  ;

  ParamList:
    /* nothing */                 { result = [] }
  | IDENTIFIER                    { result = val }
  | ParamList "," IDENTIFIER      { result = val[0] << val[2] }
  ;

# Classの定義は関数の定義に似ています。
# Class definition is similar to method definition.
# Lexer設計の最初の方でも書いた通り、Classの名前は大文字から始まる為、定数Constantとして扱われます。
# Class names are also constant because they start with a capital letter.
  Class:
    CLASS CONSTANT Block          { result = ClassNode.new(val[1], val[2]) }
  ;

# 最後に、制御構文のifです。クラスと表記は似ていますが、receiverがconditionになっています。
# Finally, "if" is similar to "class" but receivers a "condition".
  If:
    IF Expression Block           { result = IfNode.new(val[1], val[2]) }
  ;
end

# 以下にあるRaccファイル最後のコードは、そのままParserクラスに書き出されます。
# The final code at the bottom of this Racc file will be put as-is in the generated Parser class.
# ここでは、コードの先頭に追加したいプログラムはheaderに、クラスの内部に追記したいコードはinnerに記述します。
# You can put some code at the top ("header") and some inside the class ("inner").
---- header
  require_relative "lexer"
  require_relative "nodes"

---- inner
  def parse(code, show_tokens=false)
    @tokens = Lexer.new.tokenize(code) # Tokenize the code using our lexer
    puts @tokens.inspect if show_tokens
    do_parse # Kickoff the parsing process
  end

  def next_token
    @tokens.shift
  end
