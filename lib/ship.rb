class Ship
  EXPLOSION = Gosu::Image.load_tiles('./gfx/M484ExplosionSet1.png', 32, 32, retro: true)
  VELOCITY = 5.0

  attr_reader :lasers, :bombs

  def initialize(window)
    @window = window
    @image = Gosu::Image.new('./gfx/ship.png', retro: true)
    @sounds = {
      fire: Gosu::Sample.new('./sfx/alienshoot1.wav'),
      explosion: Gosu::Sample.new('./sfx/Chunky Explosion.mp3'),
      bonus: Gosu::Sample.new('./sfx/spell1_0.wav')
    }
    reset_ship
  end

  def reset_ship
    @collider = Circle.new(@window.width / 2, @window.height / 2, @image.width * 0.3)
    @state = :ingame
    @explosion_frame = 0
    @explosion_frame_duration = 100
    @explosion_frame_tick = Gosu::milliseconds

    @in_recovery = true
    @recovery_time = 1000.0
    @recovery_tick = Gosu::milliseconds

    @lasers = []
  end

  def button_down(id)
    case @state
    when :ingame
      # laser shoot
      if id == Gosu::KB_SPACE
        @sounds[:fire].play(0.2)
        shoot_laser
      end

      # mega bomb
      if id == Gosu::KB_RETURN && @window.bombs > 0
        @window.bombs -= 1
        @window.map.destroy_all_asteroids
        @sounds[:explosion].play(1.0)
      end
    end
  end

  def shoot_laser
    @lasers.push Laser.new(self, @collider.x, @collider.y)
  end

  def update(asteroids, bonuses)
    case @state
    when :ingame
      # digonal adjustment
      velocity = VELOCITY
      if [Gosu::KB_LEFT, Gosu::KB_RIGHT].any? {|k| Gosu.button_down?(k)} && [Gosu::KB_UP, Gosu::KB_DOWN].any? {|k| Gosu.button_down?(k)}
        velocity *= 0.7
      end

      @collider.x += velocity if Gosu.button_down?(Gosu::KB_RIGHT)
      @collider.x -= velocity if Gosu.button_down?(Gosu::KB_LEFT)
      @collider.y += velocity if Gosu.button_down?(Gosu::KB_DOWN)
      @collider.y -= velocity if Gosu.button_down?(Gosu::KB_UP)

      @collider.x = @collider.radius if @collider.x < @collider.radius
      @collider.x = $screen_width - @collider.radius if @collider.x > $screen_width - @collider.radius
      @collider.y = @collider.radius if @collider.y < @collider.radius
      @collider.y = $screen_height - @collider.radius if @collider.y > $screen_height - @collider.radius

      # we can't take damage if we are in recovery
      unless @in_recovery
        # only asteroids that are not exploding can hurt the player
        asteroids.select {|a| a.state != :exploded}.each do |asteroid|
          # if there is collision between this asteroid and the player
          if asteroid.collider.collides?(@collider)
            asteroid.explode!
            explode!
            @sounds[:explosion].play(1, 1.5)
          end
        end
      # we check if recovery time is reached
      else
        if Gosu::milliseconds - @recovery_tick >= @recovery_time
          @in_recovery = false
        end
      end

      # BONUSES
      bonuses.each do |bonus|
        # if there is collision between this bonus and the player
        if bonus.collider.collides?(@collider)
          bonus.pickup!
          @sounds[:bonus].play(1, 1.5)
        end
      end

      # LASERS
      @lasers.each {|laser| laser.update(asteroids)}
      @lasers.delete_if {|laser| (laser.collider.y - laser.collider.radius < 0) || laser.to_delete}
    when :exploded
      if Gosu::milliseconds - @explosion_frame_tick >= @explosion_frame_duration
        @explosion_frame += 1
        @explosion_frame_tick = Gosu::milliseconds
      end

      # we want to reset the ship if explosion is over
      if @explosion_frame >= EXPLOSION.size
        reset_ship
      end
    end
  end

  def explode!
    @explosion_frame_tick = Gosu::milliseconds
    @state = :exploded
    @window.lives -= 1
  end

  def draw
    case @state
    when :ingame
      color = @in_recovery ? Gosu::Color.new(16, 255, 255, 255) : Gosu::Color::WHITE

      @image.draw_rot(@collider.x, @collider.y, 2, 0, 0.5, 0.5, 1, 1, color)
      # @collider.draw(Gosu::Color::BLUE)

      # LASERS
      @lasers.each {|laser| laser.draw}
    when :exploded
      EXPLOSION[@explosion_frame].draw_rot(@collider.x, @collider.y, 3)
    end
  end
end