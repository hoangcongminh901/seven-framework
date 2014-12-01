require "sinatra"
require "data_mapper"
require "dm-serializer"
require 'sinatra/contrib/all'
require "sinatra/mustache"
require "slim"
require_relative "bookmark"
require_relative "tagging"
require_relative "tag"

DataMapper::setup :default, "sqlite3://#{Dir.pwd}/bookmarks.db"
DataMapper::finalize.auto_upgrade!

class Hash
  def slice *whitelist
    whitelist.inject({}){|result, key| result.merge key => self[key]}
  end
end

with_tagList = {methods: [:tagList]}

def get_all_bookmarks
  Bookmark.all order: :title
end

get "/bookmarks" do
  @bookmarks = get_all_bookmarks
  respond_with :bookmark_list, @bookmarks
end

get "/bookmarks/*" do
  tags = params[:splat].first.split "/"
  bookmarks = Bookmark.all
  tags.each do |tag|
    bookmarks = bookmarks.all({taggings: {tag: {label: tag}}})
  end
  bookmarks.to_json with_tagList
end

post "/bookmarks" do
  input = params.slice "url", "title"
  bookmark = Bookmark.new input
  if bookmark.save
    add_tags bookmark
    # Created
    [201, "/bookmarks/#{bookmark['id']}"]
  else
    400 #Bad Request
  end
end

get %r{"/bookmarks/\d+"} do
  content_type :json
  bookmark.to_json with_tagList
end

put %r{"/bookmarks/\d+"} do
  input = params.slice "url", "title"
  if bookmark.update input
    204 # No Content
  else
    400
  end
end

delete %r{"/bookmarks/\d+"} do
  @bookmark.destroy
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

before %r{"/bookmarks/\d+"} do |id|
  @bookmark = Bookmark.get id
  unless @bookmark
    halt 404, "bookmark #{id} not found"
  end
end

helpers do
  def h text
    Rack::Utils.escape_html text
  end

  def add_tags bookmark
    labels = (params["tagAsString"] || "").split(",").map(&:strip)
    existing_labels = []
    bookmark.taggings.each do |tagging|
      if labels.include? tagging.tag.label
        existing_labels.push tagging.tag.label
      else
        tagging.destroy
      end
    end

    (labels - existing_labels).each do |label|
      tag = {label: lable}
      existing = Tag.first tag
      unless existing
        existing = Tag.create tag
      end
      Tagging.create tag: existing, bookmark: bookmark
    end
  end
end