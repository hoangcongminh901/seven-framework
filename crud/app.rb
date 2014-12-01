require "sinatra"
require "data_mapper"
require "dm-serializer"
require 'sinatra/contrib/all'
require "sinatra/mustache"
require "slim"
require_relative "bookmark"

DataMapper::setup :default, "sqlite3://#{Dir.pwd}/bookmarks.db"
DataMapper::finalize.auto_upgrade!

class Hash
  def slice *whitelist
    whitelist.inject({}){|result, key| result.merge key => self[key]}
  end
end

def get_all_bookmarks
  Bookmark.all order: :title
end

get "/bookmarks" do
  @bookmarks = get_all_bookmarks
  respond_with :bookmark_list, @bookmarks
end

post "/bookmarks" do
  input = params.slice "url", "title"
  bookmark = Bookmark.new input
  if bookmark.save
    # Created
    [201, "/bookmarks/#{bookmark['id']}"]
  else
    400 #Bad Request
  end
end

get "/bookmarks/:id" do
  id = params[:id]
  puts id
  bookmark = Bookmark.get id
  content_type :json
  bookmark.to_json
end

put "/bookmarks/:id" do
  id = params[:id]
  bookmark = Bookmark.get id
  input = params.slice "url", "title"
  bookmark.update input
  204 # No Content
end

delete "/bookmarks/:id" do
  id = params[:id]
  bookmark = Bookmark.get id
  bookmark.destroy
  200
end

get "/" do
  @bookmarks = get_all_bookmarks
  # erb :bookmark_list
  # mustache :bookmark_list
  slim :bookmark_list
end

get "/bookmark/new" do
  erb :bookmark_form_new
end

helpers do
  def h text
    Rack::Utils.escape_html text
  end
end
