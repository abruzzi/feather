var feather = feather || {};

(function($){
    var router = Backbone.Router.extend({
        routes: {
            '': 'list',
            'edit': 'edit'
        },

        initialize: function() {
            $('.back').live('click', function() {
                window.history.back();
                return false;
            });

            this.firstPage = true;
        },

        list: function() {
            this.changePage(new feather.AppView());
        },

        edit: function() {
            this.changePage(new feather.NoteEditView());
        },

        changePage: function(page) {
            $(page.el).attr('data-role', 'page');
            page.render();
            $('body').append($(page.el));
            var transition = $.mobile.defaultPageTransition;

            if(this.firstPage) {
                transition = 'none';
                this.firstPage = false;
            }

            $.mobile.changePage($(page.el), {
                changeHash: false,
                transition: transition
            });
        }
    });

    feather.router = new router();
})(jQuery);
