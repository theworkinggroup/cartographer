// Cartographer Object: used to properly include and initialize the Google Map libraries.
// (c) 2009 Georges Gabereau & The Working Group, Inc.

function Cartographer(el){
  this.element = el;
  this.map = null;
  
  this.initialize = function(callback){
    if (GBrowserIsCompatible()) {
      //alert(document.getElementById(this.element));
      this.map = new GMap2(document.getElementById(this.element));
      callback();
    }
  };
}

Cartographer.loadScript = function(path){
  var script = document.createElement('script');
  script.src = path;
  script.type = 'text/javascript';
  document.getElementsByTagName('head')[0].appendChild(script);
};

Cartographer.loadAPIs = function(apikey) {
  Cartographer.loadScript('http://www.google.com/jsapi?key=' + this.apikey + '&callback=Cartographer.loadMaps');
};

Cartographer.loadMaps = function(){
  google.load('maps', Cartographer.apiversion, { 'callback': Cartographer.confirmMapsLoaded });
};

Cartographer.confirmMapsLoaded = function(){
  $(window).trigger('mapsLoaded');
};

$(window).bind('mapsLoaded', function(){
  //Properly unload the Google libraries.
  if(self.Event && Event.observe){
      Event.observe(window, 'unload', GUnload);
  }else{
      window.onunload = GUnload;
  }
});