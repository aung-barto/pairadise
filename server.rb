require 'sinatra'
require 'sqlite3'
require 'json'

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

counter = 0
get "/api/:key/:id" do 
	key = params[:key]
	id = params[:id]
	if key.length<5 && counter < 5 
		counter+= 1 
		movie = db.execute("SELECT * FROM movies WHERE id = ?", id.to_i)[0]
		content_type :json 
		response = {:id => movie[0], :title => movie[1], :rating => movie[2], :img_url => movie[3]}.to_json
	elsif key.length <5 && counter >=5 
		response = {:error =>"You've reach maximum # of access"}.to_json
	else 
		response = {:error => "we don't have the movie you're looking for "}.to_json
	end
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
