class Player
  def self.generate_body_segments(game)
    body = []

    INITIAL_BODY.times do |step|
      case game.state.direction
      when "up"
        body << [game.state.head_x, game.state.head_y + (step + 1)]
      when "right"
        body << [game.state.head_x - (step + 1), game.state.head_y]
      when "down"
        body << [game.state.head_x, game.state.head_y - (step + 1)]
      when "left"
        body << [game.state.head_x + (step + 1), game.state.head_y]
      end
    end

    body
  end

  def self.render_head(game)
    game.outputs.solids << {
      x: GRID_START_X + (game.state.head_x * BLOCK_WIDTH) + 2,
      y: GRID_START_Y + (game.state.head_y * BLOCK_WIDTH) + 2,
      w: BLOCK_WIDTH - 4,
      h: BLOCK_WIDTH - 4
    }.merge(COLOR_PLAYER)
  end

  def self.render_head_shadow(game)
    game.outputs.solids << {
      x: GRID_START_X + (game.state.head_x * BLOCK_WIDTH) + SHADOW_OFFSET,
      y: GRID_START_Y + (game.state.head_y * BLOCK_WIDTH) - SHADOW_OFFSET,
      w: BLOCK_WIDTH,
      h: BLOCK_WIDTH,
      a: SHADOW_ALPHA
    }.merge(COLOR_PLAYER)
  end

  def self.render_body(game)
    game.state.body.each do |body_part|
      game.outputs.solids << {
        x: GRID_START_X + (body_part[0] * BLOCK_WIDTH) + 2,
        y: GRID_START_Y + (body_part[1] * BLOCK_WIDTH) + 2,
        w: BLOCK_WIDTH - 4,
        h: BLOCK_WIDTH - 4
      }.merge(COLOR_PLAYER)
    end
  end

  def self.render_body_shadow(game)
    game.state.body.each do |body_part|
      game.outputs.solids << {
        x: GRID_START_X + (body_part[0] * BLOCK_WIDTH) + SHADOW_OFFSET,
        y: GRID_START_Y + (body_part[1] * BLOCK_WIDTH) - SHADOW_OFFSET,
        w: BLOCK_WIDTH,
        h: BLOCK_WIDTH,
        a: SHADOW_ALPHA
      }.merge(COLOR_PLAYER)
    end
  end
end