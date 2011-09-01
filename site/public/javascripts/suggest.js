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

		$.fn.multisuggest = function(options) {
				function split(val) {
						return val.split(/,\s*/);
				}
				function extractLast(term) {
						return split(term).pop();
				}

				return this.each(function() {
						var $this = $(this); 
						var $info = $('<span class="suggest-info"><span>').insertAfter($this);   

						var settings = {
								minLength: 2,
								source: function(req, res) {
										return getMatches({ term: extractLast(req.term) }, res, options.url, $info);
								}
						};

						if(options) { 
								$.extend(settings, options);
						}

						settings.search = function() {
								var term = extractLast(this.value);
								if(term.length < options.minLength) {
										return false;
								}
								if(options.search) {
										return options.search();
								}
								return true;
						};

						settings.focus = function() {
								// prevent value inserted on focus
								return false;
						};

						settings.select = function(event, ui) {
								var terms = split(this.value);
								// remove the current input
								terms.pop();
								// add the selected item
								terms.push(ui.item.value);
								// add placeholder to get the comma-and-space at the end
								terms.push("");
								this.value = terms.join(", ");

								if(options.select) {
										options.select(event, ui);
								}
								return false;
						};

						$this
								.bind("keydown", function(event) {
										// don't navigate away from the field on tab when selecting an item
										if(event.keyCode === $.ui.keyCode.TAB &&
												 $(this).data("autocomplete").menu.active) {
												event.preventDefault();
										}
								})
								.suggest(settings);
				});
		};

		$.fn.suggest = function(options) {
				return this.each(function() {
						var $this = $(this);    
						var $info = $('<span class="suggest-info"><span>').insertAfter($this);   

						var settings = {
								minLength: 2,
								directlyTypedMustExist: false,
								source: function(req, res) {
										return getMatches(req, res, options.url, $info);
								}
						};

						if(options) { 
								$.extend(settings, options);
						}

						$this.autocomplete(settings);
						$this.blur(function() { $info.text('') });

						if(settings.supplement) {
								$this.data('autocomplete')._renderItem = function(ul, item) {
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
})( jQuery );

