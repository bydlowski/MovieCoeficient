class CoefficientController < ApplicationController
  before_filter :authenticate_user!

  def index

    @user_imdb_rating = current_user.imdb_rating
    @user = current_user
    
  end

  def update 

    # UPDATE USER RATINGS
    @user = current_user
    # Get ratings given by the user
    @user_rating = params[:result_path][:user_rating]
    @film_imdb_rating = params[:result_path][:form_imdb_rating]
    @film_rotten_rating = params[:result_path][:form_rotten_rating]
    @film_tmdb_rating = params[:result_path][:form_tmdb_rating]
    @film_metacritic_rating = params[:result_path][:form_metacritic_rating]

    if ((@film_imdb_rating).to_f > 0 && (@film_rotten_rating).to_f > 0 && (@film_tmdb_rating).to_f > 0 && (@film_metacritic_rating).to_f > 0 && (@user_rating).to_f > 0) 
      puts "OKKKK" 
      ok = true
    else
      puts "NOOOOO" 
      ok = false
    end      

    # Compare ratings user/website
    def percent_difference(u_rating, w_rating)
      absolute_difference = (u_rating - w_rating).abs
      if absolute_difference > 4
        result = 0
      else
        result = (1 - (absolute_difference / 4)).round(2)
      end
    end

    # Update the arrays and coefficients in the database
    if @user.update(rating_param)
      puts percent_difference((@user_rating).to_f, (@film_imdb_rating).to_f)
      if ok
        (current_user.imdb_rating_array).push(percent_difference((@user_rating).to_f, (@film_imdb_rating).to_f))
        (current_user.rotten_rating_array).push(percent_difference((@user_rating).to_f, (@film_rotten_rating).to_f))
        (current_user.tmdb_rating_array).push(percent_difference((@user_rating).to_f, (@film_tmdb_rating).to_f))
        (current_user.metacritic_rating_array).push(percent_difference((@user_rating).to_f, (@film_metacritic_rating).to_f))
        current_user.amount += 1
        new_imdb_array = []
        new_rotten_array = []
        new_tmdb_array = []
        new_metacritic_array = []
        (current_user.imdb_rating_array).each { |x| new_imdb_array << x.to_f }
        (current_user.rotten_rating_array).each { |x| new_rotten_array << x.to_f }
        (current_user.tmdb_rating_array).each { |x| new_tmdb_array << x.to_f }
        (current_user.metacritic_rating_array).each { |x| new_metacritic_array << x.to_f }
        imdb_average = new_imdb_array.inject{ |sum, el| sum + el }.to_f / (new_imdb_array).size
        rotten_average = new_rotten_array.inject{ |sum, el| sum + el }.to_f / (new_rotten_array).size
        tmdb_average = new_tmdb_array.inject{ |sum, el| sum + el }.to_f / (new_tmdb_array).size
        metacritic_average = new_metacritic_array.inject{ |sum, el| sum + el }.to_f / (new_metacritic_array).size
        current_user.imdb_rating = imdb_average.round(2)
        current_user.rotten_rating = rotten_average.round(2)
        current_user.tmdb_rating = tmdb_average.round(2)
        current_user.metacritic_rating = metacritic_average.round(2)
        @imdb_now = current_user.imdb_rating
        @rotten_now = current_user.rotten_rating
        @metacritic_now = current_user.metacritic_rating
        @tmdb_now = current_user.tmdb_rating
        @amount_now = current_user.amount
        @user.update(coeficient: @user_rating)
      else
        @imdb_now = current_user.imdb_rating
        @rotten_now = current_user.rotten_rating
        @metacritic_now = current_user.metacritic_rating
        @tmdb_now = current_user.tmdb_rating
        @amount_now = current_user.amount
      end
    else
      redirect_to root_url
    end

    respond_to do |format|
      format.html
      format.js
    end 

  end

  

  def rating_param
     params.require(:result_path).permit(:imdb_rating, :imdb_rating_array)
  end

end