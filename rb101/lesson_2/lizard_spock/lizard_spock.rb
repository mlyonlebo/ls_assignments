require 'yaml'
SCRIPT = YAML.load_file('script.yml')

scoreboard = {
               'you' => 0,
               'the computer' => 0,
               'no one' => 0
             }

winning_combos = {
                    'rock' => ['scissors', 'lizard'],
                    'paper' => ['rock', 'spock'],
                    'scissors' => ['paper', 'lizard'],
                    'lizard' => ['paper', 'spock'],
                    'spock' => ['scissors', 'rock']
                 }

MOVES = winning_combos.keys
                 
def prompt(message)
  puts message.center(40)
end

def valid?(input)
  MOVES.include?(input)
end

def who_won?(user_move, computer_move, winning_combos)
  if winning_combos[user_move].include?(computer_move)
    'you'
  elsif winning_combos[computer_move].include?(user_move)
    'the computer'
  else
    'no one'
  end
end

def pregnant_pause
  tokens = %w(| / - \\ | / - \\)
  tokens.each do |token|
    puts token
    sleep(0.15)
  end
end

prompt(SCRIPT['welcome'])

loop do
  input = ''
  loop do
    prompt(SCRIPT['move_selection'])
    input = gets.chomp.downcase
    if input == 's'
      prompt(SCRIPT['s_selector'])
      input = gets.chomp.downcase
    else
      MOVES.each do |move|
        if move.start_with?(input)
          input = move
        end
      end
    end
    break if valid?(input)
    prompt(SCRIPT['invalid_input'])
  end
  
  computer_choice = MOVES.sample
  winner = who_won?(input, computer_choice, winning_combos)
  scoreboard[winner] += 1
  
  prompt("You chose #{input.upcase}.
  The computer chose...")
  pregnant_pause
  prompt("...#{computer_choice.upcase}!")
  pregnant_pause
  prompt("#{winner.upcase} WON!!\n
  You have #{scoreboard['you']}.\n
  The computer has #{scoreboard['the computer']}.\n\n")

  break if scoreboard.value?(3)
end
prompt(SCRIPT['game_over'])
