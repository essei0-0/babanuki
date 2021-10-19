class Game

    def welcome()
        while true
            puts ""
            puts "##############################"
            puts "1.ゲームをはじめる"
            puts "2.ルールをみる"
            puts "################################"
            start_input = $stdin.gets.chomp!

            if start_input == '1'
                puts "1.ゲームをはじめる"
                self.prepare()
                break
            elsif start_input == '2'
                puts "2.ルールをみる"
                self.rule()
            else
                puts "もう一度入力してください。"
            end
        end
    end

    def prepare()
        # 人数を決める(とりあえず4人で)
        player = Player.new("狐火", false)

        cp_names = ['輪入道', '空也MC', 'DJなおや']
        cps = Player.create_cps(cp_names)

        @players = [player] + cps
        
        puts ""
        sleep(1)
        puts "##############################"
        puts "対戦相手はこちらです。"
        @players.each do |player|
            player.is_cp ? (puts "cp    ：#{player.name}") : (puts "あなた：#{player.name}")
        end
        puts "##############################"

        #トランプカードを生成する。
        cards = Trump.new()

        #トランプカードをシャッフルする。
        shuffled_cards = cards.shuffled()
        # p shuffled_cards

        #トランプカードを配る
        puts ""
        puts "カードを配ってます。"
        shuffled_cards.each_with_index do |card, i|
            @players[i%4].get_card(card)
        end
        sleep(1)
        #手札確認
        puts "カードを配りました。"
        sleep(1)
        puts "あなた(#{@players[0].name})の手札はこちらです。"
        sleep(1)
        puts ""
        puts @players[0].check_cards
        
        # デバッグ用
        # puts @players[1].name, @players[1].check_cards
        # puts "--------------------"
        # puts @players[2].name, @players[2].check_cards
        # puts "--------------------"
        # puts @players[3].name, @players[3].check_cards

        #順番を決める
        puts ""
        puts "順番を決めています。"

        @shuffled_players = @players.shuffle
        @shuffled_players.each_with_index do |player, i|
            @shuffled_players[i].target = @shuffled_players[(i+1)%4]
            # puts("#{@shuffled_players[i].name} : #{@shuffled_players[i].target.name}")
        end
        sleep(1)
    end

    def start()
        #手持ちのペアカードを捨てる処理
        puts ""
        puts "ペアのカードを捨てています。"
        @shuffled_players.each do |player|
            player.cards.each_with_index do |card, i|     
                next if card.place == 'table'
                card_num_array = player.cards[(i+1)..-1].map(&:number)
                if pear_index = card_num_array.find_index(card.number)
                    card.place = 'table'
                    player.cards[i + pear_index].place = 'table'
                end
            end
        end
        sleep(1)

        turn = 1
        remaining_player = 4
        @shuffled_players.map{|player| player.rank = 4}

        ready = 'n'
        while ready != 'y'
            puts ""
            puts "ゲームを始めます。準備はいいですか？(y/n)"
            ready = $stdin.gets.chomp!
        end

        puts ""
        puts "##############################"
        puts "Game Start!"
        puts "##############################"
        sleep(1)

        while remaining_player > 1 do
            puts ""
            puts "##############################"
            puts "#{turn}ターン目"
            puts "##############################"

            @shuffled_players.each_with_index do |player, i|
                next if player.rank < 4

                active_player = player
                passive_player = player.target
                # puts "ターゲット：#{active_player.target}"

                puts "#{active_player.name}さんの番です。"
                if !active_player.is_cp
                    puts "現在の手札はこちらです"
                    puts active_player.check_cards
                end

                puts "#{passive_player.name}さんのカードを一枚引いてください"
                # 次のひとのカードを引く処理
                passive_player_cards_num = passive_player.cards.length
                array = Array.new(passive_player_cards_num){'#'}
                print array
                puts "左から何番目のカードを引きますか?(1~#{passive_player_cards_num}):" 

                if active_player.is_cp
                    draw_num = rand(1..passive_player_cards_num)
                    puts "#{active_player.name}さんは#{draw_num}番目のカードを引きました。"
                else 
                    draw_num = $stdin.gets.to_i

                    #標準入力が指定した範囲でない場合のエラー処理
                    while !(1..passive_player_cards_num).include?(draw_num)
                        puts "1~#{passive_player_cards_num}の数字を入力してください"
                        draw_num = $stdin.gets.to_i
                    end
                end

                draw_card = passive_player.cards[draw_num-1]
                passive_player.cards.delete(draw_card)
                # カードを引かれた人の手持ちが0かどうかを判定する処理
                if passive_player.cards.length == 0
                    remaining_player -= 1
                    passive_player.rank = 4 - remaining_player
                    puts "rank"
                    puts 4 - remaining_player
                    active_player.target = passive_player.target
                end

                # 引いたカードと同じカードがあるか判定する処理
                if pear_index = active_player.cards.map(&:number).index(draw_card.number)
                    # 引いたカードと手札のカードのペアを捨てる処理
                    active_player.cards.delete_at(pear_index)

                    # カードを引いた人の手持ちが0かどうか判定する処理
                    if active_player.cards.length == 0
                        remaining_player -= 1
                        active_player.rank = 4 - remaining_player
                        puts "rank"
                        puts 4 - remaining_player
                        @shuffled_players[i-1].target = passive_player
                    end
                else
                    # 引いたカードを手札に加える処理
                    active_player.get_card(draw_card)
                end
            end
            turn += 1
        end
        
        # 順位を表示
        ranked_players = @shuffled_players.sort_by(&:rank)
        puts "-------ランキング-------"
        ranked_players.each do |player|
            puts "#{player.rank}位：#{player.name}"
        end
    end

    def rule()
        puts("ググってくれい")
    end



    def end()
        puts "thank you!!"
    end
end