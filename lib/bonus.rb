class Bonus
  IMAGES = Gosu::Image.load_tiles('./gfx/bonuses.png', 32, 32, retro: true)
  SCORE = 1000
  
  attr_accessor :collider, :state, :map
  def initialize(map, x, y, radius = 32)
    @map = map

    @type = [:life, :bomb].sample

    @collider = Circle.new(x, y, radius)
    @state = :ingame
    
    @duration = 5000
    @spawn_tick = Gosu::milliseconds
    @to_delete = false
  end

  def update
    case @state
    when :ingame
      @to_delete = true if Gosu::milliseconds - @spawn_tick > @duration
    end
  end

  def pickup!
    @map.window.score += SCORE
    case @type
    when :life then @map.window.lives += 1
    when :bomb then @map.window.bombs += 1
    end
    
    @to_delete = true
  end

  def to_delete?
    return true if @to_delete
  end

  def draw(draw_collider = false)
    case @state
    when :ingame
      type_id = [:life, :bomb].index(@type) 
      IMAGES[type_id].draw_rot(@collider.x, @collider.y, 0)
    end
  end
end