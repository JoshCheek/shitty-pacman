# 😀 😁 😂 😃 😄 😅 😆 😇 😈 👿 😉 😊 ☺️ 😋 😌 😍 😎 😏 😐 😑 😒 😓 😔 😕 😖 😗 😘 😙 😚
# 😛 😜 😝 😞 😟 😠 😡 😢 😣 😤 😥 😦 😧 😨 😩 😪 😫 😬 😭 😮 😯 😰 😱 😲 😳 😴 😵 😶 😷
# 😸 😹 😺 😻 😼 😽 😾 😿 🙀 👣 👤 👥 👻 👹 👺 💩 💀 👽 👾
#
# 🍅 🍆 🌽 🍠 🍇 🍈 🍉 🍊 🍋 🍌 🍍 🍎 🍏 🍐 🍑 🍒 🍓 🍔 🍕 🍖 🍗 🍘 🍙 🍚 🍛 🍜 🍝 🍞 🍟
# 🍡 🍢 🍣 🍤 🍥 🍦 🍧 🍨 🍩 🍪 🍫 🍬 🍭 🍮 🍯 🍰 🍱 🍲 🍳 🍴 🍵 ☕️ 🍶 🍷 🍸 🍹 🍺 🍻 🍼
#
# 🎀 🎁 🎂 🎃 🎄 🎋 🎍 🎑 🎆 🎇 🎉 🎊 🎈 💫 ✨ 💥 🎓 👑 🎎 🎏 🎐 🎌 🏮 💍
#
# ❤️ 💔 💌 💕 💞 💓 💗 💖 💘 💝 💟 💜 💛 💚 💙
#
# ⚡️ 🔥 🌙 ☀️ ⛅️ ☁️ 💧 💦 ☔️ 💨 ❄️ 🌟 ⭐️ 🌠 🌄 🌅 🌈 🌊 🌋 🌌 🗻 🗾
#
# 🌐 🌍 🌎 🌏 🌑 🌒 🌓 🌔 🌕 🌖 🌗 🌘 🌚 🌝 🌛 🌜 🌞
#
# 🐀 🐁 🐭 🐹 🐂 🐃 🐄 🐮 🐅 🐆 🐯 🐇 🐰 🐈 🐱 🐎 🐴 🐏 🐑 🐐 🐓 🐔
# 🐤 🐣 🐥 🐦 🐧 🐘 🐪 🐫 🐗 🐖 🐷 🐽 🐕 🐩 🐶 🐺 🐻 🐨 🐼 🐵 🙈 🙉
# 🙊 🐒 🐉 🐲 🐊 🐍 🐢 🐸 🐋 🐳 🐬 🐙 🐟 🐠 🐡 🐚 🐌 🐛 🐜 🐝 🐞 🐾
#
# 🌱 🌲 🌳 🌴 🌵 🌷 🌸 🌹 🌺 🌻 🌼 💐 🌾 🌿 🍀 🍁 🍂 🍃 🍄 🌰
#
# 👦 👧 👨 👩 👮 👰 👱 👲 👳 👴 👵 👶 👷 👸 💂 👼 🎅 🙇
# 💁 🙅 🙆 🙋 🙎 🙍 💆 💇 👪 👫 👬 👭 👯 💑 💏 🙇
#
# 💅 👂 👃 👋 👍 👎 ☝ 👆 👇 👈 👉 👌 ✌ 👊 ✊ ✋ 💪 👐 🙌 👏 🙏
# 👋 👍 👎 ☝️ 👆 👇 👈 👉 👌 ✌️ 👊 ✊ ✋ 💪 👐 🙌 👏 🙏 👀 👄 💋 👅

class Pacman
  class Piece
    def self.dequeue_id
      @current_id ||= 0
      @current_id += 1
    end

    def self.for(char)
      each { |piece| return piece if piece.for? char }
      raise "Couldn't find a piece for: #{char.inspect}"
    end

    def self.all
      @all ||= []
    end

    def self.each(&block)
      all.each &block
    end

    def self.create(type, simple_token, fancy_tokens, &block)
      # normalize
      fancy_tokens = Array fancy_tokens

      # all pieces get the predicate
      define_method("#{type}?") { false }

      # metaprogram in the superclass to support overriding
      default_overrides = Class.new self do
        define_singleton_method :for? do |matcher|
          type == matcher || simple_token == matcher || fancy_tokens.include?(matcher)
        end

        define_method("#{type}?")    { true }
        define_method(:simple_token) { simple_token }
        define_method(:fancy_token)  { |i=0| fancy_tokens.rotate(i).first }
        define_method(:inspect)      { "#<Piece:#{id.inspect}:#{fancy_tokens.first}>" }
      end

      # the actual class
      klass = Class.new default_overrides do
        const_set :DefaultOverrides, default_overrides
        class_eval &block if block
      end

      # track the pieces
      all << klass
      klass
    end

    attr_accessor :id

    def initialize(id: Piece.dequeue_id)
      self.id = id
    end

    def ==(piece)
      id == piece.id
    end

    def desired_move(board)
      nil # dont move this piece
    end

    def tick
      dup.tock
    end

    def tock
      self # no op, subclasses can override
    end

    def barrier?
      false
    end

    def ghost?
      false
    end

    Empty = Piece.create :empty, ' ', ' '

    Gate = Piece.create :gate, '=', '―' do
      def barrier?
        true
      end
    end

    # ☭\e[0m"
    # ▣\e[0m"
    #  ⃝\e[0m"
    # 右\e[0m"
    # ✚\e[0m"
    # ⌗\e[0m"
    # ✛\e[0m"
    # ✜\e[0m" # pretty good
    Wall = Piece.create :wall,  'W', "\e[44;30m✧\e[0m" do
      def barrier?
        true
      end
    end

    # scarier ones:, 🔥 😱 👹 😈 👾 👻 other animals: 🐛 🐝 🐣 🐢 🐶

    module Ghost
      def self.<<(klass)
        class << klass
          attr_accessor :initial_wait
        end
        klass.__send__ :include, self
      end

      attr_accessor :strategy_time, :strategy

      def initialize(strategy: :mellow, initial_wait: self.class.initial_wait, **keyrest)
        self.strategy      = :mellow
        self.strategy_time = initial_wait
        super **keyrest
      end

      def ghost?
        true
      end

      def mellow?
        strategy == :mellow
      end

      def jail?
        strategy == :jail
      end

      def tock
        self.strategy_time -= 1
        if strategy_time < 0
          self.strategy_time += 100
          self.strategy = :attack
        end
        super
      end

      def go_directly_to_jail
        self.strategy = :jail
        self.strategy_time = 100
      end

      def desired_move(board)
        return nil if mellow?
        if jail?
          next_step_on_shortest_path_to(
            board, self, board.jail
          )
        else
          next_step_on_shortest_path_to(
            board, self, board.pacman
          )
        end
      end

      def next_step_on_shortest_path_to(board, from, to)
        map = board.each_row.map do |row|
          row.map do |pieces|
            meaning = pieces.each.to_a.map do |piece|
              if piece.wall? || piece.ghost?
                :blocked
              elsif piece == to
                :pacman
              else
                nil
              end
            end
            meaning.compact.first || :available
          end
        end

        seen       = Hash.new
        check_next = []
        check_next << [board.to_location(from), nil]
        result     = nil
        until result
          break nil if check_next.empty?  # we can't get to pacman, chill for a bit

          to_check, parent = check_next.shift
          seen[to_check] = parent
          y, x = to_check

          [[y-1,x], [y+1, x], [y, x-1], [y, x+1]].each do |adjacent|
            newy, newx = adjacent
            if seen.key?(adjacent) || newy < 0 || newx < 0 || newy >= map.length || newx >= map[newy].length || map[newy][newx] == :blocked
              # no op
            elsif map[newy][newx] == :pacman
              check_next << [adjacent, to_check]
              seen[adjacent] = to_check
              result = adjacent
              while seen[seen[result]]
                result = seen[result]
                map[result[0]][result[1]] = :path
              end
              map[result[0]][result[1]] = :move
            else
              check_next << [adjacent, to_check]
            end
          end
        end

        result
      end
    end


        # targety, targetx = board.to_location(board.jail)
        # actualy, actualx = board.to_location(self)
        # [[actualy-1, actualx],
        #  [actualy+1, actualx],
        #  [actualy,   actualx-1],
        #  [actualy,   actualx+1],
        # ].reject { |loc| board.pieces_on(loc).any? &:wall? }
        #  .min_by { |y, x|
        #    ydist = (y-targety).abs
        #    xdist = (x-targetx).abs
        #    Math.sqrt(ydist**2 + xdist**2)
        #  }
    # red aka shadow
    Blinky = Piece.create :blinky, 'r', '🐷' do
      Ghost << self
      self.initial_wait = 0
    end

    # pink aka speedy
    Pinky = Piece.create :ghost, 'y', '🐙' do
      Ghost << self
      self.initial_wait = 0
    end

    # cyan aka bashful
    Inky = Piece.create :ghost, 'i', '🐳' do
      Ghost << self
      self.initial_wait = 30
    end

    # orange aka pokey
    Clyde = Piece.create :ghost, 'o', '🐌' do
      Ghost << self
      self.initial_wait = 90
    end

    Vitamin = Piece.create :vitamin, 'v', ['🍄', ' '] do
      def value
        50
      end
    end

    Food = Piece.create :food, '.', '●' do
      def value
        10
      end
    end

    Jail = Piece.create :jail, 'J', ' '

# Fruit:
# Cherry: 100 points.
# Strawberry: 300 points
# Orange: 500 points
# Apple: 700 points
# Melon: 1000 points
# Galxian Boss: 2000 points
# Bell: 3000 points
# Key: 5000 points

    Pacman = Piece.create :pacman, 'p', '😜' do
      const_set :TOKENS, {
        dead:      ['😲'],
        roid_rage: ['😡'],
        # hungry:    %w[😄 😁 ],
        hungry:    %w[😜 😛 😝 ],
      }.freeze

      attr_accessor :status, :num_lives, :direction, :score, :tokens, :roid_level, :next_roid_bonus

      def initialize(status: :hungry, num_lives: 3, direction: :up, score: 0, tokens: Pacman::TOKENS, roid_level: 0, next_roid_bonus: 200, **kwrest)
        super **kwrest
        self.score           = score
        self.status          = status
        self.num_lives       = num_lives
        self.direction       = direction
        self.tokens          = tokens
        self.roid_level      = roid_level
        self.next_roid_bonus = next_roid_bonus
      end

      def die!
        self.status = :dead
      end

      def dead?
        status == :dead
      end

      def roid_rage!
        self.roid_level += 40
        self.status = :roid_rage
      end

      def roid_rage?
        status == :roid_rage
      end

      def hungry!
        self.roid_level      = 0
        self.next_roid_bonus = 200
        self.status          = :hungry
      end

      def hungry?
        status == :hungry
      end

      def fancy_token(i=0)
        tokens[status].rotate(i).first
      end

      def game_over?
        status == :dead && num_lives.zero?
      end

      def face(direction)
        self.direction = direction
      end

      def desired_move(board)
        crnty, crntx = board.to_location(self)
        newy,  newx  = crnty, crntx
        case direction
        when :up    then newy -= 1
        when :right then newx += 1
        when :down  then newy += 1
        when :left  then newx -= 1
        else raise "Unknown direction: #{direction.inspect}"
        end

        if board.pieces_on([newy, newx]).any?(&:barrier?)
          [crnty, crntx]
        else
          [newy, newx]
        end
      end

      def eat(edible)
        if edible.vitamin?
          roid_rage!
          self.score += edible.value
        elsif edible.ghost?
          self.score += next_roid_bonus
          self.next_roid_bonus *= 2
        else
          self.score += edible.value
        end
      end

      def tock
        if roid_rage?
          self.roid_level -= 1
          hungry! if roid_level <= 0
        end
        super
      end
    end
  end
end
