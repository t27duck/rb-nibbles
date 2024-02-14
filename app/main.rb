GRID_WIDTH = 41
GRID_HEIGHT = 23
GRID_START_X = 74
GRID_START_Y = 40
BLOCK_WIDTH = 28
MOVE_WAIT = 10
INITIAL_BODY = 7

def tick(args)
  args.state.scene ||= "title"
  draw_field(args)
  send("tick_#{args.state.scene}", args)
end

def tick_title(args)
  args.outputs.labels << {
    x: (args.grid.w / 2),
    y: (args.grid.h / 2),
    text: "Nibbles",
    size_enum: 8,
    alignment_enum: 1,
    r: 255,
    g: 255,
    b: 255
  }

  args.outputs.labels << {
    x: (args.grid.w / 2),
    y: (args.grid.h / 2) - 50,
    text: "Press Spacebar to Start",
    size_enum: 4,
    alignment_enum: 1,
    r: 255,
    g: 255,
    b: 255
  }

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
    alignment_enum: 1,
    r: 255,
    g: 255,
    b: 255
  }

  args.outputs.labels << {
    x: (args.grid.w / 2),
    y: (args.grid.h / 2) - 50,
    text: "Score: #{args.state.score}",
    size_enum: 4,
    alignment_enum: 1,
    r: 255,
    g: 255,
    b: 255
  }

  args.outputs.labels << {
    x: (args.grid.w / 2),
    y: (args.grid.h / 2) - 150,
    text: "Press Spacebar to Play Again",
    size_enum: 4,
    alignment_enum: 1,
    r: 255,
    g: 255,
    b: 255
  }

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
    original_xy = [args.state.head_x, args.state.head_y]
    original_body = args.state.body.dup
    args.state.body.pop
    args.state.body.unshift(original_xy)
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
      args.state.head_x, args.state.head_y = original_xy
      args.state.body = original_body
      args.state.scene = "gameover"
    end

    # Check for body collision
    if args.state.body.any? { |body_part| args.state.head_x == body_part[0] && args.state.head_y == body_part[1] }
      args.state.head_x, args.state.head_y = original_xy
      args.state.body = original_body
      args.state.scene = "gameover"
    end

    # Check for food collision
    if args.state.head_x == args.state.food[0] && args.state.head_y == args.state.food[1]
      args.state.food = spawn_food(args)
      args.state.body.unshift([args.state.haed_x, args.state.haed_y])
      args.state.score +=1
    end
  end


  GRID_HEIGHT.times do |row|
    GRID_WIDTH.times do |column|
      if column == args.state.head_x && row == args.state.head_y
        args.outputs.sprites << {
          x: GRID_START_X + (column * BLOCK_WIDTH),
          y: GRID_START_Y + (row * BLOCK_WIDTH),
          w: BLOCK_WIDTH,
          h: BLOCK_WIDTH,
          path: "sprites/head.png"
        }
      end

      if column == args.state.food[0] && row == args.state.food[1]
        args.outputs.sprites << {
          x: GRID_START_X + (column * BLOCK_WIDTH),
          y: GRID_START_Y + (row * BLOCK_WIDTH),
          w: BLOCK_WIDTH,
          h: BLOCK_WIDTH,
          path: "sprites/food.png"
        }
      end

      if args.state.body.any? { |body_part| column == body_part[0] && row == body_part[1] }
        args.outputs.sprites << {
          x: GRID_START_X + (column * BLOCK_WIDTH),
          y: GRID_START_Y + (row * BLOCK_WIDTH),
          w: BLOCK_WIDTH,
          h: BLOCK_WIDTH,
          path: "sprites/body.png"
        }
      end
    end
  end

  args.outputs.labels  << {
    x: GRID_START_X,
    y: GRID_START_Y - 5,
    text: "Score: #{args.state.score}",
    size_enum: 5,
    alignment_enum: 1
  }
end

# Determines the location of the food.
def spawn_food(args)(args)
  loop do
    x = rand(GRID_WIDTH)
    y = rand(GRID_HEIGHT)

    ok = args.state.body.none? { |body_part| x == body_part[0] && y == body_part[1] } &&
         (x == args.state.head_x && y == args.state.head_y)

    return [x, y] unless ok
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

# Creates the gamefield of "background"
def draw_field(args)
  # Whole window, represents out of bounds after all graphics draw.
  args.outputs.solids << {
    x: 0,
    y: 0,
    w: args.grid.w,
    h: args.grid.h,
    r: 92,
    g: 120,
    b: 230,
  }

  # Gameplay area
  args.outputs.solids << {
    x: GRID_START_X,
    y: GRID_START_Y,
    w: (BLOCK_WIDTH * GRID_WIDTH),
    h: (BLOCK_WIDTH * GRID_HEIGHT),
    r: 0,
    g: 0,
    b: 0,
  }
end

$gtk.reset
