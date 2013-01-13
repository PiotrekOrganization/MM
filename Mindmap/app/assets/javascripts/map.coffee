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

		@after(@gui, 'newNodePrepared', (node) -> 
			usecase.createNode(node)
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
		gui_node = document.createElement('div')
		gui_node = $(gui_node)
		gui_node.attr('class', 'map-element map-element-secondary')
		gui_node.attr('data-id', node.id )
		gui_node.css('top', 0)
		gui_node.css('left', 0)
		gui_node.html(node.title + ', #' + node.id)
		if( node.parent ) 
			gui_node.html( gui_node.html() + ', #' + node.parent)
		@appendNode(gui_node)

	appendNode: (node) ->
		@canvas.append(node)
		@prepareNodeTriggers(node)
		@prepareNodeDrag(node)

	prepareNodeTriggers: (node) ->
		node.contextmenu( (event) => 
			@showContextMenu(node)
			return false
		)

	prepareNodeDrag: (node) ->
		node.mousedown( (e) =>
			oldX = e.pageX
			oldY = e.pageY
			$(document).mousemove( (e) =>
				#calculate delta transitions
				diffX = e.pageX - oldX
				diffY = e.pageY - oldY

				node.css( 'top', parseInt(node.css('top')) + diffY )
				node.css( 'left', parseInt(node.css('left')) + diffX )
				#set values for new delta
				oldX = e.pageX
				oldY = e.pageY
			)
			#unbind mousemove following
			$(document).mouseup( =>
				$(document).unbind('mousemove')
			)
		)

	showContextMenu: (node) ->
		@hideAllContextMenus()
		contextMenu = HandlebarsTemplates['contextMenu']
		menuContainer = $('<div></div>')
		menuContainer.append(contextMenu)
		@control.append(menuContainer)
		contextMenu = menuContainer.find('.context-menu')
		contextMenu.css 'left', parseInt node.css('left')
		contextMenu.css 'top', parseInt node.css('top')
		contextMenu.fadeIn(300)
		@enableMenuHidder(contextMenu)
		@prepareContextMenuTriggers(contextMenu, node)

	prepareContextMenuTriggers: (menu, node) ->
		menu.find('.new-node').click( (event) =>
			event.preventDefault()
			@prepareNewNode(node.attr('data-id'))
			menu.parent().remove()
		)
		menu.find('.remove-node').click( (event) =>
			event.preventDefault()
			@removeNode(node)
			menu.parent().remove()
		)

	removeNode: (node) ->
		node.remove()

	hideAllContextMenus: ->
		$('.context-menu').parent().remove()

	enableMenuHidder: (menu) ->
		event = @canvas.click( =>
			menu.fadeOut(600, ->
				$(this).remove()
			)
		)

	prepareNewNode: (parent) ->
		node_object = new Node('node', parent)
		@newNodePrepared(node_object)

	newNodePrepared: (node) ->

class Spa
	constructor: ->
		storage = new Storage
		usecase = new UseCase
		gui = new Gui
		glue = new Glue(usecase, gui, storage)
		root = new Node('Map')
		usecase.createNode(root)

$ -> new Spa