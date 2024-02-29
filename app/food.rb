class Food
  MAX_FOOD_SPAWN_ATTEMPTS = GRID_WIDTH * GRID_HEIGHT

  def self.determine_new_coordinates(game)
    attempts = 0
    loop do
      x = rand(GRID_WIDTH)
      y = rand(GRID_HEIGHT)

      ok = game.state.body.none? { |body_part| x == body_part[0] && y == body_part[1] } &&
           WALLS[game.state.level].none? { |wall_cord| x == wall_cord[0] && y == wall_cord[1] } &&
           (x != game.state.head[0] && y != game.state.head[1])

      return [x, y] if ok

      attempts += 1
      return [] if attempts > MAX_FOOD_SPAWN_ATTEMPTS
    end
  end
end
