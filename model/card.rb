class Card
	attr_reader :mark, :number, :type
	attr_accessor :place
	
	
	def initialize(mark, number, type)
		@mark = mark
		@number = number
		@type = type
	end
end
