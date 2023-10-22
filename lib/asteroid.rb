class Asteroid
  IMAGE = Gosu::Image.new('./gfx/Asteroid Brown.png')
  EXPLOSION = Gosu::Image.load_tiles('./gfx/M484ExplosionSet1.png', 32, 32, retro: true)
  SCORE = 50
  
  attr_accessor :collider, :state, :map, :angle
  def initialize(map, x = nil, y = nil, radius = nil)
    @map = map

    @rotation_way = [:clockwise, :counterclockwise].sample

    radius = Gosu.random(8, 64).floor if radius.nil?
    @image_scale = (radius * 2.0) / IMAGE.width
    @rotation = 0

    @explosion_scale = (IMAGE.width * @image_scale) / EXPLOSION[0].width.to_f

    # calculate spawn point
    @from_side = [:left, :right, :top, :bottom].sample
    
    if x.nil? && y.nil?
      x, y = 0, 0 

      if @from_side == :top || @from_side == :bottom 
        x = Gosu.random(-radius, $screen_width + radius).floor
        y = (@from_side == :top) ? -radius : $screen_height + radius
      elsif @from_side == :left || @from_side == :right 
        x = (@from_side == :left) ? -radius : $screen_width + radius
        y = Gosu.random(-radius, $screen_height + radius).floor
      end
    end

    @angle = Gosu.angle(x, y, $screen_width / 2, $screen_height / 2)
    @angle += Gosu.random(-15.0, 15.0)
    @velocity = Gosu.random(1, 3).floor

    @collider = Circle.new(x, y, radius)
    @state = :ingame
    @explosion_frame = 0
    @explosion_frame_duration = 100
    @explosion_frame_tick = Gosu::milliseconds
    @to_delete = false
  end

  def update
    case @state
    when :ingame
      # update position and rotation
      @collider.x += Gosu.offset_x(@angle, @velocity)
      @collider.y += Gosu.offset_y(@angle, @velocity)

      rotation_step = (@rotation_way == :clockwise) ? @velocity : -@velocity
      @rotation += rotation_step
    when :exploded
      if Gosu::milliseconds - @explosion_frame_tick >= @explosion_frame_duration
        @explosion_frame += 1
        @explosion_frame_tick = Gosu::milliseconds
      end

      # we want to reset the ship if explosion is over
      if @explosion_frame >= EXPLOSION.size
        @to_delete = true
      end
    end
  end

  def explode!
    @state = :exploded
    @map.window.score += SCORE
  end

  def to_delete?
    return true if @to_delete
    
    half_radius = @collider.radius / 2
    return true if @collider.x - half_radius > $screen_width + half_radius + 10 
    return true if @collider.x + half_radius < 0 - half_radius - 10 
    return true if @collider.y - half_radius > $screen_height + half_radius + 10 
    return true if @collider.y + half_radius < 0 - half_radius - 10 
    return false # otherwise we keep it
  end

  def draw(draw_collider = false)
    case @state
    when :ingame
      @collider.draw if draw_collider
      IMAGE.draw_rot(@collider.x, @collider.y, 0, @rotation, 0.5, 0.5, @image_scale, @image_scale)
    when :exploded
      EXPLOSION[@explosion_frame].draw_rot(@collider.x, @collider.y, 3, 0, 0.5, 0.5, @explosion_scale, @explosion_scale)
    end
  end
end