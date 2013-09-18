require 'sinatra'
require_relative 'lib/sudoku'
require_relative 'lib/cell'
require 'sinatra/partial' 
set :partial_template_engine, :erb

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
  session[:puzzle] = puzzle(sudoku)
  session[:current_solution] = session[:puzzle]    
end

def prepare_to_check_solution
  @check_solution = session[:check_solution]
  session[:check_solution] = nil
end

# this method removes some digits from the solution to create a puzzle
def puzzle(sudoku)
  # this method is yours to implement
   # puzzled = sudoku.map {|element| if element.to_i == (1..9).to_a.sample.to_i then 0 else element end} 
    random = (0..81).to_a.sample(20)
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

get '/solution' do
  @current_solution = session[:solution]
  @solution = session[:solution]
  @puzzle = session[:puzzle]
  erb :index
end

post '/' do
  cells = params["cell"]
  session[:current_solution] = cells.map{|value| value.to_i }.join
  session[:check_solution] = true
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