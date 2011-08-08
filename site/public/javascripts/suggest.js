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
            if(data.meta.matches == 0) {
              $info.text('No matches');
            } 
            else if(data.meta.clipped) {
              $info.text('many more matches');
            }
            else if(data.meta.more) {
              $info.text(data.meta.excess + ' more match' + (data.meta.excess > 1 ? 'es' : ''));
            }
            $.each(data.items, function(i, val) {  
                suggestions.push({ label: val.label, id: val.id, supplement: val.supplement });  
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

