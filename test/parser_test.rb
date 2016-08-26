require 'test/unit'
require_relative '../src/parser'

class ParserTest < Test::Unit::TestCase
  def test_parser
    code = <<-CODE
def method(a, b):
  b()

def b():
  false
CODE

    nodes = Nodes.new([
      DefNode.new("method", ["a", "b"],
        Nodes.new([
          CallNode.new(nil, "b", [])
        ])
      ),
      DefNode.new("b",[],
        Nodes.new([
          FalseNode.new
        ])
      )
    ])

    assert_equal nodes, Parser.new.parse(code)
  end
end
