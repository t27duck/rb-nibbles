class Stage
  def self.render(game, &block)
    render_gamefield(game)
    render_top(game)
    render_left(game)
    yield block
    render_bottom(game)
    render_right(game)
  end

  def self.render_left(game)
    game.outputs.solids << {
      x: 0,
      y: GRID_START_Y,
      w: BLOCK_WIDTH,
      h: game.grid.h - GRID_START_Y - BLOCK_WIDTH - GRID_Y_OFFSET_MAGIC_NUMBER
    }.merge(COLOR_WALL)

    # Shadow
    game.outputs.solids << {
      x: 0 + SHADOW_OFFSET,
      y: GRID_START_Y - SHADOW_OFFSET,
      w: BLOCK_WIDTH,
      h: game.grid.h - GRID_START_Y - BLOCK_WIDTH - GRID_Y_OFFSET_MAGIC_NUMBER,
      a: SHADOW_ALPHA
    }.merge(COLOR_WALL)
  end

  def self.render_right(game)
    game.outputs.solids << {
      x: game.grid.w - GRID_START_X,
      y: GRID_START_Y,
      w: BLOCK_WIDTH,
      h: game.grid.h
    }.merge(COLOR_WALL)
  end

  def self.render_top(game)
    game.outputs.solids << {
      x: 0,
      y: game.grid.h - BLOCK_WIDTH - GRID_Y_OFFSET_MAGIC_NUMBER,
      w: game.grid.w - BLOCK_WIDTH,
      h: BLOCK_WIDTH + 16
    }.merge(COLOR_WALL)

    # Shadow
    game.outputs.solids << {
      x: 0 + SHADOW_OFFSET,
      y: game.grid.h - BLOCK_WIDTH - GRID_Y_OFFSET_MAGIC_NUMBER - SHADOW_OFFSET,
      w: game.grid.w - BLOCK_WIDTH,
      h: BLOCK_WIDTH + 16,
      a: SHADOW_ALPHA
    }.merge(COLOR_WALL)
  end

  def self.render_bottom(game)
    game.outputs.solids << {
      x: 0,
      y: 0,
      w: game.grid.w,
      h: GRID_START_Y
    }.merge(COLOR_WALL)
  end

  def self.render_gamefield(game)
    game.outputs.solids << {
      x: GRID_START_X,
      y: GRID_START_Y,
      w: (BLOCK_WIDTH * GRID_WIDTH),
      h: (BLOCK_WIDTH * GRID_HEIGHT)
    }.merge(COLOR_GAME_FIELD)
  end

  def self.render_score(game)
    game.outputs.labels << {
      x: GRID_START_X,
      y: GRID_START_Y - 5,
      text: "Score: #{game.state.score}",
      size_enum: 5,
      anchor_x: 0
    }.merge(COLOR_TEXT_DARK)
  end
end
