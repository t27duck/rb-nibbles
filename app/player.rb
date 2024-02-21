class Player
  def self.generate_body_segments(game)
    body = []

    INITIAL_BODY.times do |step|
      case game.state.direction
      when "up"
        body << [game.state.head[0], game.state.head[1] + (step + 1)]
      when "right"
        body << [game.state.head[0] - (step + 1), game.state.head[1]]
      when "down"
        body << [game.state.head[0], game.state.head[1] - (step + 1)]
      when "left"
        body << [game.state.head[0] + (step + 1), game.state.head[1]]
      end
    end

    body
  end

  def self.change_direction_on_input(game)
    # Prevents constant change in direction until the head moves.
    return if game.state.lock_movement == true
    current_direction = game.state.direction

    # Prevent from moving in the opposite direction.
    game.state.direction = "up" if game.inputs.up && current_direction != "down"
    game.state.direction = "right" if game.inputs.right && current_direction != "left"
    game.state.direction = "down" if game.inputs.down && current_direction != "up"
    game.state.direction = "left" if game.inputs.left && current_direction != "right"

    game.state.lock_movement = true if current_direction != game.state.direction
  end
end
