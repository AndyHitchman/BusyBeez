(function ($) {
    var effects = {
        show : function() { $(this).show(); },
        hide : function() { $(this).hide(); },
        none : function() { }
    };

    function doToggle(toggle, dependentBlock, settings) {
        var enable =
            (settings.toggleWhen == 'any-enabled' && toggle.is(":checked"))
            || (settings.toggleWhen == 'all-enabled' && toggle.filter(":checked").size() == toggle.size());

        var disable =
            (settings.toggleWhen == 'any-disabled' && !toggle.is(":checked"))
            || (settings.toggleWhen == 'all-disabled' && toggle.filter(":checked").size() != toggle.size());

        var affectedInputs = $(':input', dependentBlock).add(dependentBlock.filter(':input'));

        if (enable || disable) {
            dependentBlock.each(settings.checkEffect);
            affectedInputs.removeAttr("disabled");
        }
        if (!enable && !disable) {
            dependentBlock.each(settings.uncheckEffect);
            affectedInputs.attr("disabled", "disabled");
        }
    };


    $.fn.toggleDependentFields = function (dependentBlock, options) {
       var settings = {
          toggleWhen : 'any-enabled', // 'all-enabled', 'any-disabled', 'all-disabled'
          checkEffect : 'show', // 'hide', 'none', function,
          uncheckEffect : 'hide' // 'show', 'none', function,
        };

        var toggle = this;

        // If options exist, lets merge them
        // with our default settings
        if (options) {
            $.extend(settings, options);
        }

        if (toggle.size() == 0) {
            if (typeof console != "undefined") console.log('toggleDependentFields was bound to an empty selector');
            return this;
        }

        if (dependentBlock.size() == 0) {
            if (typeof console != "undefined") console.log('toggleDependentFields was given a empty dependendBlock selector');
            return this;
        }

        settings.checkEffect = effects[settings.checkEffect] ? effects[settings.checkEffect] : settings.checkEffect;
        settings.uncheckEffect = effects[settings.uncheckEffect] ? effects[settings.uncheckEffect] : settings.uncheckEffect;

        doToggle(toggle, dependentBlock, settings);

        toggle.click(function () {
           doToggle(toggle, dependentBlock, settings);
        });

        //Other parts of a radio group not specifically named as toggling the dependent block.
        var otherRadios = $();

        this.filter(':radio').map(function () {
            return $(':radio[name=' + this.name + ']').not(toggle);
        }).each(function() {
            $.merge(otherRadios, this);
        });

        otherRadios.click(function () {
           doToggle(toggle, dependentBlock, settings);
        });
        
        return this;
    };
})(jQuery);


