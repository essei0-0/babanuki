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
        create_players
        display_players
        distribute_cards
        display_my_cards

        puts ""
        puts "順番を決めています。"
        puts ""

        decide_play_order

        puts "順番が決まりました。"
        puts ""

        display_play_order

        sleep(1)
    end

    def start()
        puts ""
        puts "ペアのカードを捨てています。"
        discard_pair_cards
        #sleep(1)

        #ターン数
        turn = 1
        #残りプレイヤー
        remaining_player = 4

        #各プレイヤーのランキングを初期化
        @shuffled_players.map{|player| player.rank = 4}

        confirm_before_start

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
                puts ""
                puts "#{active_player.name}さんの番です。"

                if !active_player.is_cp
                    puts "現在の手札はこちらです"
                    puts ""
                    puts active_player.check_cards
                end
                #sleep(1)

                puts ""
                puts "#{passive_player.name}さんのカードを一枚引いてください"
                # 次のひとのカードを引く処理
                passive_player_cards_num = passive_player.cards.length
                array = Array.new(passive_player_cards_num){'#'}
                puts ""
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
                #sleep(1)
                # カードを引かれた人の手持ちが0かどうかを判定する処理
                if passive_player.cards.length == 0
                    remaining_player -= 1
                    passive_player.rank = 4 - remaining_player
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
        puts ""
        puts "##############################"  
        puts "ランキング"
        puts "##############################"  
        ranked_players.each do |player|
            puts "#{player.rank}位：#{player.name}"
        end

        player_rank = @players[0].rank

        puts ""
        puts "結果は#{@players[0].rank}位でした。"

        case player_rank
        when 1 then
            puts "1位おめでとう!!"
        when (2..3) then
            puts "惜しい、、ナイスファイト！！"
        when 4 then
            puts "最下位だね、リベンジしよう！"
        end
    end

    def rule()
        puts ""
        puts "##############################"       
        puts "こちらを参照してください。"
        puts "https://www.card-asobi.com/babanuki.html"
        puts "##############################"  
    end



    def end()
        puts ""
        puts "##############################" 
        puts "thank you!!"
        puts "##############################" 
    end

    private
    def create_players
        # 人数を決める(とりあえず4人で)
        player = Player.new("P1", false)

        cp_names = ['com1', 'com2', 'com3']
        cps = Player.create_cps(cp_names)

        @players = [player] + cps
    end

    def display_players
        puts ""
        puts "##############################"
        puts "対戦相手はこちらです。"
        @players.each do |player|
            player.is_cp ? (puts "cp    ：#{player.name}") : (puts "あなた：#{player.name}")
        end
        puts "##############################"
    end

    def distribute_cards
        #トランプカードを生成する。
        cards = Trump.new()

        #トランプカードをシャッフルする。
        shuffled_cards = cards.shuffled()
        # p shuffled_cards

        #トランプカードを配る
        puts ""
        puts "カードを配っています。"
        shuffled_cards.each_with_index do |card, i|
            @players[i%4].get_card(card)
        end
        puts "カードを配りました。"
    end

    def display_my_cards
        #自分の手札を表示する。
        puts "あなた(#{@players[0].name})の手札はこちらです。"
        puts ""
        puts @players[0].check_cards
    end

    def decide_play_order
        #順番を決める
        @shuffled_players = @players.shuffle
        @shuffled_players.each_with_index do |player, i|
            @shuffled_players[i].target = @shuffled_players[(i+1)%4]
        end
    end

    def display_play_order
        #プレイ順を表示する
        @shuffled_players.each_with_index do |player, i|
            puts "#{i+1}番目：#{player.name}"
        end
    end

    def discard_pair_cards
        #配られた手持ちのペアカードを捨てる処理
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
    end

    def confirm_before_start
        ready = 'n'
        while ready != 'y'
            puts ""
            puts "ゲームを始めます。準備はいいですか？(y/n)"
            ready = $stdin.gets.chomp!
        end
    end




end