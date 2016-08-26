# 初めの属性はそれぞれが式を表すノードの蓄積をする責任が持ちます。
# The first type is respnsible for holding a collection of nodes, each one representing an expression.
# これらは、ブロック内にあるコードの内部的な表現法として考えることが出来ます。
# You can think of it as the internal representation of a block of code.
# 以下では、ノードをRubyのクラスであるStructクラスを継承したものとして定義しています。
# Here we define nodes as Ruby classes that inherit from a [Struct].
# これはRubyにおいて、ある属性(値)を持つようなclassを作る単純な方法です。
# This is a simple way, in Ruby, to create a class that holds some attributes (values).
# 以下は後ほど記述されるNodesクラスとほぼ等価なクラスです。(Structクラスを継承しない場合)
# It is almost equivalent to:
#  class Nodes
#    def initialize(nodes)
#      @nodes = nodes
#    end
#
#    def nodes
#      @nodes
#    end
#  end
#
#  n = Nodes.new("this is stored @nodes")
# n.nodes # => "this is stored @nodes"
# しかしRubyのStructクラスは==メソッドのオーバーライドを扱っており、
# But Ruby's [Struct] takes care of overriding the == operator for us
# また、その他様々な便利な仕様により、我々がテストを行うことをより簡単にしてくれます。
# and a bunch of other things that will make testing easier.
class Nodes < Struct.new(:nodes)
  def <<(node)
    nodes << node
    self
  end
end

# リテラルは静的な値として、Rubyの表記法で描かれます。
# Literals are static values that have a Ruby representation.
# 例えば、文字列や、数値、true、false、nilなどがそれに該当します。
# For example, a string, a number, true, false, nil, etc.
# ここでは、我々は上にあげたそれぞれの値のノードを定義し、またそれぞれの値の属性を内部に含む形のRubyの表記法でノードを記憶します。
# We define a node for each one of those and store their Ruby representation indide their value attribute.
class LiteralNode < Struct.new(:value); end

class NumberNode < LiteralNode; end

class StringNode < LiteralNode; end

class TrueNode < LiteralNode
  def initialize
    super(true)
  end
end

class FalseNode < LiteralNode
  def initialize
    super(false)
  end
end

class NilNode < LiteralNode
  def initialize
    super(nil)
  end
end

# メソッド呼び出しのノードはreceiverと、メソッド呼び出し元のオブジェクトと、
# The node for a method call holds the [receiver], the object on which the method is called,
# 呼び出されたメソッドの名前と、幾つかの他のノードにある引数を保持します。
# the [method] name and its arguments which are other nodes.
class CallNode < Struct.new(:receiver, :method, :arguments); end

# 以下のノードでは、定数の値を、その定数の名前(name)により探してきます。
# Retrieving the value of a constant by its [name] is done by the following node.
class GetConstantNode < Struct.new(:name); end

# 値のセットは以下のノードによって行なわれます。valueはノードになります。
# And setting its value is done by this one. The [value] will be a node.
# 例えば、もし数値を指定された定数を記憶すると、valueはNumberNodeのインスタンスを含むことになるでしょう。
# If we're storing a number inside a constant, for example, [value] would contain an instance of [NumberNode].
class SetConstantNode < Struct.new(:name, :value); end

# 以前のノードと同じように、以下はローカル変数を扱う為のノードです。
# Similar to the previous nodes, the next ones are for dealing with local variables.
class GetLocalNode < Struct.new(:name); end

class SetLocalNode < Struct.new(:name, :value); end

# 各々の関数の定義は以下のノードによって記憶されます。
# Each method definition will be stored into the following node.
# このノードは関数のnameと、関数の引数であるparams、
# It holds the [name] of the method, the name of its parameters ([params])
# それにbodyを、関数が呼び出された時に評価するために全てのノードの親がNodesであるノード木の形で保持します。
# and the [body] to evaluate when the method is called, which is a tree of node, the root one being a [Nodes] instance.
class DefNode < Struct.new(:name, :params, :body); end

# クラスの定義は以下のノードによって記憶されます。
# Class definitions are stores into the following node.
# 再び、クラスのnameとクラスのbodyがノードの木の形で記憶されます。
# Once again, the [name] of the class and its [body], a tree of nodes.
class ClassNode < Struct.new(:name, :body); end

# 制御構文のifは以下のノード地震によって記憶されます。
# [if] control structyres are stored in a node of their own.
# 条件式に当たるconditionとifの中身に当たるbodyも同様にノードの形になり、様々な時に評価されます。
# The [condition] and [body] will also be nodes that need to be evaluated at some point.
# もし他の制御構文、whileやfor、loopなどを実装したい時は、このノードを見ると良いでしょう。
# Look at this node if you want to implement other control structures like [while], [for], [loop], etc.
class IfNode  < Struct.new(:condition, :body); end
