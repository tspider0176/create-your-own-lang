require 'test/unit'
require_relative '../src/parser'

class ParserTest < Test::Unit::TestCase
  def test_parser
    code = <<-CODE
    def method(a, b):
      true
    CODE

    nodes = Nodes.new([
      DefNode.new("method", ["a", "b"],
        Nodes.new([TrueNode.new])
      )
    ])

    assert_equal nodes, Parser.new.parse(code)
  end
end
