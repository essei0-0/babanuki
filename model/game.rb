class Game
    attr_accessor :cp_num

    # def initialize(cp_num)
    #     @cp_num = cp_num
    # end


    def welcome()
        puts "1.ゲームをはじめる\n2.ルールをみる"
        start_input = $stdin.gets
        return start_input
    end

    def prepare()
        # 人数を決める(とりあえず4人で)
        player = Player.new("狐火", false)
        p player

        cp_names = ['輪入道', '空也MC', 'DJなおや']
        cps = Player.create_cps(cp_names)
        p cps

        @players = [player] + cps
        p @players

        #トランプカードを生成する。
        cards = Trump.new()

        #トランプカードをシャッフルする。
        shuffled_cards = cards.shuffled()
        # p shuffled_cards

        #トランプカードを配る

        shuffled_cards.each_with_index do |card, i|
            @players[i%4].get_card(card)
        end

        #手札確認
        puts "準備が完了しました。"
        puts "あなたの手札はこちらです。"
        puts @players[0].name, @players[0].check_cards
        puts "--------------------"
        
        # デバッグ用
        puts @players[1].name, @players[1].check_cards
        puts "--------------------"
        puts @players[2].name, @players[2].check_cards
        puts "--------------------"
        puts @players[3].name, @players[3].check_cards

        #順番を決める
        @shuffled_players = @players.shuffle
        @shuffled_players.each_with_index do |player, i|
            @shuffled_players[i].target = @shuffled_players[(i+1)%4]
            puts("#{@shuffled_players[i].name} : #{@shuffled_players[i].target.name}")
        end
    end

    def start()
        turn = 1
        winners = []

        while winners.length < 3 do
            puts "#{turn}ターン目"
            @shuffled_players.map do |player|
                @shuffled_players.each do |test|
                    puts test.cards.length
                end
                active_player = player
                passive_player = player.target

                puts "#{active_player.name}さんの番です。"
                puts "#{passive_player.name}さんのカードを一枚引いてください"

                # 次のひとのカードを引く処理
                passive_player_cards_num = passive_player.cards.length
                array = Array.new(passive_player_cards_num){'*'}
                print array
                puts "左から何番目のカードを引きますか?(1~#{passive_player_cards_num}):" 
                draw_num = $stdin.gets.to_i

                p draw_card = passive_player.cards[draw_num-1]

                passive_player.cards.delete_at(draw_num-1)
                # カードを引かれた人の手持ちが0かどうかを判定する処理
                if passive_player.cards.length == 0
                    winners << passive_player
                    active_player.target = passive_player.target
                end

                # 引いたカードと同じカードがあるか判定する処理
                
                if pear_index = active_player.cards.map(&:number).index(draw_card.number)
                    # 引いたカードと手札のカードのペアを捨てる処理
                    active_player.cards.delete_at(pear_index)

                    # カードを引いた人の手持ちが0かどうか判定する処理
                    if active_player.cards.length == 0
                        winners << active_player
                    end
                else
                    # 引いたカードを手札に加える処理
                    active_player.get_card(draw_card)
                end
            end
            turn += 1
        end
        
        # 順位を表示
        puts winners
    end

    def rule()
        puts("ググってくれい")
    end



    def end()
        puts "thank you!!"
    end
end