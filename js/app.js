(function() {
  var app = angular.module('EspIO', ['espio-directives']);

  app.controller('EspIOController', ['$http', function($http, $scope){
    $scope.ios={'io1', 'io2', 'io3'};
  }]);

})();
