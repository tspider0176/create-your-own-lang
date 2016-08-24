# coding: utf-8

class Lexer
  # 最初に、我々の言語でのspecial keywordsを定数で定義します。
  # First we define the special keywords of our language in a constant.
  # 後ほど、これはtokenizingの過程で、
  # It will be used later on in the tokenizing process to disambiguate
  # keywordと識別子（メソッド名、ローカル変数、その他）と区別するために使われます。
  # an identifier (method name, local variable, etc.) from a keyword.
  KEYWORDS = ["def", "class", "if", "true", "false", "nil"]

  def tokenize(code)
    code.chomp!
    tokens = []
    # ここでは、プログラムが現在どれほど深いインデントを字句解析しているかを知るために、
    # We need to know how deep we are in the indentation
    # 現在字句解析しているインデントレベルを保持し、またそのレベルをスタックに保持します。
    # so we keep track of the current indentation level we are in, and previous ones in the stack
    # そうすることにより、インデントレベルが下がった時(デデントした時)、我々が正しいレベルに居るかどうかを確認できます。
    # so that when we dedent, we can check if we're on the correct level.
    current_indent = 0
    indent_stack = []

    # 以下がとても単純なScannerの実装方法になります。
    # Here is how to implement a very simple scanner.
    # 解析するべき文字を見つけるまで、一文字ずつ文字を読み進めていきます。
    # Advance one character at the time until you find something to parse.
    # 以下のwhile文内では正規表現を用いて、現在の解析位置(変数iに格納されます)からコードの最後までプログラムを字句解析していきます。
    # We'll use regular expressions to scan from the current position (i) up to the end of the code.
    i = 0
    while i < code.size
      chunk = code[i..-1]

      # 以下の各if/elsif節では、解析位置(変数i)のコードのまとまりを正規表現を使って検査していきます。
      # Each of the following [if/elsif]s will test the current code chunk with a regular expression.
      # ここで、ifをメソッド名ではなくキーワード(プログラム最初に宣言したKEYWORDS定数)として認識させる為には
      # 最初のif/else節で補足する必要があり、今後も各if/else節の順番は重要になってきます。
      # The order is important as we want to match [if] as a keyword, and not a method name, we'll need to apply it first.
      # まず最初に、メソッド名や変数名(以下、識別子)を字句解析します。
      # First, we'll scan for names: method names and variable names, which we'll call identifiers.
      # 同じく、定数KEYWORDSに保持されている特別な意味を持つ単語(if、defやtrueなど)についてもここで字句解析します。
      # Also scanning for special reserved keywords such as [if], [def] and [true].
      if identifier = chunk[/\A([a-z]\w*)/, 1]
        if KEYWORDS.include?(identifier)
          tokens << [identifier.upcase.to_sym, identifier]
        else
          tokens << [:IDENTIFIER, identifier]
        end
        i += identifier.size
      # 次に、先頭が大文字から始まる定数の走査に入ります。
      # Now scanning for constants, names starting with a capital letter.
      # これが意味するのは、我々の言語Awesomeではクラス名は定数であるということです。
      # Which means, class names are constants in our language.
      elsif constant = chunk[/\A([A-Z]\w*)/, 1]
        tokens << [:CONSTANT, constant]
        i += constant.size
      # 次にNumberのマッチングに入ります。ここで、この言語では整数型のみを扱うことにします。
      # Next, matching numbers. Our language will only support integers.
      # しかし、浮動小数点型を新しく扱うにしても
      # But to add support for floats,
      # 単純に整数型と似た規則と正規表現を通例に従って適用する必要があるだけです。
      # you'd simply need to add a similar rule and adapt the regular expression accordingly.
      elsif number = chunk[/\A([0-9]+)/, 1]
        tokens << [:NUMBER, number.to_i]
        i += number.size
      # もちろん、Stringのマッチングも同様です。ダブルクォートで囲まれた文字全てが対象になります。
      # Of course, matching strings too. Anything between ["] and ["].
      elsif string = chunk[/\A"([^"]*)"/, 1]
        tokens << [:STRING, string]
        i += string.size + 2
      # さて、ここからが重要なインデントマジックについてです！ここで我々は三つのケースを取り扱う必要があります。
      # And here's the indentation magic! We have to take care of 3 cases:
      # if true:  # 1) The block is created.
      #  line 1
      #  line 2   # 2) New line inside a block, at the same level.
      # continue  # 3) Dedent.
      # このelsif節では最初のケースを取り扱います。空白文字の数がインデントレベルを決定します。
      # This [elsif] takes care of the first case. The number of spaces will determine the indent level.
      elsif indent = chunk[/\A\:\n( +)/m, 1]
        if indent.size <= current_indent
          raise "Bad indent level, got #{indent.size} indents, " + "expected > #{current_indent}"
        end

        current_indent = indent.size
        indent_stack.push(current_indent)
        tokens << [:INDENT, indent.size]
        i += indent.size + 2
      # 次のelsif節では以下のCase2と3を取り扱います。
      # The next [elsif] takes care of the two last cases:
      #  Case 2: もしインデントレベル(空白文字の数)がcurrent_indentと同じだった場合、同じブロックに留まります。
      #  Case 2: We stay in the same block if the indent level (number of spaces) is the same as [current_indent].
      #  Case 3: インデントレベルがcurrent_indentよりも低かった場合、現在のブロックを:DEDENTにより閉じます。
      #  Case 3: Close the current block, if indent level is lower than [current_indent].
      elsif indent = chunk[/\A\n( *)/m, 1]
        if indent.size == current_indent
          tokens << [:NEWLINE, "\n"]
        elsif indent.size < current_indent
          while indent.size < current_indent
            indent_stack.pop
            current_indent = indent_stack.last || 0
            tokens << [:DEDENT, indent.size]
          end
          tokens << [:NEWLINE, "\n"]
        else
          raise "Missing ':'"
        end

        i += indent.size + 1
      # Long operators(記述される事が多くよく利用される演算子?)、
      # いわゆる ||だとか、&&、== などは以下のelsif節のブロックで捕捉されます。
      # Long operators such as ||, &&, ==, etc. will be matched by the following block.
      # 1文字のLong operatorsはこれより下のelse節で全て捕捉されます。
      # One character long operators are matched by the catch all [else] at the bottom.
      elsif operator = chunk[/\A(\|\||&&|==|!=|<=|>=)/, 1]
        tokens << [operator, operator]
        i += operator.size
      # この言語、Awesomeでは空白は無視されます。改行文字とは対照的に、空白文字はここでは特別な意味を持たないのです。
      # We're ignoring spaces. Contrary to line breaks, spaces are meaningless in our language.
      # 理由として、我々が空白文字用のトークンを作成しないというからというが挙げられます。
      # That's why we don't create tokens for them.
      # 空白文字は、あるトークンとまた別のトークンを分割するためだけに使われます。
      # They are only used to separate other tokens.
      elsif chunk.match(/\A /)
        i += 1
      # 最後に、全ての一文字の記号(主に演算子)を補足します。
      # Finally, catch all single characters, mainly operators.
      # ここで、今までのif-else節で補足されていない全ての一文字の記号はトークンとして扱います。
      # We treat all other single characters as a token. Eg.: ( ) , . ! + - <.
      else
        value = chunk[0,1]
        tokens << [value, value]
        i += 1
      end
    end

    # ここでは全ての開いたブロックを閉じます。
    # Close all open blocks.
    # もしデデント無しにコードが終わっていた場合、ここでインデントとデデントの数を調節します。
    # If the code ends without dedenting, this will take care of balancing the [INDENT]...[DEDENT]s.
    while indent = indent_stack.pop
      tokens << [:DEDENT, indent_stack.first || 0]
    end

    tokens
  end
end
