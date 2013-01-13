class WebGlue
	constructor: (@useCase, @gui, @storage) ->
		gui = @gui
		storage = @storage
		usecase = @useCase

	before: (object, methodName, adviseMethod) ->
		YouAreDaBomb(object, methodName).before(adviseMethod)

	after: (object, methodName, adviseMethod) ->
    	YouAreDaBomb(object, methodName).after(adviseMethod)

    around: (object, methodName, adviseMethod) ->
    	YouAreDaBomb(object, methodName).around(adviseMethod)

class UseCase

class Storage

class Gui

class Spa
	constructor: ->
		storage = new Storage
		usecase = new UseCase
		gui = new Gui
		glue = new Glue(usecase, gui, storage)
		usecase.generateView()

$ -> new Spa