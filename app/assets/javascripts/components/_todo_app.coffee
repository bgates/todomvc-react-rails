{header, h1, input, label, ul, li, div
, button, section, span, strong, footer, a} = React.DOM
{classSet, LinkedStateMixin} = React.addons

ENTER_KEY = 13
ESCAPE_KEY = 27

TodoApp = React.createClass
  displayName: 'TodoApp'
  mixins: [classSet, LinkedStateMixin]

  propTypes:
    filter: React.PropTypes.oneOf(['all', 'active', 'completed']).isRequired
    todos: React.PropTypes.array.isRequired
    todos_path: React.PropTypes.string.isRequired

  getInitialState: ->
    todos: @_sort(JSON.parse(@props.todos))
    newTodoTitle: ''
    editing: null
    editText: ''
    filter: @props.filter

  addTodo: (title) ->
    $.ajax
      type: 'POST'
      url: @props.todos_path
      data: { todo: { title: title, completed: false } }
      dataType: 'json'
    .done (data) =>
      @setState todos: @_sort(@state.todos.concat([data]))
    .fail (xhr, status, err) ->
      console.error @props.todos_path, status, err.toString()

  toogle: (item) ->
    @_update item, completed: !item.completed
    .done (data) =>
      @setState todos: @_sort(@state.todos.map (todo) ->
        if item is todo then data else todo
        )
    .fail (xhr, status, err) ->
      console.error status, err.toString()

  toogleAll: (checked) ->
    todos = if checked then @activeTodos() else @completedTodos()
    $.when
    .apply null, todos.map (todo) =>
      @_update todo, completed: checked
    .done (results...) =>
      if results.length == 3
        results = [results] if typeof(results[1]) is 'string'
      newTodos = {}
      newTodos[result[0].id] = result[0] for result in results
      for todo in @state.todos
        newTodos[todo.id.toString()] = todo if !(todo.id of newTodos)
      @setState todos: @_sort(v for k, v of newTodos)

  save: (item, attrs) ->
    @_update item, attrs
    .done (data) =>
      @setState todos: @_sort(@state.todos.map (todo) ->
        if item is todo then data else todo
        )
    .fail (xhr, status, err) ->
      console.error status, err.toString()

  destroy: (item) ->
    $.ajax
      type: 'DELETE'
      url: @props.todos_path + "/#{item.id}"
      dataType: 'json'
    .done =>
      @setState todos: @_sort(@state.todos.filter (todo) ->
        todo != item
        )

  clearCompleted: ->
    $.when
    .apply null, @completedTodos().map (todo) =>
      $.ajax
        type: 'DELETE'
        url: @props.todos_path + "/#{todo.id}"
        dataType: 'json'
    .then =>
      @setState todos: @activeTodos()

  isAllComplete: ->
    @state.todos.every (todo) ->
      todo.completed

  activeTodos: ->
    @state.todos.filter (todo) ->
      !todo.completed

  completedTodos: ->
    @state.todos.filter (todo) ->
      todo.completed

  _update: (todo, attrs) ->
    newTodo = {}
    newTodo[k] = v for k, v of todo
    newTodo[k] = v for k, v of attrs
    $.ajax
      type: 'PUT'
      url: @props.todos_path + "/#{todo.id}"
      data: { todo: newTodo }
      dataType: 'json'

  _sort: (todos) ->
    todos.sort (a, b) ->
      a.id - b.id

  handleNewTodoKeyDown: (event) ->
    return if event.which != ENTER_KEY
    event.preventDefault()
    val = @refs.newField.getDOMNode().value.trim()
    @addTodo(val) if val
    @setState newTodoTitle: ''

  handleToggle: (item) ->
    @toogle item

  handleToggleAll: (event) ->
    @toogleAll event.target.checked

  handleEdit: (item) ->
    @setState editing: item, editText: item.title

  handleEditChange: (event) ->
    @setState editText: event.target.value

  handleEditKeyDown: (event) ->
    if event.which is ESCAPE_KEY
      @setState editText: '', editing: null
    else if event.which is ENTER_KEY
      @handleEditSubmit event

  handleEditSubmit: (event) ->
    return unless @state.editing
    val = @state.editText.trim()
    if val
      @save @state.editing, title: val
    else
      @destroy @state.editing
    @setState editText: '', editing: null

  handleClearCompleted: (event) ->
    @clearCompleted()

  handleFilterClick: (item, event) ->
    @setState filter: item.filter

  render: ->
    div null,
      @renderHeader()
      @renderSection() if @state.todos.length
      @renderFooter() if @state.todos.length

  renderHeader: ->
    header id: 'header',
      h1 null, 'todos'
      input
        id: 'new-todo'
        placeholder: 'What needs to be done?'
        autoFocus: true
        ref: 'newField'
        onKeyDown: @handleNewTodoKeyDown
        valueLink: @linkState('newTodoTitle')

  renderSection: ->
    section id: 'main',
      input
        id: 'toggle-all'
        type: 'checkbox'
        checked: @isAllComplete()
        onChange: @handleToggleAll
      label htmlFor: 'toggle-all', 'Mark all as complete'
      ul id: 'todo-list', @renderTodoItems()

  renderTodoItems: ->
    todos = switch @state.filter
      when 'active' then @activeTodos()
      when 'completed' then @completedTodos()
      else @state.todos
    (@renderTodoItem(item) for item in todos)

  renderTodoItem: (item) ->
    classes = classSet
      completed: item.completed
      editing: item is @state.editing
    li { key: item.id, className: classes },
      div className: 'view',
        input
          className: 'toggle'
          type: 'checkbox'
          checked: item.completed
          onChange: @handleToggle.bind(@, item)
        label onDoubleClick: @handleEdit.bind(@, item),
          item.title
        button className: 'destroy'
      input
        className: 'edit'
        value: @state.editText
        onChange: @handleEditChange
        onKeyDown: @handleEditKeyDown
        onBlur: @handleEditSubmit

  renderFooter: ->
    activeCount = @activeTodos().length
    completedCount = @state.todos.length - activeCount
    footer id: 'footer',
      span id: 'todo-count',
        strong null, activeCount
        " item#{if activeCount is 1 then '' else 's'} left"
      ul id: 'filters', @renderFilters()
      @renderClearCompletedButton(completedCount) if completedCount

  renderFilters: ->
    items = [
      { filter: 'all', href: '?filter=all', val: 'All' }
      { filter: 'active', href: '?filter=active', val: 'Active' }
      { filter: 'completed', href: '?filter=completed', val: 'Completed' }
    ]
    items.map (item) =>
      props= { href: item.href, onClick: @handleFilterClick.bind(@, item) }
      props['className'] = 'selected' if @state.filter is item.filter
      li key: item.filter,
        a props, item.val

  renderClearCompletedButton: (completedCount) ->
    button
      id: 'clear-completed'
      onClick: @handleClearCompleted
      , "Clear completed (#{completedCount})"

window.TodoApp = TodoApp
