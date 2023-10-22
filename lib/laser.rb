class Laser
  SPRITE = Gosu::Image.new('./gfx/airplane_04_64x64_002.png', retro: true)
  VELOCITY = 5.0

  attr_accessor :collider, :to_delete

  def initialize(ship, x, y)
    @ship = ship
    @collider = Circle.new(x, y, 12)
    @to_delete = false

    @sounds = {
      explosion: Gosu::Sample.new('./sfx/explosion.wav')
    }
  end

  def update(asteroids)
    @collider.y -= VELOCITY

    asteroids.select {|asteroid| asteroid.state != :exploded}.each do |asteroid|
      # if the laser touches the asteroid, it will split in two pieces
      if asteroid.collider.collides?(@collider)
        @to_delete = true
        asteroid.map.split_asteroid(asteroid)
        asteroid.explode!
        @sounds[:explosion].play(0.3, 1.0)
      end
    end
  end

  def draw
    SPRITE.draw_rot(@collider.x, @collider.y, 1)
  end
end