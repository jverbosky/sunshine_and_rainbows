####################################
############# Sunshine #############
####################################

require 'sinatra'
require 'sinatra/reloader' if development?  # automatically reload app.rb on save via sinatra-contrib gem
require_relative 'sunshine.rb'  # load Ruby script (same directory)

get '/' do  # route to load the initial hangman page
  @start = start_game()  # necessary to start the game, won't run if method called by itself
  @image = hangman(wrong_count())  # use incorrect guess count to load correct image
  @current = current_word()  # placeholder underscores and correct letters as guessed
  @guessed = guessed_letters()  # list of letters that have been guessed
  @won = games_won()  # cumulative number of games won
  @lost = games_lost()  # cumulative number of games lost
  erb :start  # load play.erb file (mainly a placeholder, populated via layout.erb)
end

post '/guess' do  # route that accesses input from start.erb and play.erb form's post > action
  @letter = params[:letter]  # params used to access input from post > action (name="letter")
  @test = good_letter(@letter)  # necessary to pass guessed letter to good_letter(), won't run if called by itself
  @image = hangman(wrong_count())  # use incorrect guess count to load correct image
  @current = current_word()  # placeholder underscores and correct letters as guessed
  @guessed = guessed_letters()  # list of letters that have been guessed
  @feedback = feedback()  # optional feedback on correct/incorrect letter
  @won = games_won()  # cumulative number of games won
  @lost = games_lost()  # cumulative number of games lost
  game_over?() ? (erb :endgame) : (erb :play)  # if game is over load endgame.erb, otherwise load play.erb
end

post '/new' do  # route that accesses input from endgame.erb form's post > action
  @start = start_game()  # necessary to start the game, won't run if method called by itself
  @image = hangman(wrong_count())  # use incorrect guess count to load correct image
  @current = current_word()  # placeholder underscores and correct letters as guessed
  @guessed = guessed_letters()  # list of letters that have been guessed
  @won = games_won()  # cumulative number of games won
  @lost = games_lost()  # cumulative number of games lost
  erb :start  # load play.erb file (mainly a placeholder, populated via layout.erb)
end