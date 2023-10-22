class Map
  attr_reader :window, :asteroids, :bonuses
  def initialize(window)
    @window = window
    @bg = Gosu::Image.new('./gfx/back.png', retro: true)
    @bg_y = -@bg.height
    @bg_scroll_speed = 3
    @asteroids = []
    @asteroid_timer = Gosu::milliseconds
    @next_asteroid_min_timer = 300.0
    @next_asteroid_max_timer = 1200.0
    @next_asteroid_timer = Gosu.random(@next_asteroid_min_timer, @next_asteroid_max_timer)
    @max_asteroids = 20
    @asteroid_minimum_radius = 8

    @bonuses = []
    @max_bonuses = 5
    @bonus_chance = 20 # 1 out of bonus chance
  end

  def auto_spawn_asteroid
    if (Gosu::milliseconds - @asteroid_timer >= @next_asteroid_timer) && @asteroids.size < @max_asteroids
      spawn_asteroid
      @asteroid_timer = Gosu::milliseconds 
      @next_asteroid_timer = Gosu.random(@next_asteroid_min_timer, @next_asteroid_max_timer)
    end
  end
  
  def spawn_asteroid
    @asteroids.push Asteroid.new(self)
  end
  
  def spawn_bonus(asteroid)
    if @bonuses.size < @max_bonuses
      # it has one chance out of ten to spawn some item
      if Gosu.random(0, @bonus_chance).floor == 0
        x, y, radius = asteroid.collider.x, asteroid.collider.y, 32.0
        @bonuses.push Bonus.new(self, x, y, radius)
      end
    end
  end

  def split_asteroid(asteroid)
    if (asteroid.collider.radius / 2.0) >= @asteroid_minimum_radius
      2.times do
        x, y, radius = asteroid.collider.x, asteroid.collider.y, asteroid.collider.radius / 2.0
        @asteroids.push Asteroid.new(self, x, y, radius)
      end
      # if the asteroid was too small, we may want to spawn some item
    else
      spawn_bonus(asteroid)
    end
  end

  def destroy_all_asteroids
    @asteroids.each do |asteroid| 
      spawn_bonus(asteroid)
      asteroid.explode!
    end
  end

  def background_scroll
    @bg_y += @bg_scroll_speed
    @bg_y = -@bg.height if @bg_y > $screen_height
  end

  def update
    background_scroll
    auto_spawn_asteroid

    @asteroids.each {|asteroid| asteroid.update}
    @asteroids.delete_if {|asteroid| asteroid.to_delete?}

    @bonuses.each {|bonus| bonus.update}
    @bonuses.delete_if {|bonus| bonus.to_delete?}
  end

  def draw
    # three drawings to make it loop
    @bg.draw(0, @bg_y, 0)
    @bg.draw(0, @bg_y + @bg.height, 0)
    @bg.draw(0, @bg_y - @bg.height, 0)

    @asteroids.each {|asteroid| asteroid.draw}
    @bonuses.each {|bonus| bonus.draw}
  end
end