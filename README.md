Awesome
-----

### About
**Awesome** is a toy language which is a mix of Ruby syntax and Python's indentation by Marc-Andre Cournoyer.  
From:  
http://createyourproglang.com/

### Test
```
bundle install
rbenv rehash
```
On the project root directory:

About lexer:
```
ruby test/lexer_test.rb
```

About parser:
```
racc -o src/parser.rb src/grammar.y
ruby test/parser_test.rb
```

About runtime:
```
ruby test/runtime_test.rb
```
