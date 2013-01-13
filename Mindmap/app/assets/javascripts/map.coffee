class Glue
	constructor: (@useCase, @gui, @storage) ->
		gui = @gui
		storage = @storage
		usecase = @useCase

		@after(@useCase, 'createNode', (title) -> 
			gui.renderNode(title)
		)
	
	before: (object, methodName, adviseMethod) ->
		YouAreDaBomb(object, methodName).before(adviseMethod)
	
	after: (object, methodName, adviseMethod) ->
    	YouAreDaBomb(object, methodName).after(adviseMethod)
    
    around: (object, methodName, adviseMethod) ->
    	YouAreDaBomb(object, methodName).around(adviseMethod)

class UseCase

	createNode: (title) ->

class Storage

class Gui

	constructor: ->
		@canvas = $('.map-canvas')
		@control = $('.control-layer')

	renderNode: (title) ->
		node = $('<div class="map-element map-element-secondary"></div>')
		node.html(title)
		@appendNode(node)

	appendNode: (node) ->
		@canvas.append(node)
		@prepareNodeTriggers(node)

	prepareNodeTriggers: (node) ->
		node.contextmenu( (event) => 
			@showContextMenu(node)
			return false
		)

	showContextMenu: (node) ->
		@hideAllContextMenus()
		contextMenu = HandlebarsTemplates['contextMenu']
		menuContainer = $('<div></div>')
		menuContainer.append(contextMenu)
		@control.append(menuContainer)
		contextMenu = menuContainer.find('.context-menu')
		contextMenu.fadeIn(300)
		@enableMenuHidder(contextMenu)
		@prepareContextMenuTriggers(contextMenu, node)

	prepareContextMenuTriggers: (menu, node) ->
		menu.find('.new-node').click( (event) =>
			event.preventDefault()

			)
		menu.find('.remove-node').click( (event) =>
			event.preventDefault()
			node.remove()
			menu.parent().remove()
			)


	hideAllContextMenus: ->
		$('.context-menu').parent().remove()

	enableMenuHidder: (menu) ->
		event = @canvas.click( =>
			menu.fadeOut(600, ->
				$(this).remove()
			)
		)


class Spa
	constructor: ->
		storage = new Storage
		usecase = new UseCase
		gui = new Gui
		glue = new Glue(usecase, gui, storage)
		usecase.createNode('test')

$ -> new Spa