var app = angular.module("App_base", ["ngResource"])

app.factory("Bookmark", function($resource){
  return $resource("/bookmarks/:id", {id:"@id"});
});

app.factory("bookmarks", function(Bookmark){
  return Bookmark.query();
});

app.factory("saveBookmark", function(bookmarks, state){
  return function(bookmark){
    if (!bookmark.id) {
      bookmarks.push(bookmark);
    };
    bookmark.$save();
    state.clearForm();
  };
});

app.factory("deleteBookmark", function(bookmarks) {
  return function(bookmark) {
    var index = bookmarks.indexOf(bookmark);
    bookmark.$delete();
    bookmarks.splice(index, 1);
  };
});

app.factory("editBookmark", function(state){
  return function(bookmark){
    state.formBookmark.bookmark = bookmark;
  };
});

app.controller("BookmarkListController",
  function($scope, bookmarks, deleteBookmark, editBookmark){
    $scope.bookmarks = bookmarks;
    $scope.deleteBookmark = deleteBookmark;
    $scope.editBookmark = editBookmark;
  }
);

app.controller("BookmarkFormController",
  function($scope, state, bookmarks, saveBookmark){
    $scope.formBookmark = state.formBookmark;
    $scope.saveBookmark = saveBookmark;
    $scope.clearForm = state.clearForm;
  }
);

app.service("state", function(Bookmark){
  this.formBookmark = {bookmark:new Bookmark()};
  this.clearForm = function(){
    this.formBookmark.bookmark = new Bookmark();
  };
  this.bookmarkFilter = {filterTag:""};
});

app.factory("buildTagList", function(){
  return function(bookmarks){
    var bookmarkCounts = {};

    bookmarks.each(function(bookmark){
      var tagList = bookmark.tagList;

      tagList.each(function(tag){
        var existing = bookmarkCounts[tag];
        bookmarkCounts[tag] = existing ? existing + 1 : 1;
        });
      });
    var labels = Object.keys(bookmarkCounts);
    labels.sort();
    return labels.map(function(label){
      return {label:label, bookmarkCount:bookmarkCounts[label]};
    });
  };
});

app.controller("TagListController",
  function($scope, state, bookmarks, buildTagList){
    $scope.bookmarks = bookmarks;
    $scope.$watch("bookmarks", function(updatedBookmarks){
      $scope.tags = buildTagList(updatedBookmarks);
    }, true);
    $scope.filterBy = function(tag){
      state.bookmarkFilter.filterTag = tag.label;
    };
  }
);

app.filter("filterByTag", function(){
  return function(bookmarks, filterTag){
    return bookmarks.filter(byTag(filterTag));
  };
});