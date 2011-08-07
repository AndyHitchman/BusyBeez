(function( $ ){
  $.fn.suggest = function(options) {

    var settings = {
      minLength : 3
    };

    if(options) { 
      $.extend(settings, options);
    }

    return this.each(function() {
      var $this = $(this)     
      var $info = $('<span class="suggest-info"><span>').insertAfter($this);
      

      $this.autocomplete({
        minLength: settings.minLength,
        source: function(req, add) {
          $info.text('');
          $.getJSON(settings.source, req, function(data) {  
            var suggestions = [];
            if(data.length == 0) {
              $info.text('No matches');
            }
            $.each(data, function(i, val) {  
              if(val.clipped) {
                $info.text('many more matches');
              }
              else if(val.more) {
                $info.text(val.excess + ' more match' + (val.excess > 1 ? 'es' : ''));
              } else {
                suggestions.push({ label: val.label, id: val.id });  
              }
            });  
            add(suggestions);
          });
        },
        select: settings.select,
      }).blur(function() {
        $info.text('');    
      });
    });
  };
})( jQuery );

