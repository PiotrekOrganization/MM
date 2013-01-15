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
		gui_node_body = document.createElement('div')
		gui_node = $('<div></div>')
		gui_node_body = $(gui_node_body)
		gui_node_body.attr('class', 'map-element map-element-secondary')
		gui_node.attr('class', 'map-element-container')
		gui_node.attr('data-id', node.id )
		gui_node.append(gui_node_body)
		gui_node.css('top', 0)
		gui_node.css('left', 0)
		gui_node_body.html(node.title + ', #' + node.id)
		if( node.parent ) 
			gui_node_body.html( gui_node_body.html() + ', #' + node.parent)
		@appendNode(gui_node, node.parent)

	appendNode: (node, parent) ->
		@canvas.append(node)
		@prepareNodeTriggers(node)
		@prepareNodeDrag(node)

	prepareNodeTriggers: (node) ->
		node.contextmenu( (event) => 
			@showContextMenu(node)
			return false
		)
		node.dblclick( (event) =>
			event.preventDefault
			@enableEditMode(node)
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
			menu.fadeOut(300, ->
				$(this).remove()
			)
		)

	prepareNewNode: (parent) ->
		node_object = new Node('node', parent)
		@newNodePrepared(node_object)

	newNodePrepared: (node) ->

	fitNodeLayout: (children_container) ->
		outerHeight = children_container.outerHeight() - children_container.parent().find('> .map-element').outerHeight()
		console.log(outerHeight)
		height = (outerHeight/2)*-1
		children_container.css('bottom', height)
		#children_container.parent().css('margin-top', height*2)


	enableEditMode: (node) ->
		input = $('<input type="text" class="edit-title" value="'+node.find('.map-element').text()+'" />')
		node.find('.map-element').html(input)
		node.unbind()
		input.keydown( (event) =>
			if(event.keyCode == 13)
				@disableEditMode(node)
		)
		$(window).click( (event) =>
			@disableEditMode( node )
			$(this).unbind( event );
		)
		node.click( (event) =>
			event.stopPropagation()
		)

	disableEditMode: (node) ->
		node.find('.map-element').html( node.find('.map-element input.edit-title').val() )
		node.unbind()
		@prepareNodeTriggers(node)
		@prepareNodeDrag(node)

class Spa
	constructor: ->
		storage = new Storage
		usecase = new UseCase
		gui = new Gui
		glue = new Glue(usecase, gui, storage)
		root = new Node('Root')
		usecase.createNode(root)
		root2 = new Node('Second Root')
		usecase.createNode(root2)

$ -> new Spa