###############################################################################
### Very basic hangman game inspired by TechHire interview with Mined Minds ###
###############################################################################
###################### Rewritten for Sinatra (2017-02-13) #####################
#############################  by John C. Verbosky ############################
###############################################################################

###############################################################################
# Features:                                                                   #
# - animations for winning and losing                                         #
# - ability to start a new game or exit after win/loss                        #
# - cumulative score                                                          #
###############################################################################

###############################################################################
#################### Variables, arrays, counters and flags ####################
###############################################################################

# array of mystery words
$words = ["research", "persistence", "dedication", "curiosity", "troubleshoot", "energetic", "organization",
          "communication", "development", "loyalty", "adaptable", "creativity", "improvement", "dependable",
          "teamwork", "collaboration", "optimistic", "focused", "meticulous", "effective", "inspired"]

$word = ""  # string for mystery word
$prompt = ""  # string for feedback after guessing a letter
$bucket = []  # array to hold all letters that have been entered to guess
$build_word = []  # array to hold guessed letters that are found in mystery word
$wrong_count = []  # array to hold guessed letters that are not found in mystery word
$games_won = 0  # counter for displaying cumulative number of games won
$games_lost = 0  # counter for displaying cumulative number of games lost
$game_over = false  # flag to indicate whether the game is over, used to drive start_game()
$game_won = false  # flag to indicate whether the game was won, used by wrong_count() for images

###############################################################################
######################## Method for starting a new game #######################
###############################################################################

# Method to initialize game status flags, letter arrays and mystery word
def start_game()
  $game_over = false  # set flag to false when starting a new game
  $game_won = false  # set flag to false when starting a new game
  $bucket = []  # empty array when starting a new game
  $build_word = []  # empty array when starting a new game
  $wrong_count = []  # empty array when starting a new game
  $word = $words.sample  # select a random word from the words array
  $word.length.times { $build_word.push("_") }  # push placeholder underscores to $build_word array
end

###############################################################################
##################### Methods for passing values to app.rb ####################
###############################################################################

# Method to display the current mystery word
# Corresponds to @current in app.rb
def current_word()
  current = $build_word.join(" ")  # return a string of placeholder underscores + correctly guessed letters
end

# Method to display the current guessed letters
# Corresponds to @guessed in app.rb
def guessed_letters()
  guessed = $bucket.join(" ")  # return a string of guessed letters
end

# Method to provide feedback on letter submitted by user
# Corresponds to @feedback in app.rb
def feedback()
  return $prompt  # $prompt is conditionally populated by good_letter(), word_test() and wrong_letter()
end

# Method to return the game status for conditionally displaying the correct view (play.erb, endgame.erb)
# Used by "post '/guess' do" route in app.rb
def game_over?()
  $game_over == true  # if true, the endgame.erb will be used which removes the form and enables a new game
end

# Method to return the number of games won for displaying a running total
# Corresponds to @won in app.rb
def games_won()
  $games_won
end

# Method to return the number of games lost for displaying a running total
# Corresponds to @lost in app.rb
def games_lost()
  $games_lost
end

###############################################################################
####################### Methods for testing each letter #######################
###############################################################################

# Method that checks the user-specified letter for a few things
# Used by @test in "post '/guess' do" route in app.rb
def good_letter(letter)
  if $bucket.include? letter  # check to see if letter has already been guessed and reprompt if so
    $prompt = "Sorry, sunshine - you already guessed that one!"
  elsif letter[/[a-zA-Z]+/] and letter.length == 1  # check is a single -letter- has been entered
    $bucket.push(letter)  # if so, add it to the bucket array
    letter_test(letter)  # then pass it to letter_test()
  else  # if multiple letters, non-alpha characters or nothing has been entered
    $prompt = "Sorry, but I need to have a single letter. Please try again!"  # reprompt user to try again
  end
end

# Method that checks to see if letter is in the mystery word
def letter_test(letter)
  # If it is in the word pass it to find_locations(), if not pass it to wrong_letter()
  $word.include?(letter) ? find_locations(letter) : wrong_letter(letter)
end

# Method that finds all locations of a letter in the word
def find_locations(letter)
  locations = []  # array for the index (position) of all instances of the letter in the word
  last_index = 0  # dual-purpose variable that holds the index (position) of the letter and the .index offset
  occurrences = $word.count letter  # variable used to control do loop iteration count
  occurrences.times do  # for every occurrence of the letter in the word
    last_index = $word.index(letter, last_index)  # determine the position of the letter in the word
    locations.push(last_index)  # push the position of the letter to the location array
    last_index += 1  # increment last_index by 1 to target the next occurrence of the letter (via .index offset)
  end
  add_letter(letter, locations)  # pass the user-specified letter and array of locations to add_letter()
  # return locations  # use for test 15
end

# Method to populate $build_word with every occurrence of a letter
def add_letter(letter, locations)
  # for each occurrence of a letter, add the letter to the correct location in $build-word
  locations.each { |location| $build_word[location] = letter }
  word_test()  # then run word_test()
end

# Method to compare the current build_word array against the mystery word
def word_test()
  if $build_word.join == $word  # if $build_word equals $word, the user won
    $game_over = true  # set the flag to indicate that the game is over
    $game_won = true  # set the flag to indicate that the player won the game
    $games_won += 1  # so increase the games_won score by 1
  else  # if they don't match, run user_input() for another letter
    $prompt = "Great job, sunshine - please guess again!"
  end
end

# Method that receives non-mystery word letter and adds it to the wrong_count array
def wrong_letter(letter)
  if $wrong_count.length < 9  # if the wrong_count array has less than 9 letters
    $wrong_count.push(letter)  # then add the letter to the array
    $prompt = "Sorry, sunshine - that letter isn't in the word!"
  else  # if this is the tenth wrong letter, it's game over
    $wrong_count.push(letter)  # then add the letter to the array
    $game_over = true  # set the flag to indicate that the game is over
    $games_lost += 1  # increase the games_lost score by 1
  end
end

###############################################################################
#################### Methods for displaying hangman images ####################
###############################################################################

# Method to determine which image count should be passed to hangman()
# Used as hangman() argument by @image in app.rb
def wrong_count()
  $game_won == true ? 11 : $wrong_count.length  # if the user won use 11, otherwise use the number of wrong letters
end

# Method to progressively draw the hangman stages as incorrect letters are guessed
# Used by @image in app.rb
def hangman(count)
  case count
    when 0 then image = "/images/wrong_0.png"
    when 1 then image = "/images/wrong_1.png"
    when 2 then image = "/images/wrong_2.png"
    when 3 then image = "/images/wrong_3.png"
    when 4 then image = "/images/wrong_4.png"
    when 5 then image = "/images/wrong_5.png"
    when 6 then image = "/images/wrong_6.png"
    when 7 then image = "/images/wrong_7.png"
    when 8 then image = "/images/wrong_8.png"
    when 9 then image = "/images/wrong_9.png"
    when 10 then image = "/images/loser.gif"
    when 11 then image = "/images/winner.gif"
  end
end

###############################################################################
##################################### End #####################################
###############################################################################