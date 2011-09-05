(function( $ ){
		function getMatches(req, res, url, $info) {
				$info.text('');
				$.getJSON(url, req, function(data) {  
						if(data.meta.matches == 0) {
								$info.text('No matches');
						} 
						else if(data.meta.clipped) {
								$info.text('many more matches');
						}
						else if(data.meta.more) {
								$info.text(data.meta.excess + ' more match' + (data.meta.excess > 1 ? 'es' : ''));
						}
						var suggestions = [];
						$.each(data.items, function(i, val) {  
								suggestions.push({ label: val.label, id: val.id, supplement: val.supplement });  
						});  
						res(suggestions);
				});
		}

		$.fn.suggest = function(options) {
				return this.each(function() {
						var $this = $(this);    
						
						var settings = {
								minLength: 2,
								directlyTypedMustExist: false,
								source: function(req, res) {
										return getMatches(req, res, options.url, $info);
								},
								close: function() {
									$info.empty();	
								}
						};

						if(options) { 
								$.extend(settings, options);
						}

						$this.autocomplete(settings);

						var $info = $('<li class="suggest-info"></li>');
						var $ac = $this.data('autocomplete');
				    $ac._renderMenu = function(ul, items) {
								$.each(items, function(index, item) {
										$ac._renderItem(ul, item);
								});
								$info.appendTo(ul);
						};

						if(settings.supplement) {
								$ac._renderItem = function(ul, item) {
										return $('<li></li>')
												.data('item.autocomplete', item)
												.append('<a>' + item.label + settings.supplement(item.supplement) + '</a>')
												.appendTo(ul);
								};
						}
						
						if(settings.directlyTypedMustExist) {
								$this.blur(function() {
										var item = $this.data('autocomplete').selectedItem;
										if(!item) {
												//Nothing selected, but possibly a valid value. See if one result returned.
												$.getJSON(settings.url, { exact: true, term: $this.val() }, function(data) {  
														if(data.meta.matches == 1) {
																var ui = { item: data.items[0] };
																//Treat it as selected.
																$this.data('autocomplete')
																		.options.select(null, ui);
														}
												});
										}
								});
						}
				});
		};


		$.fn.tags = function(options) {
				return this.each(function() {
						var $this = $(this);

						var settings = {
								minLength: 1,
								directlyTypedMustExist: false,
								tagSource: function(req, res) {
										//$info is hoisted which aloows this closure access to the value set below.
										return getMatches(req, res, options.url, $info);
								},
								close: function() {
									$info.empty();	
								}
						};

						if(options) { 
								$.extend(settings, options);
						}

						$this.tagit(settings);
						var $input = $('.tagit-input', $this);

						var $info = $('<li class="suggest-info"></li>');
						var $ac = $input.data('autocomplete');
				    $ac._renderMenu = function(ul, items) {
								$.each(items, function(index, item) {
										$ac._renderItem(ul, item);
								});
								$info.appendTo(ul);
						};

						if(settings.supplement) {
								$ac._renderItem = function(ul, item) {
										return $('<li></li>')
												.data('item.autocomplete', item)
												.append('<a>' + item.label + settings.supplement(item.supplement) + '</a>')
												.appendTo(ul);
								};
						}

						if(settings.directlyTypedMustExist) {
								$input.blur(function() {
										var item = $input.data('autocomplete').selectedItem;
										if(!item) {
												//Nothing selected, but possibly a valid value. See if one result returned.
												$.getJSON(settings.url, { exact: true, term: $input.val() }, function(data) {  
														if(data.meta.matches == 1) {
																var ui = { item: data.items[0] };
																//Treat it as selected.
																$input.data('autocomplete')
																		.options.select(null, ui);
														}
												});
										}
								});
						}
				});
		};
})( jQuery );

