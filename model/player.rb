class Player
    attr_reader :name
    attr_accessor :is_cp, :cards, :target, :rank

    def initialize(name, is_cp)
        @name = name
        @is_cp = is_cp
        @cards = []
    end

    def self.create_cps(names)
        names.map do |name|
            Player.new(name, true)
        end
    end

    # cardを取得する
    def get_card(card)
        @cards << card
    end

    # cardを捨てる

    # 手札を確認する
    def check_cards
        cards.map do |card|
            card.type == 'normal'? {mark: card.mark, number: card.number}: card.type
        end
    end


end