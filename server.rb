require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end

get '/' do
  erb :'index'
end

get '/movies' do
  db_connection do |conn|
    movies = conn.exec("select movies.id, movies.title, movies.year, movies.rating, studios.name as studio, genres.name as genre
    from movies
    join studios
    on (movies.studio_id = studios.id)
    join genres
    on (movies.genre_id = genres.id)
    order by movies.title
    ;")
    erb :'movies/index', locals: {movies: movies }
  end
end

get '/movies/:title' do
  db_connection do |conn|
    movie_info = conn.exec("select movies.year, movies.rating, movies.synopsis,
    studios.name as studio, genres.name as genre
    from movies
    join studios
    on (movies.studio_id = studios.id)
    join genres
    on (movies.genre_id = genres.id)
    where movies.title = '#{params[:title]}'
    ;")
    cast_info = conn.exec("select actors.name, cast_members.character
    from cast_members
    join movies
    on (cast_members.movie_id = movies.id)
    join actors
    on (cast_members.actor_id = actors.id)
    where movies.title = '#{params[:title]}'
    ;")
    erb :'movies/show', locals: { title: params[:title], movie_info: movie_info, cast_info: cast_info }
  end
end

get '/actors' do
  db_connection do |conn|
    names = conn.exec("select name
    from actors
    order by name")
    erb :'actors/index', locals: { names: names.values.flatten }
  end
end


get '/actors/:name' do
  db_connection do |conn|
    actor_info = conn.exec("select movies.title as title, cast_members.character as character
    from cast_members
    join movies
    on (cast_members.movie_id = movies.id)
    join actors
    on (cast_members.actor_id = actors.id)
    where actors.name = '#{params[:name]}'
    order by movies.title;")
    erb :'actors/show', locals: { name: params[:name], actor_info: actor_info }
  end
end
