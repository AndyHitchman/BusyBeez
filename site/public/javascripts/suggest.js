(function( $ ){
  $.fn.suggest = function(options) {

    var settings = {
      minLength : 2
    };

    if(options) { 
      $.extend(settings, options);
    }

    return this.each(function() {
      var $this = $(this)     
      var $info = $('<span class="suggest-info"><span>').insertAfter($this);   

      var config = 
        $.extend({}, settings, {
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
          }
        });

        $this.autocomplete(config)
          .blur(function() { $info.text('') });

        if(config.supplement) {
          $this
            .data('autocomplete')._renderItem = function(ul, item) {
              return $('<li></li>')
	              .data('item.autocomplete', item)
	              .append('<a>' + item.label + config.supplement(item.supplement) + '</a>')
        				.appendTo(ul);
            };
        }
    });
  };
})( jQuery );

