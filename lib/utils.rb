class Circle
  attr_accessor :x, :y, :radius
  def initialize(x, y, radius)
    @x, @y, @radius = x, y, radius
    @segments = 16
  end

  def collides?(other)
    Gosu.distance(@x, @y, other.x, other.y) <= @radius + other.radius
  end

  def draw(color = Gosu::Color::WHITE)
    # drawing center
    center_size = 2
    Gosu.draw_rect(@x - center_size / 2, @y - center_size / 2, center_size, center_size, color)

    # drawing low poly circle
    angle_step = 360.0 / @segments
    first_x, first_y = nil, nil
    previous_x, previous_y = nil, nil

    @segments.times do |i|
      angle = i * angle_step

      next_x = @x + Gosu.offset_x(angle, @radius)
      next_y = @y + Gosu.offset_y(angle, @radius)

      unless (previous_x.nil? || previous_y.nil?)
        Gosu.draw_line(previous_x, previous_y, color, next_x, next_y, color)
      else
        first_x, first_y = next_x, next_y
      end
      
      previous_x, previous_y = next_x, next_y
    end

    # we draw the first segment
    Gosu.draw_line(previous_x, previous_y, color, first_x, first_y, color)
  end
end