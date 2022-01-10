require 'active_support/all'
require 'thor'
WORDS = File.read("/usr/share/dict/words").split.map(&:downcase)
COMMON_FIVE_LETTER_WORDS = File.read("./five_letter_words.txt").split.map(&:downcase)

class Solver
  def initialize(green: '', orange: '', reject: '', length: 5)
    @green = green || ''
    @orange = orange || ''
    @reject = reject || ''
    @length = length || ''
  end

  def solve
    possible_words = WORDS.select do |word|
      word.size == @length
    end.select do |word|
      green_letters = @green.split('').each_slice(2).map do |position, letter|
        [word[position.to_i], letter]
      end
      green_letters.all? do |(possible_letter, actual_letter)|
        possible_letter == actual_letter
      end
    end.reject do |word|
      wrong_positions = @orange.split('').each_slice(2).map do |position, letter|
        [word[position.to_i], letter]
      end
      wrong_positions.any? do |(guessed_letter, cannot_be)|
        guessed_letter == cannot_be
      end
    end.select do |word|
      possible_letters = @orange.split('').each_slice(2).map do |_position, letter|
        letter
      end
      possible_letters.all? { |letter| word.include?(letter) }
    end.reject do |word|
      word.split('').any? { |letter| @reject.split('').include?(letter) }
    end

    possible_words
  end
end

class SolverCLI < Thor
  desc "solve", "solve --green 0g2e --orange 1e --reject qwtyuiopas"
  option :green
  option :orange
  option :reject

  def solve
    potential_solutions = Solver.new(green: options[:green], orange: options[:orange], reject: options[:reject]).solve
    puts "Top words"
    puts "========="
    i = 0
    COMMON_FIVE_LETTER_WORDS.each do |word|
      next if i == 10
      if potential_solutions.include?(word)
        i += 1
        puts word
      end
    end
    puts
    puts "All"
    puts "==="
    puts potential_solutions
  end
end

SolverCLI.start(ARGV)
