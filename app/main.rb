GRID_WIDTH = 38
GRID_HEIGHT = 20
GRID_START_X = 32
GRID_START_Y = 32
GRID_Y_OFFSET_MAGIC_NUMBER = 16
BLOCK_WIDTH = 32
MOVE_WAIT = 10 # Frames
COUNTDOWN_WAIT = 60 # Frames
INITIAL_BODY = 7

COLOR_TEXT_DARK = { r: 58, g: 63, b: 51 }.freeze
COLOR_PLAYER = { r: 58, g: 63, b: 51 }.freeze
COLOR_FOOD = { r: 58, g: 63, b: 51 }.freeze
COLOR_GAME_FIELD = { r: 149, g: 156, b: 119 }.freeze
COLOR_WALL = { r: 107, g: 113, b: 87 }.freeze

SHADOW_OFFSET = 4
SHADOW_ALPHA = 75

require "app/stage"
require "app/player"
require "app/food"
require "app/collision"
require "app/scene"
require "app/block"

def tick(game)
  game.state.scene ||= "title"

  Stage.render(game) do
    send("tick_#{game.state.scene}", game)
  end
end

def tick_title(game)
  Scene.render_title(game)

  reset_and_start_game(game) if game.inputs.keyboard.key_down.space
end

def tick_gameover(game)
  Scene.render_gameover(game)

  reset_and_start_game(game) if game.inputs.keyboard.key_down.space
end

def reset_and_start_game(game)
  game.state.level ||= 1
  game.state.head = [8, 4]
  game.state.direction = "right"
  game.state.move_wait = MOVE_WAIT
  game.state.lock_movement = false
  game.state.body = Player.generate_body_segments(game)
  game.state.food = Food.determine_new_coordinates(game)
  game.state.score = 0
  game.state.scene = "countdown"
  game.state.countdown = 2
  game.state.countdown_wait = COUNTDOWN_WAIT
end

def tick_countdown(game)
  game.state.countdown_wait -= 1
  if game.state.countdown_wait <= 0
    game.state.countdown -= 1
    if game.state.countdown < 0
      game.state.scene = "gameplay"
      return
    end
    game.state.countdown_wait = COUNTDOWN_WAIT
  end

  Scene.render_countdown(game)
end

def tick_gameplay(game)
  Player.change_direction_on_input(game)

  game.state.move_wait -= 1
  if game.state.move_wait <=0
    game.state.lock_movement = false
    game.state.move_wait = MOVE_WAIT

    # Append segment before moving head to start moving the body
    game.state.body.unshift(game.state.head.dup)

    # Move head one position forward
    case game.state.direction
    when "up"
      game.state.head[1] += 1
    when "right"
      game.state.head[0] += 1
    when "down"
      game.state.head[1] -= 1
    when "left"
      game.state.head[0] -= 1
    end

    if Collision.wall?(game) || Collision.body?(game)
      game.state.scene = "gameover"
      return
    end

    if Collision.food?(game)
      game.state.food = Food.determine_new_coordinates(game)
      game.state.score +=1
    else
      # No collision means no expanding body
      # Remove segment from the end to complete moving the body
      game.state.body.pop
    end
  end


  Block.render(game, game.state.head)
  Block.render(game, game.state.body)
  Block.render(game, game.state.food, size: :small)
  Block.render(game, WALLS[game.state.level], size: :full, color: COLOR_WALL)
  Stage.render_score(game)
end

$gtk.reset
