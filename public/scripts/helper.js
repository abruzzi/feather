var helper = {
    getRenderer: function(id){
        if(haml.cache && haml.cache[id]){
            return haml.cache[id];
        }

        var el = $('#'+id);
        if (el.attr('type') === 'text/template') {
            return haml.compileHaml(id);
        }

        return null;
    },
    
    renderTemplate: function(func, id, parameters, owner) {
        var html = '';
        try{
            html = func.call(owner, parameters);
        }catch(e){
            throw new Error('can not render: ' + e.message); 
        }

        return html;
    },

    loadTemplate: function(id, parameters, owner){
        var html = '';

        var func = helper.getRenderer(id);
        if(func){
            html = helper.renderTemplate(func, id, parameters, owner);
        }else{
            if(window.console){
                window.console.log('can not find template: ' + id);
            }
        }
        return html;
    }
}

