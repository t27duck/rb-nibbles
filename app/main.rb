GRID_WIDTH = 38
GRID_HEIGHT = 20
GRID_START_X = 32
GRID_START_Y = 32
GRID_Y_OFFSET_MAGIC_NUMBER = 16
BLOCK_WIDTH = 32
MOVE_WAIT = 10
INITIAL_BODY = 7

COLOR_TEXT_DARK = { r: 58, g: 63, b: 51 }.freeze
COLOR_PLAYER = { r: 58, g: 63, b: 51 }.freeze
COLOR_FOOD = { r: 58, g: 63, b: 51 }.freeze
COLOR_GAME_FIELD = { r: 149, g: 156, b: 119 }.freeze
COLOR_WALL = { r: 107, g: 113, b: 87 }.freeze

SHADOW_OFFSET = 4
SHADOW_ALPHA = 75

def tick(game)
  game.state.scene ||= "title"
  # Gameplay area
  game.outputs.solids << {
    x: GRID_START_X,
    y: GRID_START_Y,
    w: (BLOCK_WIDTH * GRID_WIDTH),
    h: (BLOCK_WIDTH * GRID_HEIGHT)
  }.merge(COLOR_GAME_FIELD)

  # Top side
  game.outputs.solids << {
    x: 0,
    y: game.grid.h - BLOCK_WIDTH - GRID_Y_OFFSET_MAGIC_NUMBER,
    w: game.grid.w - BLOCK_WIDTH,
    h: BLOCK_WIDTH + 16
  }.merge(COLOR_WALL)

  # Top side shadow
  game.outputs.solids << {
    x: 0 + SHADOW_OFFSET,
    y: game.grid.h - BLOCK_WIDTH - GRID_Y_OFFSET_MAGIC_NUMBER - SHADOW_OFFSET,
    w: game.grid.w - BLOCK_WIDTH,
    h: BLOCK_WIDTH + 16,
    a: SHADOW_ALPHA
  }.merge(COLOR_WALL)

  # Left side
  game.outputs.solids << {
    x: 0,
    y: GRID_START_Y,
    w: BLOCK_WIDTH,
    h: game.grid.h - GRID_START_Y - BLOCK_WIDTH - GRID_Y_OFFSET_MAGIC_NUMBER
  }.merge(COLOR_WALL)

  # Left side shadow
  game.outputs.solids << {
    x: 0 + SHADOW_OFFSET,
    y: GRID_START_Y - SHADOW_OFFSET,
    w: BLOCK_WIDTH,
    h: game.grid.h - GRID_START_Y - BLOCK_WIDTH - GRID_Y_OFFSET_MAGIC_NUMBER,
    a: SHADOW_ALPHA
  }.merge(COLOR_WALL)

  send("tick_#{game.state.scene}", game)

  # Bottom side
  game.outputs.solids << {
    x: 0,
    y: 0,
    w: game.grid.w,
    h: GRID_START_Y
  }.merge(COLOR_WALL)

  # Right side
  game.outputs.solids << {
    x: game.grid.w - GRID_START_X,
    y: GRID_START_Y,
    w: BLOCK_WIDTH,
    h: game.grid.h
  }.merge(COLOR_WALL)
end

def tick_title(game)
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

  if game.inputs.keyboard.key_down.space
    game.state.scene = "gameplay"
    reset_gameplay(game)
  end
end

def tick_gameover(game)
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

  if game.inputs.keyboard.key_down.space
    game.state.scene = "gameplay"
    reset_gameplay(game)
  end
end

def reset_gameplay(game)
  game.state.head_x = 8
  game.state.head_y = 4
  game.state.direction = "right"
  game.state.move_wait = MOVE_WAIT
  game.state.lock_movement = false
  game.state.body = init_body(game)
  game.state.food = spawn_food(game)
  game.state.score = 0
end

def tick_gameplay(game)
  determine_direction(game)

  game.state.move_wait -= 1
  if game.state.move_wait <=0
    game.state.lock_movement = false
    game.state.move_wait = MOVE_WAIT

    # Append segment before moving head to start moving the body
    game.state.body.unshift([game.state.head_x, game.state.head_y])

    # Move head one position forward
    case game.state.direction
    when "up"
      game.state.head_y += 1
    when "right"
      game.state.head_x += 1
    when "down"
      game.state.head_y -= 1
    when "left"
      game.state.head_x -= 1
    end

    # Check for wall collision
    if game.state.head_x < 0 || game.state.head_x >= GRID_WIDTH ||
      game.state.head_y < 0 || game.state.head_y >= GRID_HEIGHT
      game.state.scene = "gameover"
    end

    # Check for body collision
    if game.state.body.any? { |body_part| game.state.head_x == body_part[0] && game.state.head_y == body_part[1] }
      game.state.scene = "gameover"
    end

    # Check for food collision
    if game.state.head_x == game.state.food[0] && game.state.head_y == game.state.food[1]
      game.state.food = spawn_food(game)
      game.state.score +=1
    else
      # No collision means no expanding body
      # Remove segment from the end to complete moving the body
      game.state.body.pop
    end
  end

  # Render food shadow
  game.outputs.solids << {
    x: GRID_START_X + (game.state.food[0] * BLOCK_WIDTH) + SHADOW_OFFSET,
    y: GRID_START_Y + (game.state.food[1] * BLOCK_WIDTH) - SHADOW_OFFSET,
    w: BLOCK_WIDTH,
    h: BLOCK_WIDTH,
    a: SHADOW_ALPHA
  }.merge(COLOR_FOOD)

  # Render head shadow
  game.outputs.solids << {
    x: GRID_START_X + (game.state.head_x * BLOCK_WIDTH) + SHADOW_OFFSET,
    y: GRID_START_Y + (game.state.head_y * BLOCK_WIDTH) - SHADOW_OFFSET,
    w: BLOCK_WIDTH,
    h: BLOCK_WIDTH,
    a: SHADOW_ALPHA
  }.merge(COLOR_PLAYER)

  # Render body shadow
  game.state.body.each do |body_part|
    game.outputs.solids << {
      x: GRID_START_X + (body_part[0] * BLOCK_WIDTH) + SHADOW_OFFSET,
      y: GRID_START_Y + (body_part[1] * BLOCK_WIDTH) - SHADOW_OFFSET,
      w: BLOCK_WIDTH,
      h: BLOCK_WIDTH,
      a: SHADOW_ALPHA
    }.merge(COLOR_PLAYER)
  end

  # Render food
  game.outputs.solids << {
    x: GRID_START_X + (game.state.food[0] * BLOCK_WIDTH),
    y: GRID_START_Y + (game.state.food[1] * BLOCK_WIDTH),
    w: BLOCK_WIDTH,
    h: BLOCK_WIDTH
  }.merge(COLOR_FOOD)

  # Render head
  game.outputs.solids << {
    x: GRID_START_X + (game.state.head_x * BLOCK_WIDTH) + 2,
    y: GRID_START_Y + (game.state.head_y * BLOCK_WIDTH) + 2,
    w: BLOCK_WIDTH - 4,
    h: BLOCK_WIDTH - 4
  }.merge(COLOR_PLAYER)


  # Render body
  game.state.body.each do |body_part|
    game.outputs.solids << {
      x: GRID_START_X + (body_part[0] * BLOCK_WIDTH) + 2,
      y: GRID_START_Y + (body_part[1] * BLOCK_WIDTH) + 2,
      w: BLOCK_WIDTH - 4,
      h: BLOCK_WIDTH - 4
    }.merge(COLOR_PLAYER)
  end

  # Render score
  game.outputs.labels << {
    x: GRID_START_X,
    y: GRID_START_Y - 5,
    text: "Score: #{game.state.score}",
    size_enum: 5,
    anchor_x: 0
  }.merge(COLOR_TEXT_DARK)
end

# Determines the location of the food.
def spawn_food(game)(game)
  loop do
    x = rand(GRID_WIDTH)
    y = rand(GRID_HEIGHT)

    ok = game.state.body.none? { |body_part| x == body_part[0] && y == body_part[1] } &&
         (x != game.state.head_x && y != game.state.head_y)

    return [x, y] if ok
  end
end

# Creates initial segments of the body.
def init_body(game)
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

# Updates direction based on user input.
def determine_direction(game)
  # Prevents constant change in direction until the head moves.
  return if game.state.lock_movement == true
  current_direction = game.state.direction

  game.state.direction = "up" if game.inputs.up && game.state.direction != "down"
  game.state.direction = "right" if game.inputs.right  && game.state.direction != "left"
  game.state.direction = "down" if game.inputs.down && game.state.direction != "up"
  game.state.direction = "left" if game.inputs.left && game.state.direction != "right"

  game.state.lock_movement = true if current_direction != game.state.direction
end

$gtk.reset
