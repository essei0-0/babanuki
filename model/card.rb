class Card
    attr_reader :mark, :number, :type
    

    def initialize(mark, number, type)
        @mark = mark
        @number = number
        @type = type
    end
end
