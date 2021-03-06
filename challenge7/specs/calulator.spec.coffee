{Calculator} = require './../Calculator'

# For Jasmine help API:
# https://github.com/pivotal/jasmine/wiki/Suites-and-specs
# https://github.com/pivotal/jasmine/wiki/Matchers
# https://github.com/pivotal/jasmine/wiki/Before-and-After
# https://github.com/pivotal/jasmine/wiki/Spies
# https://github.com/pivotal/jasmine/wiki/Asynchronous-specs
#
# Official Jasmine site: 
# http://pivotal.github.com/jasmine/

arrayHasSubstring = (theArray, substring) -> # finds a substring in the array items
  for item in theArray
    if item.indexOf(substring) != -1 then return true # if substring is found in the array item
  false

describe 'Calculator', ->
  describe '#result', ->
    describe 'when a single input is parsed to the calculator', ->
      it 'can add', ->
        calculator = new Calculator('2+3')
        expect(calculator.result()).toEqual 5
      it 'can subtract', ->
        calculator = new Calculator('3-2')
        expect(calculator.result()).toEqual 1
      it 'can multiply', ->
        calculator = new Calculator('2*3')
        expect(calculator.result()).toEqual 6
      it 'can divide', ->
        calculator = new Calculator('3/2')
        expect(calculator.result()).toEqual 1.5
      it 'can use brackets', ->
        calculator = new Calculator('200 / (1 + 1)')
        expect(calculator.result()).toEqual 100
      it 'can use multiple operands (Challenge 6 pass!)', ->
        calculator = new Calculator('200 - 23 + 2 * 34')
        expect(calculator.result()).toEqual 245
      it 'throws an error when letters are included in input string', ->
        calculator = new Calculator('a+3')
        try
          calculator.result()
          expect('expected an error').toEqual 'no error was thrown' # TODO: Better formulation
        catch error
          expect(error[0]).toContain 'odd characters'
      it 'throws an error when illegal symbols are included in the input string', ->
        calculator = new Calculator('2&3?!')
        try
          calculator.result()
          expect('expected an error').toEqual 'no error was thrown' # TODO: Better formulation
        catch error
          expect(arrayHasSubstring error,'odd characters').toBeTruthy()
      it 'throws an error when one legal operator is followed by another (adjacent) in the input string', ->
        calculator = new Calculator('2++5')
        try
          calculator.result()
          expect('expected an error').toEqual 'no error was thrown' # TODO: Better formulation
        catch error
          expect(arrayHasSubstring error,'adjacent operators').toBeTruthy()
      it 'throws an error when legal operators are not followed by a digit in the input string', ->
        calculator = new Calculator('2+')
        try
          calculator.result()
          expect('expected an error').toEqual 'no error was thrown' # TODO: Better formulation
        catch error
          expect(arrayHasSubstring error,'ends with an operator').toBeTruthy()
      it 'throws an error when brackets are not in pairs in the input string', ->
        calculator = new Calculator('2+(5+2')
        try
          calculator.result()
          expect('expected an error').toEqual 'no error was thrown' # TODO: Better formulation
        catch error
          expect(arrayHasSubstring error,'something crazy').toBeTruthy()
      it 'throws multiple errors when multiple rules are broken in the input string', ->
        calculator = new Calculator('2&3++?!')
        try
          calculator.result()
          expect('expected an error').toEqual 'no error was thrown' # TODO: Better formulation
        catch error
            expect(arrayHasSubstring error,'odd characters').toBeTruthy() 
            expect(arrayHasSubstring error,'adjacent operators').toBeTruthy()
  
    describe 'when input and total are parsed to the calculator', ->
      describe 'when plus (+) is the first input letter', ->
        it 'adds input to total', ->
          calculator = new Calculator('+5',100)
          expect(calculator.result()).toEqual 105
      describe 'when minus (-) is first input letter', ->
        it 'subtracts input from total', ->
          calculator = new Calculator('-5',100)
          expect(calculator.result()).toEqual 95
      describe 'when multiple (*) is first input letter', ->
        it 'multiplies input with total', ->
          calculator = new Calculator('*5',100)
          expect(calculator.result()).toEqual 500      
      describe 'when divide (/) is first input letter', ->
        it 'divides total with input', ->
          calculator = new Calculator('/5',100)
          expect(calculator.result()).toEqual 20 
        it 'returns 0 if the dividend is 0 (althought it does not follow math conventions)', ->
          calculator = new Calculator('/0',100)
          expect(calculator.result()).toEqual 0
          
    describe 'when the input contains noise', ->
      # TODO: Make sure it handles brackets () properly

      describe 'when white space is included', ->
        it 'ignores it', ->
          calculator = new Calculator('+ 50 / 2',100)
          expect(calculator.result()).toEqual 125
          
      describe 'when only dots (.) are included', ->
        it 'uses dots as decimal delimeter', ->
          calculator = new Calculator('2.554',100)
          expect(calculator.result()).toEqual 2.554
      describe 'when only commas (,) are included', ->
        it 'replaces the commas (,) with dots (.)', ->
          calculator = new Calculator('2,554+2,447',100)
          expect(new Number(calculator.result().toFixed(3))).toEqual 5.001 # ASK: Apparently '2.554+2.447' = 5.000999999994 !?
        it 'handles millions fine', ->
          calculator = new Calculator('1,554,447+543.50',100)
          expect(calculator.result()).toEqual 1554990.5 
      describe 'when both dots and commas are included', ->
        it 'replaces the commas (,) with dots (.) for numbers wihtin 2 and 2000 ', ->
          calculator = new Calculator('2,554+2.447',100)
          expect(new Number(calculator.result().toFixed(3))).toEqual 5.001 # ASK: Apparently '2.554+2.447' = 5.000999999994 !?
        it 'converts each number based on an individual assessment', ->
          calculator = new Calculator('1,554+2.447',100)
          expect(calculator.result()).toEqual 1556.447
        it 'can convert all numbers in a long input string', ->
          calculator = new Calculator('3,335+8.8/2+1.025+2.025+3.05+2,510,055.687+52',100)
          expect(calculator.result()).toEqual 2511145.497
        describe 'when several dots and/or commas are used in a number', ->
          it 'uses the dot the most to the right', ->
            calculator = new Calculator('1,554.447',100)
            expect(calculator.result()).toEqual 1554.447
          it 'uses the comma the most to the right', ->
            calculator = new Calculator('1.554,447',100)
            expect(calculator.result()).toEqual 1554.447
            
          # Failing test '1,55+1,550'
          
  describe '#isValid', ->
    describe 'when input is valid', ->
      calculator = new Calculator('2 + 3')
      it 'returns true', ->
        expect(calculator.isValid()).toEqual true
    describe 'when input is invalid', ->
      calculator = new Calculator('a+3')
      it 'returns false', ->
        expect(calculator.isValid()).toEqual false
    describe 'when #isValid is called multiple times', ->
      it 'does not duplicate error messages', ->
        calculator = new Calculator('2&3?!')
        calculator.isValid()
        calculator.isValid()
        errors = calculator.errorsInInput()
        error = errors.shift()
        expect(errors).not.toContain error
        
  describe '#errorsInInput', ->
    describe 'when input is valid', ->
      calculator = new Calculator('2 + 3')
      it 'returns empty array', ->
        expect(calculator.errorsInInput()).toEqual []
    describe 'when input is invalid', ->
      calculator = new Calculator('a+3')
      it 'returns array (with error messages)', ->
        calculator.isValid()
        expect(calculator.errorsInInput().length).toBeGreaterThan 0
        
  describe '#format', ->
    describe 'when input is an integer > 1000', ->
      calculator = new Calculator('1500250')
      it 'returns a string with thousand delimiters', ->
        expect(calculator.formattedResult(0)).toEqual '1,500,250'
    describe 'when input is a float', ->
      it 'returns a rounded number', ->
        calculator = new Calculator('250.495')
        expect(calculator.formattedResult(2)).toEqual '250.50'
    describe 'when input is a float and > 1000', ->
      it 'returns a string with a rounded number with thousand delimiters', ->
        calculator = new Calculator('1500250.495')        
        expect(calculator.formattedResult(2)).toEqual '1,500,250.50'
    describe 'when input has operands', ->
      calculator = new Calculator('5+5')        
      it 'returns calculated result', ->
        expect(calculator.formattedResult(0)).toEqual '10'
    describe 'when no decimal places is given', ->
      calculator = new Calculator('3')  
      it 'defaults to 2 decimal places', ->
        expect(calculator.formattedResult()).toEqual '3.00'
        
    describe 'when input is invalid', ->
      calculator = new Calculator('invalid')
      it 'throws an error', ->
        try
          calculator.formattedResult()
          expect('expected an error').toEqual 'no error was thrown' # TODO: Better formulation


  describe '.split', ->
    it 'splits a number into a given number of parts', ->
      expect(Calculator.split(100, 2)).toEqual 50

    it '4.1) returns 0 for (0, 0)', ->
      expect(Calculator.split(0,0)).toEqual 0

    it '4.2) returns 5 for (\"10\", \"2\")', ->
      expect(Calculator.split("10","2")).toEqual 5

    it '5.1) returns 0 for (\"\", \"\")', ->
      expect(Calculator.split("","")).toEqual 0

    it '5.2) returns 0 for (null, 3)', ->
      expect(Calculator.split(null,3)).toEqual 0

    it '5.3) returns 0 for (100, null)', ->
      expect(Calculator.split(100,null)).toEqual 0

    it '5.4) returns 50.25 for (100.5, 2)', ->
      expect(Calculator.split(100.5, 2)).toEqual 50.25

    it '5.5) returns 0 for (\"a12\", 2)', ->
      expect(Calculator.split("a12",2)).toEqual 0
