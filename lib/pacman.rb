require 'pacman/board'

class Pacman
  attr_accessor :board, :num_ticks

  def initialize
    @num_ticks = 0
    @quit      = false
    @board     = Board.from_string \
      "WWWWWWWWWWWWWWWWWWWWWWWWWWWW",
      "W............WW............W",
      "W.WWWW.WWWWW.WW.WWWWW.WWWW.W",
      "WvWWWW.WWWWW.WW.WWWWW.WWWWvW",
      "W.WWWW.WWWWW.WW.WWWWW.WWWW.W",
      "W..........................W",
      "W.WWWW.WW.WWWWWWWW.WW.WWWW.W",
      "W.WWWW.WW.WWWWWWWW.WW.WWWW.W",
      "W......WW....WW....WW......W",
      "WWWWWW.WWWWW WW WWWWW.WWWWWW",
      "     W.WWWWW WW WWWWW.W     ",
      "     W.WW    r     WW.W     ",
      "     W.WW WW====WW WW.W     ",
      "WWWWWW.WW W      W WW.WWWWWW",
      "      .   W iyo  W   .      ",
      "WWWWWW.WW W  J   W WW.WWWWWW",
      "     W.WW WWWWWWWW WW.W     ",
      "     W.WW          WW.W     ",
      "     W.WW WWWWWWWW WW.W     ",
      "WWWWWW.WW WWWWWWWW WW.WWWWWW",
      "W............WW............W",
      "W.WWWW.WWWWW.WW.WWWWW.WWWW.W",
      "W.WWWW.WWWWW.WW.WWWWW.WWWW.W",
      "Wv..WW.......p........WW..vW",
      "WWW.WW.WW.WWWWWWWW.WW.WW.WWW",
      "WWW.WW.WW.WWWWWWWW.WW.WW.WWW",
      "W......WW....WW....WW......W",
      "W.WWWWWWWWWW.WW.WWWWWWWWWW.W",
      "W.WWWWWWWWWW.WW.WWWWWWWWWW.W",
      "W..........................W",
      "WWWWWWWWWWWWWWWWWWWWWWWWWWWW"
  end

  def quit!
    @quit = true
  end

  def quit?
    @quit
  end

  def pacman
    board.pacman
  end

  def over?
    quit? || pacman.game_over?
  end

  def each_row(&block)
    board.each_row &block
  end

  def face_pacman(direction)
    pacman.face direction
  end

  def tick
    raise "Don't tick time after the game is over!" if over?
    prev_board = @board
    next_board = @board = prev_board.next_board
    pacman     = next_board.pacman

    move_pieces              prev_board, next_board
    handle_passthrough_ghost prev_board, next_board, pacman
    handle_collisions        next_board, pacman

    self.num_ticks += 1
  end

  def move_pieces(prev_board, next_board)
    prev_board.each_piece do |piece|
      move = piece.desired_move(prev_board)
      next_board.move(piece, move)
    end
  end

  def handle_passthrough_ghost(prev_board, next_board, pacman)
    collisions_for(prev_board, pacman).select(&:ghost?).each do |piece|
      fight_ghost next_board, pacman, piece
    end
  end

  def handle_collisions(board, pacman)
    collisions_for(board, pacman).each do |piece|
      if    piece.ghost?   then fight_ghost board, pacman, piece
      elsif piece.food?    then eat_food    board, pacman, piece
      elsif piece.vitamin? then eat_vitamin board, pacman, piece
      elsif piece.empty?   then # noop
      else raise "Pacman doesn't know what to do with: #{piece}"
      end
    end
  end

  def collisions_for(board, pacman)
    board.pieces_on(pacman)
  end

  def eat_food(board, pacman, food)
    pacman.eat food
    board.remove food
  end

  def fight_ghost(board, pacman, ghost)
    if pacman.roid_rage?
      pacman.eat ghost
      ghost.go_directly_to_jail
    else
      pacman.die!
    end
  end

  def eat_vitamin(board, pacman, vitamin)
    pacman.eat vitamin
    board.remove vitamin
  end
end
