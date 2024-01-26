# computer uses Donald Knuth five-guess algorithm

# main function to play multiple games
def main
  playing = "y"

  while playing.downcase == "y" do
    play
    puts "Play again? (Y/N)"
    playing = gets.chomp
  end
end

# main play function
def play
  colors = ["blue", "red", "green", "yellow", "black", "white"]
  color_to_digit = {"blue" => "1", "red" => "2", "green" => "3", "yellow" => "4", "black" => "5", "white" => "6"}
  guess = nil
  turn = 1
  result = nil

  # Generate list of possible codes
  $codes = (1..6).to_a.repeated_permutation(4).to_a

  # player chooses side
  team = pick_side

  # get code
  code = gen_code(team, colors, color_to_digit)
  puts code.inspect

  #run game
  while !winner(guess, code, team, turn)
    puts "Turn: #{turn}"
    guess = get_guess(guess, team, colors, color_to_digit, result, turn)
    result = check_guess(guess, code)
    puts "Guess: #{guess}"
    puts "#{result[0]} color(s) are in the correct position."
    puts "#{result[1]} color(s) are in the wrong position."
    turn += 1
  end

  #declare winner
  puts winner(guess, code, team, turn)
end

#let user pick side
def pick_side
  puts "Would you like to be the Mastermind or Guesser?"
  team = gets.chomp.downcase
  while not ((team == "mastermind") || (team == "guesser"))
    puts "Invalid selection, please try again: "
    team = gets.chomp.downcase
  end
  # true = mastermind, false = guesser
  team == "mastermind" ? team = true : team = false
end

# generate code (input or rng)
def gen_code(team, colors, color_to_digit)
  if team
    return get_input(team, colors, color_to_digit)
  else
    return Array.new(4) {rand(1..6) }
  end
end

# get code input (code choice or guess)
def get_input(team, colors, color_to_digit)
  # get code from user
  role = team ? "code" : "guess"
  puts "Enter your #{role} as four colors separated by commas (valid colors include: blue, red, green, yellow, black, and white): "
  # convert to readable format
  code = gets.chomp.gsub(/[^a-zA-Z,]/, '').downcase.split(",")
  # catch invalid input
  while not ((code - colors).empty? && code.length == 4)
    puts "Invalid selection, please try again: "
    code = gets.chomp.gsub(/[^a-zA-Z,]/, '').downcase.split(",")
    puts code.inspect
  end
  # translate code to numbers
  code = code.map { |code| color_to_digit[code].to_i }
  code
end

# get guess (computer or player)
def get_guess(guess, team, colors, color_to_digit, result, turn)
  if not team
    # player guesses
    return get_input(team, colors, color_to_digit)
  elsif team
    # computer guesses
    if turn == 1
      return [1,1,2,2]
    end
    return computer_guess(guess, result)
  end
end

# check how close guess is to code
def check_guess(guess, code)
  position = 0
  color = 0
  checked = []
  if guess == code then return [4,0] end
  guess.each_with_index do |i, index|
    i == code[index] ? position += 1 : nil
    if code.include?(i) && (not checked.include?(i))
      color += guess.count(i) > code.count(i) ? code.count(i) : guess.count(i)
      checked.push(i)
    end
  end
  color = color - position
  [position, color]
end

# get computer guess
def computer_guess(guess, result)
  codes_to_delete = []
  $codes.each do |code|
    codes_to_delete << code if check_guess(code, guess) != result
  end
  $codes -= codes_to_delete
  puts $codes.inspect
  next_guess = minimax
  next_guess
end

# calculate best guess
def minimax
  best_guess = nil
  min_max_score = Float::INFINITY

  $codes.each do |guess|
    score_count = Hash.new(0)

    $codes.each do |possible_code|
      score = check_guess(guess, possible_code)
      score_count[score] += 1
    end

    max_score = score_count.values.max

    if max_score < min_max_score
      min_max_score = max_score
      best_guess = guess
    end
  end
  $codes.delete(best_guess)
  return best_guess
end

# check for winner
def winner(guess, code, team, turn)
  guesser = team ? 'Computer' : 'Player'
  mastermind = team ? 'Player' : 'Computer'
  if code == guess
    return "#{guesser} wins!"
  elsif turn >= 12
    return "No turns left, #{mastermind} wins!"
  end
  nil
end

main
