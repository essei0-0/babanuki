require './model/player.rb'
require './model/game.rb'
require'./model/trump.rb' 

def main()

    # スタート,ルール
    # 手札配る 4人
    # （順番決める）
    # play
    # 順位

    # welcome()
    game = Game.new()

    # if game.start() == '1'
    #     game.prepare()
    # elsif game.start() == '2'
    #     game.rule()
    # else
    #     puts "もう一度入力してください。"
    #     puts "1.ゲームをはじめる\n2.ルールをみる"
    #     start_input = $stdin.gets.to_i 
    # end

    game.prepare()

    game.start()

    game.end()


    

end

main() if __FILE__ == $0