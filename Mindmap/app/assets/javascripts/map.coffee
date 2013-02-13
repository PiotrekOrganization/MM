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

		@after(@gui, 'nodeCurvesPrepared', (pathSet) ->
			storage.storePath(pathSet)
		)

		@after(@gui, 'nodeDragStartTrigged', (node) ->
			storage.preparePathsForDrag(node)
		)

		@after(@storage, 'pathsForDragPreapared', (node, paths_array) ->
			gui.nodeDragEnable(node, paths_array)
		)

		@after(@gui, 'reDrown', (pathSet) ->
			storage.refreshPathObject(pathSet)
		)

		@after(@gui, 'newRelation', (f_id, s_id) ->
			useCase.createRelation(f_id, s_id, null) 
		)
	
		@after(@useCase, 'createRelation', (f_id, s_id, title) ->
			storage.saveRelation(f_id, s_id, title)
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

	createRelation: (first_node_id, second_node_id, title) ->

class Storage

	constructor: ->
		@nodes = []
		@paths = []

	saveNode: (node) ->
		auto_id++
		node.id = auto_id
		@nodeSaved(node)

	nodeSaved: (node) ->
		@nodes.push(node)

	storePath: (pathSet) ->
		@paths.push(pathSet)

	getNodePaths: (node_id) ->
		result = []
		for path in @paths
			if path[0] == node_id or path[1] == node_id
				result.push(path)
		return result

	preparePathsForDrag: (node_id) ->
		@pathsForDragPreapared node_id, @getNodePaths(node_id)

	pathsForDragPreapared: (node_id, paths_array) ->

	refreshPathObject: (pathSet) ->
		for path in @paths
			if path[0] == pathSet[0] and path[1] == pathSet[1]
				path[2] = pathSet[2]


class Node
	constructor: (title) -> 
		@title = title
		@id = null
		@relations = []

class Relation 
	constructor: (name, element_f, element_s) ->
		@name = name
		@elements = [element_f, element_s]

class Gui

	constructor: ->
		@canvas = $('.map-canvas')
		@control = $('.control-layer')
		@lines = $('.lines-layer')
		@paper = Raphael("draw-paper", $(window).width(), $(window).height())
		@emptySpace = @lines

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
		@appendNode(gui_node, node.relations)

	appendNode: (node, parent) ->
		@canvas.append(node)
		@prepareNodeTriggers(node)
		@prepareNodeDrag(node)
		#if parent != null
		#	@prepareNodeCurves(node, parent)

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
			@nodeDragStartTrigged parseInt node.attr('data-id')
		)

	nodeDragStartTrigged: (node_id) ->

	nodeDragEnable: (node_id, paths) ->
		node = @canvas.find('.map-element-container[data-id='+node_id+']')
		$(document).mousemove( (e) =>
			@oldX = e.pageX
			@oldY = e.pageY
			$(document).unbind('mousemove')
			$(document).mousemove( (e) =>
				#calculate delta transitions
				diffX = e.pageX - @oldX
				diffY = e.pageY - @oldY

				node.css( 'top', parseInt(node.css('top')) + diffY )
				node.css( 'left', parseInt(node.css('left')) + diffX )
				#set values for new delta
				@oldX = e.pageX
				@oldY = e.pageY
			)
			#unbind mousemove following
			$(document).mouseup( =>
				$(document).unbind('mousemove')
				for path in paths
					@reDraw @canvas.find('.map-element-container[data-id='+path[0]+']'), @canvas.find('.map-element-container[data-id='+path[1]+']'), path[2]
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


	# those are triggers for all buttons in contect menu which is shown after left click on node
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
		menu.find('.new-relation').click( (event) =>
			event.preventDefault()
			menu.parent().remove()
			@selectNodeToSetRelation(node.attr('data-id'))
		)

	# enables select node mode
	selectNodeToSetRelation: (relation_mate_id) ->
		$('.map-element-container').not('[data-id='+relation_mate_id+']').hover \
			( -> 
				$(this).addClass('highlight') 
			), \
			( -> 
				$(this).removeClass('highlight') 
			)
		$('.map-element-container').not('[data-id='+relation_mate_id+']').click( -> 
			selected_id = $(this).attr('data-id')
			$('.map-element-container').not('[data-id='+relation_mate_id+']').removeClass('highlight')
			$('.map-element-container').not('[data-id='+relation_mate_id+']').unbind('hover')
			$('.map-element-container').not('[data-id='+relation_mate_id+']').unbind('click')
		)
		@emptySpace.click( (event) => 
			console.log('test')
			$('.map-element-container').not('[data-id='+relation_mate_id+']').removeClass('highlight')
			$('.map-element-container').not('[data-id='+relation_mate_id+']').unbind('hover')
			$('.map-element-container').not('[data-id='+relation_mate_id+']').unbind('click')
			$(this).unbind( event )
		)

	# this triggers usecase to create this relation
	newRelation: (element_f_id, element_s_id) ->

	removeNode: (node) ->
		node.remove()

	hideAllContextMenus: ->
		$('.context-menu').parent().remove()

	enableMenuHidder: (menu) ->
		event = @emptySpace.click( =>
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
		node.addClass('edit-on')
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
		node.removeClass('edit-on')
		node.find('.map-element').html( node.find('.map-element input.edit-title').val() )
		node.unbind()
		@prepareNodeTriggers(node)
		@prepareNodeDrag(node)

	prepareNodeCurves: (node, parent) ->
		node_y = node.offset().top
		node_x = node.offset().left
		parent = @canvas.find('.map-element-container[data-id='+parent+']')
		parent_y = parent.offset().top
		parent_x = parent.offset().left
		path = @paper.path('M' + parent_x + ' ' + parent_y + 'L' + node_x + ' ' + node_y);
		@nodeCurvesPrepared [parseInt( node.attr('data-id') ), parseInt( parent.attr('data-id') ), path]

	nodeCurvesPrepared: (pathSet) ->

	reDrown: (pathSet) ->

	reDraw: (node, parent, path) ->
		path.remove()
		node_y = node.offset().top
		node_x = node.offset().left
		parent_y = parent.offset().top
		parent_x = parent.offset().left
		path = @paper.path('M' + parent_x + ' ' + parent_y + 'L' + node_x + ' ' + node_y);
		@reDrown [parseInt( node.attr('data-id') ), parseInt( parent.attr('data-id') ), path]

class Spa
	constructor: ->
		storage = new Storage
		usecase = new UseCase
		gui = new Gui
		glue = new Glue(usecase, gui, storage)
		root = new Node('Root')
		usecase.createNode(root)
		root2 = new Node('Second Root')
		root3 = new Node('Projekt')
		usecase.createNode(root2)
		usecase.createNode(root3)

$ -> new Spa