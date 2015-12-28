var app = angular.module('EspIO', []);

app.controller('EspIOController', ['$http', function($http, $scope){
  $scope.ios=['io1', 'io2', 'io3'];
}]);

