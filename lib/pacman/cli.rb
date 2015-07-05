require 'io/console'
require 'pacman'

class Pacman
  class CLI
    def self.call(argv, stdin, stdout, stderr)
      new(argv, stdin, stdout, stderr).call
    end

    def initialize(argv, stdin, stdout, stderr)
      @argv, @stdin, @stdout, @stderr, @game, @state =
        argv, stdin, stdout, stderr, Pacman.new, :playing
    end

    def call
      @stdout.print hide_cursor, clear_screen

      input_thread = listen_for_inputs @stdin do |input|
        case input
        when :left, :right, :up, :down then @game.face_pacman input
        when :pause                    then @state = :paused
        when :resume                   then @state = :playing
        when :quit                     then @game.quit!
        when :noop                     then # noop
        else raise "Unexpected input: #{input.inspect}"
        end
      end

      loop do
        @stdout.print reset_cursor
        @stdout.print show_game @game
        sleep 0.1
        next  if paused?
        break if @game.over?
        @game.tick
      end

      @stdout.print reset_cursor
      @stdout.print show_game @game
    ensure
      @stdout.print show_cursor
      input_thread.kill if input_thread.alive?
    end

    private

    def paused?
      @state == :paused
    end

    def listen_for_inputs(stdin, &listener)
      Thread.new do
        Thread.current.abort_on_exception = true
        loop do
          char  = stdin.raw &:getc
          event = case char
          when 'p'   then :pause
          when 'r'   then :resume
          when 'q'   then :quit
          when 'h'   then :left
          when 'j'   then :down
          when 'k'   then :up
          when 'l'   then :right
          when 3.chr then :interrupt # C-c
          when "\e"
            final = stdin.raw {
              middle = stdin.getc
              middle == '[' or raise "Expected a [ after \\e, but got: #{middle.inspect}!"
              stdin.getc
            }
            case final
            when "A" then :up
            when "C" then :right
            when "B" then :down
            when "D" then :left
            else raise "Expected arrow key (up, down, left, right)"
            end
          else :noop
          end
          listener.call event
        end
      end
    end

    def clear_screen
      "\e[H\e[2J"
    end

    def reset_cursor
      "\e[H"
    end

    def hide_cursor
      "\e[?25l"
    end

    def show_cursor
      "\e[?25h"
    end

    def show_game(game)
      game.each_row.map { |row|
        successors = row.rotate(-1).drop(1).rotate(1)
        row.zip(successors).map { |crnt_pieces, succ_pieces|
          # next crnt_pieces.first.fancy_token
          next crnt_pieces.first.fancy_token(game.num_ticks) unless succ_pieces
          crnt = crnt_pieces.to_ary.find { |c| c.wall? || c.gate? } || crnt_pieces.first
          succ = succ_pieces.to_ary.find { |c| c.wall? || c.gate? } || succ_pieces.first

          if (crnt.wall? && succ.wall?) || (crnt.gate? && succ.gate?) || (crnt.wall? && succ.gate?)
            crnt.fancy_token(game.num_ticks) * 2
          elsif crnt.gate? && succ.wall?
            succ.fancy_token(game.num_ticks) * 2
          else
            "#{crnt.fancy_token(game.num_ticks)} "
          end
        }.join << "\r\n"
      }.join
    end
  end
end
