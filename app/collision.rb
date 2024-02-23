class Collision
  def self.wall?(game)
    game.state.head[0] < 0 || game.state.head[0] >= GRID_WIDTH ||
      game.state.head[1] < 0 || game.state.head[1] >= GRID_HEIGHT ||
      WALLS[game.state.level].any? { |wall_cord| game.state.head[0] == wall_cord[0] && game.state.head[1] == wall_cord[1] }
  end

  def self.body?(game)
    game.state.body.any? { |body_part| game.state.head[0] == body_part[0] && game.state.head[1] == body_part[1] }
  end

  def self.food?(game)
    game.state.head[0] == game.state.food[0] && game.state.head[1] == game.state.food[1]
  end
end
