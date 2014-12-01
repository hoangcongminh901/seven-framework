for i in 1..10
  post "/bookmarks", {url: "http://www.test#{i}.com", title: "Test#{i}"}
end