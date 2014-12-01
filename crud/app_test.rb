require "rspec"
require "rack/test"
require_relative "app"

describe "crud application" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "creates a new bookmark" do
    get "/bookmarks"
    bookmarks = JSON.parse last_response.body
    last_size = bookmarks.size

    post "/bookmarks", {url: "http://www.test.com", title: "Test"}
    expect(last_response.status).to eq 201
    expect(last_response.body).to match /\/bookmarks\/\d+/

    get "/bookmarks"
    bookmarks = JSON.parse last_response.body
    expect(bookmarks.size).to eq last_size + 1
  end

  it "updates a bookmark" do
    post "/bookmarks", {url: "http://www.test.com", title: "Test"}
    bookmark_uri = last_response.body
    id = bookmark_uri.split("/").last

    put "/bookmarks/#{id}", {title: "Success"}
    expect(last_response.status).to eq 204

    get "/bookmarks/#{id}"
    retrieved_bookmark = JSON.parse last_response.body
    expect(retrieved_bookmark["title"]).to eq "Success"
  end

  it "delete a bookmark" do
    get "/bookmarks"
    bookmarks = JSON.parse last_response.body
    last_size = bookmarks.size

    id = bookmarks.last["id"]

    delete "/bookmarks/#{id}"
    expect(last_response.status).to eq 200

    get "/bookmarks"
    bookmarks = JSON.parse last_response.body
    expect(bookmarks.size).to eq last_size - 1
  end

  it "sends an error code for an invalid create request" do
    post "/bookmarks", {url: "test", title: "Test"}
    expect(last_response.status).to eq 400
  end
end
