class Collision
  def self.wall?(game)
    game.state.head_x < 0 || game.state.head_x >= GRID_WIDTH ||
      game.state.head_y < 0 || game.state.head_y >= GRID_HEIGHT
  end

  def self.body?(game)
    game.state.body.any? { |body_part| game.state.head_x == body_part[0] && game.state.head_y == body_part[1] }
  end

  def self.food?(game)
    game.state.head_x == game.state.food[0] && game.state.head_y == game.state.food[1]
  end
end
