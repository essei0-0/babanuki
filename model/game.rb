class Game
    attr_accessor :second
    def initialize
        @second = 1.5
    end
    def welcome
        while true
            content = ['1.ゲームをはじめる', '2.ルールをみる', '3.設定']
            display_as_heading(content)
            start_input = $stdin.gets.chomp!

            case start_input
            when '1' then
                puts "1.ゲームをはじめる"
                self.prepare
                break
            when '2' then
                puts "2.ルールをみる"
                self.rule
            when '3' then
                puts "3.設定"
                self.setting
            else
                puts "もう一度入力してください。"
            end
        end
    end

    def prepare
        create_players
        delay_processing(display_players, @second)
        delay_processing(distribute_cards, @second)
        delay_processing((puts "カードを配りました。"), @second)
        delay_processing(display_my_cards, @second)

        puts ""
        delay_processing((puts "順番を決めています。"), @second)
        puts ""

        decide_play_order
        
        delay_processing((puts "順番が決まりました。"), @second)
        puts ""

        display_as_heading("順番")
        delay_processing(display_play_order, @second)
    end

    def start
        puts ""
        puts "ペアのカードを捨てています。"
        delay_processing(discard_pair_cards, @second)

        #ターン数
        turn = 1
        #残りプレイヤー
        @remaining_player = 4

        #各プレイヤーのランキングを初期化
        @shuffled_players.map{|player| player.rank = 4}

        confirm_before_start

        delay_processing(display_as_heading("Game Start!"), @second)
        
        while @remaining_player > 1 do
            delay_processing(display_as_heading("#{turn}ターン目"), @second)

            @shuffled_players.each_with_index do |player, i|
                next if player.rank < 4

                active_player = player
                passive_player = player.target
                puts ""
                delay_processing((puts "#{active_player.name}さんの番です。"), @second)

                if !active_player.is_cp
                    puts "現在の手札はこちらです"
                    puts ""
                    puts active_player.check_cards
                end

                puts ""
                draw_card = move_card(passive_player, active_player)

                # カードを引かれた人の手持ちが0かどうかを判定する処理
                if passive_player.cards.length == 0
                    @remaining_player -= 1
                    passive_player.rank = 4 - @remaining_player
                    active_player.target = passive_player.target
                end

                # 引いたカードと同じカードがあるか判定する処理
                if pear_index = active_player.cards.map(&:number).index(draw_card.number)
                    # 引いたカードと手札のカードのペアを捨てる処理
                    active_player.cards.delete_at(pear_index)

                    # カードを引いた人の手持ちが0かどうか判定する処理
                    if active_player.cards.length == 0
                        @remaining_player -= 1
                        active_player.rank = 4 - @remaining_player
                        @shuffled_players[i-1].target = passive_player
                    end
                else
                    # 引いたカードを手札に加える処理
                    active_player.get_card(draw_card)
                end    
            end
            turn += 1
        end       
        delay_processing(display_ranking, @second)
    end

    def rule
        content = ['こちらを参照してください。', 'https://www.card-asobi.com/babanuki.html']
        display_as_heading(content)
    end

    def setting
        display_as_heading("設定")
        while true
            speed_lists = ["1.ゆっくり", "2.ふつう（デフォルト）", "3.はやい", "9.デバッグモード"]
            puts "出力のスピードを選択してください（数字で入力）"
            puts speed_lists
            speed = $stdin.gets.chomp!

            case speed
            when '1' then
                self.second = 2
                break
            when '2' then
                self.second = 1.5
                break
            when '3' then
                self.second = 1
                break
            when '9' then
                self.second = 0
                break
            else
                puts "無効な値です。もう一度入力してください。"
                
            end
        end
    end



    def end
        display_as_heading("thank you!!")
    end


    private

    #プレイヤーを作成する
    def create_players
        player = Player.new("P1", false)

        cp_names = ['com1', 'com2', 'com3']
        cps = Player.create_cps(cp_names)

        @players = [player] + cps
    end

    #プレイヤーの表示
    def display_players
        display_as_heading('対戦相手')
        @players.each do |player|
            player.is_cp ? (puts "cp    ：#{player.name}") : (puts "あなた：#{player.name}")
        end
    end

    #トランプカードを作成し、シャッフルと配布をする処理
    def distribute_cards
        #トランプカードを生成する。
        cards = Trump.new()

        #トランプカードをシャッフルする。
        shuffled_cards = cards.shuffled
        # p shuffled_cards

        #トランプカードを配る
        puts ""
        puts "カードを配っています。"
        shuffled_cards.each_with_index do |card, i|
            @players[i%4].get_card(card)
        end
    end

    #自分の手札を表示する処理
    def display_my_cards
        puts "あなた(#{@players[0].name})の手札はこちらです。"
        puts ""
        puts @players[0].check_cards
    end

    #順番を決める処理
    def decide_play_order
        @shuffled_players = @players.shuffle
        @shuffled_players.each_with_index do |player, i|
            @shuffled_players[i].target = @shuffled_players[(i+1)%4]
        end
    end

    #プレイ順を表示する処理
    def display_play_order
        @shuffled_players.each_with_index do |player, i|
            puts "#{i+1}番目：#{player.name}"
        end
    end

    #配られた手持ちのペアカードを捨てる処理
    def discard_pair_cards
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

    #ゲームを始めるか確認する処理
    def confirm_before_start
        ready = 'n'
        while ready != 'y'
            puts ""
            puts "ゲームを始めます。準備はいいですか？(y/n)"
            ready = $stdin.gets.chomp!
        end
    end

    #from_playerからto_playerへカードを移動させる処理
    def move_card(from_player, to_player)
        delay_processing((puts "#{from_player.name}さんのカードを一枚引いてください"), @second)
        # 次のひとのカードを引く処理
        from_player_cards_num = from_player.cards.length
        array = Array.new(from_player_cards_num){'#'}
        puts ""
        delay_processing((print "#{array}\n"), @second)
        delay_processing((puts "左から何番目のカードを引きますか?(1~#{from_player_cards_num}):"), @second)

        if to_player.is_cp
            draw_num = rand(1..from_player_cards_num)
            delay_processing((puts "#{to_player.name}さんは#{draw_num}番目のカードを引きました。"), @second)
        else 
            draw_num = $stdin.gets.to_i

            #標準入力が指定した範囲でない場合のエラー処理
            while !(1..from_player_cards_num).include?(draw_num)
                puts "1~#{from_player_cards_num}の数字を入力してください"
                draw_num = $stdin.gets.to_i
            end
        end

        draw_card = from_player.cards[draw_num - 1]
        from_player.cards.delete(draw_card)
        return draw_card
    end

    #順位を表示する処理
    def display_ranking
        ranked_players = @shuffled_players.sort_by(&:rank)
        display_as_heading('ランキング')

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

    #contentを見出しとして表示する。
    def display_as_heading(content)
        puts ""
        puts "##############################"  
        puts content
        puts "##############################"
        puts "" 
    end

    def delay_processing(cmd,second)
        start_time = Time.now()
        cmd
        processing_time = Time.now - start_time
        sleep(second - processing_time) if (second > processing_time)
    end
end