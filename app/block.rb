class Block
  def self.render(game, cords, size: :normal)
    inner_offset = size == :normal ? 2 : 4
    shadow_offset = size == :normal ? 0 : 4
    cords = [cords] unless cords[0].is_a?(Array)
    cords.each do |cord|
      x, y = cord
      game.outputs.solids << {
        x: GRID_START_X + (x * BLOCK_WIDTH) + SHADOW_OFFSET + shadow_offset,
        y: GRID_START_Y + (y * BLOCK_WIDTH) - SHADOW_OFFSET + shadow_offset,
        w: BLOCK_WIDTH - (shadow_offset * 2),
        h: BLOCK_WIDTH - (shadow_offset * 2),
        a: SHADOW_ALPHA
      }.merge(COLOR_PLAYER)

      game.outputs.solids << {
        x: GRID_START_X + (x * BLOCK_WIDTH) + inner_offset,
        y: GRID_START_Y + (y * BLOCK_WIDTH) + inner_offset,
        w: BLOCK_WIDTH - (inner_offset * 2),
        h: BLOCK_WIDTH - (inner_offset * 2)
      }.merge(COLOR_PLAYER)
    end
  end
end
