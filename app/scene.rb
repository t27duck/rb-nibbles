class Scene
  def self.render_title(game)
    game.outputs.labels << {
      x: (game.grid.w / 2),
      y: (game.grid.h / 2),
      text: "Nibbles",
      size_enum: 8,
      alignment_enum: 1
    }.merge(COLOR_TEXT_DARK)

    game.outputs.labels << {
      x: (game.grid.w / 2),
      y: (game.grid.h / 2) - 50,
      text: "Press Spacebar to Start",
      size_enum: 4,
      alignment_enum: 1,
    }.merge(COLOR_TEXT_DARK)
  end

  def self.render_gameover(game)
    game.outputs.labels << {
      x: (game.grid.w / 2),
      y: (game.grid.h / 2),
      text: "Game Over",
      size_enum: 8,
      alignment_enum: 1
    }.merge(COLOR_TEXT_DARK)

    game.outputs.labels << {
      x: (game.grid.w / 2),
      y: (game.grid.h / 2) - 50,
      text: "Score: #{game.state.score}",
      size_enum: 4,
      alignment_enum: 1
    }.merge(COLOR_TEXT_DARK)

    game.outputs.labels << {
      x: (game.grid.w / 2),
      y: (game.grid.h / 2) - 150,
      text: "Press Spacebar to Play Again",
      size_enum: 4,
      alignment_enum: 1
    }.merge(COLOR_TEXT_DARK)
  end
end
