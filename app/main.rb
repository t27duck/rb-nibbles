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

def tick(args)
  args.state.scene ||= "title"
  # Gameplay area
  args.outputs.solids << {
    x: GRID_START_X,
    y: GRID_START_Y,
    w: (BLOCK_WIDTH * GRID_WIDTH),
    h: (BLOCK_WIDTH * GRID_HEIGHT)
  }.merge(COLOR_GAME_FIELD)

  # Top side
  args.outputs.solids << {
    x: 0,
    y: args.grid.h - BLOCK_WIDTH - GRID_Y_OFFSET_MAGIC_NUMBER,
    w: args.grid.w - BLOCK_WIDTH,
    h: BLOCK_WIDTH + 16
  }.merge(COLOR_WALL)

  # Top side shadow
  args.outputs.solids << {
    x: 0 + SHADOW_OFFSET,
    y: args.grid.h - BLOCK_WIDTH - GRID_Y_OFFSET_MAGIC_NUMBER - SHADOW_OFFSET,
    w: args.grid.w - BLOCK_WIDTH,
    h: BLOCK_WIDTH + 16,
    a: SHADOW_ALPHA
  }.merge(COLOR_WALL)

  # Left side
  args.outputs.solids << {
    x: 0,
    y: GRID_START_Y,
    w: BLOCK_WIDTH,
    h: args.grid.h - GRID_START_Y - BLOCK_WIDTH - GRID_Y_OFFSET_MAGIC_NUMBER
  }.merge(COLOR_WALL)

  # Left side shadow
  args.outputs.solids << {
    x: 0 + SHADOW_OFFSET,
    y: GRID_START_Y - SHADOW_OFFSET,
    w: BLOCK_WIDTH,
    h: args.grid.h - GRID_START_Y - BLOCK_WIDTH - GRID_Y_OFFSET_MAGIC_NUMBER,
    a: SHADOW_ALPHA
  }.merge(COLOR_WALL)

  send("tick_#{args.state.scene}", args)

  # Bottom side
  args.outputs.solids << {
    x: 0,
    y: 0,
    w: args.grid.w,
    h: GRID_START_Y
  }.merge(COLOR_WALL)

  # Right side
  args.outputs.solids << {
    x: args.grid.w - GRID_START_X,
    y: GRID_START_Y,
    w: BLOCK_WIDTH,
    h: args.grid.h
  }.merge(COLOR_WALL)
end

def tick_title(args)
  args.outputs.labels << {
    x: (args.grid.w / 2),
    y: (args.grid.h / 2),
    text: "Nibbles",
    size_enum: 8,
    alignment_enum: 1
  }.merge(COLOR_TEXT_DARK)

  args.outputs.labels << {
    x: (args.grid.w / 2),
    y: (args.grid.h / 2) - 50,
    text: "Press Spacebar to Start",
    size_enum: 4,
    alignment_enum: 1,
  }.merge(COLOR_TEXT_DARK)

  if args.inputs.keyboard.key_down.space
    args.state.scene = "gameplay"
    reset_gameplay(args)
  end
end

def tick_gameover(args)
  args.outputs.labels << {
    x: (args.grid.w / 2),
    y: (args.grid.h / 2),
    text: "Game Over",
    size_enum: 8,
    alignment_enum: 1
  }.merge(COLOR_TEXT_DARK)

  args.outputs.labels << {
    x: (args.grid.w / 2),
    y: (args.grid.h / 2) - 50,
    text: "Score: #{args.state.score}",
    size_enum: 4,
    alignment_enum: 1
  }.merge(COLOR_TEXT_DARK)

  args.outputs.labels << {
    x: (args.grid.w / 2),
    y: (args.grid.h / 2) - 150,
    text: "Press Spacebar to Play Again",
    size_enum: 4,
    alignment_enum: 1
  }.merge(COLOR_TEXT_DARK)

  if args.inputs.keyboard.key_down.space
    args.state.scene = "gameplay"
    reset_gameplay(args)
  end
end

def reset_gameplay(args)
  args.state.head_x = 8
  args.state.head_y = 4
  args.state.direction = "right"
  args.state.move_wait = MOVE_WAIT
  args.state.lock_movement = false
  args.state.body = init_body(args)
  args.state.food = spawn_food(args)
  args.state.score = 0
end

def tick_gameplay(args)
  determine_direction(args)

  args.state.move_wait -= 1
  if args.state.move_wait <=0
    args.state.lock_movement = false
    args.state.move_wait = MOVE_WAIT

    # Append segment before moving head to start moving the body
    args.state.body.unshift([args.state.head_x, args.state.head_y])

    # Move head one position forward
    case args.state.direction
    when "up"
      args.state.head_y += 1
    when "right"
      args.state.head_x += 1
    when "down"
      args.state.head_y -= 1
    when "left"
      args.state.head_x -= 1
    end

    # Check for wall collision
    if args.state.head_x < 0 || args.state.head_x >= GRID_WIDTH ||
      args.state.head_y < 0 || args.state.head_y >= GRID_HEIGHT
      args.state.scene = "gameover"
    end

    # Check for body collision
    if args.state.body.any? { |body_part| args.state.head_x == body_part[0] && args.state.head_y == body_part[1] }
      args.state.scene = "gameover"
    end

    # Check for food collision
    if args.state.head_x == args.state.food[0] && args.state.head_y == args.state.food[1]
      args.state.food = spawn_food(args)
      args.state.score +=1
    else
      # No collision means no expanding body
      # Remove segment from the end to complete moving the body
      args.state.body.pop
    end
  end

  # Render food shadow
  args.outputs.solids << {
    x: GRID_START_X + (args.state.food[0] * BLOCK_WIDTH) + SHADOW_OFFSET,
    y: GRID_START_Y + (args.state.food[1] * BLOCK_WIDTH) - SHADOW_OFFSET,
    w: BLOCK_WIDTH,
    h: BLOCK_WIDTH,
    a: SHADOW_ALPHA
  }.merge(COLOR_FOOD)

  # Render head shadow
  args.outputs.solids << {
    x: GRID_START_X + (args.state.head_x * BLOCK_WIDTH) + SHADOW_OFFSET,
    y: GRID_START_Y + (args.state.head_y * BLOCK_WIDTH) - SHADOW_OFFSET,
    w: BLOCK_WIDTH,
    h: BLOCK_WIDTH,
    a: SHADOW_ALPHA
  }.merge(COLOR_PLAYER)

  # Render body shadow
  args.state.body.each do |body_part|
    args.outputs.solids << {
      x: GRID_START_X + (body_part[0] * BLOCK_WIDTH) + SHADOW_OFFSET,
      y: GRID_START_Y + (body_part[1] * BLOCK_WIDTH) - SHADOW_OFFSET,
      w: BLOCK_WIDTH,
      h: BLOCK_WIDTH,
      a: SHADOW_ALPHA
    }.merge(COLOR_PLAYER)
  end

  # Render food
  args.outputs.solids << {
    x: GRID_START_X + (args.state.food[0] * BLOCK_WIDTH),
    y: GRID_START_Y + (args.state.food[1] * BLOCK_WIDTH),
    w: BLOCK_WIDTH,
    h: BLOCK_WIDTH
  }.merge(COLOR_FOOD)

  # Render head
  args.outputs.solids << {
    x: GRID_START_X + (args.state.head_x * BLOCK_WIDTH) + 2,
    y: GRID_START_Y + (args.state.head_y * BLOCK_WIDTH) + 2,
    w: BLOCK_WIDTH - 4,
    h: BLOCK_WIDTH - 4
  }.merge(COLOR_PLAYER)


  # Render body
  args.state.body.each do |body_part|
    args.outputs.solids << {
      x: GRID_START_X + (body_part[0] * BLOCK_WIDTH) + 2,
      y: GRID_START_Y + (body_part[1] * BLOCK_WIDTH) + 2,
      w: BLOCK_WIDTH - 4,
      h: BLOCK_WIDTH - 4
    }.merge(COLOR_PLAYER)
  end

  # Render score
  args.outputs.labels << {
    x: GRID_START_X,
    y: GRID_START_Y - 5,
    text: "Score: #{args.state.score}",
    size_enum: 5,
    anchor_x: 0
  }.merge(COLOR_TEXT_DARK)
end

# Determines the location of the food.
def spawn_food(args)(args)
  loop do
    x = rand(GRID_WIDTH)
    y = rand(GRID_HEIGHT)

    ok = args.state.body.none? { |body_part| x == body_part[0] && y == body_part[1] } &&
         (x != args.state.head_x && y != args.state.head_y)

    return [x, y] if ok
  end
end

# Creates initial segments of the body.
def init_body(args)
  body = []

  INITIAL_BODY.times do |step|
    case args.state.direction
    when "up"
      body << [args.state.head_x, args.state.head_y + (step + 1)]
    when "right"
      body << [args.state.head_x - (step + 1), args.state.head_y]
    when "down"
      body << [args.state.head_x, args.state.head_y - (step + 1)]
    when "left"
      body << [args.state.head_x + (step + 1), args.state.head_y]
    end
  end

  body
end

# Updates direction based on user input.
def determine_direction(args)
  # Prevents constant change in direction until the head moves.
  return if args.state.lock_movement == true
  current_direction = args.state.direction

  args.state.direction = "up" if args.inputs.up && args.state.direction != "down"
  args.state.direction = "right" if args.inputs.right  && args.state.direction != "left"
  args.state.direction = "down" if args.inputs.down && args.state.direction != "up"
  args.state.direction = "left" if args.inputs.left && args.state.direction != "right"

  args.state.lock_movement = true if current_direction != args.state.direction
end

$gtk.reset
