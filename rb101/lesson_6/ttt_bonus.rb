def non_markers_string(padding)
  edge = padding * 5
  string = ((edge + "|") * 2) + edge
  puts string
end

def markers_string(row, row_count, choices)
  string = '  '
  row.each_with_index do |marker, index|
    marker = choices_only(marker, index, row_count) if choices
    string += marker
    string += '  |  ' unless index == 2
  end
  puts string
end

def choices_only(marker, index, row_count)
  marker == ' ' ? (index + 1 + (row_count * 3)).to_s : ' '
end

def builder(board, choices=false)
  row_count = 0
  rows(board).each do |row|
    non_markers_string(' ')
    markers_string(row, row_count, choices)
    non_markers_string('_')
    row_count += 1
  end
end

def rows(board)
  [board[0, 3], board[3, 3], board[6, 3]]
end

def columns(board)
  [[board[0], board[3], board[6]],
   [board[1], board[4], board[7]],
   [board[2], board[5], board[8]]]
end

def left_diag(board)
  [board[0], board[4], board[8]]
end

def right_diag(board)
  [board[2], board[4], board[6]]
end

def strategic?(line, marker)
  line.count(marker) == 2 && line.count(' ') == 1
end

def row_strategizer(rows, offensive_moves, defensive_moves)
  index = 0
  rows.each do |row|
    if strategic?(row, 'o')
      offensive_moves << row.index(' ') + index
    elsif strategic?(row, 'x')
      defensive_moves << row.index(' ') + index
    end
    index += 3
  end
end

def column_strategizer(columns, offensive_moves, defensive_moves)
  index = 0
  columns.each do |column|
    if strategic?(column, 'o')
      offensive_moves << ((column.index(' ') * 3) + index)
    elsif strategic?(column, 'x')
      defensive_moves << ((column.index(' ') * 3) + index)
    end
    index += 1
  end
end

def left_diag_strategizer(left_diag, offensive_moves, defensive_moves)
  if strategic?(left_diag, 'o')
    offensive_moves << left_diag.index(' ') * 4
  elsif strategic?(left_diag, 'x')
    defensive_moves << left_diag.index(' ') * 4
  end
end

def right_diag_strategizer(right_diag, offensive_moves, defensive_moves)
  if strategic?(right_diag, 'o')
    offensive_moves << ((right_diag.index(' ') * 2) + 2)
  elsif strategic?(right_diag, 'x')
    defensive_moves << ((right_diag.index(' ') * 2) + 2)
  end
end

def strategizer(board)
  offensive_moves = []
  defensive_moves = []
  row_strategizer(rows(board), offensive_moves, defensive_moves)
  column_strategizer(columns(board), offensive_moves, defensive_moves)
  left_diag_strategizer(left_diag(board), offensive_moves, defensive_moves)
  right_diag_strategizer(right_diag(board), offensive_moves, defensive_moves)
  return offensive_moves, defensive_moves
end

def all_choices(board)
  choices = []
  board.each_with_index do |marker, index|
    choices << index if marker == ' '
  end
  choices
end

def computer_picks_square(board)
  offensive_moves, defensive_moves = strategizer(board)
  if offensive_moves.size > 0
    board[offensive_moves.sample] = 'o'
  elsif defensive_moves.size > 0
    board[defensive_moves.sample] = 'o'
  else
    board[all_choices(board).sample] = 'o'
  end
  system("clear")
  puts "The computer counters!"
  builder(board)
end

def user_picks_square(board)
  input = ''
  loop do
    puts "Your move: pick from the available choices:"
    builder(board, true)
    input = gets.chomp.to_i
    break if input > 0 && board[input - 1] == ' '
    puts "You are valid, friend, but that move is not."
  end
  board[input - 1] = 'x'
  builder(board)
end

def winner?(board, marker)
  all_lines = rows(board) + columns(board) + 
    [left_diag(board)] + [right_diag(board)]
  winning_lines = all_lines.select do |line|
    line.all?(marker)
  end
  winning_lines.size > 0
end

def game_over?(board, scoreboard)
  if winner?(board, 'x')
    scoreboard[:user] += 1
    puts "You won! Nice game!"
    true
  elsif winner?(board, 'o')
    scoreboard[:computer] += 1
    puts "You lost! Nice game!"
    true
  elsif board.any?(' ') == false
    scoreboard[:draws] += 1
    puts "Draw!"
    true
  else
    false
  end
end

def turn_alternator(board, user_turn, scoreboard)
  loop do
    user_turn ? user_picks_square(board) : computer_picks_square(board)
    user_turn = !user_turn
    break if game_over?(board, scoreboard)
  end
end

def score_reader(scoreboard)
  puts "You have #{scoreboard[:user]}"
  puts "The computer has #{scoreboard[:computer]}"
end

def match_over(scoreboard)
  if scoreboard[:user] == 5
    puts "You won the match!"
    true
  elsif scoreboard[:computer] == 5
    puts "You lost the match!"
    true
  else
    false
  end
end

puts "Welcome to Tic-Tac-Toe! Let's play first to five!"
scoreboard = { user: 0, computer: 0, draws: 0 }
loop do
  board = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
  turn_alternator(board, true, scoreboard)
  score_reader(scoreboard)
  match_over(scoreboard) ? break : next
end
