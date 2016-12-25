
clone = require( 'clone' )

class Function

    # static private variables
    _describe = 'Function'

    constructor: ( @name, @call, @params ) ->
        # args = @call.toString().match(/^\s*function\s+(?:\w*\s*)?\((.*?)\)/)
        # @args = if args? then ( if args[1]? then args[1].trim().split(/\s*,\s*/) else [] ) else null
        
        @data       = null
        
        # Private var
        @_posts = new Set()
        @_pres  = new Set()
        return @

    Bind: ( func, pname ) ->
        return false if not func.params[pname]?
        

    setout: ( func ) ->
        @_posts.add( func )
        return
    
    SetIn: ( func ) ->
        @_pres.add( func )
        return
    

    IsPrepared: ->
        return false if false in ( pref.data isnt null for pref in @_pres )
        return true

    Call: ->
        paramap = @params
        for p, obj of paramap
            paramap.p = obj.data
        

        

    # static functions
    # @Bind = ( fin, fout ) -> 




    

module.exports = Function if module?

