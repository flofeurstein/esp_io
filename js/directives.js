(function(){
  var app = angular.module('esp-io-body', []);

  app.directive("espIOBody", function() {
    return {
      restrict: 'E',
      templateUrl: "https://raw.githubusercontent.com/flofeurstein/esp_io/master/html/esp_io_body.html",
      controller: function() {
          };
        },
        controllerAs: "header"
    };
  });
})();
