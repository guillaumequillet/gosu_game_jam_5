require 'gosu'
Dir['./lib/*.rb'].each {|fn| require_relative "./#{fn}"}

$screen_width = 640
$screen_height = 480

class Window < Gosu::Window
  attr_reader :ship, :map
  attr_accessor :score, :bombs, :lives
  
  def initialize
    super($screen_width, $screen_height, false)
    self.caption = 'Gosu Game Jam 5 - Asteroids'
    @font = Gosu::Font.new(24)
    @state = :title

    @screens = {
      title: Gosu::Image.new('./gfx/screens/title_screen.png', retro: true),
      tuto: Gosu::Image.new('./gfx/screens/tuto_screen.png', retro: true),
      game_over: Gosu::Image.new('./gfx/screens/gameover_screen.png', retro: true)
    }

    @music = Gosu::Song.new('./sfx/Space Heroes.ogg')
    @music.volume = 0.6
  end

  def needs_cursor?; true; end

  def button_down(id)
    super
    close! if id == Gosu::KB_ESCAPE

    case @state
    # we display the tuto if state was title
    when :title
      @state = :tuto
    # we start the game, whatever key was pressed, it state was tuto
    when :tuto
      restart_game
    when :game
      @ship.button_down(id)
    end
  end

  def restart_game
    @state = :game
    @bombs = 3
    @lives = 5
    @score = 0
    @map = Map.new(self)
    @ship = Ship.new(self)
    @music.play(true)
  end

  def update
    case @state
    when :game
      @map.update
      @ship.update(@map.asteroids, @map.bonuses)

      if @lives < 0
        @state = :gameover
        @music.stop
      end

    when :gameover
      restart_game if Gosu.button_down?(Gosu::KB_RETURN)
    end
  end

  def draw_hud
    @font.draw_text("Lives : #{@lives}", 10, 10, 100)
    @font.draw_text("Bombs : #{@bombs}", 10, 40, 100)
    @font.draw_text("Score : #{@score}", 10, 70, 100)
  end
  
  def draw
    case @state
    when :title
      @screens[:title].draw(0, 0, 0)
    when :tuto
      @screens[:tuto].draw(0, 0, 0)
    when :game
      @map.draw
      @ship.draw

      draw_hud
    when :gameover
      @screens[:game_over].draw(0, 0, 0)
      @font.draw_text("Score : #{@score}", 65, 200, 100, 2, 2)
      @font.draw_text("- Press ENTER to restart -", 65, 300, 100, 2, 2)
    end
  end
end

Window.new.show
