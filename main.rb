require './model/player.rb'
require './model/game.rb'
require'./model/trump.rb' 

def main

    # スタート,ルール
    # 手札配る 4人
    # （順番決める）
    # play
    # 順位

    game = Game.new()
    game.welcome
    game.start
    game.end


    

end

main if __FILE__ == $0