require_relative 'card.rb'
class Trump
    attr_reader :cards

    def initialize()
        #トランプカード生成
        @cards = []
        marks  = ['spade', 'heart', 'diamond', 'club']
        numbers = (1..13)
        type = 'normal'

        # ジョーカー以外生成
        marks.each do |mark|
            numbers.each do |number|
                card = Card.new(mark, number, type)
                @cards << card
            end
        end
        # ジョーカー生成
        mark = nil
        number = nil
        type = 'joker'
        joker = Card.new(mark, number, type)
        @cards << joker
        # p @cards
    end

    def shuffled()
        @cards.shuffle
    end

    def distributed()

    end
end