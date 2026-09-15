
import Foundation
let RULES = """
Правила:
1. Ходы:
    Игроки по очереди бросают игральный кубик и передвигают свою
фишку на выпавшее количество клеток
2. Лестница (Удача):
    Если фишка останавливается на клетке, где
находится низ лестницы, игрок поднимается по ней до клетки на верху
лестницы
3. Змея (Неудача):
    Если фишка останавливается на клетке, где
находится голова змеи, игрок скатывается вниз по ней до клетки на хвосте
змеи
4. Точный бросок:
    Чтобы занять последнюю клетку, нужно выбросить точное
число. Если выпавшее число больше, чем нужно для победы, фишка
остается на месте и ждет следующего хода\n
"""


func generateRandomEmoji() -> String{
    return "🫥"
}


class Player{
    static var numberOfPlayers = 0
    let name:String
    let avatar:String
    var turn: Int = 0
    let index: Int
    init(name: String, avatar: String) {
        Self.numberOfPlayers+=1
        index = Self.numberOfPlayers
        self.name = name != "" ? name : "\(index)"
        self.avatar = avatar != "" ? avatar : generateRandomEmoji()
    }
    var nickname:String {
        return "\(name) \(avatar)"
    }
    static func reset(){
        Self.numberOfPlayers = 0
    }
}

class Cell{
    var players: [Player] = []
    var value:Int
    init(bonus:Int=0) {
        self.value = bonus
    }
    
}

class GameBoard{
    var board: [Cell]
    let size:Int
    private var currentPlayerIndex = 0;
    init(size:Int){
        self.size = min(size, 12)
        self.board = [Cell](repeating: Cell(), count: size*size)
    }
    func generateBonuses(){
        let bonusCount = (self.size + 1) / 2
        
    }
    
}

class MainGame{
    var gameBoard:GameBoard
    var players:[Player] = []
    var numberOfPlayers, boardSize:Int
    init(players: [Player], numberOfPlayers: Int, boardSize: Int) {
        self.players = players
        self.numberOfPlayers = numberOfPlayers
        self.boardSize = boardSize
        self.gameBoard = GameBoard(size: boardSize)
    }
    
}
func startGame(){
    print("ИГРА 'ЗМЕИ И ЛЕСТНИЦЫ'\nХотитe прочитать правила? (Y - Да) ")
    var answer:String?
    answer = readLine() ?? ""
    if answer == "Y"{
        print(RULES)
    }
    repeat {
        print("Введите размер доски (5...12):")
        answer = readLine() ?? ""
    } while answer == nil || !answer!.allSatisfy({$0.isNumber}) || !(5...12).contains(Int(answer!)!)
    let boardSize = Int(answer!)!
    print("Размер: \(boardSize)")
    repeat {
        print("Введите кол-во игроков (2...5):")
        answer = readLine() ?? ""
    } while answer == nil || !answer!.allSatisfy({$0.isNumber}) || !(2...5).contains(Int(answer!)!)
    let numberOfPlayers = Int(answer!)!
    print("Игроков: \(numberOfPlayers)")
    var players:[Player] = []
    var name, avatar:String
    for i in 1...numberOfPlayers{
        print("Введите имя \(i) игрока:")
        name = readLine()!
        print("Введите аватар (смайл через Ctrl+Cmd+Space), символ):")
        avatar = readLine()!
        players.append(Player(name: name, avatar: avatar))
        print("Зарегистрирован \(i) Игрок \(players[players.count-1].nickname)\n")
    }
    
}
startGame()
