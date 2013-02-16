auto_id = 0
auto_id_relations = 0

$.extend $.fn,
	modalWindow: ->
		@each ->
			e = $(this)

			# init DOM elements
			final_container = e.parent()
			content = e
			box = $('<div class="modal-window-box" style="display:none"></div>')
			mask = $('<div class="modal-window-mask" style="display:none"></div>')
			close = $('<a href="#" class="modal-window-close">Close</a>')

			# place everything in right container
			content.prependTo( box )
			close.prependTo( box )
			final_container.append( mask )
			final_container.append( box )

			# fit to screen
			window_height = $(window).height()
			box_height = box.height()
			box.css('top', parseInt( (window_height - box_height) / 3 ) )
			window_width = $(window).width()
			box_width = $(box).width()
			box.css('left', parseInt( (window_width - box_width) / 2 ) )

			# so let's show our stuff
			box.fadeIn()
			mask.fadeIn()

			# close button
			close.click( (event) -> 
				event.preventDefault()
				box.fadeOut( 300, ->
					$(this).remove()
				)
				mask.fadeOut( 300, ->
					$(this).remove()
				)
			)

			# close on mask click too
			mask.click( (event) -> 
				event.preventDefault()
				box.fadeOut( 300, ->
					$(this).remove()
				)
				mask.fadeOut( 300, ->
					$(this).remove()
				)
			)

class Glue
	constructor: (@useCase, @gui, @storage) ->
		gui = @gui
		storage = @storage
		usecase = @useCase

		@after(@useCase, 'createNode', (node) -> storage.saveNode(node))

		@after(@storage, 'nodeSaved', (node) -> usecase.showNode(node))

		@after(@useCase, 'showNode', (node) -> gui.renderNode(node))

		@after(@gui, 'newNodePrepared', (node) -> usecase.createNode(node))

		@after(@gui, 'nodeCurvesPrepared', (pathSet) -> storage.storePath(pathSet))

		@after(@gui, 'nodeDragStartTrigged', (node) -> storage.preparePathsForDrag(node))

		@after(@storage, 'pathsForDragPreapared', (node, paths_array) -> gui.nodeDragEnable(node, paths_array))

		@after(@gui, 'reDrown', (pathSet) -> storage.refreshPathObject(pathSet))

		@after(@gui, 'newRelation', (f_id, s_id) -> useCase.createRelation(parseInt(f_id), parseInt(s_id), 'no title') )
	
		@after(@useCase, 'createRelation', (f_id, s_id, title) -> storage.saveRelation(f_id, s_id, title))

		@after(@storage, 'relationSaved', (relation) -> useCase.drawRelation(relation))

		@after(@useCase, 'drawRelation', (relation) -> gui.drawRelation(relation))

		@after(@gui, 'addToRelation', (label_id, element_id) -> storage.addToRelation(parseInt(label_id), parseInt(element_id)))

		@after(@storage, 'newRelationElementSaved', (relation) -> useCase.drawLine(relation.label.id, relation.elements[1]))

		@after(@useCase, 'drawLine', (element_f, element_s) -> gui.drawLine(element_f, element_s))

		@after(@gui, 'prepareNodeRelationsPopup', (node_id) -> storage.prepareNodeRelationsArray(parseInt(node_id)) )

		@after(@storage, 'nodeRelationsArrayPrepared', (relations) -> gui.showNodeRelationsPopup(relations))

		@after(@gui, 'updateRelationTitle', (label_id, new_title) -> useCase.updateRelationTitle(parseInt(label_id), new_title))

		@after(@useCase, 'updateRelationTitle', (label_id, new_title) -> storage.updateRelationTitle(label_id, new_title))

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

	drawRelation: (relation) ->

	drawLine: (element_f, element_s) ->

	updateNodeTitle: (node_id, new_title) ->

	updateRelationTitle: (label_id, new_title) ->

class Storage

	constructor: ->
		@nodes = []
		@paths = []
		@relations = []

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

	saveRelation: (f_id, s_id, title) ->
		return false if @getRelation( f_id, s_id )
		relation = new Relation(f_id, s_id, title)
		relation.id = ++auto_id_relations
		@relations.push(relation)
		relation_label = new Node('no title', 2)
		@saveNode(relation_label)
		relation.label = relation_label
		@relationSaved(relation)


	getRelation: (f_id, s_id) ->
		for relation in @relations
			if (relation.elements[0] == f_id and relation.elements[1] == s_id) or (relation.elements[1] == f_id and relation.elements[0] == s_id)
				return relation
		return false

	getRelationByNodeId: (node_id) ->
		resultsArray = []
		for relation in @relations
			if(relation.elements[0] == node_id)
				resultsArray.push { parent: node_id, child: relation.elements[1], title: relation.title }
			else if(relation.elements[1] == node_id)
				resultsArray.push { parent: relation.elements[0], child: node_id, title: relation.title }
		console.log('storage:getRelationByNodeId(' + node_id + ')')
		console.log(resultsArray)
		return resultsArray

	getNode: (id) ->
		for node in @nodes
			if node.id == id
				return node
		return false

	getRelationByLabel: (label_id) ->
		for relation in @relations
			console.log(relation.label.id)
			console.log(label_id)
			if relation.label.id == label_id
				 return relation
		return false

	relationSaved: (relation) ->
		console.log(@relations)

	addToRelation: (label_id, node_id) ->
		relation = @getRelationByLabel(label_id)
		relation_top_element = relation.elements[0]
		new_relation = new Relation(relation_top_element, node_id, relation.title)
		new_relation.id = ++auto_id_relations
		new_relation.label = @getNode(label_id)
		@relations.push(new_relation)
		@newRelationElementSaved(new_relation) # this will enable usecase and gui which will draw lines

	newRelationElementSaved: (relation) ->

	prepareNodeRelationsArray: (node_id) ->
		@nodeRelationsArrayPrepared @getRelationByNodeId(node_id)
	
	nodeRelationsArrayPrepared: (relations) ->

	updateRelationTitle: (label_id, new_title) ->
		console.log('new title: ' + new_title)
		console.log(@relations)
		for relation in @relations
			if( relation.label.id == label_id )
				relation.title = new_title
		@relations

class Node
	constructor: (title, type = 1) -> 
		@type = type
		@title = title
		@id = null
		@relations = []

class Relation 
	constructor: (element_f, element_s, title) ->
		@id = null
		@title = title
		@elements = [element_f, element_s]
		@label = null

class Gui

	constructor: ->
		@messagesBox = $('.messages-box')
		@canvas = $('.map-canvas')
		@control = $('.control-layer')
		@lines = $('.lines-layer')
		@modalWindowSpace = $('.modal-windows-space')
		@paper = Raphael("draw-paper", $(window).width(), $(window).height())
		@emptySpace = @lines
		@helloMessage()

	helloMessage: ->
		@showMessage('System is ready. Feel free to express your minds.')

	showMessage: (content, type = 'notice') ->
		context = {content: content, type: type}
		message = HandlebarsTemplates['message'](context)
		message = $(message)
		@messagesBox.append( message )
		message.fadeIn().delay(4000).fadeOut()

	renderNode: (node) ->
		switch node.type
			when 1 then @renderStandardNode node
			when 2 then @renderCategoryLabel node

	renderCategoryLabel: (node) ->
		gui_node_body = document.createElement('div')
		gui_node = $('<div></div>')
		gui_node_body = $(gui_node_body)
		gui_node_body.attr('class', 'map-element map-element-relation-label')
		gui_node.attr('class', 'map-element-container')
		gui_node.attr('data-id', node.id )
		gui_node.attr('data-type', node.type )
		gui_node.append(gui_node_body)
		gui_node.css('top', 0)
		gui_node.css('left', 0)
		gui_node_body.html(node.title + ', #' + node.id)
		@appendNode(gui_node, node.relations, node.type)

	renderStandardNode: (node) ->
		gui_node_body = document.createElement('div')
		gui_node = $('<div></div>')
		gui_node_body = $(gui_node_body)
		gui_node_body.attr('class', 'map-element map-element-secondary')
		gui_node.attr('class', 'map-element-container')
		gui_node.attr('data-id', node.id )
		gui_node.attr('data-type', node.type )
		gui_node.append(gui_node_body)
		gui_node.css('top', 0)
		gui_node.css('left', 0)
		gui_node_body.html(node.title + ', #' + node.id)
		@appendNode(gui_node, node.relations, node.type)

	appendNode: (node, parent, type) ->
		@canvas.append(node)
		@prepareNodeTriggers(node, type)
		@prepareNodeDrag(node)

	prepareNodeTriggers: (node) ->
		type = parseInt(node.attr('data-type'))
		node.contextmenu( (event) =>
			@showContextMenu(node) if type == 1
			@showRelationMenu(node) if type == 2
			return false
		)
		node.dblclick( (event) =>
			event.preventDefault
			@enableEditMode(node)
		)

	showRelationMenu: (node) ->
		@hideAllContextMenus()
		contextMenu = HandlebarsTemplates['relationMenu']
		menuContainer = $('<div></div>')
		menuContainer.append(contextMenu)
		@control.append(menuContainer)
		contextMenu = menuContainer.find('.context-menu')
		contextMenu.css 'left', parseInt node.css('left')
		contextMenu.css 'top', parseInt node.css('top')
		contextMenu.fadeIn(300)
		@enableMenuHidder(contextMenu)
		@prepareRelationMenuTriggers(contextMenu, node)

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
		menu.find('.show-relations').click( (event) =>
			event.preventDefault()
			@prepareNodeRelationsPopup(node.attr('data-id'))
			menu.parent().remove()
		)

	# enables select node mode
	selectNodeToSetRelation: (relation_mate_id) ->
		@showMessage('Please select element which you want to be related with.')
		$('.map-element-container').not('[data-id='+relation_mate_id+']').hover \
			( -> 
				$(this).addClass('highlight') 
			), \
			( -> 
				$(this).removeClass('highlight') 
			)
		$('.map-element-container').not('[data-id='+relation_mate_id+']').click( (event) => 
			selected_id = $(event.currentTarget).attr('data-id')
			$('.map-element-container').not('[data-id='+relation_mate_id+']').removeClass('highlight')
			$('.map-element-container').not('[data-id='+relation_mate_id+']').unbind('hover')
			$('.map-element-container').not('[data-id='+relation_mate_id+']').unbind('click')
			@emptySpace.unbind('click')
			@newRelation( relation_mate_id, selected_id )
		)
		@emptySpace.click( (event) =>
			$('.map-element-container').not('[data-id='+relation_mate_id+']').removeClass('highlight')
			$('.map-element-container').not('[data-id='+relation_mate_id+']').unbind('hover')
			$('.map-element-container').not('[data-id='+relation_mate_id+']').unbind('click')
			$(this).unbind( event )
		)

	# this triggers usecase to create this relation
	newRelation: (element_f_id, element_s_id) ->

	# function is enabled after storage saved relation
	drawRelation: (relation) ->
		element_f_id = parseInt(relation.elements[0])
		element_s_id = parseInt(relation.elements[1])
		relation_label_id = parseInt(relation.label.id)
		@prepareNodeCurves(
			element_f_id,
			relation_label_id
		)
		@prepareNodeCurves(
			element_s_id,
			relation_label_id
		)

	# this function draws line between two elements and set update actions to lines
	drawLine: (element_f_id, element_s_id) ->
		console.log('gui.drawLine')
		console.log(element_f_id)
		console.log(element_s_id)
		@prepareNodeCurves(
			element_f_id,
			element_s_id
		)

	#those are triggers for all buttons in contect menu which is shown after left click on relation label
	prepareRelationMenuTriggers: (menu, node) ->
		menu.find('.select-related').click( (event) =>
			event.preventDefault()
			menu.parent().remove()
			@selectNodeToAddToRelation(node.attr('data-id'))
		)

	# enables select node mode
	selectNodeToAddToRelation: (relation_label_id) ->
		@showMessage('Please select element which you want to be related with.')
		$('.map-element-container').not('[data-id='+relation_label_id+']').hover \
			( -> 
				$(this).addClass('highlight') 
			), \
			( -> 
				$(this).removeClass('highlight') 
			)
		$('.map-element-container').not('[data-id='+relation_label_id+']').click( (event) => 
			selected_id = $(event.currentTarget).attr('data-id')
			$('.map-element-container').not('[data-id='+relation_label_id+']').removeClass('highlight')
			$('.map-element-container').not('[data-id='+relation_label_id+']').unbind('hover')
			$('.map-element-container').not('[data-id='+relation_label_id+']').unbind('click')
			@emptySpace.unbind('click')
			@addToRelation( parseInt(relation_label_id), parseInt(selected_id) )
		)
		@emptySpace.click( (event) =>
			$('.map-element-container').not('[data-id='+relation_label_id+']').removeClass('highlight')
			$('.map-element-container').not('[data-id='+relation_label_id+']').unbind('hover')
			$('.map-element-container').not('[data-id='+relation_label_id+']').unbind('click')
			$(this).unbind( event )
		)

	# this triggers usecase to add element in relation
	addToRelation: (relation_label_id, node_id) ->

	# this asks storage to send information about node's relations
	prepareNodeRelationsPopup: (node_id) ->

	# and storage's response lands here
	showNodeRelationsPopup: (relations) ->
		console.log('gui:showNodeRelationsPopup')
		console.log(relations)
		@openModalWindow( HandlebarsTemplates['relationsTable'](relations: relations) )

	openModalWindow: (content) ->
		box = $('<div></div>')
		box.append(content)
		@modalWindowSpace.append(box)
		box.modalWindow()

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

	prepareNewNode: (related_node_id) ->
		node_object = new Node('node', 1)
		@newNodePrepared(node_object)

	newNodePrepared: (node) ->

	enableEditMode: (node) ->
		node.addClass('edit-on')
		input = $('<input type="text" class="edit-title" value="'+node.find('.map-element').text()+'" />')
		node.find('.map-element').html(input)
		node.unbind()
		input.keydown( (event) =>
			if(event.keyCode == 13)
				@disableEditMode(node)
			$(window).unbind('click')
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
		new_title = node.find('.map-element input.edit-title').val()
		node.find('.map-element').html( new_title )
		type = node.attr('data-type')
		@updateRelationTitle(node.attr('data-id'), new_title) if type == "2"
		node.unbind()
		@prepareNodeTriggers(node)
		@prepareNodeDrag(node)

	prepareNodeCurves: (node_id, parent_id) ->
		node = @canvas.find('.map-element-container[data-id='+node_id+']')
		node_y = node.offset().top
		node_x = node.offset().left
		parent = @canvas.find('.map-element-container[data-id='+parent_id+']')
		parent_y = parent.offset().top
		parent_x = parent.offset().left
		path = @paper.path('M' + parent_x + ' ' + parent_y + 'L' + node_x + ' ' + node_y);
		@nodeCurvesPrepared [node_id, parent_id, path]

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

	updateRelationTitle: (label_id, new_title) ->
		console.log('gui:updateRelationTitle')

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