import Foundation
let MODE = true // true - xcode, false - terminal
let RULES = """
Правила:
1. Ходы:
    Игроки по очереди бросают игральный кубик и передвигают свою
фишку(смайл-аватар)🤗 на выпавшее количество клеток
2. Лестница (Удача):
    Если фишка останавливается на клетке, где
находится низ лестницы 🪜, игрок поднимается по ней до клетки на верху
лестницы
3. Змея (Неудача):
    Если фишка останавливается на клетке, где
находится голова змеи 🐍, игрок скатывается вниз по ней до клетки на хвосте
змеи
4. Точный бросок:
    Чтобы занять последнюю клетку, нужно выбросить точное
число. Если выпавшее число больше, чем нужно для победы, фишка
остается на месте и ждет следующего хода\n
"""


//TODO: Доработать чтобы не было повторок
func generateRandomEmoji() -> String{
    let emojiRange = (0x1f600...0x1f64f)
    while true{
        if let emoji = UnicodeScalar(Int.random(in: emojiRange)), emoji.properties.isEmojiPresentation  {
            return String(emoji)
        }
    }
}

class Player{
    static var numberOfPlayers = 0
    let name:String
    let avatar:String
    var pos: Int = 0
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
enum CellType{
    case Default, Snake, Ladder, Finish
}
enum TurnRes{
    case OK(_ msg:String?), Fail(_ msg:String?), GameOver(_ msg:String?)
}
class Cell{
    var players: [Player] = []
    let type:CellType
    let value:Int
    init(type:CellType = .Default, value:Int = 0 ) {
        self.type = type
        self.value = value
    }
    
}

class GameBoard{
    var board: [Cell]
    let size:Int
    private var currentPlayerIndex = 0;
    init(size:Int){
        //TODO: Добавить генерацию бонусов
        self.size = min(size, 12)
        self.board = (0..<size*size).map { _ in Cell() }
        board[5-1] = Cell(type: .Ladder, value: 15)
        board[10-1] = Cell(type: .Snake, value: 3)
        board[size*size-1] = Cell(type: .Finish)
    }
    func updatePlayerPos(player:Player, turn:Int=0, initial:Bool = false) -> TurnRes{
        var msg:String? = nil
        
        if initial{
            board[0].players.append(player)
            msg = nil
            return .OK(msg)
        }
        
        let currPos = player.pos
        let targetPos = currPos + turn
        if !(0..<size*size).contains(currPos) || !(0..<size*size).contains(targetPos) {
            msg = "Ход не возможен, выход за границу."
            return .Fail(msg)
        }
        
        let currCell = board[currPos]
        if !currCell.players.contains(where: {$0 === player}) {
            msg = "Error1"
            return .Fail(msg)
        }
        
        var targetCell = board[targetPos]
        var result:TurnRes
        switch (targetCell.type){
        case .Ladder, .Snake:
            let newTargetPos = targetCell.value
            if !(0..<size*size).contains(newTargetPos) {
                msg = "Error2"
                return .Fail(msg)
            }
            let res:TurnRes = switch targetCell.type {
            case .Ladder:
                    .OK("Вы попали на лестницу 🪜 до клетки \(newTargetPos+1)")
            case .Snake:
                    .Fail("Вы попали на голову змеи 🐍 до клетки \(newTargetPos+1)")
            default:
                    .Fail(nil)
            }
            targetCell = board[newTargetPos]
            player.pos = newTargetPos
            result = res
        case .Finish:
            result = .GameOver(nil)
            player.pos = targetPos
        case .Default:
            result = .OK(nil)
            player.pos = targetPos
        }
        currCell.players.remove(at: currCell.players.firstIndex(where: {$0 === player})!)
        targetCell.players.append(player)
        return result
    }
    func printBoard() {
        let colWidth = 14
        let cellLine = String(repeating: "-", count: colWidth)
        let horizontalDivider = "#" + repeatElement(cellLine, count: size).joined(separator: "#") + "#"
        
        print(horizontalDivider)
        
        for row in 0..<size {
            let actualRow = size - 1 - row
            var rowNumbers = (1...size).map { actualRow * size + $0 }
            if actualRow % 2 != 0 {
                rowNumbers.reverse()
            }
            
            var line1 = "#" // заголовок
            var line2 = "#" // 1 ряд
            var line3 = "#" // 2 ряд
            
            for cellNumber in rowNumbers {
                let cellData = board[cellNumber - 1]
                let cellLines = buildCellLines(cellNumber: cellNumber, cellData: cellData)
                
                line1 += cellLines[0] + "#"
                line2 += cellLines[1] + "#"
                line3 += cellLines[2] + "#"
            }
            
            print(line1)
            print(line2)
            print(line3)
            print(horizontalDivider)
        }
        print()
    }
    
    // Внутренняя функция для форматирования одной клетки
    private func buildCellLines(cellNumber: Int, cellData: Cell) -> [String] {
        var lines = [String]()
        
        // Заголовок
        switch cellData.type {
        case .Snake:
            lines.append(String(format: "   %2d🐍>%2d    ", cellNumber, cellData.value+1))
        case .Ladder:
            lines.append(String(format: "   %2d🪜>%2d    ", cellNumber, cellData.value+1))
        default:
            lines.append(String(format: "      %2d      ", cellNumber))
        }
        
        // Аватары
        var avatars = cellData.players.map { $0.avatar }
        while avatars.count < 6 {
            avatars.append("  ")
        }
        avatars = Array(avatars.prefix(6))
        
        let row1 = "   \(avatars[0]) \(avatars[1]) \(avatars[2])   "
        let row2 = "   \(avatars[3]) \(avatars[4]) \(avatars[5])   "
        
        lines.append(row1)
        lines.append(row2)
        
        return lines
    }
    
}

class MainGame{
    var gameBoard:GameBoard
    var isActive = true
    var currPlayerIndex = 0
    var players:[Player] = []
    var usedAvatars:Set<String> = []
    var boardSize:Int
    init(players: [Player], boardSize: Int) {
        self.players = players
        self.boardSize = boardSize
        self.gameBoard = GameBoard(size: boardSize)
    }
    func initialize_players(){
        for p in players{
            let _ = gameBoard.updatePlayerPos(player: p, initial: true)
        }
    }
    func make_turn(){
        if !(0..<players.count).contains(currPlayerIndex){return}
        let currPlayer = players[self.currPlayerIndex]
        var answer: Int
        var result:TurnRes
        //TODO: Добавить ввод игроком выпавшего значения
        print("Ход игрока \(currPlayer.nickname)\nНажмите, чтобы бросить кубик\n")
        let _ = readLine()
        answer = throw_cube()
        print("Выпало \(answer)")
        result = gameBoard.updatePlayerPos(player: currPlayer, turn: answer)
        switch result{
        case .GameOver:
            self.isActive = false
            return
        case .OK(let msg):
            if msg != nil{
                print("Удача👑: \(msg!)")
            }
        case .Fail(let msg):
            if msg != nil{
                print("Неудача💔: \(msg!)")
            }
        }
        
        self.currPlayerIndex =  (self.currPlayerIndex + 1) % players.count
        print("Нажмите return, чтобы передать ход...")
        let _ = readLine()

        
    }
    //TODO: Улучшить анимацию
    func throw_cube() -> Int{
        return Int.random(in: 1...6)
    }
    
}
func startGame(_ debug:Bool=true) -> Bool{
    print("ИГРА 'ЗМЕИ И ЛЕСТНИЦЫ'\nХотитe прочитать правила? (Y - Да) ")
    var answer:String?
    answer = readLine()
    if let answer, answer.lowercased() == "y"{
        print(RULES)
    }
    
    while true {
        print("Введите размер доски (5...9):")
        answer = readLine()
        if let answer, answer != "" && answer.allSatisfy({$0.isNumber}) && (5...9).contains(Int(answer)!){
            break
        }
    }
    let boardSize = Int(answer!)!
    print("Размер: \(boardSize)")
        
    while true {
        print("Введите кол-во игроков (2...6):")
        answer = readLine()
        if let answer, answer != "" && answer.allSatisfy({$0.isNumber}) && (2...6).contains(Int(answer)!){
            break
        }
    }
    let numberOfPlayers = Int(answer!)!
    print("Игроков: \(numberOfPlayers)")
        
    var players:[Player] = []
    var name, avatar:String
    for i in 1...numberOfPlayers{
        print("Введите имя \(i) игрока:")
        name = readLine()!
        print("Введите аватар (смайл через Ctrl+Cmd+Space):")
        avatar = readLine()!
        players.append(Player(name: name, avatar: avatar))
        print("Зарегистрирован \(i) Игрок \(players[players.count-1].nickname)\n")
    }
        
    let game = MainGame(players: players, boardSize: boardSize)
    game.initialize_players()
    game.gameBoard.printBoard()
    repeat{
        game.make_turn()
        game.gameBoard.printBoard()
    }while game.isActive
    print("Победил \(game.players[game.currPlayerIndex].nickname)")
    print("Хотите начать новую игру? (Y - Да)")
    answer = readLine()
    if let answer, answer.lowercased() == "y"{
        return true
    }
    return false
    
}

while startGame(MODE){}
