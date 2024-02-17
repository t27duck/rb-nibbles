class Food
  def self.determine_new_coordinates(game)
    loop do
      x = rand(GRID_WIDTH)
      y = rand(GRID_HEIGHT)

      ok = game.state.body.none? { |body_part| x == body_part[0] && y == body_part[1] } &&
           (x != game.state.head_x && y != game.state.head_y)

      return [x, y] if ok
    end
  end

  def self.render(game)
    game.outputs.solids << {
      x: GRID_START_X + (game.state.food[0] * BLOCK_WIDTH),
      y: GRID_START_Y + (game.state.food[1] * BLOCK_WIDTH),
      w: BLOCK_WIDTH,
      h: BLOCK_WIDTH
    }.merge(COLOR_FOOD)
  end

  def self.render_shadow(game)
    game.outputs.solids << {
      x: GRID_START_X + (game.state.food[0] * BLOCK_WIDTH) + SHADOW_OFFSET,
      y: GRID_START_Y + (game.state.food[1] * BLOCK_WIDTH) - SHADOW_OFFSET,
      w: BLOCK_WIDTH,
      h: BLOCK_WIDTH,
      a: SHADOW_ALPHA
    }.merge(COLOR_FOOD)
  end
end
