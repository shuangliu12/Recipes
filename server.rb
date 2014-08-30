require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname:'recipes')
    yield(connection)
  ensure
    connection.close
  end
end

get '/recipes' do
  page = params[:page]
  @page_number = page.to_i || 0
  sql = 'SELECT name, id FROM recipes ORDER BY name LIMIT 20 OFFSET $1'
  db_connection do |conn|
    @recipes = conn.exec(sql,[@page_number*20])
  end
  erb :index
end

get '/recipes/:recipe_id' do
  recipe_id = params[:recipe_id]
  sql = 'SELECT recipes.votes,recipes.id, recipes.name AS recipe, recipes.instructions, recipes.description, ingredients.name AS ingredients
  FROM recipes LEFT JOIN ingredients ON recipes.id = ingredients.recipe_id WHERE recipe_id = $1'

  db_connection do |conn|
    @results = conn.exec(sql,[recipe_id])
  end
    @results = @results.to_a
  erb :each_dish
end

get '/recipes/:recipe_id/comments' do
  recipe_id = params[:recipe_id]
  sql = 'SELECT comments.content, comments.time FROM recipes JOIN comments ON comments.recipe_id = recipes.id WHERE comments.recipe_id = $1'

  db_connection do |conn|
    @all_comments = conn.exec(sql,[recipe_id])
  end
    @all_comments.to_a

  erb :comments
end


post '/recipes/:recipe_id' do
  recipe_id = params[:recipe_id]

  sql = 'SELECT votes FROM recipes WHERE id = $1'

  db_connection do |conn|
    @votes = conn.exec(sql,[recipe_id])
  end
    @votes.to_a

  insert = 'UPDATE recipes SET votes = $1 WHERE id = $2'

  db_connection do |conn|
    @results = conn.exec(insert,[@votes[0]['votes'].to_i+1,recipe_id])
  end
  redirect '/recipes'
end

post '/recipes/:recipe_id/comments' do
  text = params['text']
  recipe_id = params[:recipe_id].to_i
  sql = 'INSERT INTO comments(recipe_id, content, time) VALUES($1, $2, now())'
  db_connection do |conn|
    conn.exec_params(sql,[recipe_id, text])
  end
  redirect '/recipes'
end



