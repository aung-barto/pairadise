require 'sinatra'
require 'sqlite3'
require 'pry'

db = SQLite3::Database.new "movies.db"

rows = db.execute <<-SQL
create table if not exists movies (
	id INTEGER PRIMARY KEY,
	title TEXT,
	rating TEXT,
	img_url TEXT
	);
SQL

#redirect to all movies page
get "/" do 
	redirect("/movies")
end

#list all movies
get "/movies" do 
	movies_list = db.execute("SELECT * FROM movies")
	erb :movie, locals: {movies: movies_list}
end

#get to single movie page
get "/movies/:id" do 
	id = params[:id].to_i
	one_movie = db.execute("SELECT * FROM movies WHERE id = ?", id)
	erb :show, locals: {movie: one_movie[0]}
end

#get all movies by rating
get "/movies/rating/:rating" do
	rating = params[:rating]
	movies_list = db.execute("SELECT * FROM movies WHERE rating = ?", rating)
	erb :rating, locals: {movies: movies_list}
end

#get info from form and add into database
post "/movies" do
	db.execute("INSERT INTO movies (title, rating, img_url) VALUES (?,?,?);", params[:title], params[:rating], params[:img_url])
	latest_entry = db.execute("SELECT max(id), title, rating, img_url FROM movies;")
	erb :show, locals: {movie: latest_entry[0]}
end

#update movie info and database
put "/movies/:id" do
	id = params[:id].to_i
	new_title = params[:new_title]
	new_rating = params[:new_rating]
	new_image = params[:new_image]
	db.execute("UPDATE movies SET title = ?, rating = ?, img_url =? WHERE id = ?", new_title, new_rating, new_image, id)
	redirect("/movies")
end

#delete individual movie
delete "/movies/:id" do
	id = params[:id].to_i
	db.execute("DELETE FROM movies WHERE id = ?", id)
	redirect("/movies")
end
