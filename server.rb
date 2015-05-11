require 'sinatra'
require 'sqlite3'
require 'pry'

db = SQLite3::Database.new "movies.db"

rows = db.execute <<-SQL
create table if not exists movies (
	id INTEGER PRIMARY KEY,
	title TEXT,
	rating TEXT
	);
SQL

get "/" do 
	redirect("/movies")
end

get "/movies" do 
	movies_list = db.execute("SELECT * FROM movies")
	erb :movie, locals: {movies: movies_list}
end

get "/movies/:id" do 
	id = params[:id].to_i
	one_movie = db.execute("SELECT * FROM movies WHERE id = ?", id)
	erb :show, locals: {movie: one_movie[0]}
end

post "/movies" do
	db.execute("INSERT INTO movies (title, rating) VALUES (?,?);", params[:title], params[:rating])
	latest_entry = db.execute("SELECT max(id), title, rating FROM movies;")
	erb :show, locals: {movie: latest_entry[0]}
end

put "/movies/:id" do
	id = params[:id].to_i
	new_title = params[:new_title]
	new_rating = params[:new_rating]
	db.execute("UPDATE movies SET title = ?, rating = ? WHERE id = ?", new_title, new_rating, id)
	redirect("/movies")
end

delete "/movies/:id" do
	id = params[:id].to_i
	db.execute("DELETE FROM movies WHERE id = ?", id)
	redirect("/movies")
end
