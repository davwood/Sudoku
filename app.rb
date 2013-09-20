require 'sinatra'
require_relative 'config/newrelic.yml'
require_relative 'lib/sudoku'
require_relative 'lib/cell'
require 'sinatra/partial' 
require 'rack-flash'
use Rack::Flash
set :partial_template_engine, :erb
set :session_secret, "super secret"

enable :sessions # sessions are disabled by default 
 
def random_sudoku
  seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
  sudoku = Sudoku.new(seed.join)
  sudoku.solve!
  sudoku.to_s.chars
end

def generate_new_puzzle_if_necessary
  return if session[:current_solution]
  sudoku = random_sudoku
  session[:solution] = sudoku
  removed_cells =  case session[:difficulty] 
                        when 1 then 35
                        when 3 then 60
                        else 45
                        end
  session[:puzzle] = puzzle(sudoku,removed_cells)
  session[:current_solution] = session[:puzzle]    
end

def prepare_to_check_solution
  @check_solution = session[:check_solution]
  if @check_solution
    flash[:notice] = "Incorrect values are highlighted yellow"
end
  session[:check_solution] = nil
end

# this method removes some digits from the solution to create a puzzle
def puzzle(sudoku,removed_cells=20)
  # this method is yours to implement
    random = (0..81).to_a.sample(removed_cells)
    @puzzled = []
    sudoku.each_with_index do |element,index|
                if random.include?(index) then @puzzled.push(0)
                else @puzzled.push(element) end
            end
    @puzzled
    # random.each { |index| sudoku[index] = 0 }
    # sudoku
end

get '/' do
  prepare_to_check_solution
  generate_new_puzzle_if_necessary
  @current_solution = session[:current_solution] || session[:puzzle]
  @solution = session[:solution]
  @puzzle = session[:puzzle]

  erb :index
end

get '/easy' do
    session[:current_solution] = nil
    session[:difficulty] = 1
    redirect to("/")
end

get '/average' do
    session[:current_solution] = nil
    session[:difficulty] = 2
    redirect to("/")
end

get '/hard' do
    session[:current_solution] = nil
    session[:difficulty] = 3
    redirect to("/")
end

get '/solution' do
  redirect to("/") if session[:solution].nil?
  @current_solution = session[:solution]
  @solution = session[:solution]
  @puzzle = session[:puzzle]
  erb :index
end

post '/' do
  boxes = params["cell"].each_slice(9).to_a
  cells = (0..8).to_a.inject([]) {|memo, i|
  memo += boxes[i/3*3, 3].map{|box| box[i%3*3, 3] }.flatten
  }
  session[:current_solution] = cells.map{|value| value.to_i }.join
  session[:check_solution] = true
  redirect to("/")
end

post '/reset' do
    session[:current_solution] = nil
    redirect to("/")
end

helpers do

  def colour_class(solution_to_check, puzzle_value, current_solution_value, solution_value)
    must_be_guessed = puzzle_value == 0
    tried_to_guess = current_solution_value.to_i != 0
    guessed_incorrectly = current_solution_value != solution_value

    if solution_to_check && 
        must_be_guessed && 
        tried_to_guess && 
        guessed_incorrectly
      'incorrect'
    elsif !must_be_guessed
      'value-provided'
    end
  end


end

helpers do
    def cell_value(value)
        value.to_i == 0 ? '' : value
    end

end