require 'pacman/pieces'

class Pacman
  class Board
    def self.from_string(*rows)
      pieces = rows.join("\n").lines.map(&:chomp).map do |row|
        row.chars.map { |char| Piece.for(char).new }
      end
      new pieces
    end

    class Pieces
      def initialize(pieces)
        @pieces = Array(pieces).dup
        @pieces.each do |x|
          raise x.inspect unless x.kind_of? Piece
        end
        @pieces << Piece.for(:empty).new unless @pieces.any? &:empty?
      end

      def initialize_copy(original)
        @pieces = Array.new @pieces
      end

      def inspect
        "[Pieces:#{@pieces.reject(&:empty?).map(&:inspect).join(', ')}]"
      end

      def add(piece)
        raise piece.inspect unless piece.kind_of? Piece
        @pieces.unshift piece
      end

      def remove(piece)
        found = find piece
        found or raise "Could not delete #{piece.inspect} from #{inspect}"
        @pieces.delete found
        found
      end

      def each(&block)
        return to_enum :each unless block_given?
        @pieces.each &block
        self
      end

      def map(&block)
        return to_enum :map unless block_given?
        Pieces.new @pieces.map(&block)
      end

      def select(&block)
        return to_enum :select unless block_given?
        Pieces.new @pieces.select(&block)
      end

      def any?(*args, &block)
        @pieces.any? *args, &block
      end

      def include?(piece)
        !!find(piece)
      end

      def first
        @pieces.first
      end

      def find(piece)
        return nil unless piece.kind_of? Piece
        @pieces.find { |p| p.id == piece.id }
      end

      def to_ary
        @pieces.dup
      end

      def without(piece)
        dup.tap { |pieces| pieces.remove piece if include? piece }
      end
    end


    attr_reader :time_events

    def initialize(raw_board, time_events:[])
      @time_events     = time_events.dup
      @locations_by_id = {}
      @ghosts          = []
      @rows = raw_board.map.with_index do |row, y|
        row.map.with_index do |pieces, x|
          Pieces.new(pieces).each do |piece|
            @locations_by_id[piece.id] = [y, x]
          end
        end
      end

      raise "Needs a pacman! #{inspect}" unless pacman
    end

    def jail
      each_piece.find &:jail?
    end

    def pacman
      each_piece.find &:pacman?
    end

    def each_row(&block)
      @rows.each &block
    end

    def next_board
      rows = @rows.map { |row| row.map { |pieces| pieces.map &:tick } }
      Board.new rows
    end

    def each_piece(&block)
      return to_enum :each_piece unless block_given?
      each_row do |row|
        row.each { |pieces| pieces.each &block }
      end
    end

    def move(piece, location)
      raise piece.inspect unless piece.kind_of? Piece
      return unless location
      newy, newx = to_location location
      @rows[newy][newx].add(remove piece)
      @locations_by_id[piece.id] = [newy, newx]
    end

    def remove(piece)
      oldy, oldx = to_location piece
      removed = @rows[oldy][oldx].remove(piece)
      @locations_by_id.delete piece.id
      removed
    end

    def to_location(piece_or_location)
      if piece_or_location.respond_to? :id
        @locations_by_id.fetch piece_or_location.id
      else
        piece_or_location
      end
    end

    def pieces_on(piece_or_location)
      y, x = to_location(piece_or_location)
      pieces = @rows[y][x].to_ary
      return pieces unless piece_or_location.kind_of? Piece
      pieces.reject { |piece| piece.id == piece_or_location.id }
    end
  end
end
