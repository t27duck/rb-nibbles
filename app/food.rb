class Food
  def self.determine_new_coordinates(game)
    loop do
      x = rand(GRID_WIDTH)
      y = rand(GRID_HEIGHT)

      ok = game.state.body.none? { |body_part| x == body_part[0] && y == body_part[1] } &&
           (x != game.state.head[0] && y != game.state.head[1])

      return [x, y] if ok
    end
  end
end
