{header, h1, input, label, ul, li, div
, button, section, span, strong, footer, a} = React.DOM

ENTER_KEY = 13
ESCAPE_KEY = 27

TodoApp = React.createClass
  getInitialState: ->
    todos: []
    newTodoField: ''
    editing: null
    editText: ''
    filter: 'all'

  addTodo: (title) ->
    @state.todos.concat [{ title: title, completed: false }]

  toogle: (item) ->
    @state.todos.map (todo) =>
      if item is todo
        @_update(todo, completed: !todo.completed)
      else
        todo

  toogleAll: (checked) ->
    @state.todos.map (todo) =>
      @_update(todo, completed: checked)

  save: (item, attrs) ->
    @state.todos.map (todo) =>
      if item is todo
        @_update(todo, attrs)
      else
        todo

  destroy: (item) ->
    @state.todos.filter (todo) ->
      todo != item

  clearCompleted: ->
    @state.todos.filter (todo) ->
      !todo.completed

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
    newTodo

  handleNewTodoChange: (event) ->
    @setState newTodoField: event.target.value

  handleNewTodoKeyDown: (event) ->
    return if event.which != ENTER_KEY
    event.preventDefault()
    val = @refs.newField.getDOMNode().value.trim()
    if val
      @setState todos: @addTodo(val), newTodoField: ''

  handleToggle: (item) ->
    @setState todos: @toogle(item)

  handleToggleAll: (event) ->
    @setState todos: @toogleAll(event.target.checked)

  handleEdit: (item) ->
    @setState editing: item, editText: item.title

  handleEditChange: (event) ->
    @setState editText: event.target.value

  handleEditKeyDown: (event) ->
    if event.which is ESCAPE_KEY
      @setState editText: '', editing: null
    else if event.which is ENTER_KEY
      @handleEditSubmit(event)

  handleEditSubmit: (event) ->
    val = @state.editText.trim()
    if val
      todos = @save(@state.editing, title: val)
    else
      todos = @destroy(@state.editing)
    @setState todos: todos, editText: '', editing: null

  handleClearCompleted: (event) ->
    @setState todos: @clearCompleted()

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
        onChange: @handleNewTodoChange
        value: @state.newTodoField

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
    [@renderTodoItem(item) for item in todos]

  renderTodoItem: (item) ->
    classString = ''
    classString += 'completed' if item.completed
    classString += ' editing' if item is @state.editing
    props = {}
    props['className'] = classString if classString.length
    li props,
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
        onKeyUp: @handleEditKeyDown
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
      { filter: 'all', href: '#/', val: 'All' }
      { filter: 'active', href: '#/active', val: 'Active' }
      { filter: 'completed', href: '#/completed', val: 'Completed' }
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
