Feather.UserInfoView = Backbone.View.extend({
    initialize: function(){
        this.render();
    },

    render: function(){
        var func = haml.compileHaml({
            sourceUrl: 'templates/user-info.haml'
        });

        this.$el.html(func()); 
        return this;
    }
});
