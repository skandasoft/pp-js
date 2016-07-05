{CompositeDisposable} = require 'atom'

js2c = require 'js2coffee'
fs = require 'fs'

module.exports =
  subscriptions: null
  config:
    requires:
      title: 'NPM/Require'
      type: 'array'
      default:[]

    types:
      title: 'Javascript File Types'
      type: 'array'
      default: []

    'node-cli-args':
      title: 'Node CLI Arguments'
      type: 'array'
      default: ['-e']

    'node-args':
      title: 'Node Arguments'
      type: 'array'
      default: []


  activate: (state) ->
    @subscriptions = new CompositeDisposable

  compile: (src,options,data,fileName,quickPreview,hyperLive,editor,view)->

    jsSrc = src
    unless ( hyperLive or quickPreview or fileName.indexOf "~pp~")
      try
        jsSrc = fs.readFileSync(fileName,'utf-8').toString()
      catch e
        console.log(e)
    js2c.build jsSrc,options

  html: (src,options,data,fileName,quickPreview,hyperLive,editor,view)->
    jsSrc = src
    unless ( hyperLive or quickPreview or fileName.indexOf "~pp~js~" )
      try
        jsSrc = fs.readFileSync(fileName,'utf-8').toString()
      catch e

    js = """
          <script type='text/javascript'>
            #{jsSrc}
          </script>
        """
    atom.packages.getActivePackage('pp')?.mainModule.makeHTML
            js: js
            jsURL: data.js
            cssURL: data.css

  consumeAddPreview: (@preview)->
    requires =
      pkgName: 'js'
      fileTypes: do ->
        types = atom.config.get('pp.js-types') or []
        types.concat ['js'] #filetypes against which this compileTo Option will show

      # names: do ->
      #   names = atom.config.get('pp.js-names') or []
      #   names.concat ['CoffeeScript (Literate)'] #filetypes against which this compileTo Option will show
      #
      # scopeNames: do ->
      #   scopes = atom.config.get('pp.js-scope') or []
      #   scopes.concat ['source.js'] #filetypes against which this compileTo Option will show

      coffee:
        ext: 'coffee'
        hyperLive: true
        quickPreview: true
        exe: @compile

      html:
        ext: 'html'
        hyperLive: true
        quickPreview: true
        exe: (src,options,data,fileName,quickPreview,hyperLive,editor,view)=>
          @html(src,options,data,fileName,quickPreview,hyperLive,editor,view)

      browser:
        hyperLive: true
        quickPreview: true
        browserPlus: true
        exe: (src,options,data,fileName,quickPreview,hyperLive,editor,view)=>
          html: @html(src,options,data,fileName,quickPreview,hyperLive,editor,view)


      run:
        hyperLive: true
        quickPreview: true
        exe: (src,options={},data,fileName,quickPreview,hyperLive,editor,view)->

          if quickPreview or hyperLive or fileName.indexOf('~pp~')
            args = atom.config.get('pp-js.node-cli-args').concat(src)
            program: 'runJS.js'
            args: args
            # process: loophole.runCommand 'node', [args].concat(src),options,editor
          else
            args = atom.config.get('pp-js.node-args').concat(fileName)
            # process: loophole.runCommand 'node', [args].concat(fileName),options,view
            command: 'node'
            args: args


    @ids = @preview requires

  deactivate: ->
    preview deactivate: @ids

  serialize: ->
