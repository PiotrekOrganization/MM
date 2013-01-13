auto_id = 0

class Glue
	constructor: (@useCase, @gui, @storage) ->
		gui = @gui
		storage = @storage
		usecase = @useCase

		@after(@useCase, 'createNode', (node) -> 
			storage.saveNode(node)
		)

		@after(@storage, 'nodeSaved', (node) -> 
			usecase.showNode(node)
		)

		@after(@useCase, 'showNode', (node) -> 
			gui.renderNode(node)
		)
	
	before: (object, methodName, adviseMethod) ->
		YouAreDaBomb(object, methodName).before(adviseMethod)
	
	after: (object, methodName, adviseMethod) ->
    	YouAreDaBomb(object, methodName).after(adviseMethod)
    
    around: (object, methodName, adviseMethod) ->
    	YouAreDaBomb(object, methodName).around(adviseMethod)

class UseCase

	createNode: (node) ->

	showNode: (node) ->

class Storage

	constructor: ->
		@nodes = []

	saveNode: (node) ->
		auto_id++
		node.id = auto_id
		@nodeSaved(node)

	nodeSaved: (node) ->
		@nodes.push(node)


class Node
	constructor: (title, parent = null, children = []) -> 
		@title = title
		@parent = parent
		@children = children
		@id = null


class Gui

	constructor: ->
		@canvas = $('.map-canvas')
		@control = $('.control-layer')

	renderNode: (node) ->
		title = node.title
		gui_node = $('<div class="map-element map-element-secondary" data-id="'+node.id+'"></div>')
		gui_node.html(title)
		@appendNode(gui_node)

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
		root = new Node('Map')
		usecase.createNode(root)

$ -> new Spa