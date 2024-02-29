class Block
  BLOCK_SIZES = {
    small: [4, 4],
    normal: [2, 0],
    full: [0, 0]
  }

  def self.render(game, cords, size: :normal, color: COLOR_PLAYER)
    inner_offset, shadow_offset = BLOCK_SIZES[size]
    cords = [cords] unless cords[0].is_a?(Array)
    cords.each do |cord|
      next if cord.empty?

      x, y = cord
      game.outputs.solids << {
        x: GRID_START_X + (x * BLOCK_WIDTH) + SHADOW_OFFSET + shadow_offset,
        y: GRID_START_Y + (y * BLOCK_WIDTH) - SHADOW_OFFSET + shadow_offset,
        w: BLOCK_WIDTH - (shadow_offset * 2),
        h: BLOCK_WIDTH - (shadow_offset * 2),
        a: SHADOW_ALPHA
      }.merge(color)

      game.outputs.solids << {
        x: GRID_START_X + (x * BLOCK_WIDTH) + inner_offset,
        y: GRID_START_Y + (y * BLOCK_WIDTH) + inner_offset,
        w: BLOCK_WIDTH - (inner_offset * 2),
        h: BLOCK_WIDTH - (inner_offset * 2)
      }.merge(color)
    end
  end
end
