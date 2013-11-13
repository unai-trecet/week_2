require 'pry'

class Card

  attr_accessor :suit, :value

  def initialize(v, s)
    @value = v
    @suit = s
  end

  def to_s
    puts "#{value} of #{suit}."
  end

end

########################################################
class Deck

  attr_accessor :cards

  def initialize()
    @cards = []

    ["spades", "clubs", "diamonds", "hearts"].each do |s|
      ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'].each {|v| @cards << Card.new(v, s)} 
    end
    scrumble
  end

  def scrumble 
    cards.shuffle!
  end

  def deal
    cards.pop
  end
end

########################################################
class Blackjack_player

  attr_accessor :sum, :hand

  def initialize(deck)
    @sum = 0
    @hand = []
  end

  def hand_sum  
    self.sum = 0
    aces = 0
    
    hand.each do |c|
      case c.value
      when "Ace"   then aces += 1
      when "Jack"  then self.sum   += 10   
      when "Queen" then self.sum   += 10  
      when "King"  then self.sum   += 10  
      else self.sum += c.value.to_i
      end
    end  
    
    if aces > 0 
      sum_aces aces
    end
  end

  def sum_aces aces
    while true
      if aces > 0 
        if sum <=10
          self.sum += 11
          aces -=1
        else
          self.sum += 1
          aces -= 1
        end 
      else 
        break
      end
    end    
  end

  def hit deck
    hand << deck.deal
    hand_sum
  end

  def h_to_s
    hand.each {|card| card.to_s}
  end
end

########################################################
class Player < Blackjack_player
  attr_accessor :name

  def initialize(deck, n)
    super deck
    @name = n
  end

  def hand_to_s
    puts "#{name} your hand is: "
    h_to_s
  end

  def hand_sum_to_s
    puts "#{name}, your hand sum is: #{self.sum}"
  end  
end

########################################################
class Dealer < Blackjack_player

  def hand_to_s
    puts "Dealer's hand is: "
    h_to_s
  end

  def hand_sum_to_s
    puts "Dealer's hand sum is: #{sum}"
  end 
end

########################################################
class Blackjack

  attr_accessor :players, :dealer, :deck, :winner_sum, :winner_name, :names, :lose 

  def initialize(n)
    @names = n
    @deck = Deck.new()
    @players = []
    @names.each {|name| @players << Player.new(@deck, name)}
    @dealer = Dealer.new(@deck)
    @winner_sum = 0
    @winner_name = ''
    @lose = true
  end

  def new_game
    self.deck = Deck.new()
    self.players = []
    names.each {|n| players << Player.new(@deck, n)}
    self.dealer = Dealer.new(deck)
    self.winner_sum = 0
    self.winner_name = ''
    self.lose = true
    play
  end

  def check_sum
    sum_aux = 0
    names_aux = ''
    players.each do |p| 
      if sum_aux < p.sum && p.sum <= 21 
        names_aux = ''
        names_aux = p.name
        sum_aux = p.sum
        self.lose = false
      elsif sum_aux == p.sum 
        names_aux = names_aux + ', ' + p.name
      end
    end

    self.winner_sum = sum_aux
    self.winner_name = names_aux
  end

  def players_turn

    players.each do |p|
      puts "Now it's #{p.name}'s turn"
      puts

      2.times {p.hit deck}

      p.hand_to_s
      p.hand_sum_to_s

      while true
        sum_player = p.sum

        if  sum_player == 21
          puts "You win #{p.name}! Congratulations"
          break
        elsif sum_player > 21
          puts "You lose #{p.name}... Sorry..."
          break 
        end

        puts "#{p.name}, do you want to hit or stay?"
        puts
        choice = gets.chomp

        if choice == "hit"
          p.hit deck
          p.hand_to_s
          p.hand_sum_to_s
          puts
        elsif choice == "stay"
          puts
          break
        else 
          puts "Please write hit or stay, #{p.name}"
        end
      end
    end
  end

  def dealer_turn
    puts "Now it's dealers turn."
    puts

    2.times {dealer.hit deck}

    dealer.hand_to_s
    dealer.hand_sum_to_s

    while true
      sum_dealer = dealer.sum

      if  sum_dealer == 21
        puts "Dealer wins... #{winner_name}, you lose... Sorry..."
        break
      elsif sum_dealer > 21
        puts "Dealer lose... #{winner_name}, you win!!"
        break
      end

      if sum_dealer < 18 || sum_dealer <= winner_sum
        puts "The dealer deals another card."
        dealer.hit deck
        dealer.hand_to_s
        dealer.hand_sum_to_s
        puts
      elsif sum_dealer > winner_sum
        puts "#{winner_name}'s cards sum is #{winner_sum}, and Dealer's cards sum is #{sum_dealer}. Dealer wins... You lose #{winner_name}... Sorry..."
        break
      elsif sum_dealer < winner_sum
        puts "#{winner_name}'s cards sum is #{winner_sum}, and Dealer's cards sum is #{sum_dealer}. You win #{winner_name}! Congratulations"
        break
      elsif sum_dealer == winner_sum
        puts "#{winner_name}'s cards sum is #{winner_sum}, and Dealer's cards sum is #{sum_dealer}. Draw!!"
        break
      end        
    end
  end

  def play
    players_turn
    check_sum
    if winner_sum == 21  
      puts "#{winner_name} win!! You've got 21!!" 
    elsif lose
      puts "All the players have more than 21... you lose..."
    else
      dealer_turn    
    end

    while true
      puts "Do you want to play again? Write yes or no please."
      response = gets.chomp
      if response == "yes"
        puts "Good! Changing the deck!"
        new_game
        break
      elsif response == "no"
        puts "Bye!"
        break
      else
        puts "Please, write yes or no."
      end
    end 
  end
end

########################################################

puts "Hello, do you want to play blackjack? Great!"
puts "How many players are going to play?"
num_p = gets.chomp
puts
names = Array.new(num_p.to_i)
names.each_index do |i| 
  puts "What's your name please?"
  name = gets.chomp
  names[i] = name
  puts
  puts "Nice to meet you #{name}"
  puts
end
puts "Let's start!!"
puts

blackjack = Blackjack.new(names)

blackjack.play

