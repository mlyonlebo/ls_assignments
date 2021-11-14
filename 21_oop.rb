# frozen_string_literal: true

class Deck
  attr_accessor :cards

  # rubocop:disable Style/MutableConstant
  FULL_DECK = { 'A' => 4, '2' => 4, '3' => 4,
                '4' => 4, '5' => 4, '6' => 4,
                '7' => 4, '8' => 4, '9' => 4,
                '10' => 4, 'J' => 4, 'Q' => 4,
                'K' => 4 }
  # rubocop:enable Style/MutableConstant

  def initialize
    @cards = FULL_DECK.clone
  end

  def to_s
    p cards
  end
end

class Hand
  attr_accessor :cards

  def initialize(cards)
    @cards = cards
  end

  def +(other)
    cards << other
  end

  def >(other)
    total > other.total
  end

  def non_aces_total
    total = 0
    cards.each do |card|
      if card.to_i != 0
        total += card.to_i
      elsif %w[J Q K].include?(card)
        total += 10
      end
    end
    total
  end

  def total
    total = non_aces_total
    if cards.include?('A')
      total += total > 10 ? 1 : 11
    end
    total
  end

  def under_21?
    total <= 21
  end

  def under_17?
    total < 17
  end

  # rubocop:disable Metrics/AbcSize
  def display
    strings = ['', '', '', '', '', '', '', '']
    cards.each do |card|
      strings[1] += ' ______ '
      strings[2] += "|#{card}#{' ' * (5 - (card.length - 1))}|"
      strings[3] += '|      |'
      strings[4] += '|      |'
      strings[5] += "|#{'_' * (5 - (card.length - 1))}#{card}|"
    end
    puts strings
  end
  # rubocop:enable Metrics/AbcSize
end

module DealerPatter
  def welcome_message
    puts "Welcome to Twenty One!\nEnjoy yourself, but remember:"
    puts 'Gambling is a terrible vice. Besides, the house ALWAYS wins!'
  end

  def goodbye_message
    puts "Thanks for playing Twenty One!\nI hope you find meaning in your life"
    puts 'far from these cursed tables of wrath and ruin.'
    puts "You'll find no redemption here! No, no!\nGood night and good luck #{human.name}!"
  end

  def random_name_association
    ['flower', 'disgraced movie star',
     'Sicilian delicacy', 'degenerative illness'].sample
  end

  def random_number_association
    ["loves I've lost", 'years I was in prison', 'toes on my left foot',
     'licks it takes to get to the center of a Tootsie pop', "children I've sired",
     "stallions I've domesticated", "cottages I've burglarized",
     "times I've been forcibly removed from Disneyworld", 'sons of disappointed',
     'switchblades I have secreted on my person', 'the Immortal One'].sample
  end
end

class Player
  attr_accessor :hand, :wins

  def initialize
    @wins = 0
  end

  def visible_hand
    visible_cards = hand.cards.clone
    visible_cards[0] = ' '
    Hand.new(visible_cards)
  end
end

class Computer < Player; end

class Human < Player
  attr_reader :name

  include DealerPatter
  def initialize
    super
    @name = set_name
  end

  def set_name
    input = ''
    loop do
      puts "What's your name, friend?"
      input = gets.chomp
      break unless input.empty?

      puts 'You are valid, friend, but that input is not...'
    end
    puts "#{input}? You don't say!\nAfter the #{random_name_association}, by chance?\nMy mistake!"
    puts "When you get to my age...\nWell! Let me deal you in."
    input
  end

  def hit?
    input = ''
    loop do
      puts 'Hit or stay? (h/s)'
      input = gets.chomp
      break if input.downcase == 'h' || input.downcase == 's'

      puts "Alas! You are valid, #{name}, but that choice is not."
    end
    input.downcase == 'h'
  end

  def play_again?
    input = ''
    loop do
      puts 'Play again? (y/n)'
      input = gets.chomp
      break if input.downcase == 'y' || input.downcase == 'n'

      puts "Alas! You are valid, #{name}, but that choice is not."
    end
    input.downcase == 'y'
  end
end

class TwentyOne
  attr_accessor :human, :computer, :deck, :bust

  include DealerPatter
  def initialize
    welcome_message
    @human = Human.new
    @computer = Computer.new
  end

  def new_game
    @deck = Deck.new.cards
    @bust = false
  end

  def card_from_shuffled_deck
    card = deck.to_a.sample[0]
    deck[card] -= 1
    card
  end

  def deal_and_display_hands
    human.hand = Hand.new([card_from_shuffled_deck, card_from_shuffled_deck])
    computer.hand = Hand.new([card_from_shuffled_deck, card_from_shuffled_deck])
    display_hands
    computer_total
    human_total
  end

  def display_hands
    computer.visible_hand.display
    human.hand.display
  end

  def computer_total
    puts "Yours truly, the dealer, has #{computer.visible_hand.total} showing.\nPlus a little something extra..."
  end

  def human_total
    total = human.visible_hand.total
    puts "You've got #{total} showing."
    puts "Funny... #{total} is precisely the number of #{random_number_association}."
  end

  def human_bust
    puts 'By the way, you bust!'
    self.bust = true
    computer_win
  end

  def computer_bust
    puts 'Conflagration! I bust!'
    self.bust = true
    human_win
  end

  def human_turn
    while human.hand.under_21?
      human.hit? ? human.hand + card_from_shuffled_deck : return
      display_hands
      human_total
    end
    human_bust
  end

  # rubocop:disable Lint/Void
  def computer_turn
    while computer.hand.under_17?
      computer.hand + card_from_shuffled_deck
      display_hands
      computer_total
    end
    computer_bust unless computer.hand.under_21?
  end
  # rubocop:enable Lint/Void

  def human_win
    human.wins += 1
    puts 'While you may have won this game, in succumbing to the mortal sin of gambling,'
    puts "haven't you lost something greater?"
  end

  def computer_win
    computer.wins += 1
    puts "Didn't I tell you, the house always wins?"
  end

  def compare_hands
    computer.hand.display
    human.hand.display
    puts "I've got #{computer.hand.total}."
    puts "You've got #{human.hand.total}."
  end

  def declare_winner
    compare_hands
    human.hand > computer.hand ? human_win : computer_win
  end

  def report_score
    puts "You've got #{human.wins} wins to my #{computer.wins}."
  end

  def play
    loop do
      new_game
      deal_and_display_hands
      human_turn
      computer_turn unless bust
      declare_winner unless bust
      report_score
      break unless human.play_again?
    end
    goodbye_message
  end
end

TwentyOne.new.play
