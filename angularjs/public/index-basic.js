/*creates AngularJS application
args: choose name and indicate the list of required plugins or just an empty list [] */
var app = angular.module("BasicApp", [])

/*
define service
*/
app.service("greeter", function(){
  this.name = "";
  this.greeting = function(){
    return (this.name) ? ("Hello, " + this.name + "!") : "";
  };
});

/*
define controller
this controller need the $scope and service
$scope is provided by angularJS to make objects available to the view
*/
app.controller("BasicController", function($scope, greeter){
  $scope.greeter = greeter
});