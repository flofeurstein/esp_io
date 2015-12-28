angular.module('EspIODirective', [])
.controller('EspIODirController', ['$scope', function($scope) {
  $scope.ios={'io1', 'io2', 'io3'};
}])
.directive('espIOBody', function() {
  return {
    restrict: 'E',
    templateUrl: 'https://rawgit.com/flofeurstein/esp_io/master/html/esp_io_body.html'
  };
});
